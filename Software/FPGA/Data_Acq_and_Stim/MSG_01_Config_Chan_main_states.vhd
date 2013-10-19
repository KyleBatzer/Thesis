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

use work.MSG_01_Config_Chan_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MSG_01_Config_Chan_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			MSG_Start					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;		
			reply_length				: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);		
end MSG_01_Config_Chan_states;

architecture Behavioral of MSG_01_Config_Chan_states is

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
MSG_01_Config_Chan_state: process(rst_n, curr_state, reply_length, count)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
-- Message Request Payload and Checksum			
			when READ_MESSAGE =>
				async_flags(READ_MESSAGE_FLAG) <= '1';
				
			when INC_RX_FIFO =>
					async_flags(INC_COUNT_FLAG) <= '1';
					async_flags(RX_RD_EN_FLAG) <= '1';
					--async_flags(TX_WR_EN_FLAG) <= '1';  -- uncomment to enable TX loopback of incoming messages (except for start byte)
			
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
-- MSG_01_ConfigChan state machine
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------    
MSG_01_Config_Chan_asynch_state: process(rst_n, curr_state, count, MSG_Start, FIFO_EMPTY, reply_length)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if MSG_Start = '1' then
					next_state <= DELAY_STATE;
				else
					next_state <= IDLE;
				end if;
				
			when DELAY_STATE => 				 
				if count = 2 then
					next_state <= VALIDATE_MSG;
				else
					next_state <= WAIT_FOR_NEXT_BYTE;
				end if;
				
			when WAIT_FOR_NEXT_BYTE =>		
				if FIFO_EMPTY = '0' then
					next_state <= READ_MESSAGE;
				else
					next_state <= WAIT_FOR_NEXT_BYTE;
				end if;

			when READ_MESSAGE =>				 
				next_state <= INC_RX_FIFO; 
				
			when INC_RX_FIFO =>				 
				next_state <= DELAY_STATE;

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


