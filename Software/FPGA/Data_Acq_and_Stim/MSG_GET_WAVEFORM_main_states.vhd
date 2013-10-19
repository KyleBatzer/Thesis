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

use work.MSG_GET_WAVEFORM_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MSG_GET_WAVEFORM_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			MSG_Start					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;	
			RAM_Op_Done					: in  STD_LOGIC;
			reply_header_length		: in  STD_LOGIC_VECTOR(7 downto 0);
			num_samples					: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(19 downto 0)	--flags to enable functions
			);		
end MSG_GET_WAVEFORM_states;

architecture Behavioral of MSG_GET_WAVEFORM_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM next state
     
begin
-------------------------------------------------------------------------------
		-- synchronous part of state machine here
data_in_latch: process(clk, rst_n)
begin
   if rst_n = '0' then
		curr_state <= (others => '0');
   elsif rising_edge(clk) then
		curr_state <= next_state;
   end if;
end process;

		-- async part of state machine to set function flags
MSG_GET_WAVEFORM_state: process(rst_n, curr_state, reply_header_length, count)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
				
			when VALIDATE_MSG =>
				
------------------------------------------------------------------------------------------------------------------		
-- Message Reply
------------------------------------------------------------------------------------------------------------------		
	-- Reply Header
			when REPLY_HEADER_SET =>
				async_flags(SET_REPLY_BYTE_FLAG) <= '1';
			
			when REPLY_HEADER_SEND =>
				if count = reply_header_length then
				else
					async_flags(TX_WR_EN_FLAG) <= '1';
					async_flags(INC_COUNT_FLAG) <= '1';
				end if;
			
	-- Reply - num_samples		
			when NUM_SAMPLES_1 =>						-- Start read from RAM for num_samples
				async_flags(START_MEM_OP_FLAG) <= '1';
				async_flags(NUM_SAMPLES_RD_FLAG) <= '1';
				async_flags(CLEAR_COUNT_FLAG) <= '1';
			
			when NUM_SAMPLES_2 =>						-- wait for RAM Op to complete
				async_flags(NUM_SAMPLES_CAPTURE_FLAG) <= '1';
			
			when NUM_SAMPLES_3 =>						-- Set TX_FIFO_DIN to num_samples
				async_flags(NUM_SAMPLES_WR_FLAG) <= '1';
			
			when NUM_SAMPLES_4 =>						-- TX_WR_EN
				async_flags(TX_WR_EN_FLAG) <= '1';
			
	-- Reply - Loop1 - Amplitude:Time Pairs
			when LOOP1 =>
			
			-- Read Amplitude from RAM and write to TX_FIFO		
					when AMPLITUDE_1 =>					-- Start read from RAM for Amplitude
						async_flags(START_MEM_OP_FLAG) <= '1';
						async_flags(AMPLITUDE_RD_FLAG) <= '1';
						
					when AMPLITUDE_2 =>					-- wait for RAM Op to complete
						async_flags(AMPLITUDE_CAPTURE_FLAG) <= '1';
					
					when AMPLITUDE_3 =>					-- Set TX_FIFO_DIN to Amplitude_H 
						async_flags(AMPLITUDE_H_WR_FLAG) <= '1';
					
					when AMPLITUDE_4 =>					-- TX_WR_EN
						async_flags(TX_WR_EN_FLAG) <= '1';
						
					when AMPLITUDE_5 =>					-- Set TX_FIFO_DIN to Amplitude_L 
						async_flags(AMPLITUDE_L_WR_FLAG) <= '1';
					
					when AMPLITUDE_6 =>					-- TX_WR_EN
						async_flags(TX_WR_EN_FLAG) <= '1';
			
			-- Read Time from RAM and write to TX_FIFO	
					when TIME_1 =>							-- Start read from RAM for Amplitude
						async_flags(START_MEM_OP_FLAG) <= '1';
						async_flags(TIME_RD_FLAG) <= '1';
						
					when TIME_2 =>							-- wait for RAM Op to complete
						async_flags(TIME_CAPTURE_FLAG) <= '1';
					
					when TIME_3 =>							-- Set TX_FIFO_DIN to Amplitude_H 
						async_flags(TIME_H_WR_FLAG) <= '1';
					
					when TIME_4 =>							-- TX_WR_EN
						async_flags(TX_WR_EN_FLAG) <= '1';
						
					when TIME_5 =>							-- Set TX_FIFO_DIN to Amplitude_L 
						async_flags(TIME_L_WR_FLAG) <= '1';
					
					when TIME_6 =>							-- TX_WR_EN
						async_flags(TX_WR_EN_FLAG) <= '1';
			
			when LOOP1_COMPLETE =>
				async_flags(INC_COUNT_FLAG) <= '1';
 	
	
	-- Reply - Checksum	
			when WRITE_CHECKSUM_1 =>
				async_flags(CHECKSUM_WR_FLAG) <= '1';
			
			when WRITE_CHECKSUM_2 =>
				async_flags(TX_WR_EN_FLAG) <= '1';

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;   
 
 
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------		
-- MSG_GET_WAVEFORM state machine
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------    
MSG_GET_WAVEFORM_asynch_state: process(rst_n, curr_state, count, MSG_Start, FIFO_EMPTY, reply_header_length, num_samples, RAM_Op_Done)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if MSG_Start = '1' then
					next_state <= VALIDATE_MSG;
				else
					next_state <= IDLE;
				end if;
						
			when VALIDATE_MSG =>
				next_state <= REPLY_HEADER_SET;
				
