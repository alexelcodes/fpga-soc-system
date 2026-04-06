-- RGB Controller
-- Holds R, G, B brightness values (0–255).
-- Controls which channel is active and adjusts its value up/down.
-- Inputs come from button_pulser modules:
--   * pulse_sel  – short press: switch channel (R→G→B→R)
--   * pulse_up   – increase brightness
--   * pulse_down – decrease brightness
-- Asynchronous active-low reset.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity rgb_controller is
  port (
    clk        : in  std_logic; -- slow clock (1 kHz)
    n_Reset    : in  std_logic; -- async reset, active-low
    pulse_sel  : in  std_logic; -- channel select button pulse
    pulse_up   : in  std_logic; -- brightness up pulse
    pulse_down : in  std_logic; -- brightness down pulse

    -- 8-bit number (0..255). Index 7..0 = 8 bits (bit7 MSB → bit0 LSB).
    -- Stored as bit array: [bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0], e.g. 01010110.
    red_val    : out std_logic_vector(7 downto 0);
    green_val  : out std_logic_vector(7 downto 0);
    blue_val   : out std_logic_vector(7 downto 0);
    sel_r      : out std_logic; -- active channel indicator
    sel_g      : out std_logic;
    sel_b      : out std_logic
  );
end entity;

architecture rtl of rgb_controller is
  --------------------------------------------------------------------
  -- FSM state type for selecting RGB channel
  --  * CH_R – Red channel active
  --  * CH_G – Green channel active
  --  * CH_B – Blue channel active
  --------------------------------------------------------------------
  type t_channel is (CH_R, CH_G, CH_B);
  signal ch_state : t_channel := CH_R; -- current channel state, starts at RED

  --------------------------------------------------------------------
  -- Brightness registers
  --------------------------------------------------------------------
  -- 8-bit brightness registers for R, G, B (0..255). 
  -- unsigned is used so we can do +1 / -1. 
  -- (others => '0') sets all 8 bits to 0 → "00000000" (start value)
  signal reg_r : unsigned(7 downto 0) := (others => '0');
  signal reg_g : unsigned(7 downto 0) := (others => '0');
  signal reg_b : unsigned(7 downto 0) := (others => '0');

  -- Limits for brightness:
  -- C_MAX = 255 → "11111111" (max brightness)
  -- C_MIN =   0 → "00000000" (min brightness)
  -- to_unsigned(...) converts an integer to an 8-bit unsigned value.
  --   Example: to_unsigned(255,8) → 11111111
  --            to_unsigned(5,8)   → 00000101
  constant C_MAX : unsigned(7 downto 0) := to_unsigned(255, 8);
  constant C_MIN : unsigned(7 downto 0) := to_unsigned(0, 8);

begin
  --------------------------------------------------------------------
  -- Output current register values
  --------------------------------------------------------------------
  red_val   <= std_logic_vector(reg_r);
  green_val <= std_logic_vector(reg_g);
  blue_val  <= std_logic_vector(reg_b);

  --------------------------------------------------------------------
  -- Active channel indicators (for LED or debug)
  --------------------------------------------------------------------
  sel_r <= '1' when ch_state = CH_R else '0';
  sel_g <= '1' when ch_state = CH_G else '0';
  sel_b <= '1' when ch_state = CH_B else '0';

  --------------------------------------------------------------------
  -- Main process: channel selection + brightness control

  --------------------------------------------------------------------
  process (clk, n_Reset)
  begin
    if n_Reset = '0' then
      ch_state <= CH_R;
      reg_r <= (others => '0');
      reg_g <= (others => '0');
      reg_b <= (others => '0');

    elsif rising_edge(clk) then
      -- Channel selection (btn1)
      if pulse_sel = '1' then
        case ch_state is
          -- "when ... =>" means: if current state matches, do this action
          when CH_R => ch_state <= CH_G; -- switch from channel RED to GREEN
          when CH_G => ch_state <= CH_B;
          when CH_B => ch_state <= CH_R;
        end case;
      end if;

      -- Brightness control (btn2/btn3)
      case ch_state is
        when CH_R =>
          if pulse_up = '1' and reg_r < C_MAX then
            reg_r <= reg_r + 1;
          elsif pulse_down = '1' and reg_r > C_MIN then
            reg_r <= reg_r - 1;
          end if;

        when CH_G =>
          if pulse_up = '1' and reg_g < C_MAX then
            reg_g <= reg_g + 1;
          elsif pulse_down = '1' and reg_g > C_MIN then
            reg_g <= reg_g - 1;
          end if;

        when CH_B =>
          if pulse_up = '1' and reg_b < C_MAX then
            reg_b <= reg_b + 1;
          elsif pulse_down = '1' and reg_b > C_MIN then
            reg_b <= reg_b - 1;
          end if;
      end case;
    end if;
  end process;

end architecture;
