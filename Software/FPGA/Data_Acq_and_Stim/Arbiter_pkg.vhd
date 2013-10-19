----------------------------------------------------------------------------------
-- Company: 	NASA-GRC
-- Engineer: 	KDB
-- 
-- Create Date:    09:00:00 1/28/2010 
-- Design Name: 
-- Module Name:    energy_pkg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:   This module contains the state constants to be used for the 
--                enc_lag3 state machine as part of the enc_lag3 submodule of the
--        	  EVA encoder block prototype.         
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

package Arbiter_pkg is    


constant IDLE								: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant SET_BUS_GRANT					: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant WAIT1								: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant CLEAR_BUS_GRANT				: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant WAIT_FOR_BUSY					: STD_LOGIC_VECTOR(7 downto 0) := x"04";


constant INC_COUNT_FLAG				 	: integer := 0;
constant SET_BG_FLAG						: integer := 1;
constant CLEAR_BG_FLAG					: integer := 2;
constant IDLE_FLAG						: integer := 3;




												

end Arbiter_pkg;

package body Arbiter_pkg is    

end Arbiter_pkg;            


