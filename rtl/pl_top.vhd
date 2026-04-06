-- PL logic for dual RGB PWM dimmer. Controlled from PS via AXI GPIO
-- Control bus (from axi_gpio):
--   ctrl(0) : reset (active-high)
--   ctrl(1) : select
--   ctrl(2) : brightness up
--   ctrl(3) : brightness down
--   ctrl(4) : sw0 select (0=RGB4, 1=RGB5)
-- Outputs:
--   led[2:0] : selected channel (R/G/B) of active dimmer
--   led[3]   : active RGB indicator (mirrors ctrl(4))
--   led4_* / led5_* : PWM outputs to RGB LEDs

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity pl_top is
  port (
    sysclk : in  std_logic;                    -- 125 MHz system clock
    ctrl   : in  std_logic_vector(4 downto 0); -- from AXI GPIO (PS->PL)
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

architecture rtl of pl_top is

  --------------------------------------------------------------------
  -- Decode "virtual buttons/switch" from ctrl bus
  --------------------------------------------------------------------
  signal btn0_rst  : std_logic;
  signal btn1_sel  : std_logic;
  signal btn2_up   : std_logic;
  signal btn3_down : std_logic;
  signal sw0       : std_logic;

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

  -- decode ctrl bus
  btn0_rst  <= ctrl(0);
  btn1_sel  <= ctrl(1);
  btn2_up   <= ctrl(2);
  btn3_down <= ctrl(3);
  sw0       <= ctrl(4);

  --------------------------------------------------------------------
  -- Reset: btn0 (active-high on board) -> internal active-low
  --------------------------------------------------------------------
  n_Reset <= not btn0_rst;

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
      btn_in    => btn1_sel,
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
      btn_in    => btn2_up,
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
      btn_in    => btn3_down,
      pulse_out => pulse_down
    );

  --------------------------------------------------------------------
  -- Demux button pulses based on SW0
  -- SW0=0 -> control RGB4
  -- SW0=1 -> control RGB5
  --------------------------------------------------------------------
  psel4  <= pulse_sel when sw0 = '0' else '0';
  pup4   <= pulse_up when sw0 = '0' else '0';
  pdown4 <= pulse_down when sw0 = '0' else '0';

  psel5  <= pulse_sel when sw0 = '1' else '0';
  pup5   <= pulse_up when sw0 = '1' else '0';
  pdown5 <= pulse_down when sw0 = '1' else '0';

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
  led(3) <= sw0; -- active RGB LED indicator

  led(0) <= sel4_r when sw0 = '0' else sel5_r; -- R selected
  led(1) <= sel4_g when sw0 = '0' else sel5_g; -- G selected
  led(2) <= sel4_b when sw0 = '0' else sel5_b; -- B selected

end architecture;
