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

use work.MSG_SET_WAVEFORM_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MSG_SET_WAVEFORM_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			MSG_Start					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;	
			RAM_Op_Done					: in  STD_LOGIC;
			reply_length				: in  STD_LOGIC_VECTOR(7 downto 0);
			num_samples					: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);		
end MSG_SET_WAVEFORM_states;

architecture Behavioral of MSG_SET_WAVEFORM_states is

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
MSG_SET_WAVEFORM_state: process(rst_n, curr_state, reply_length, count)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
-- Message Request Payload and Checksum			
			
			when NUM_SAMPLES_2 =>    	-- read from RX_FIFO
				async_flags(NUM_SAMPLES_RD_FLAG) <= '1';
				
			when NUM_SAMPLES_3 =>	 	-- inc fifo and start mem op (set all inputs and trigger start op)
				async_flags(RX_RD_EN_FLAG) <= '1';
				async_flags(START_MEM_OP_FLAG) <= '1';
				async_flags(NUM_SAMPLES_WR_FLAG) <= '1';
				--async_flags(TX_WR_EN_FLAG) <= '1';  --adding rs232 loopback for debug
				
-- Loop Amplitude:Time read from RX_FIFO and Write to RAM
			when LOOP1 =>
			
			-- Read Amplitude and Write to RAM (amplitude is 16 bits, high and low bytes are read from RX FIFO and written to RAM)
						
					when AMPLITUDE_H_2 =>				-- read Amplitude high byte
						async_flags(AMPLITUDE_H_RD_FLAG) <= '1';
					
					when AMPLITUDE_H_3 => 				-- inc fifo
						async_flags(RX_RD_EN_FLAG) <= '1';
						--async_flags(TX_WR_EN_FLAG) <= '1';  --adding rs232 loopback for debug

					when AMPLITUDE_L_2 =>				-- read Amplitude low byte
						async_flags(AMPLITUDE_L_RD_FLAG) <= '1';
					
					when AMPLITUDE_L_3 => 				-- inc fifo and start mem op (set all inputs and trigger start op)
						async_flags(RX_RD_EN_FLAG) <= '1';
						async_flags(START_MEM_OP_FLAG) <= '1';
						async_flags(AMPLITUDE_WR_FLAG) <= '1';
						--async_flags(TX_WR_EN_FLAG) <= '1';  --adding rs232 loopback for debug

			-- Read Time and Write to RAM (Time is 16 bits, high and low bytes are read from RX FIFO and written to RAM)	
	
					when TIME_H_2 =>						-- read Time high byte
						async_flags(TIME_H_RD_FLAG) <= '1';
					
					when TIME_H_3 => 						-- inc fifo
						async_flags(RX_RD_EN_FLAG) <= '1';
						--async_flags(TX_WR_EN_FLAG) <= '1';  --adding rs232 loopback for debug
					
					when TIME_L_2 =>						-- read Time low byte
						async_flags(TIME_L_RD_FLAG) <= '1';
					
					when TIME_L_3 => 						-- inc fifo and start mem op (set all inputs and trigger start op)
						async_flags(RX_RD_EN_FLAG) <= '1';
						async_flags(START_MEM_OP_FLAG) <= '1';
						async_flags(TIME_WR_FLAG) <= '1';
						--async_flags(TX_WR_EN_FLAG) <= '1';  --adding rs232 loopback for debug
						
			
			when LOOP1_END =>
				async_flags(INC_COUNT_FLAG) <= '1';
				
			when VALIDATE_MSG =>
				async_flags(CLEAR_COUNT_FLAG) <= '1';
	
	
-- Message Reply
			when SET_REPLY_BYTE =>
				async_flags(SET_REPLY_BYTE_FLAG) <= '1';
				
			
			when SEND_REPLY_BYTE =>
				if(count = reply_length) then
				else
					async_flags(TX_WR_EN_FLAG) <= '1';
					async_flags(INC_COUNT_FLAG) <= '1';
				end if;

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;   
 
  
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------		
-- MSG_SET_WAVEFORM state machine
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------    
MSG_SET_WAVEFORM_asynch_state: process(rst_n, curr_state, count, MSG_Start, FIFO_EMPTY, reply_length, num_samples, RAM_Op_Done)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if MSG_Start = '1' then
					next_state <= NUM_SAMPLES_1;
				else
					next_state <= IDLE;
				end if;
				
