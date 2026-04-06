#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>

#define GPIO_BASEADDR 0x41200000u
#define MAP_SIZE 4096u

/* AXI GPIO register offsets (Channel 1) */
#define GPIO_DATA_OFFSET 0x0u
#define GPIO_TRI_OFFSET 0x4u

/* AXI GPIO -> PL ctrl[4:0] bit mapping */
#define CTRL_RST (1u << 0)  /* reset (active-high) */
#define CTRL_SEL (1u << 1)  /* select color */
#define CTRL_UP (1u << 2)   /* brightness up */
#define CTRL_DOWN (1u << 3) /* brightness down */
#define CTRL_SW0 (1u << 4)  /* select active dimmer (0=RGB4, 1=RGB5) */
#define CTRL_MASK 0x1Fu     /* only lower 5 bits are used */

/* Timing constants (ms) */
#define GAP_MS 200u
#define RESET_MS 300u
#define SEL_MS 80u
#define HOLD_UP_MS 2500u
#define HOLD_DOWN_MS 2500u

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

static volatile uint32_t *gpio_regs = NULL;

/* Explicit state tracking (two dimmers have independent channel state) */
static rgb_t cur_rgb = RGB4;
static color_t cur_col4 = RED;
static color_t cur_col5 = RED;

static inline void msleep(uint32_t ms)
{
    usleep((useconds_t)(ms * 1000u));
}

static inline void reg_write(uint32_t offset, uint32_t value)
{
    gpio_regs[offset / 4u] = value;
}

static inline void set_outputs(void)
{
    reg_write(GPIO_TRI_OFFSET, 0x00000000u); /* all outputs */
}

static inline void write_ctrl(uint32_t v)
{
    reg_write(GPIO_DATA_OFFSET, v & CTRL_MASK);
}

/* Drive one control bit for given time, then release and wait GAP_MS */
static void press(uint32_t base, uint32_t bit, uint32_t ms)
{
    write_ctrl(base | bit);
    msleep(ms);
    write_ctrl(base);
    msleep(GAP_MS);
}

static inline uint32_t base_for(rgb_t rgb)
{
    return (rgb == RGB5) ? CTRL_SW0 : 0u;
}

/* Select active dimmer (SW0) with a small "finger move" delay */
static void set_rgb(rgb_t rgb)
{
    if (rgb == cur_rgb)
        return;

    write_ctrl(base_for(rgb)); /* release buttons, keep only SW0 state */
    msleep(300u);              /* human-like delay */
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

    uint32_t base = base_for(cur_rgb);

    for (int i = 0; i < steps; i++)
        press(base, CTRL_SEL, SEL_MS);

    msleep(250u); /* short delay after selecting channel */
    *pcol = target;
}

/* Global reset (affects both dimmers); also sync our software state */
static void reset_all(void)
{
    press(0u, CTRL_RST, RESET_MS); /* reset does not depend on SW0 */
    write_ctrl(0u);
    msleep(300u);

    cur_rgb = RGB4;
    cur_col4 = RED;
    cur_col5 = RED;
}

/* One generic ramp function (UP or DOWN), always goes RED->GREEN->BLUE */
static void ramp(rgb_t rgb, uint32_t dir_bit, uint32_t hold_ms, const char *label)
{
    printf("\n%s %s\n", label, (rgb == RGB5) ? "RGB5" : "RGB4");
    fflush(stdout);

    set_rgb(rgb);
    uint32_t base = base_for(rgb);

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
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0)
    {
        perror("open(/dev/mem)");
        return 1;
    }

    gpio_regs = (volatile uint32_t *)mmap(NULL,
                                          MAP_SIZE,
                                          PROT_READ | PROT_WRITE,
                                          MAP_SHARED,
                                          fd,
                                          GPIO_BASEADDR);
    if (gpio_regs == MAP_FAILED)
    {
        perror("mmap()");
        close(fd);
        return 1;
    }

    set_outputs();
    write_ctrl(0u);

    printf("=== Linux PS->AXI GPIO->PL RGB dimmer control demo ===\n");
    fflush(stdout);

    while (1)
    {
        reset_all();   /* known state at start of cycle */
        ramp_up(RGB4); /* RGB4: increase R->G->B */
        ramp_up(RGB5); /* RGB5: increase R->G->B */

        reset_all();     /* reset all */
        ramp_up(RGB5);   /* RGB5: increase */
        ramp_down(RGB5); /* RGB5: decrease */

        msleep(1000u); /* pause between cycles */
    }

    /* Unreachable in current demo loop, but kept for completeness */
    munmap((void *)gpio_regs, MAP_SIZE);
    close(fd);
    return 0;
}