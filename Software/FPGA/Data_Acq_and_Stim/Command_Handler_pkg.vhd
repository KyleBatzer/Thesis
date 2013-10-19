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

package Command_Handler_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant CHECK_START								: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant READ_MESSAGE							: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant INC_RX_FIFO								: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant VALIDATE_MSG 							: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant WAIT_FOR_NEXT_BYTE					: STD_LOGIC_VECTOR(7 downto 0) := x"05";
constant DELAY_STATE								: STD_LOGIC_VECTOR(7 downto 0) := x"06";

constant PAYLOAD_START 							: STD_LOGIC_VECTOR(7 downto 0) := x"10";
constant PAYLOAD 									: STD_LOGIC_VECTOR(7 downto 0) := x"11";


constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant INC_COUNT_FLAG							: integer := 1;
constant CLEAR_COUNT_FLAG						: integer := 2;

constant RX_RD_EN_FLAG							: integer := 3;
constant READ_MESSAGE_FLAG						: integer := 4;

--constant SET_REPLY_BYTE_FLAG					: integer := 5;
constant TX_WR_EN_FLAG							: integer := 6;

constant PAYLOAD_START_FLAG					: integer := 7;
constant PAYLOAD_FLAG							: integer := 8;


constant DONE_FLAG								: integer := 15;

												

end Command_Handler_pkg;

package body Command_Handler_pkg is    

end Command_Handler_pkg;            


