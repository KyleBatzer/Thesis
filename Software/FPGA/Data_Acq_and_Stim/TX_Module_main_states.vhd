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

use work.TX_Module_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TX_Module_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;		
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);		
end TX_Module_states;

architecture Behavioral of TX_Module_states is

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
TX_Module_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
				
			when START_BIT => 
				async_flags(START_BIT_FLAG) <= '1';
				
			when SEND_BYTE => 
				async_flags(SEND_BYTE_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			
			when END_BIT => 
				async_flags(END_BIT_FLAG) <= '1';
				
			when INC_FIFO => 
				async_flags(RD_EN_FLAG) <= '1';
				
			when INTER_BYTE_DELAY =>
				async_flags(INC_COUNT_FLAG) <= '1';
			
			when FINISH =>
				--async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- TX_Module state machine 
TX_Module_asynch_state: process(rst_n, curr_state, FIFO_EMPTY, count)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if FIFO_EMPTY = '0' then
					next_state <= START_BIT;
				else
					next_state <= IDLE;
				end if;
				
			when START_BIT => 
				next_state <= SEND_BYTE;
				
			when SEND_BYTE => 
				if count = 7 then
					next_state <= END_BIT;
				else
					next_state <= SEND_BYTE;
				end if;
			
			when END_BIT => 
				next_state <= INC_FIFO;
				
			when INC_FIFO => 
				next_state <= INTER_BYTE_DELAY;
			
			when INTER_BYTE_DELAY => 
				if count = 10 then
					next_state <= FINISH;
				else
					next_state <= INTER_BYTE_DELAY;
				end if;

			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


