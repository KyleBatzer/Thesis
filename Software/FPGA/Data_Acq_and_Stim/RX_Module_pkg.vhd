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

package RX_Module_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant WAIT_BAUD								: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant CAPTURE_BYTE							: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant WRITE_TO_FIFO							: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant WAIT_BAUD2								: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant WAIT_BAUD3								: STD_LOGIC_VECTOR(7 downto 0) := x"05";


constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant CAPTURE_BYTE_FLAG						: integer := 1;
constant INC_COUNT_FLAG							: integer := 2;
constant WR_EN_FLAG								: integer := 3;
constant INC_BAUD_COUNT_FLAG					: integer := 4;
constant CLEAR_BAUD_COUNT_FLAG				: integer := 5;


--constant DONE_FLAG								: integer := 6;

												

end RX_Module_pkg;

package body RX_Module_pkg is    

end RX_Module_pkg;            


