-- RGB PWM
-- Combines three PWM generators (R/G/B) into one reusable block.
-- Inputs are 8-bit brightness values, outputs are PWM signals for one RGB LED.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity rgb_pwm is
  generic (
    G_WIDTH : positive := 8 -- PWM resolution (8-bit -> 0..255)
  );
  port (
    clk_pwm : in  std_logic;                              -- PWM clock (e.g., 1 MHz)
    n_Reset : in  std_logic;                              -- async reset, active-low
    r_val   : in  std_logic_vector(G_WIDTH - 1 downto 0); -- red brightness
    g_val   : in  std_logic_vector(G_WIDTH - 1 downto 0); -- green brightness
    b_val   : in  std_logic_vector(G_WIDTH - 1 downto 0); -- blue brightness
    pwm_r   : out std_logic;                              -- PWM out red
    pwm_g   : out std_logic;                              -- PWM out green
    pwm_b   : out std_logic                               -- PWM out blue
  );
end entity;

architecture rtl of rgb_pwm is
begin

  u_pwm_r: entity work.pwm
    generic map (
      G_WIDTH => G_WIDTH
    )
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => r_val,
      pwm_out => pwm_r
    );

  u_pwm_g: entity work.pwm
    generic map (
      G_WIDTH => G_WIDTH
    )
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => g_val,
      pwm_out => pwm_g
    );

  u_pwm_b: entity work.pwm
    generic map (
      G_WIDTH => G_WIDTH
    )
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => b_val,
      pwm_out => pwm_b
    );

end architecture;
