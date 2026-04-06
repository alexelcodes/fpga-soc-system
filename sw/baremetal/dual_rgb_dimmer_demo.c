#include "xparameters.h" // Hardware definitions (AXI addresses, peripherals)
#include "xil_printf.h"  // Debug output to UART/XSDB console
#include "xil_io.h"      // Memory-mapped IO access functions
#include "xil_types.h"   // Xilinx-specific data types (u32, etc.)
#include "sleep.h"       // Delay functions (usleep)

/* Base memory address of AXI GPIO peripheral in PL.
   PS accesses PL hardware via this memory-mapped address. */
#define GPIO_BASEADDR XPAR_AXI_GPIO_0_BASEADDR

/* AXI GPIO register offsets (Channel 1) */
#define GPIO_DATA_OFFSET 0x0 // DATA register (ctrl[4:0])
#define GPIO_TRI_OFFSET 0x4  // TRI register (0=output, 1=input)

/* AXI GPIO -> PL ctrl[4:0] bit mapping */
#define CTRL_RST (1u << 0)  // reset (active-high)
#define CTRL_SEL (1u << 1)  // select color
#define CTRL_UP (1u << 2)   // brightness up
#define CTRL_DOWN (1u << 3) // brightness down
#define CTRL_SW0 (1u << 4)  // select active dimmer (0=RGB4, 1=RGB5)
#define CTRL_MASK 0x1F      // only lower 5 bits are used

/* Timing constants (ms) */
#define GAP_MS 200        // delay between actions (button release gap)
#define RESET_MS 300      // reset pulse duration
#define SEL_MS 80         // short press for channel select
#define HOLD_UP_MS 2500   // hold time for brightness up
#define HOLD_DOWN_MS 2500 // hold time for brightness down

/* Low-level helpers */
static inline void set_outputs(void)
{
    Xil_Out32(GPIO_BASEADDR + GPIO_TRI_OFFSET, 0x00000000); // all outputs
}

static inline void write_ctrl(u32 v)
{
    Xil_Out32(GPIO_BASEADDR + GPIO_DATA_OFFSET, v & CTRL_MASK);
}

static inline void msleep(u32 ms)
{
    usleep((unsigned int)(ms * 1000u));
}

/* Drive one control bit for given time, then release and wait GAP_MS */
static void press(u32 base, u32 bit, u32 ms)
{
    write_ctrl(base | bit);
    msleep(ms);
    write_ctrl(base);
    msleep(GAP_MS);
}

/* Explicit state tracking (two dimmers have independent channel state) */
typedef enum
{
    RGB4 = 0,
    RGB5 = 1
} rgb_t;
typedef enum
{
    RED = 0,
    GREEN = 1,
    BLUE = 2
} color_t;

static rgb_t cur_rgb = RGB4;
static color_t cur_col4 = RED; // current channel inside dimmer4
static color_t cur_col5 = RED; // current channel inside dimmer5

static inline u32 base_for(rgb_t rgb)
{
    return (rgb == RGB5) ? CTRL_SW0 : 0;
}

/* Select active dimmer (SW0) with a small "finger move" delay */
static void set_rgb(rgb_t rgb)
{
    if (rgb == cur_rgb)
        return;

    write_ctrl(base_for(rgb)); // release buttons, keep only SW0 state
    msleep(300);               // human-like delay
    cur_rgb = rgb;
}

/* Select target color channel using CTRL_SEL pulses (RED->GREEN->BLUE->RED) */
static void set_color(color_t target)
{
    color_t *pcol = (cur_rgb == RGB5) ? &cur_col5 : &cur_col4;

    if (target == *pcol)
        return;

    int steps = (int)target - (int)(*pcol);
    if (steps < 0)
        steps += 3;

    u32 base = base_for(cur_rgb);

    for (int i = 0; i < steps; i++)
        press(base, CTRL_SEL, SEL_MS);

    msleep(250); // short delay after selecting channel
    *pcol = target;
}

/* Global reset (affects both dimmers); also sync our software state */
static void reset_all(void)
{
    press(0, CTRL_RST, RESET_MS); // reset does not depend on SW0
    write_ctrl(0);
    msleep(300);

    cur_rgb = RGB4;
    cur_col4 = RED;
    cur_col5 = RED;
}

/* One generic ramp function (UP or DOWN), always goes RED->GREEN->BLUE */
static void ramp(rgb_t rgb, u32 dir_bit, u32 hold_ms, const char *label)
{
    xil_printf("\r\n%s %s\r\n", label, (rgb == RGB5) ? "RGB5" : "RGB4");

    set_rgb(rgb);
    u32 base = base_for(rgb);

    set_color(RED);
    press(base, dir_bit, hold_ms);

    set_color(GREEN);
    press(base, dir_bit, hold_ms);

    set_color(BLUE);
    press(base, dir_bit, hold_ms);
}

static inline void ramp_up(rgb_t rgb)
{
    ramp(rgb, CTRL_UP, HOLD_UP_MS, "Ramp UP");
}

static inline void ramp_down(rgb_t rgb)
{
    ramp(rgb, CTRL_DOWN, HOLD_DOWN_MS, "Ramp DOWN");
}

int main(void)
{
    set_outputs();
    write_ctrl(0);

    xil_printf("\r\n=== PS->AXI GPIO->PL RGB dimmer control demo ===\r\n");

    while (1)
    {
        reset_all();   // known state at start of cycle
        ramp_up(RGB4); // RGB4: increase R->G->B
        ramp_up(RGB5); // RGB5: increase R->G->B

        reset_all();     // reset all
        ramp_up(RGB5);   // RGB5: increase
        ramp_down(RGB5); // RGB5: decrease

        msleep(1000); // pause between cycles
    }

    return 0;
}