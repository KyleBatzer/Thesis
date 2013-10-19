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

package RS232_Test_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant RX_TO_TX									: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant WAIT_1									: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant WAIT_2									: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant WAIT_3									: STD_LOGIC_VECTOR(7 downto 0) := x"04";


constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



--constant IDLE_FLAG								: integer := 0;

constant TX_WR_EN_FLAG							: integer := 1;
constant RX_RD_EN_FLAG							: integer := 2;



--constant DONE_FLAG								: integer := 6;

												

end RS232_Test_pkg;

package body RS232_Test_pkg is    

end RS232_Test_pkg;            


