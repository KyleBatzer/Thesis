----------------------------------------------------------------------------------
-- Company: 	NASA-GRC
-- Engineer: 	KDB
-- 
-- Create Date:    18:30:00 11/18/2009 
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:   This module contains the S.M. to control functions of the 
--                convolve submodule. 
--
--
--   
--
-- Dependencies: 
--
-- Revision: 
--
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.DAC_Module_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DAC_Module_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			DAC_Module_start			: in  STD_LOGIC;			--start S.M. into motion
			SPI_Done						: in  STD_LOGIC;
			RAM_Op_Done					: in  STD_LOGIC;
			--continuous					: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			time_count					: in  STD_LOGIC_VECTOR(15 downto 0);
			time_val						: in  STD_LOGIC_VECTOR(15 downto 0);
			sample_count				: in  STD_LOGIC_VECTOR(7 downto 0);
			num_samples					: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(23 downto 0)	--flags to enable functions
			);	
end DAC_Module_states;

architecture Behavioral of DAC_Module_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := INIT;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := INIT;  -- FSM next state
     
begin
-------------------------------------------------------------------------------
		-- synchronous part of state machine here
data_in_latch: process(clk, rst_n)
begin
   if rst_n = '0' then
		curr_state <= INIT;
   elsif rising_edge(clk) then
		curr_state <= next_state;
   end if;
end process;

		-- async part of state machine to set function flags
