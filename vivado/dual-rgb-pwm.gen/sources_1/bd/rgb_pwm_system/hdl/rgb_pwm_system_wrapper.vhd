--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.2.1 (win64) Build 6403652 Thu Mar 19 19:48:24 GMT 2026
--Date        : Fri Apr 17 06:10:12 2026
--Host        : DESKTOP-0F96DQA running 64-bit major release  (build 9200)
--Command     : generate_target rgb_pwm_system_wrapper.bd
--Design      : rgb_pwm_system_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity rgb_pwm_system_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    led4_b_0 : out STD_LOGIC;
    led4_g_0 : out STD_LOGIC;
    led4_r_0 : out STD_LOGIC;
    led5_b_0 : out STD_LOGIC;
    led5_g_0 : out STD_LOGIC;
    led5_r_0 : out STD_LOGIC;
    led_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    oled_clk_0 : out STD_LOGIC;
    oled_cs_0 : out STD_LOGIC;
    oled_dc_0 : out STD_LOGIC;
    oled_din_0 : out STD_LOGIC;
    oled_res_0 : out STD_LOGIC
  );
end rgb_pwm_system_wrapper;

architecture STRUCTURE of rgb_pwm_system_wrapper is
  component rgb_pwm_system is
  port (
    led_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    led4_r_0 : out STD_LOGIC;
    led4_g_0 : out STD_LOGIC;
    led4_b_0 : out STD_LOGIC;
    led5_r_0 : out STD_LOGIC;
    led5_g_0 : out STD_LOGIC;
    led5_b_0 : out STD_LOGIC;
    oled_din_0 : out STD_LOGIC;
    oled_clk_0 : out STD_LOGIC;
    oled_cs_0 : out STD_LOGIC;
    oled_dc_0 : out STD_LOGIC;
    oled_res_0 : out STD_LOGIC;
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC
  );
  end component rgb_pwm_system;
begin
rgb_pwm_system_i: component rgb_pwm_system
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      led4_b_0 => led4_b_0,
      led4_g_0 => led4_g_0,
      led4_r_0 => led4_r_0,
      led5_b_0 => led5_b_0,
      led5_g_0 => led5_g_0,
      led5_r_0 => led5_r_0,
      led_0(3 downto 0) => led_0(3 downto 0),
      oled_clk_0 => oled_clk_0,
      oled_cs_0 => oled_cs_0,
      oled_dc_0 => oled_dc_0,
      oled_din_0 => oled_din_0,
      oled_res_0 => oled_res_0
    );
end STRUCTURE;
