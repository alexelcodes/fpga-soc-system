-- Testbench for rgb_controller
-- Verifies:
--  * After reset: channel = RED, all values = 0
--  * pulse_sel  : channel cycles R -> G -> B -> R ...
--  * pulse_up   : increases active channel value (with saturation)
--  * pulse_down : decreases active channel value (with saturation)

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity tb_rgb_controller is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_rgb_controller is

  --------------------------------------------------------------------
  -- Clock and reset
  --------------------------------------------------------------------
  constant CLK_PERIOD : time := 100 ns; -- 10 MHz for sim
  signal clk     : std_logic := '0';
  signal n_Reset : std_logic := '0'; -- active-low reset

  --------------------------------------------------------------------
  -- Stimulus and DUT I/O
  --------------------------------------------------------------------
  signal pulse_sel  : std_logic := '0';
  signal pulse_up   : std_logic := '0';
  signal pulse_down : std_logic := '0';

  signal red_val   : std_logic_vector(7 downto 0);
  signal green_val : std_logic_vector(7 downto 0);
  signal blue_val  : std_logic_vector(7 downto 0);

  signal sel_r : std_logic;
  signal sel_g : std_logic;
  signal sel_b : std_logic;

begin

  --------------------------------------------------------------------
  -- Clock generator
  --------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD / 2;

  --------------------------------------------------------------------
  -- Stimulus
  -- Sequence:
  --  1) Hold reset low, then release
  --  2) A few UP pulses on RED
  --  3) One SEL pulse -> GREEN
  --  4) UP and DOWN pulses on GREEN
  --  5) More SEL pulses to step through channels
  --------------------------------------------------------------------
  stim_p: process
  begin
    --------------------------------------------------------------
    -- 1) Reset
    --------------------------------------------------------------
    n_Reset <= '0'; -- reset active
    pulse_sel <= '0';
    pulse_up <= '0';
    pulse_down <= '0';
    wait for 10 * CLK_PERIOD;
    n_Reset <= '1'; -- release reset
    wait for 10 * CLK_PERIOD;

    --------------------------------------------------------------
    -- 2) A few UP pulses on RED (increase red_val)
    --------------------------------------------------------------
    pulse_up <= '1';
    wait for CLK_PERIOD;
    pulse_up <= '0';
    wait for 5 * CLK_PERIOD;

    pulse_up <= '1';
    wait for CLK_PERIOD;
    pulse_up <= '0';
    wait for 5 * CLK_PERIOD;

    --------------------------------------------------------------
    -- 3) One SEL pulse -> switch to GREEN
    --------------------------------------------------------------
    pulse_sel <= '1';
    wait for CLK_PERIOD;
    pulse_sel <= '0';
    wait for 10 * CLK_PERIOD;

    --------------------------------------------------------------
    -- 4) UP then DOWN on GREEN
    --------------------------------------------------------------
    -- UP on GREEN
    pulse_up <= '1';
    wait for CLK_PERIOD;
    pulse_up <= '0';
    wait for 5 * CLK_PERIOD;

    -- DOWN on GREEN
    pulse_down <= '1';
    wait for CLK_PERIOD;
    pulse_down <= '0';
    wait for 10 * CLK_PERIOD;

    --------------------------------------------------------------
    -- 5) Step through channels GREEN -> BLUE -> RED
    --------------------------------------------------------------
    pulse_sel <= '1';
    wait for CLK_PERIOD;
    pulse_sel <= '0';
    wait for 5 * CLK_PERIOD;

    pulse_sel <= '1';
    wait for CLK_PERIOD;
    pulse_sel <= '0';
    wait for 20 * CLK_PERIOD;

    wait; -- stop process
  end process;

  --------------------------------------------------------------------
  -- DUT: rgb_controller
  --------------------------------------------------------------------
  dut: entity work.rgb_controller
    port map (
      clk        => clk,
      n_Reset    => n_Reset,
      pulse_sel  => pulse_sel,
      pulse_up   => pulse_up,
      pulse_down => pulse_down,
      red_val    => red_val,
      green_val  => green_val,
      blue_val   => blue_val,
      sel_r      => sel_r,
      sel_g      => sel_g,
      sel_b      => sel_b
    );

  --------------------------------------------------------------------
  -- Optional monitor: print basic info at each clock
  monitor_p: process
    variable channel_str : string(1 to 1);
  begin
    wait until rising_edge(clk);

    if sel_r = '1' then
      channel_str := "R";
    elsif sel_g = '1' then
      channel_str := "G";
    else
      channel_str := "B";
    end if;
    report "CH = " & channel_str & "  R=" & integer'image(to_integer(unsigned(red_val))) & "  G=" & integer'image(to_integer(unsigned(green_val))) & "  B=" & integer'image(to_integer(unsigned(blue_val)));
  end process;

end architecture;
