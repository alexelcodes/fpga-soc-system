-- Testbench for PWM
-- Verifies:
--  * pwm_val = 0       -> pwm_out always '0'
--  * pwm_val = mid     -> ~50% duty cycle
--  * pwm_val = max     -> pwm_out mostly '1'

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity tb_pwm is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_pwm is

  --------------------------------------------------------------------
  -- Clock and reset for simulation
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 100 ns; -- 10 MHz clock
  signal clk     : std_logic := '0';
  signal n_Reset : std_logic := '0'; -- start in reset (active-low)

  --------------------------------------------------------------------
  -- DUT I/O
  --------------------------------------------------------------------
  constant C_WIDTH : positive := 8;
  signal pwm_val : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
  signal pwm_out : std_logic;

begin

  --------------------------------------------------------------------
  -- Clock generator: 10 MHz (toggle every 50 ns)
  --------------------------------------------------------------------
  clk <= not clk after (SYSCLK_PERIOD / 2);

  --------------------------------------------------------------------
  -- Stimulus:
  --  1) Hold reset low for a few cycles, then release
  --  2) Test pwm_val = 0
  --  3) Test pwm_val = mid (128)
  --  4) Test pwm_val = max (255)
  --------------------------------------------------------------------
  stim_p: process
  begin
    -- 1) Reset
    n_Reset <= '0';
    wait for 10 * SYSCLK_PERIOD;
    n_Reset <= '1'; -- release reset

    -- 2) pwm_val = 0  -> output always '0'
    pwm_val <= std_logic_vector(to_unsigned(0, C_WIDTH));
    wait for 500 * SYSCLK_PERIOD;

    -- 3) pwm_val = 128 (~50% duty)
    pwm_val <= std_logic_vector(to_unsigned(128, C_WIDTH));
    wait for 500 * SYSCLK_PERIOD;

    -- 4) pwm_val = 255 (~almost always '1')
    pwm_val <= std_logic_vector(to_unsigned(255, C_WIDTH));
    wait for 500 * SYSCLK_PERIOD;

    wait; -- stop testbench process
  end process;

  --------------------------------------------------------------------
  -- DUT: PWM
  --------------------------------------------------------------------
  dut: entity work.pwm
    generic map (
      G_WIDTH => C_WIDTH
    )
    port map (
      clk     => clk,
      n_Reset => n_Reset,
      pwm_val => pwm_val,
      pwm_out => pwm_out
    );

end architecture;
