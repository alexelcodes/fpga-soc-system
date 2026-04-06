-- PWM
-- Simple PWM generator with configurable resolution.
-- Duty cycle is controlled by pwm_val:
--   pwm_out = '1' when counter < pwm_val, else '0'.
-- Asynchronous active-low reset.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity pwm is
  generic (
    -- Number of bits for PWM resolution.
    -- Example:
    --   G_WIDTH = 4  -> 0..15 steps (16 levels)
    --   G_WIDTH = 8  -> 0..255 steps (256 levels)
    --   G_WIDTH = 10 -> 0..1023 steps
    G_WIDTH : positive := 8
  );
  port (
    clk     : in  std_logic;                              -- PWM clock
    n_Reset : in  std_logic;                              -- async reset, active-low
    pwm_val : in  std_logic_vector(G_WIDTH - 1 downto 0); -- brightness value from rgb_controller
    pwm_out : out std_logic                               -- PWM output
  );
end entity;

architecture rtl of pwm is

  -- Free-running counter: runs 0..255 forever (for G_WIDTH=8).
  -- PWM brightness works by comparing cnt with pwm_val:
  --   pwm_out = '1' while cnt < pwm_val  → LED ON (brightness part)
  --   pwm_out = '0' when cnt >= pwm_val → LED OFF
  -- So brightness = (pwm_val / 255) portion of each cycle.
  signal cnt : unsigned(G_WIDTH - 1 downto 0) := (others => '0');

begin

  --------------------------------------------------------------------
  -- Counter: increments every clock, wraps around automatically
  --------------------------------------------------------------------
  process (clk, n_Reset)
  begin
    if n_Reset = '0' then -- asynchronous reset
      cnt <= (others => '0');
    elsif rising_edge(clk) then -- on rising edge of clk
      cnt <= cnt + 1;
    end if;
  end process;

  --------------------------------------------------------------------
  -- PWM compare:
  --  pwm_out = '1' while cnt < pwm_val
  --  pwm_out = '0' otherwise
  --------------------------------------------------------------------
  pwm_out <= '1' when cnt < unsigned(pwm_val) else '0';

end architecture;
