-- OLED Controller
-- Drives an SPI OLED display from PL logic.
-- Current version is a minimal skeleton:
--   * keeps OLED outputs in safe idle states
--   * passes reset to the display
-- Later this module will be extended with:
--   * clock divider for SPI clock
--   * initialization FSM
--   * byte transmit logic for commands/data
--
-- OLED interface:
--   oled_din : serial data to display
--   oled_clk : serial clock
--   oled_cs  : chip select (active-low)
--   oled_dc  : data/command select
--   oled_res : reset (active-low)
--
-- Asynchronous active-low reset.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity oled_controller is
  port (
    clk      : in  std_logic; -- system clock
    n_Reset  : in  std_logic; -- async reset, active-low

    oled_din : out std_logic; -- SPI data output (DIN on display)
    oled_clk : out std_logic; -- SPI clock output (CLK on display)
    oled_cs  : out std_logic; -- chip select, active-low
    oled_dc  : out std_logic; -- 0 = command, 1 = data
    oled_res : out std_logic  -- reset, active-low
  );
end entity;

architecture rtl of oled_controller is

  --------------------------------------------------------------------
  -- Internal placeholder signals
  -- These signals will later be driven by the SPI / FSM logic.
  --------------------------------------------------------------------
  signal s_din : std_logic := '0';
  signal s_clk : std_logic := '0';
  signal s_cs  : std_logic := '1';
  signal s_dc  : std_logic := '0';

begin

  --------------------------------------------------------------------
  -- Output mapping
  --------------------------------------------------------------------
  oled_din <= s_din;
  oled_clk <= s_clk;
  oled_cs  <= s_cs;
  oled_dc  <= s_dc;

  --------------------------------------------------------------------
  -- Reset output to display
  -- OLED reset is active-low.
  -- For now we simply forward the internal active-low reset signal.
  --------------------------------------------------------------------
  oled_res <= n_Reset;

  --------------------------------------------------------------------
  -- Main process
  -- Current version only keeps the interface in idle state.
  --
  -- Idle SPI state:
  --   * CS  = '1'  -> display not selected
  --   * CLK = '0'  -> clock low
  --   * DIN = '0'  -> data low
  --   * D/C = '0'  -> default to command mode
  --
  -- Later this process will be replaced by:
  --   * reset timing
  --   * initialization command sequence
  --   * SPI transmit state machine

  --------------------------------------------------------------------
  process (clk, n_Reset)
  begin
    if n_Reset = '0' then
      s_din <= '0';
      s_clk <= '0';
      s_cs <= '1';
      s_dc <= '0';

    elsif rising_edge(clk) then
      -- Keep idle values for now
      s_din <= '0';
      s_clk <= '0';
      s_cs <= '1';
      s_dc <= '0';
    end if;
  end process;

end architecture;