------------------------------------------------------------------------------------------------------------------		
-- Message Reply
------------------------------------------------------------------------------------------------------------------		
	-- Reply Header
			when REPLY_HEADER_SET =>
				next_state <= REPLY_HEADER_SEND;
			
			when REPLY_HEADER_SEND =>
				if count = reply_header_length then
					next_state <= NUM_SAMPLES_1;
				else
					next_state <= REPLY_HEADER_SET;
				end if;
			
	-- Reply - num_samples		
			when NUM_SAMPLES_1 =>						-- Start read from RAM for num_samples
				next_state <= NUM_SAMPLES_2;
			
			when NUM_SAMPLES_2 =>						-- wait for RAM Op to complete
				if RAM_Op_Done = '1' then
					next_state <= NUM_SAMPLES_3;
				else
					next_state <= NUM_SAMPLES_2;
				end if;
			
			when NUM_SAMPLES_3 =>						-- Set TX_FIFO_DIN to num_samples
				next_state <= NUM_SAMPLES_4;
			
			when NUM_SAMPLES_4 =>						-- TX_WR_EN
				next_state <= LOOP1;
			
	-- Reply - Loop1 - Amplitude:Time Pairs
			when LOOP1 =>
				if count = num_samples then
					next_state <= WRITE_CHECKSUM_1;
				else
					next_state <= AMPLITUDE_1;
				end if;
					
			-- Read Amplitude from RAM and write to TX_FIFO		
					when AMPLITUDE_1 =>					-- Start read from RAM for Amplitude
						next_state <= AMPLITUDE_2;
						
					when AMPLITUDE_2 =>					-- wait for RAM Op to complete
						if RAM_Op_Done = '1' then
							next_state <= AMPLITUDE_3;
						else
							next_state <= AMPLITUDE_2;
						end if;
					
					when AMPLITUDE_3 =>					-- Set TX_FIFO_DIN to Amplitude_H 
						next_state <= AMPLITUDE_4;
					
					when AMPLITUDE_4 =>					-- TX_WR_EN
						next_state <= AMPLITUDE_5;
						
					when AMPLITUDE_5 =>					-- Set TX_FIFO_DIN to Amplitude_L 
						next_state <= AMPLITUDE_6;
					
					when AMPLITUDE_6 =>					-- TX_WR_EN
						next_state <= TIME_1;
			
			-- Read Time from RAM and write to TX_FIFO	
					when TIME_1 =>							-- Start read from RAM for Amplitude
						next_state <= TIME_2;
						
					when TIME_2 =>							-- wait for RAM Op to complete
						if RAM_Op_Done = '1' then
							next_state <= TIME_3;
						else
							next_state <= TIME_2;
						end if;
					
					when TIME_3 =>							-- Set TX_FIFO_DIN to Amplitude_H 
						next_state <= TIME_4;
					
					when TIME_4 =>							-- TX_WR_EN
						next_state <= TIME_5;
						
					when TIME_5 =>							-- Set TX_FIFO_DIN to Amplitude_L 
						next_state <= TIME_6;
					
					when TIME_6 =>							-- TX_WR_EN
						next_state <= LOOP1_COMPLETE;
			
			when LOOP1_COMPLETE =>
				next_state <= LOOP1;
	
	
	-- Reply - Checksum	
			when WRITE_CHECKSUM_1 =>
				next_state <= WRITE_CHECKSUM_2;
			
			when WRITE_CHECKSUM_2 =>
				next_state <= FINISH;
	
	
			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


