-- Testbench for clk_divider
-- Generates 125 MHz clock, applies active-low reset,
-- and observes divided output waveform.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_clk_divider is
  -- No ports in testbench
end entity;

architecture Behavioral of tb_clk_divider is
  --------------------------------------------------------------------
  -- Clock and reset signals for simulation
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 8 ns; -- period of 125 MHz input clock
  signal clk_in  : std_logic := '0'; -- simulated input clock
  signal n_Reset : std_logic := '0'; -- active-low reset (starts active)
  signal clk_out : std_logic;        -- divided output clock from DUT

begin
  --------------------------------------------------------------------
  -- Clock generator (toggles every half period)
  -- Creates a 125 MHz square wave by flipping clk_in every 4 ns
  --------------------------------------------------------------------
  clk_in <= not clk_in after (SYSCLK_PERIOD / 2.0);

  --------------------------------------------------------------------
  -- Reset and simulation control
  -- Keeps reset low for 25 cycles, then releases it
  -- After that, waits a few microseconds to observe the divided clock
  --------------------------------------------------------------------
  stim_proc: process
  begin
    -- Keep reset active (low) for 25 input clock cycles
    wait for (SYSCLK_PERIOD * 25);
    n_Reset <= '1'; -- release reset (start normal operation)

    -- Let simulation run for a while to see clk_out toggling
    wait for 5 us; -- observe several slow clock periods
    wait; -- stop process, simulation continues passively
  end process;

  --------------------------------------------------------------------
  -- DUT: clk_divider
  -- Use higher output frequency for faster simulation
  --------------------------------------------------------------------
  dut: entity work.clk_divider -- "work" = current project library
  generic map (
    G_INPUT_HZ => 125_000_000, -- input clock 125 MHz
    G_OUT_HZ   => 1_000_000 -- faster 1 MHz output for simulation
  ) port map (
    clk_in  => clk_in,  -- connect testbench clock
    n_Reset => n_Reset, -- connect testbench reset
    clk_out => clk_out -- observe divided output
  );

  --------------------------------------------------------------------
  -- Observation
  -- Open waveform: clk_in, n_Reset, clk_out.
  --   clk_in = 125 MHz (8 ns period)
  --   clk_out ≈ 1 MHz (1 µs period)
  --   duty cycle ≈ 50%
  --------------------------------------------------------------------

  -- Simple monitor to confirm clk_out is toggling (prevents [W-303] warning)
  monitor: process
  begin
    wait until rising_edge(clk_out);
    report "clk_out tick";
  end process;

end architecture;

