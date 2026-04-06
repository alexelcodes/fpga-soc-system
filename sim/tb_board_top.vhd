-- Testbench for board_top (Dual RGB Dimmer)
-- Verifies end-to-end:
--  * clk_divider -> button_pulser -> 2x rgb_controller -> 6x PWM -> RGB4/RGB5
--  * btn0 : reset
--  * btn1 : select R/G/B channel
--  * btn2 : brightness up
--  * btn3 : brightness down
--  * sw0  : selects active RGB LED (0=RGB4, 1=RGB5)
--  * led[2:0] : selected channel of active controller
--  * led[3]   : active RGB indicator (mirrors sw0)

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_board_top is
end entity;

architecture Behavioral of tb_board_top is

  --------------------------------------------------------------------
  -- Board clock and inputs (simulation signals)
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 8 ns; -- 125 MHz clock period

  signal sysclk : std_logic                    := '0';
  signal btn    : std_logic_vector(3 downto 0) := (others => '0');
  signal sw     : std_logic_vector(0 downto 0) := (others => '0'); -- sw(0) used

  --------------------------------------------------------------------
  -- Observed outputs
  --------------------------------------------------------------------
  signal led : std_logic_vector(3 downto 0);

  signal led4_r : std_logic;
  signal led4_g : std_logic;
  signal led4_b : std_logic;

  signal led5_r : std_logic;
  signal led5_g : std_logic;
  signal led5_b : std_logic;

  --------------------------------------------------------------------
  -- Helper procedures for "button press"
  --------------------------------------------------------------------
  procedure press_button(signal b : inout std_logic; press_time : time) is
  begin
    b <= '1';
    wait for press_time;
    b <= '0';
  end procedure;

begin

  --------------------------------------------------------------------
  -- 125 MHz clock generator
  --------------------------------------------------------------------
  sysclk <= not sysclk after (SYSCLK_PERIOD / 2);

  --------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------
  stim_p: process
  begin
    -- init
    btn <= (others => '0');
    sw <= (others => '0');

    ----------------------------------------------------------------
    -- 1) Reset
    ----------------------------------------------------------------
    btn(0) <= '1';
    wait for 1 us;
    btn(0) <= '0';

    -- let slow clock (1 kHz) run
    wait for 5 ms;

    ----------------------------------------------------------------
    -- 2) Work on RGB4 (SW0=0)
    ----------------------------------------------------------------
    sw(0) <= '0';
    wait for 1 ms;

    -- Select channel changes: R->G
    press_button(btn(1), 5 ms);
    wait for 3 ms;

    -- Increase brightness on GREEN (BTN2=UP)
    press_button(btn(2), 5 ms);
    wait for 5 ms;

    ----------------------------------------------------------------
    -- 3) Switch to RGB5 (SW0=1) and modify it
    ----------------------------------------------------------------
    sw(0) <= '1';
    wait for 5 ms;

    -- Select channel changes: start at R, go to B (two selects)
    press_button(btn(1), 5 ms);
    wait for 3 ms;
    press_button(btn(1), 5 ms);
    wait for 3 ms;

    -- Increase brightness on BLUE (BTN2=UP)
    press_button(btn(2), 5 ms);
    wait for 5 ms;

    -- Decrease brightness (BTN3=DOWN)
    press_button(btn(3), 5 ms);
    wait for 5 ms;

    ----------------------------------------------------------------
    -- 4) Switch back to RGB4 and do another change
    --    (should keep its previous values)
    ----------------------------------------------------------------
    sw(0) <= '0';
    wait for 5 ms;

    -- Increase brightness (BTN2=UP) on whatever channel is currently selected for RGB4
    press_button(btn(2), 5 ms);
    wait for 10 ms;

    -- observe for a while
    wait for 20 ms;

    wait;
  end process;

  --------------------------------------------------------------------
  -- DUT: board_top
  --------------------------------------------------------------------
  dut: entity work.board_top
    port map (
      sysclk => sysclk,
      btn    => btn,
      sw     => sw,
      led    => led,

      led4_r => led4_r,
      led4_g => led4_g,
      led4_b => led4_b,

      led5_r => led5_r,
      led5_g => led5_g,
      led5_b => led5_b
    );

end architecture;
