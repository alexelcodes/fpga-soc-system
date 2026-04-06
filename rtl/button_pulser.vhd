-- Button Pulser
-- Generates a 1-clock-wide pulse on the rising edge of btn_in.
-- If the button is held down long enough, emits a repeating pulse train:
--   - Start delay  = G_START_DELAY_CYCLES (in clock cycles)
--   - Repeat period = G_REPEAT_PERIOD_CYCLES (in clock cycles)
-- Includes asynchronous active-low reset.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity button_pulser is
  generic (
    -- How long the button must be held before auto-repeat starts
    -- (e.g. one pulse every 2 s at 1 kHz clock = 2000 cycles)
    G_START_DELAY_CYCLES   : positive := 2000;

    -- How often to send pulses while the button is held
    -- (e.g. one pulse every 0.5 s at 1 kHz clock = 500 cycles)
    G_REPEAT_PERIOD_CYCLES : positive := 500
  );
  port (
    clk       : in  std_logic; -- slow clock input (e.g., 1 kHz)
    n_Reset   : in  std_logic; -- async reset, active-low
    btn_in    : in  std_logic; -- gets '0' or '1' from its button: btn(1)=select, btn(2)=up, btn(3)=down
    pulse_out : out std_logic  -- one-clock pulse output
  );
end entity;

architecture rtl of button_pulser is
  --------------------------------------------------------------------
  -- FSM state type and internal signals
  --------------------------------------------------------------------
  -- Define all possible states of the button pulser:
  --  * IDLE        – button not pressed
  --  * HOLD_DELAY  – button held, counting time before auto-repeat starts
  --  * REPEAT_WAIT – button held, generating repeated pulses
  type t_state is (IDLE, HOLD_DELAY, REPEAT_WAIT);
  signal state : t_state := IDLE; -- current state of the FSM, starts in IDLE

  signal pulse_q   : std_logic := '0'; -- pulse output (1 clock cycle wide)
  signal cnt_delay : natural   := 0;   -- counts how long button is held before repeat
  signal cnt_rep   : natural   := 0;   -- counts delay between repeated pulses

begin
  pulse_out <= pulse_q; -- connect internal pulse signal to output

  --------------------------------------------------------------------
  -- Main button pulser process
  --  - Detects rising edge of btn_in (pressed)
  --  - Generates 1-clock pulse on press
  --  - Starts auto-repeat after hold delay

  --------------------------------------------------------------------
  process (clk, n_Reset)
  begin
    if n_Reset = '0' then -- asynchronous reset (pressed)
      state <= IDLE;
      pulse_q <= '0';
      cnt_delay <= 0;
      cnt_rep <= 0;

    elsif rising_edge(clk) then -- runs every time clock rises from 0→1
      pulse_q <= '0'; -- by default, no pulse is sent this clock cycle

      case state is -- runs every clock tick (0→1) to update FSM state
        ----------------------------------------------------------------
        when IDLE =>
          if btn_in = '1' then
            pulse_q <= '1'; -- single pulse on press
            cnt_delay <= 0; -- start long-press timer
            state <= HOLD_DELAY;
          end if;

        ----------------------------------------------------------------
        when HOLD_DELAY =>
          if btn_in = '0' then
            state <= IDLE; -- released before repeat
          else
            if cnt_delay = G_START_DELAY_CYCLES - 1 then
              cnt_delay <= 0;
              cnt_rep <= 0;
              state <= REPEAT_WAIT; -- enter repeat mode
            else
              cnt_delay <= cnt_delay + 1;
            end if;
          end if;

        ----------------------------------------------------------------
        when REPEAT_WAIT =>
          if btn_in = '0' then
            cnt_rep <= 0;
            state <= IDLE; -- stop repeat on release
          else
            if cnt_rep = G_REPEAT_PERIOD_CYCLES - 1 then
              pulse_q <= '1'; -- next repeat pulse
              cnt_rep <= 0;
            else
              cnt_rep <= cnt_rep + 1;
            end if;
          end if;

      end case;
    end if;
  end process;
end architecture;
