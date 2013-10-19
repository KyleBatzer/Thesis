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
--                pred_lt3 state machine as part of the pred_lt3 submodule of the
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

package SPI_pkg is    


constant IDLE 							: STD_LOGIC_VECTOR(7 downto 0) := x"00";
--constant OUTPUT_DATA 				: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant OUTPUT_B31	 				: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant OUTPUT_B30 					: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant OUTPUT_B29 					: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant OUTPUT_B28					: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant OUTPUT_B27 					: STD_LOGIC_VECTOR(7 downto 0) := x"05";
constant OUTPUT_B26					: STD_LOGIC_VECTOR(7 downto 0) := x"06";
constant OUTPUT_B25	 				: STD_LOGIC_VECTOR(7 downto 0) := x"07";
constant OUTPUT_B24 					: STD_LOGIC_VECTOR(7 downto 0) := x"08";
constant OUTPUT_B23	 				: STD_LOGIC_VECTOR(7 downto 0) := x"09";
constant OUTPUT_B22 					: STD_LOGIC_VECTOR(7 downto 0) := x"10";
constant OUTPUT_B21 					: STD_LOGIC_VECTOR(7 downto 0) := x"11";
constant OUTPUT_B20					: STD_LOGIC_VECTOR(7 downto 0) := x"12";
constant OUTPUT_B19					: STD_LOGIC_VECTOR(7 downto 0) := x"13";
constant OUTPUT_B18					: STD_LOGIC_VECTOR(7 downto 0) := x"14";
constant OUTPUT_B17	 				: STD_LOGIC_VECTOR(7 downto 0) := x"15";
constant OUTPUT_B16					: STD_LOGIC_VECTOR(7 downto 0) := x"16";
constant OUTPUT_B15	 				: STD_LOGIC_VECTOR(7 downto 0) := x"17";
constant OUTPUT_B14					: STD_LOGIC_VECTOR(7 downto 0) := x"18";
constant OUTPUT_B13					: STD_LOGIC_VECTOR(7 downto 0) := x"19";
constant OUTPUT_B12					: STD_LOGIC_VECTOR(7 downto 0) := x"1A";
constant OUTPUT_B11 					: STD_LOGIC_VECTOR(7 downto 0) := x"1B";
constant OUTPUT_B10 					: STD_LOGIC_VECTOR(7 downto 0) := x"1C";
constant OUTPUT_B9	 				: STD_LOGIC_VECTOR(7 downto 0) := x"1D";
constant OUTPUT_B8 					: STD_LOGIC_VECTOR(7 downto 0) := x"1E";
constant OUTPUT_B7	 				: STD_LOGIC_VECTOR(7 downto 0) := x"1F";
constant OUTPUT_B6 					: STD_LOGIC_VECTOR(7 downto 0) := x"20";
constant OUTPUT_B5 					: STD_LOGIC_VECTOR(7 downto 0) := x"21";
constant OUTPUT_B4 					: STD_LOGIC_VECTOR(7 downto 0) := x"22";
constant OUTPUT_B3 					: STD_LOGIC_VECTOR(7 downto 0) := x"23";
constant OUTPUT_B2 					: STD_LOGIC_VECTOR(7 downto 0) := x"24";
constant OUTPUT_B1	 				: STD_LOGIC_VECTOR(7 downto 0) := x"25";
constant OUTPUT_B0 					: STD_LOGIC_VECTOR(7 downto 0) := x"26";
constant TX_COMPLETE					: STD_LOGIC_VECTOR(7 downto 0) := x"FF";

constant INIT_FLAG					: integer := 32;

constant B31_FLAG						: integer := 31;
constant B30_FLAG						: integer := 30;
constant B29_FLAG						: integer := 29;
constant B28_FLAG						: integer := 28;
constant B27_FLAG						: integer := 27;
constant B26_FLAG						: integer := 26;
constant B25_FLAG						: integer := 25;
constant B24_FLAG						: integer := 24;
constant B23_FLAG						: integer := 23;
constant B22_FLAG						: integer := 22;
constant B21_FLAG						: integer := 21;
constant B20_FLAG						: integer := 20;
constant B19_FLAG						: integer := 19;
constant B18_FLAG						: integer := 18;
constant B17_FLAG						: integer := 17;
constant B16_FLAG						: integer := 16;
constant B15_FLAG						: integer := 15;
constant B14_FLAG						: integer := 14;
constant B13_FLAG						: integer := 13;
constant B12_FLAG						: integer := 12;
constant B11_FLAG						: integer := 11;
constant B10_FLAG						: integer := 10;
constant B9_FLAG						: integer := 9;
constant B8_FLAG						: integer := 8;
constant B7_FLAG						: integer := 7;
constant B6_FLAG						: integer := 6;
constant B5_FLAG						: integer := 5;
constant B4_FLAG						: integer := 4;
constant B3_FLAG						: integer := 3;
constant B2_FLAG						: integer := 2;
constant B1_FLAG						: integer := 1;
constant B0_FLAG						: integer := 0;

--constant OUTPUT_FLAG				 	: integer := 1;
constant DONE_FLAG					: integer := 33;

--type inter_3l is array (0 to 30) of STD_LOGIC_VECTOR(15 downto 0);
--constant inter_3l_array : inter_3l := (x"7303", x"6277", x"396D", x"0C47", x"EECE", 
--													x"E926", x"F521", x"04BB", x"0C3A", x"08D3",
--													x"0000", x"F98C", x"F97E", x"FE30", x"02F4",
--													x"044B", x"0226", x"FF0B", x"FD86", x"FE3D",
--													x"0000", x"0134", x"0128", x"004E", x"FF88",
--													x"FF5B", x"FFB1", x"0022", x"005B", x"0046",
--													x"0000");

end SPI_pkg;


package body SPI_pkg is    

end SPI_pkg;            