DAC_Module_state: process(rst_n, curr_state, sample_count, num_samples, DAC_Module_start)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			when INIT => 
				async_flags(RESET_OP_SET_FLAG) <= '1';
				async_flags(RESET_COUNT_FLAG) <= '1';
			
			when RESET_OP_START =>
				async_flags(START_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			when RESET_OP_WAIT =>
				async_flags(RESET_COUNT_FLAG) <= '1';	
			when RESET_OP_COMPLETE =>   -- due to different clock rate the SPI_Start signal is held high throughout the op. SPI waits for SPI_Start to go low
				async_flags(INTERNAL_REF_REG_SET_FLAG) <= '1';
				
			when INTERNAL_REF_REG_START =>
				async_flags(START_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			when INTERNAL_REF_REG_WAIT =>
				async_flags(RESET_COUNT_FLAG) <= '1';	
			when INTERNAL_REF_REG_COMPLETE =>
				async_flags(LDAC_REG_SET_FLAG) <= '1';
				
			when LDAC_REG_START =>
				async_flags(START_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			when LDAC_REG_WAIT =>
				async_flags(RESET_COUNT_FLAG) <= '1';	
			when LDAC_REG_COMPLETE =>
				async_flags(POWER_DAC_SET_FLAG) <= '1';
			
			when POWER_DAC_START =>
				async_flags(START_FLAG) <= '1';	
				async_flags(INC_COUNT_FLAG) <= '1';
			when POWER_DAC_WAIT =>
				async_flags(RESET_COUNT_FLAG) <= '1';	
			when POWER_DAC_COMPLETE =>
				async_flags(CLEAR_CODE_SET_FLAG) <= '1';
				
			when CLEAR_CODE_START =>
				async_flags(START_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			when CLEAR_CODE_WAIT =>
				async_flags(RESET_COUNT_FLAG) <= '1';	
			
			when IDLE => 
				async_flags(IDLE_FLAG) <= '1';
				
---------------------------------- Adding read from memory states -------------------------------

-- Reply - num_samples		
			when NUM_SAMPLES_1 =>						-- Start read from RAM for num_samples
				async_flags(START_MEM_OP_FLAG) <= '1';
				async_flags(NUM_SAMPLES_RD_FLAG) <= '1';
				--async_flags(CLEAR_COUNT_FLAG) <= '1';
			
			when NUM_SAMPLES_2 =>						-- wait for RAM Op to complete
				async_flags(NUM_SAMPLES_CAPTURE_FLAG) <= '1';
					
	-- Read Amplitude from RAM and write to TX_FIFO		
			when AMPLITUDE_1 =>					-- Start read from RAM for Amplitude
				async_flags(START_MEM_OP_FLAG) <= '1';
				async_flags(AMPLITUDE_RD_FLAG) <= '1';
				
			when AMPLITUDE_2 =>					-- wait for RAM Op to complete
				async_flags(AMPLITUDE_CAPTURE_FLAG) <= '1';
	
	-- Read Time from RAM and write to TX_FIFO	
			when TIME_1 =>							-- Start read from RAM for Amplitude
				async_flags(START_MEM_OP_FLAG) <= '1';
				async_flags(TIME_RD_FLAG) <= '1';
				
			when TIME_2 =>							-- wait for RAM Op to complete
				async_flags(TIME_CAPTURE_FLAG) <= '1';

---------------------------------- End read from memory states ----------------------------------
				
			when SET_SAMPLE_DATA => 
				if sample_count = num_samples and DAC_Module_start = '0' then
					async_flags(VOLTAGE_DEFAULT_FLAG) <= '1';
				else
					async_flags(VOLTAGE_SET_FLAG) <= '1';
				end if;
				
			when TX_START =>
				async_flags(START_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
				
			when TX_WAIT  =>
				async_flags(WAIT_FLAG) <= '1';
				--async_flags(START_FLAG) <= '1';
				async_flags(RESET_COUNT_FLAG) <= '1';
				
			when WAIT_FOR_TIME =>					-- adds delay to implement the time part of the amplitude:time pair
				async_flags(TIME_COUNT_INC_FLAG) <= '1';
				
			when TX_COMPLETE =>
				async_flags(TIME_COUNT_RESET_FLAG) <= '1';
				if sample_count = num_samples then
					async_flags(SAMPLE_COUNT_RESET_FLAG) <= '1';
				else
					async_flags(SAMPLE_COUNT_INC_FLAG) <= '1';
				end if;
				
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- DAC_Module state machine 
DAC_Module_asynch_state: process(rst_n, curr_state, DAC_Module_start, count, RAM_Op_Done, SPI_Done, time_count, time_val, sample_count, num_samples)
begin
   if rst_n = '0' then
		next_state <= INIT;    
   else
		case curr_state is    
   		
			when INIT => 
				next_state <= RESET_OP_START;
				
			when RESET_OP_START =>
				if count = 9 then
					next_state <= RESET_OP_WAIT;
				else 
					next_state <= RESET_OP_START;
				end if;
			when RESET_OP_WAIT =>
				if SPI_Done = '1' then
					next_state <= RESET_OP_COMPLETE;
				else
					next_state <= RESET_OP_WAIT;
				end if;
			when RESET_OP_COMPLETE =>
				if SPI_Done = '0' then
					next_state <= INTERNAL_REF_REG_START;
				else
					next_state <= RESET_OP_COMPLETE;
				end if;
			
			when INTERNAL_REF_REG_START =>
				if count = 9 then
					next_state <= INTERNAL_REF_REG_WAIT;
				else 
					next_state <= INTERNAL_REF_REG_START;
				end if;
				
			when INTERNAL_REF_REG_WAIT =>
				if SPI_Done = '1' then
					next_state <= INTERNAL_REF_REG_COMPLETE;
				else
					next_state <= INTERNAL_REF_REG_WAIT;
				end if;
			when INTERNAL_REF_REG_COMPLETE =>
				if SPI_Done = '0' then
					next_state <= LDAC_REG_START;
				else
					next_state <= INTERNAL_REF_REG_COMPLETE;
				end if;
			
			when LDAC_REG_START =>
				if count = 9 then
					next_state <= LDAC_REG_WAIT;
				else 
					next_state <= LDAC_REG_START;
				end if;
				
			when LDAC_REG_WAIT =>
				if SPI_Done = '1' then
					next_state <= LDAC_REG_COMPLETE;
				else
					next_state <= LDAC_REG_WAIT;
				end if;
			when LDAC_REG_COMPLETE =>
				if SPI_Done = '0' then
					next_state <= POWER_DAC_START;
				else
					next_state <= LDAC_REG_COMPLETE;
				end if;
				
			when POWER_DAC_START =>
				if count = 9 then
					next_state <= POWER_DAC_WAIT;
				else 
					next_state <= POWER_DAC_START;
				end if;
				
			when POWER_DAC_WAIT =>
				if SPI_Done = '1' then
					next_state <= POWER_DAC_COMPLETE;
				else
					next_state <= POWER_DAC_WAIT;
				end if;
				
			when POWER_DAC_COMPLETE =>
				if SPI_Done = '0' then
					next_state <= CLEAR_CODE_START;
				else
					next_state <= POWER_DAC_COMPLETE;
				end if;
			
			when CLEAR_CODE_START =>
				if count = 9 then
					next_state <= CLEAR_CODE_WAIT;
				else
					next_state <= CLEAR_CODE_START;
				end if;
				
			when CLEAR_CODE_WAIT =>
				if SPI_Done = '1' then
					next_state <= CLEAR_CODE_COMPLETE;
				else
					next_state <= CLEAR_CODE_WAIT;
				end if;
			when CLEAR_CODE_COMPLETE =>
				if DAC_Module_start = '0' and SPI_Done = '0' then
					next_state <= IDLE;	
				else
					next_state <= CLEAR_CODE_COMPLETE;
				end if;

			
			when IDLE =>					
				if DAC_Module_start = '1' then
					next_state <= NUM_SAMPLES_1;
				else
					next_state <= IDLE;
				end if;
				
---------------------------------- Adding read from memory states -------------------------------

-- Reply - num_samples		
			when NUM_SAMPLES_1 =>						-- Start read from RAM for num_samples
				next_state <= NUM_SAMPLES_2;
			
			when NUM_SAMPLES_2 =>						-- wait for RAM Op to complete
				if RAM_Op_Done = '1' then
					next_state <= AMPLITUDE_1;
				else
					next_state <= NUM_SAMPLES_2;
				end if;
					
	-- Read Amplitude from RAM and write to TX_FIFO		
			when AMPLITUDE_1 =>					-- Start read from RAM for Amplitude
				next_state <= AMPLITUDE_2;
				
			when AMPLITUDE_2 =>					-- wait for RAM Op to complete
				if RAM_Op_Done = '1' then
					next_state <= TIME_1;
				else
					next_state <= AMPLITUDE_2;
				end if;
	
	-- Read Time from RAM and write to TX_FIFO	
			when TIME_1 =>							-- Start read from RAM for Amplitude
				next_state <= TIME_2;
				
			when TIME_2 =>							-- wait for RAM Op to complete
				if RAM_Op_Done = '1' then
					next_state <= SET_SAMPLE_DATA;
				else
					next_state <= TIME_2;
				end if;

---------------------------------- End read from memory states ----------------------------------
				
			when SET_SAMPLE_DATA =>
				next_state <= TX_START;
			
			when TX_START =>
				if count = 9 then
					next_state <= TX_WAIT;
				else
					next_state <= TX_START;
				end if;
				
			when TX_WAIT =>
				if SPI_Done = '1' then
					next_state <= WAIT_FOR_TIME;
				else
					next_state <= TX_WAIT;
				end if;
				
			when WAIT_FOR_TIME =>					-- adds delay to implement the time part of the amplitude:time pair
				if time_count = time_val then
					next_state <= TX_COMPLETE;
				else
					next_state <= WAIT_FOR_TIME;
				end if;
			
			when TX_COMPLETE =>
				if sample_count = num_samples and DAC_Module_start = '0' then
					next_state <= IDLE;
				elsif sample_count = num_samples and DAC_Module_start = '1' then
					next_state <= NUM_SAMPLES_1;
				else
					next_state <= AMPLITUDE_1;
				end if;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        

