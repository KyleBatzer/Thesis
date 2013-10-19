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

package Synch_Slave_FIFO_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant USB_1										: STD_LOGIC_VECTOR(7 downto 0) := x"10";
constant USB_2										: STD_LOGIC_VECTOR(7 downto 0) := x"11";





constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant SET_SLWR_FLAG							: integer := 1;
constant SET_DATA_FLAG							: integer := 2;
constant SET_RD_EN_FLAG							: integer := 3;
constant INC_COUNT_FLAG							: integer := 4;

constant DONE_FLAG								: integer := 5;

												

end Synch_Slave_FIFO_pkg;

package body Synch_Slave_FIFO_pkg is    

end Synch_Slave_FIFO_pkg;            