-- Read Num Samples and Write to RAM
			when NUM_SAMPLES_1 =>		-- wait for byte in RX_FIFO
				if FIFO_EMPTY = '0' then
					next_state <= NUM_SAMPLES_2;
				else
					next_state <= NUM_SAMPLES_1;
				end if;
			
			when NUM_SAMPLES_2 =>    	-- read
				next_state <= NUM_SAMPLES_3;
				
			when NUM_SAMPLES_3 =>	 	-- inc fifo and start mem op (set all inputs and trigger start op)
				next_state <= NUM_SAMPLES_4;
			
			when NUM_SAMPLES_4 =>			-- wait for mem op to complete
				if RAM_Op_Done = '1' then
					next_state <= LOOP1;
				else
					next_state <= NUM_SAMPLES_4;
				end if;
				
-- Loop Amplitude:Time read from RX_FIFO and Write to RAM
			when LOOP1 =>
				if count = num_samples then
					next_state <= VALIDATE_MSG;
				else
					next_state <= AMPLITUDE_H_1;
				end if;
			
			-- Read Amplitude and Write to RAM (amplitude is 16 bits, high and low bytes are read from RX FIFO and written to RAM)
			
					when AMPLITUDE_H_1 => 				 -- wait for amplitude high byte in RX_FIFO
						if FIFO_EMPTY = '0' then
							next_state <= AMPLITUDE_H_2;
						else
							next_state <= AMPLITUDE_H_1;
						end if;
						
					when AMPLITUDE_H_2 =>				-- read Amplitude high byte
						next_state <= AMPLITUDE_H_3;
					
					when AMPLITUDE_H_3 => 				-- inc fifo
						next_state <= AMPLITUDE_H_4;
					
					when AMPLITUDE_H_4 => 				-- delay state to allow FIFO_EMPTY to be set after inc_fifo
						next_state <= AMPLITUDE_H_5;
					when AMPLITUDE_H_5 => 				-- delay state to allow FIFO_EMPTY to be set after inc_fifo
						next_state <= AMPLITUDE_L_1;
						
					when AMPLITUDE_L_1 => 				-- wait for amplitude low byte in RX_FIFO
						if FIFO_EMPTY = '0' then
							next_state <= AMPLITUDE_L_2;
						else
							next_state <= AMPLITUDE_L_1;
						end if;
					
					when AMPLITUDE_L_2 =>				-- read Amplitude low byte
						next_state <= AMPLITUDE_L_3;
					
					when AMPLITUDE_L_3 => 				-- inc fifo and start mem op (set all inputs and trigger start op)
						next_state <= AMPLITUDE_L_4;
						
					when AMPLITUDE_L_4 =>				-- wait for mem op to complete
						if RAM_Op_Done = '1' then
							next_state <= TIME_H_1;
						else
							next_state <= AMPLITUDE_L_4;
						end if;	
				
				
			-- Read Time and Write to RAM (Time is 16 bits, high and low bytes are read from RX FIFO and written to RAM)	

					when TIME_H_1 => 				 		-- wait for Time high byte in RX_FIFO
						if FIFO_EMPTY = '0' then
							next_state <= TIME_H_2;
						else
							next_state <= TIME_H_1;
						end if;
						
					when TIME_H_2 =>						-- read Time high byte
						next_state <= TIME_H_3;
					
					when TIME_H_3 => 						-- inc fifo
						next_state <= TIME_H_4;
					
					when TIME_H_4 => 						-- delay state to allow FIFO_EMPTY to be set after inc_fifo
						next_state <= TIME_H_5;
						
					when TIME_H_5 => 						-- delay state to allow FIFO_EMPTY to be set after inc_fifo
						next_state <= TIME_L_1;
						
					when TIME_L_1 => 						-- wait for Time low byte in RX_FIFO
						if FIFO_EMPTY = '0' then
							next_state <= TIME_L_2;
						else
							next_state <= TIME_L_1;
						end if;
					
					when TIME_L_2 =>						-- read Time low byte
						next_state <= TIME_L_3;
					
					when TIME_L_3 => 						-- inc fifo and start mem op (set all inputs and trigger start op)
						next_state <= TIME_L_4;
						
					when TIME_L_4 =>						-- wait for mem op to complete
						if RAM_Op_Done = '1' then
							next_state <= LOOP1_END;
						else
							next_state <= TIME_L_4;
						end if;
			
			when LOOP1_END =>
				next_state <= LOOP1;
						

			when VALIDATE_MSG =>
				next_state <= SET_REPLY_BYTE;
				
------------------------------------------------------------------------------------------------------------------		
-- Message Reply
------------------------------------------------------------------------------------------------------------------		
	
			when SET_REPLY_BYTE =>
				next_state <= SEND_REPLY_BYTE;
			
			when SEND_REPLY_BYTE =>
				if count = reply_length then
					next_state <= FINISH;
				else
					next_state <= SET_REPLY_BYTE;
				end if;

			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


