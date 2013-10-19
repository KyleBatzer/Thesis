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

package MSG_SET_WAVEFORM_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant NUM_SAMPLES_1							: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant NUM_SAMPLES_2							: STD_LOGIC_VECTOR(7 downto 0) := x"02";
constant NUM_SAMPLES_3							: STD_LOGIC_VECTOR(7 downto 0) := x"03";
constant NUM_SAMPLES_4							: STD_LOGIC_VECTOR(7 downto 0) := x"04";

constant LOOP1										: STD_LOGIC_VECTOR(7 downto 0) := x"05";

constant AMPLITUDE_H_1							: STD_LOGIC_VECTOR(7 downto 0) := x"10";
constant AMPLITUDE_H_2							: STD_LOGIC_VECTOR(7 downto 0) := x"11";
constant AMPLITUDE_H_3							: STD_LOGIC_VECTOR(7 downto 0) := x"12";
constant AMPLITUDE_H_4							: STD_LOGIC_VECTOR(7 downto 0) := x"13";
constant AMPLITUDE_H_5							: STD_LOGIC_VECTOR(7 downto 0) := x"14";

constant AMPLITUDE_L_1							: STD_LOGIC_VECTOR(7 downto 0) := x"20";
constant AMPLITUDE_L_2							: STD_LOGIC_VECTOR(7 downto 0) := x"21";
constant AMPLITUDE_L_3							: STD_LOGIC_VECTOR(7 downto 0) := x"22";
constant AMPLITUDE_L_4							: STD_LOGIC_VECTOR(7 downto 0) := x"23";

constant TIME_H_1									: STD_LOGIC_VECTOR(7 downto 0) := x"30";
constant TIME_H_2									: STD_LOGIC_VECTOR(7 downto 0) := x"31";
constant TIME_H_3									: STD_LOGIC_VECTOR(7 downto 0) := x"32";
constant TIME_H_4									: STD_LOGIC_VECTOR(7 downto 0) := x"33";
constant TIME_H_5									: STD_LOGIC_VECTOR(7 downto 0) := x"34";

constant TIME_L_1									: STD_LOGIC_VECTOR(7 downto 0) := x"40";
constant TIME_L_2									: STD_LOGIC_VECTOR(7 downto 0) := x"41";
constant TIME_L_3									: STD_LOGIC_VECTOR(7 downto 0) := x"42";
constant TIME_L_4									: STD_LOGIC_VECTOR(7 downto 0) := x"43";

constant LOOP1_END								: STD_LOGIC_VECTOR(7 downto 0) := x"50";

constant VALIDATE_MSG 							: STD_LOGIC_VECTOR(7 downto 0) := x"60";

constant SET_REPLY_BYTE 						: STD_LOGIC_VECTOR(7 downto 0) := x"70";
constant SEND_REPLY_BYTE 						: STD_LOGIC_VECTOR(7 downto 0) := x"71";


constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant INC_COUNT_FLAG							: integer := 1;
constant RX_RD_EN_FLAG							: integer := 2;
constant TX_WR_EN_FLAG							: integer := 3;
constant START_MEM_OP_FLAG						: integer := 4;

constant NUM_SAMPLES_RD_FLAG					: integer := 5;
constant NUM_SAMPLES_WR_FLAG					: integer := 6;

constant AMPLITUDE_H_RD_FLAG					: integer := 7;
constant AMPLITUDE_L_RD_FLAG					: integer := 8;
constant AMPLITUDE_WR_FLAG						: integer := 9;

constant TIME_H_RD_FLAG							: integer := 10;
constant TIME_L_RD_FLAG							: integer := 11;
constant TIME_WR_FLAG							: integer := 12;

constant SET_REPLY_BYTE_FLAG					: integer := 13;

constant CLEAR_COUNT_FLAG						: integer := 14;


constant DONE_FLAG								: integer := 15;

												

end MSG_SET_WAVEFORM_pkg;

package body MSG_SET_WAVEFORM_pkg is    

end MSG_SET_WAVEFORM_pkg;            


