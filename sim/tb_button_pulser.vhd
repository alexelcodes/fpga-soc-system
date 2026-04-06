-- Testbench for button_pulser
-- Verifies:
--  * SHORT press -> exactly one 1-clock pulse
--  * LONG press  -> after start delay, periodic 1-clock pulses until release

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_button_pulser is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_button_pulser is
  --------------------------------------------------------------------
  -- Clock and reset signals for simulation
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 100 ns; -- 10 MHz clock period
  signal clk     : std_logic := '0'; -- simulated clock (starts at '0')
  signal n_Reset : std_logic := '0'; -- active-low reset (starts active)

  --------------------------------------------------------------------
  -- Stimulus and DUT I/O
  --------------------------------------------------------------------
  signal btn_in    : std_logic := '0'; -- test button input
  signal pulse_out : std_logic;        -- DUT pulse output (observe this)

begin
  --------------------------------------------------------------------
  -- Clock generator (toggles every half period) -> 10 MHz square wave
  --------------------------------------------------------------------
  clk <= not clk after (SYSCLK_PERIOD / 2.0);

  --------------------------------------------------------------------
  -- Stimulus sequence:
  --  1) hold reset low for 10 cycles, then release
  --  2) SHORT press -> expect one 1-clock pulse
  --  3) LONG press  -> after delay, periodic pulses; stop on release
  --------------------------------------------------------------------
  stimulus_p: process
  begin
    -- 1) keep reset asserted (active-low) for 10 cycles
    wait for (SYSCLK_PERIOD * 10);
    n_Reset <= '1'; -- release reset (start normal operation)

    -- small guard time before pressing the button
    wait for (SYSCLK_PERIOD * 10);

    -- 2) SHORT press: press for 3 cycles, then release
    btn_in <= '1'; -- press
    wait for (SYSCLK_PERIOD * 3); -- hold briefly
    btn_in <= '0'; -- release
    -- Expect: exactly one 1-clock pulse on the first clk edge after press
    wait for (SYSCLK_PERIOD * 20); -- observe

    -- 3) LONG press: hold long enough to pass delay, see repeats, then release
    btn_in <= '1'; -- press and hold
    -- With the generics used below (20 / 10 cycles @10 MHz):
    --   start delay ≈ 20 cycles  = 2.0 us
    --   repeat     ≈ every 10 cycles = 1.0 us
    wait for 6 us; -- long enough to see a few repeats
    btn_in <= '0'; -- release -> repeating stops
    wait for (SYSCLK_PERIOD * 20); -- observe stop

    wait; -- stop this process (simulation continues passively)
  end process;

  --------------------------------------------------------------------
  -- DUT: button_pulser
  -- Small counts for fast sim:
  --   G_START_DELAY_CYCLES   = 20  (~2.0 us @10 MHz)
  --   G_REPEAT_PERIOD_CYCLES = 10  (~1.0 us @10 MHz)
  --------------------------------------------------------------------
  dut: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 20,
      G_REPEAT_PERIOD_CYCLES => 10
    )
    port map (
      clk       => clk,
      n_Reset   => n_Reset,
      btn_in    => btn_in,
      pulse_out => pulse_out
    );

  --------------------------------------------------------------------
  -- Simple monitor: print pulse_out at each rising clock edge
  -- (useful to see single pulse vs repeat train in the console)
  --------------------------------------------------------------------
  monitor_p: process
  begin
    wait until rising_edge(clk); -- runs every 0->1 edge of clk
    report "pulse_out = " & std_logic'image(pulse_out);
  end process;

end architecture;
