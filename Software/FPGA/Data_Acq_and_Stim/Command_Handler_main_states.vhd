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

use work.Command_Handler_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Command_Handler_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;	
			MSG_Complete				: in  STD_LOGIC;			
			RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);		
end Command_Handler_states;

architecture Behavioral of Command_Handler_states is

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
Command_Handler_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
			when CHECK_START => 
				async_flags(INC_COUNT_FLAG) <= '1';
				async_flags(RX_RD_EN_FLAG) <= '1';
		
		
-- Message Handler
			when READ_MESSAGE =>
				async_flags(READ_MESSAGE_FLAG) <= '1';
				
			when INC_RX_FIFO =>
				async_flags(INC_COUNT_FLAG) <= '1';
				async_flags(RX_RD_EN_FLAG) <= '1';
				--async_flags(TX_WR_EN_FLAG) <= '1';  -- uncomment to enable TX loopback of incoming messages (except for start byte)
			
			when PAYLOAD_START =>
				async_flags(PAYLOAD_START_FLAG) <= '1';
					
			when PAYLOAD =>
				async_flags(PAYLOAD_FLAG) <= '1';		
	
	

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;   
 
  
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------		
-- Command_Handler state machine
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------    
Command_Handler_asynch_state: process(rst_n, curr_state, count, RX_FIFO_DOUT, FIFO_EMPTY, MSG_Complete)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if FIFO_EMPTY = '0' then
					next_state <= CHECK_START;
				else
					next_state <= IDLE;
				end if;
				
			when CHECK_START => 
				if RX_FIFO_DOUT = x"5A" then
					next_state <= DELAY_STATE;
				else
					next_state <= FINISH;
				end if;
		
------------------------------------------------------------------------------------------------------------------		
-- Message Handler States
	
	-- DELAY_STATE: 				provides enough time for FIFO_EMPTY to go high after RX_RD_EN is set
	
	-- WAIT_FOR_NEXT_BYTE:  	wait for FIFO to have next byte
	
	-- READ_MESSAGE:				assigns RX_FIFO_DOUT to appropriate registers based on count
	
	-- INC_RX_FIFO:				increment FIFO
	
	-- VALIDATE_MSG:				currently only used to clear count.  will be used for checksum.
------------------------------------------------------------------------------------------------------------------
			when DELAY_STATE => 				 
				if count = 5 then
					next_state <= PAYLOAD_START;
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


------------------------------------------------------------------------------------------------------------------
-- process payload and send reply
------------------------------------------------------------------------------------------------------------------
			when PAYLOAD_START =>
				next_state <= PAYLOAD;
					
			when PAYLOAD =>
				if MSG_Complete = '1' then
					next_state <= FINISH;
				else
					next_state <= PAYLOAD;
				end if;
				
				


			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


