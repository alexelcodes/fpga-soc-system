-- RGB Dimmer (thin, Phase 2)
-- Contains: rgb_controller + rgb_pwm
-- External infra (clk dividers + button pulsers) stays in top.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity rgb_dimmer is
  port (
    -- clocks
    clk_1k     : in  std_logic; -- slow clock for controller (1 kHz)
    clk_pwm    : in  std_logic; -- PWM clock (e.g., 1 MHz)

    -- reset
    n_Reset    : in  std_logic; -- async reset, active-low

    -- control pulses (from shared button_pulser + SW0 demux in top)
    pulse_sel  : in  std_logic;
    pulse_up   : in  std_logic;
    pulse_down : in  std_logic;

    -- PWM outputs to one RGB LED
    pwm_r      : out std_logic;
    pwm_g      : out std_logic;
    pwm_b      : out std_logic;

    -- selected channel indicators (optional but used for LED[2:0])
    sel_r      : out std_logic;
    sel_g      : out std_logic;
    sel_b      : out std_logic
  );
end entity;

architecture rtl of rgb_dimmer is

  signal r_val : std_logic_vector(7 downto 0);
  signal g_val : std_logic_vector(7 downto 0);
  signal b_val : std_logic_vector(7 downto 0);

begin

  --------------------------------------------------------------------
  -- Control/state (Phase 2: still button-driven)
  --------------------------------------------------------------------
  u_ctrl: entity work.rgb_controller
    port map (
      clk        => clk_1k,
      n_Reset    => n_Reset,
      pulse_sel  => pulse_sel,
      pulse_up   => pulse_up,
      pulse_down => pulse_down,
      red_val    => r_val,
      green_val  => g_val,
      blue_val   => b_val,
      sel_r      => sel_r,
      sel_g      => sel_g,
      sel_b      => sel_b
    );

  --------------------------------------------------------------------
  -- Hardware output engine (PWM)
  --------------------------------------------------------------------
  u_pwm: entity work.rgb_pwm
    port map (
      clk_pwm => clk_pwm,
      n_Reset => n_Reset,
      r_val   => r_val,
      g_val   => g_val,
      b_val   => b_val,
      pwm_r   => pwm_r,
      pwm_g   => pwm_g,
      pwm_b   => pwm_b
    );

end architecture;
