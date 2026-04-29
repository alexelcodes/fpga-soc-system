-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:pl_top:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rgb_pwm_system_pl_top_0_0 IS
  PORT (
    sysclk : IN STD_LOGIC;
    ctrl : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    led4_r : OUT STD_LOGIC;
    led4_g : OUT STD_LOGIC;
    led4_b : OUT STD_LOGIC;
    led5_r : OUT STD_LOGIC;
    led5_g : OUT STD_LOGIC;
    led5_b : OUT STD_LOGIC;
    oled_din : OUT STD_LOGIC;
    oled_clk : OUT STD_LOGIC;
    oled_cs : OUT STD_LOGIC;
    oled_dc : OUT STD_LOGIC;
    oled_res : OUT STD_LOGIC
  );
END rgb_pwm_system_pl_top_0_0;

ARCHITECTURE rgb_pwm_system_pl_top_0_0_arch OF rgb_pwm_system_pl_top_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF rgb_pwm_system_pl_top_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT pl_top IS
    PORT (
      sysclk : IN STD_LOGIC;
      ctrl : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      led4_r : OUT STD_LOGIC;
      led4_g : OUT STD_LOGIC;
      led4_b : OUT STD_LOGIC;
      led5_r : OUT STD_LOGIC;
      led5_g : OUT STD_LOGIC;
      led5_b : OUT STD_LOGIC;
      oled_din : OUT STD_LOGIC;
      oled_clk : OUT STD_LOGIC;
      oled_cs : OUT STD_LOGIC;
      oled_dc : OUT STD_LOGIC;
      oled_res : OUT STD_LOGIC
    );
  END COMPONENT pl_top;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_MODE : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF oled_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 oled_clk CLK";
  ATTRIBUTE X_INTERFACE_MODE OF oled_clk: SIGNAL IS "master oled_clk";
  ATTRIBUTE X_INTERFACE_PARAMETER OF oled_clk: SIGNAL IS "XIL_INTERFACENAME oled_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN rgb_pwm_system_pl_top_0_0_oled_clk, INSERT_VIP 0";
BEGIN
  U0 : pl_top
    PORT MAP (
      sysclk => sysclk,
      ctrl => ctrl,
      led => led,
      led4_r => led4_r,
      led4_g => led4_g,
      led4_b => led4_b,
      led5_r => led5_r,
      led5_g => led5_g,
      led5_b => led5_b,
      oled_din => oled_din,
      oled_clk => oled_clk,
      oled_cs => oled_cs,
      oled_dc => oled_dc,
      oled_res => oled_res
    );
END rgb_pwm_system_pl_top_0_0_arch;
