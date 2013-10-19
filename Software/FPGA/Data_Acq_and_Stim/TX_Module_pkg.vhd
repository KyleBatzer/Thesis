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

package TX_Module_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant START_BIT								: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant SEND_BYTE 								: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant END_BIT 									: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant INC_FIFO									: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant INTER_BYTE_DELAY						: STD_LOGIC_VECTOR(7 downto 0) := x"05";

constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant START_BIT_FLAG							: integer := 1;
constant SEND_BYTE_FLAG							: integer := 2;
constant INC_COUNT_FLAG							: integer := 3;
constant END_BIT_FLAG							: integer := 4;
constant RD_EN_FLAG								: integer := 5;

--constant DONE_FLAG								: integer := 6;

												

end TX_Module_pkg;

package body TX_Module_pkg is    

end TX_Module_pkg;            


