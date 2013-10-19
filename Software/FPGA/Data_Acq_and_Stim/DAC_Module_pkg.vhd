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

package DAC_Module_pkg is    


constant INIT								: STD_LOGIC_VECTOR(7 downto 0) := x"00";

constant TX_START	 						: STD_LOGIC_VECTOR(7 downto 0) := x"01";
constant TX_WAIT 							: STD_LOGIC_VECTOR(7 downto 0) := x"02";

constant RESET_OP_START					: STD_LOGIC_VECTOR(7 downto 0) := x"04";
constant RESET_OP_WAIT					: STD_LOGIC_VECTOR(7 downto 0) := x"05";
constant RESET_OP_COMPLETE				: STD_LOGIC_VECTOR(7 downto 0) := x"06";
constant INTERNAL_REF_REG_START		: STD_LOGIC_VECTOR(7 downto 0) := x"07";
constant INTERNAL_REF_REG_WAIT		: STD_LOGIC_VECTOR(7 downto 0) := x"08";
constant INTERNAL_REF_REG_COMPLETE	: STD_LOGIC_VECTOR(7 downto 0) := x"09";
constant LDAC_REG_START					: STD_LOGIC_VECTOR(7 downto 0) := x"10";
constant LDAC_REG_WAIT					: STD_LOGIC_VECTOR(7 downto 0) := x"11";
constant LDAC_REG_COMPLETE				: STD_LOGIC_VECTOR(7 downto 0) := x"12";
constant POWER_DAC_START				: STD_LOGIC_VECTOR(7 downto 0) := x"13";
constant POWER_DAC_WAIT					: STD_LOGIC_VECTOR(7 downto 0) := x"14";
constant POWER_DAC_COMPLETE			: STD_LOGIC_VECTOR(7 downto 0) := x"15";
constant CLEAR_CODE_START				: STD_LOGIC_VECTOR(7 downto 0) := x"16";
constant CLEAR_CODE_WAIT				: STD_LOGIC_VECTOR(7 downto 0) := x"17";
constant CLEAR_CODE_COMPLETE			: STD_LOGIC_VECTOR(7 downto 0) := x"18";
constant SET_SAMPLE_DATA				: STD_LOGIC_VECTOR(7 downto 0) := x"19";

constant IDLE 								: STD_LOGIC_VECTOR(7 downto 0) := x"20";

constant NUM_SAMPLES_1					: STD_LOGIC_VECTOR(7 downto 0) := x"50";
constant NUM_SAMPLES_2					: STD_LOGIC_VECTOR(7 downto 0) := x"51";
constant AMPLITUDE_1						: STD_LOGIC_VECTOR(7 downto 0) := x"60";
constant AMPLITUDE_2						: STD_LOGIC_VECTOR(7 downto 0) := x"61";
constant TIME_1							: STD_LOGIC_VECTOR(7 downto 0) := x"70";
constant TIME_2							: STD_LOGIC_VECTOR(7 downto 0) := x"71";

constant WAIT_FOR_TIME					: STD_LOGIC_VECTOR(7 downto 0) := x"80";

constant TX_COMPLETE						: STD_LOGIC_VECTOR(7 downto 0) := x"FF";

constant START_FLAG				 		: integer := 0;
constant WAIT_FLAG						: integer := 1;
constant DONE_FLAG						: integer := 2;
constant RESET_OP_SET_FLAG				: integer := 3;
constant INTERNAL_REF_REG_SET_FLAG	: integer := 4;
constant LDAC_REG_SET_FLAG				: integer := 5;
constant POWER_DAC_SET_FLAG			: integer := 6;
constant CLEAR_CODE_SET_FLAG			: integer := 7;
constant IDLE_FLAG						: integer := 8;
constant VOLTAGE_SET_FLAG				: integer := 9;
constant VOLTAGE_DEFAULT_FLAG			: integer := 10;

constant START_MEM_OP_FLAG				: integer := 11;

constant NUM_SAMPLES_RD_FLAG			: integer := 12;
constant NUM_SAMPLES_CAPTURE_FLAG	: integer := 13;

constant AMPLITUDE_RD_FLAG				: integer := 14;
constant AMPLITUDE_CAPTURE_FLAG		: integer := 15;

constant TIME_RD_FLAG					: integer := 16;
constant TIME_CAPTURE_FLAG				: integer := 17;

constant TIME_COUNT_INC_FLAG			: integer := 18;
constant TIME_COUNT_RESET_FLAG		: integer := 19;

constant SAMPLE_COUNT_INC_FLAG		: integer := 20;
constant SAMPLE_COUNT_RESET_FLAG		: integer := 21;

constant INC_COUNT_FLAG					: integer := 22;
constant RESET_COUNT_FLAG				: integer := 23;

												

end DAC_Module_pkg;

package body DAC_Module_pkg is    

end DAC_Module_pkg;            


