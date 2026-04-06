-- Top-Level: Dual RGB Dimmer (Phase 2)
-- Board: PYNQ-Z2
-- SW0 selects active RGB LED (RGB4 or RGB5)
-- led[2:0] indicates selected channel (R/G/B) of the active controller
-- led[3] indicates active RGB LED (0=RGB4, 1=RGB5)

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity board_top is
  port (
    sysclk : in  std_logic;                    -- 125 MHz system clock
    btn    : in  std_logic_vector(3 downto 0); -- btn0=Reset, btn1=Select, btn2=Up, btn3=Down
    sw     : in  std_logic_vector(0 downto 0); -- SW0 used (sw(0))
    led    : out std_logic_vector(3 downto 0); -- small green LEDs

    -- RGB LEDs (PWM outputs)
    led4_r : out std_logic;
    led4_g : out std_logic;
    led4_b : out std_logic;

    led5_r : out std_logic;
    led5_g : out std_logic;
    led5_b : out std_logic
  );
end entity;

architecture rtl of board_top is

  --------------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------------
  signal n_Reset : std_logic := '0';

  signal clk_1k  : std_logic := '0'; -- 1 kHz for controller + button pulsers
  signal clk_pwm : std_logic := '0'; -- 1 MHz for PWM

  -- Shared button pulses
  signal pulse_sel  : std_logic := '0';
  signal pulse_up   : std_logic := '0';
  signal pulse_down : std_logic := '0';

  -- Demuxed pulses: only active channel gets pulses
  signal psel4, pup4, pdown4 : std_logic := '0';
  signal psel5, pup5, pdown5 : std_logic := '0';

  -- Selected channel indicators from each IP
  signal sel4_r, sel4_g, sel4_b : std_logic := '0';
  signal sel5_r, sel5_g, sel5_b : std_logic := '0';

begin
  --------------------------------------------------------------------
  -- Reset: btn0 (active-high on board) -> internal active-low
  --------------------------------------------------------------------
  n_Reset <= not btn(0);

  --------------------------------------------------------------------
  -- Clock dividers (shared) -> Phase 2
  --------------------------------------------------------------------
  u_clkdiv_slow: entity work.clk_divider
    generic map (
      G_INPUT_HZ => 125_000_000,
      G_OUT_HZ   => 1_000
    )
    port map (
      clk_in  => sysclk,
      n_Reset => n_Reset,
      clk_out => clk_1k
    );

  u_clkdiv_pwm: entity work.clk_divider
    generic map (
      G_INPUT_HZ => 125_000_000,
      G_OUT_HZ   => 1_000_000
    )
    port map (
      clk_in  => sysclk,
      n_Reset => n_Reset,
      clk_out => clk_pwm
    );

  --------------------------------------------------------------------
  -- Button pulsers (shared) -> Phase 2
  --------------------------------------------------------------------
  u_pulser_sel: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 2000,
      G_REPEAT_PERIOD_CYCLES => 500
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(1),
      pulse_out => pulse_sel
    );

  u_pulser_up: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 1000,
      G_REPEAT_PERIOD_CYCLES => 50
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(2),
      pulse_out => pulse_up
    );

  u_pulser_down: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 1000,
      G_REPEAT_PERIOD_CYCLES => 50
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(3),
      pulse_out => pulse_down
    );

  --------------------------------------------------------------------
  -- Demux button pulses based on SW0
  -- SW0=0 -> control RGB4
  -- SW0=1 -> control RGB5
  --------------------------------------------------------------------
  psel4  <= pulse_sel when sw(0) = '0' else '0';
  pup4   <= pulse_up when sw(0) = '0' else '0';
  pdown4 <= pulse_down when sw(0) = '0' else '0';

  psel5  <= pulse_sel when sw(0) = '1' else '0';
  pup5   <= pulse_up when sw(0) = '1' else '0';
  pdown5 <= pulse_down when sw(0) = '1' else '0';

  --------------------------------------------------------------------
  -- Two dimmer IP blocks (thin)
  -- Each IP contains rgb_controller + rgb_pwm (3x PWM)
  --------------------------------------------------------------------
  u_dimmer4: entity work.rgb_dimmer
    port map (
      clk_1k     => clk_1k,
      clk_pwm    => clk_pwm,
      n_Reset    => n_Reset,
      pulse_sel  => psel4,
      pulse_up   => pup4,
      pulse_down => pdown4,
      pwm_r      => led4_r,
      pwm_g      => led4_g,
      pwm_b      => led4_b,
      sel_r      => sel4_r,
      sel_g      => sel4_g,
      sel_b      => sel4_b
    );

  u_dimmer5: entity work.rgb_dimmer
    port map (
      clk_1k     => clk_1k,
      clk_pwm    => clk_pwm,
      n_Reset    => n_Reset,
      pulse_sel  => psel5,
      pulse_up   => pup5,
      pulse_down => pdown5,
      pwm_r      => led5_r,
      pwm_g      => led5_g,
      pwm_b      => led5_b,
      sel_r      => sel5_r,
      sel_g      => sel5_g,
      sel_b      => sel5_b
    );

  --------------------------------------------------------------------
  -- Indicators (small green LEDs)
  --------------------------------------------------------------------
  led(3) <= sw(0); -- active RGB LED indicator

  led(0) <= sel4_r when sw(0) = '0' else sel5_r; -- R selected
  led(1) <= sel4_g when sw(0) = '0' else sel5_g; -- G selected
  led(2) <= sel4_b when sw(0) = '0' else sel5_b; -- B selected

end architecture;
