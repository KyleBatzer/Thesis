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

package MSG_GET_WAVEFORM_pkg is    


constant IDLE 										: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant VALIDATE_MSG 							: STD_LOGIC_VECTOR(7 downto 0) := x"10";

constant REPLY_HEADER_SET						: STD_LOGIC_VECTOR(7 downto 0) := x"20";
constant REPLY_HEADER_SEND						: STD_LOGIC_VECTOR(7 downto 0) := x"21";

constant NUM_SAMPLES_1							: STD_LOGIC_VECTOR(7 downto 0) := x"30";
constant NUM_SAMPLES_2							: STD_LOGIC_VECTOR(7 downto 0) := x"31";
constant NUM_SAMPLES_3							: STD_LOGIC_VECTOR(7 downto 0) := x"32";
constant NUM_SAMPLES_4							: STD_LOGIC_VECTOR(7 downto 0) := x"33";

constant LOOP1										: STD_LOGIC_VECTOR(7 downto 0) := x"40";

constant AMPLITUDE_1								: STD_LOGIC_VECTOR(7 downto 0) := x"50";
constant AMPLITUDE_2								: STD_LOGIC_VECTOR(7 downto 0) := x"51";
constant AMPLITUDE_3								: STD_LOGIC_VECTOR(7 downto 0) := x"52";
constant AMPLITUDE_4								: STD_LOGIC_VECTOR(7 downto 0) := x"53";
constant AMPLITUDE_5								: STD_LOGIC_VECTOR(7 downto 0) := x"54";
constant AMPLITUDE_6								: STD_LOGIC_VECTOR(7 downto 0) := x"55";

constant TIME_1									: STD_LOGIC_VECTOR(7 downto 0) := x"60";
constant TIME_2									: STD_LOGIC_VECTOR(7 downto 0) := x"61";
constant TIME_3									: STD_LOGIC_VECTOR(7 downto 0) := x"62";
constant TIME_4									: STD_LOGIC_VECTOR(7 downto 0) := x"63";
constant TIME_5									: STD_LOGIC_VECTOR(7 downto 0) := x"64";
constant TIME_6									: STD_LOGIC_VECTOR(7 downto 0) := x"65";

constant LOOP1_COMPLETE							: STD_LOGIC_VECTOR(7 downto 0) := x"70";

constant WRITE_CHECKSUM_1						: STD_LOGIC_VECTOR(7 downto 0) := x"80";
constant WRITE_CHECKSUM_2						: STD_LOGIC_VECTOR(7 downto 0) := x"81";

constant FINISH									: STD_LOGIC_VECTOR(7 downto 0) := x"FF";



constant IDLE_FLAG								: integer := 0;

constant INC_COUNT_FLAG							: integer := 1;
constant CLEAR_COUNT_FLAG						: integer := 2;
constant RX_RD_EN_FLAG							: integer := 3;
constant TX_WR_EN_FLAG							: integer := 4;
constant START_MEM_OP_FLAG						: integer := 5;

constant NUM_SAMPLES_RD_FLAG					: integer := 6;
constant NUM_SAMPLES_WR_FLAG					: integer := 7;
constant NUM_SAMPLES_CAPTURE_FLAG			: integer := 8;

constant AMPLITUDE_H_WR_FLAG					: integer := 9;
constant AMPLITUDE_L_WR_FLAG					: integer := 10;
constant AMPLITUDE_RD_FLAG						: integer := 11;
constant AMPLITUDE_CAPTURE_FLAG				: integer := 12;

constant TIME_H_WR_FLAG							: integer := 13;
constant TIME_L_WR_FLAG							: integer := 14;
constant TIME_RD_FLAG							: integer := 15;
constant TIME_CAPTURE_FLAG						: integer := 16;

constant CHECKSUM_WR_FLAG						: integer := 17;

constant SET_REPLY_BYTE_FLAG					: integer := 18;

constant DONE_FLAG								: integer := 19;

												

end MSG_GET_WAVEFORM_pkg;

package body MSG_GET_WAVEFORM_pkg is    

end MSG_GET_WAVEFORM_pkg;            


