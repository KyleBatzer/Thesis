----------------------------------------------------------------------------------
-- Company: 	WMU - Thesis
-- Engineer: 	KDB
-- 
-- Create Date:     
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:          
--
--         	         
--   
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package ADC_Capture_pkg is    


constant ADC_RESET								: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"10";

constant CONVST									: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant WAIT_BUSY_HIGH							: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant WAIT_BUSY_LOW							: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant CAPTURE_1								: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant CAPTURE_2								: STD_LOGIC_VECTOR(7 downto 0) := x"05";

constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant CONVST_FLAG								: integer := 1;
constant SET_CS_FLAG								: integer := 2;
constant CAPTURE_DATA_FLAG						: integer := 3;
constant INC_COUNT_FLAG							: integer := 4;
constant ADC_RESET_FLAG							: integer := 5;

constant DONE_FLAG								: integer := 6;

												

end ADC_Capture_pkg;

package body ADC_Capture_pkg is    

end ADC_Capture_pkg;            


