-- Clock Divider
-- Divides 125 MHz input clock to a generic lower frequency with ~50% duty cycle.
-- Asynchronous active-low reset.
--
-- NOTE:
--   G_INPUT_HZ and G_OUT_HZ below are *default* values.
--   On PYNQ-Z2 the real input clock is 125 MHz from the board.
--   In top-level we usually override only G_OUT_HZ (target slow clock).

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity clk_divider is
  generic (
    G_INPUT_HZ : positive := 125_000_000; -- default input clock (Hz)
    G_OUT_HZ   : positive := 1_000        -- default desired output clock (Hz)
  );
  port (
    clk_in  : in  std_logic; -- 125 MHz system clock from board
    n_Reset : in  std_logic; -- async reset, active-low
    clk_out : out std_logic  -- divided clock (~50% duty)
  );
end entity;

architecture rtl of clk_divider is
  --------------------------------------------------------------------
  -- Count how many fast input cycles fit into half of one slow output cycle
  -- (We use this to know when to flip the output signal up or down)
  --------------------------------------------------------------------
  -- Number of input ticks in one full output period
  constant C_TICKS_PER_PERIOD : positive := G_INPUT_HZ / G_OUT_HZ;

  -- Number of input ticks in half period (we flip output every half)
  constant C_HALF_TICKS : positive := C_TICKS_PER_PERIOD / 2;

  --------------------------------------------------------------------
  -- Counter and internal clock signal
  -- cnt counts how many fast input cycles have passed
  -- q_clk is the divided (slow) clock that toggles after each half-period
  -- → gives ~50% duty cycle on clk_out
  --------------------------------------------------------------------
  signal cnt   : integer range 0 to C_HALF_TICKS - 1 := 0;   -- counts input ticks
  signal q_clk : std_logic                           := '0'; -- slow clock output

begin
  clk_out <= q_clk; -- connect internal (slow) clock signal to output

  process (clk_in, n_Reset) -- runs whenever clk_in or n_Reset changes
  begin
    if n_Reset = '0' then -- if reset is active (pressed)
      cnt <= 0; -- reset counter to 0
      q_clk <= '0'; -- force output clock low
    elsif rising_edge(clk_in) then -- true only on 0→1 transition of clk_in
      if cnt = C_HALF_TICKS - 1 then -- when counter reaches half-period limit
        cnt <= 0; -- reset counter
        q_clk <= not q_clk; -- flip every half-period (0→1 or 1→0)
      else
        cnt <= cnt + 1;
      end if;
    end if;
  end process;
end architecture;
