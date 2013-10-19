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

package RAM_Module_pkg is    


constant RAM_RESET								: STD_LOGIC_VECTOR(7 downto 0) := x"10";

constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";
constant PERFORM_OP								: STD_LOGIC_VECTOR(7 downto 0) := x"01";

constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant PERFORM_OP_FLAG						: integer := 1;
constant INC_COUNT_FLAG							: integer := 2;
constant RAM_RESET_FLAG							: integer := 3;



constant DONE_FLAG								: integer := 4;

												

end RAM_Module_pkg;

package body RAM_Module_pkg is    

end RAM_Module_pkg;            


