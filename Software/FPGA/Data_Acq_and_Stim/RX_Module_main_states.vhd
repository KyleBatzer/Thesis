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

use work.RX_Module_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RX_Module_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RX								: in  STD_LOGIC;		
			baud_count					: in  STD_LOGIC_VECTOR(15 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);		
end RX_Module_states;

architecture Behavioral of RX_Module_states is

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
RX_Module_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
				--async_flags(CAPTURE_BYTE_FLAG) <= '1';
				
			when WAIT_BAUD => 
				async_flags(INC_BAUD_COUNT_FLAG) <= '1';
				
			when WAIT_BAUD2 => 
				async_flags(INC_BAUD_COUNT_FLAG) <= '1';
			
			when CAPTURE_BYTE => 
				async_flags(CAPTURE_BYTE_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
				async_flags(CLEAR_BAUD_COUNT_FLAG) <= '1';
			
			when WRITE_TO_FIFO => 
				async_flags(WR_EN_FLAG) <= '1';
				
			when WAIT_BAUD3 => 
				async_flags(INC_BAUD_COUNT_FLAG) <= '1';
			
			
			when FINISH =>
				--async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- RX_Module state machine 
RX_Module_asynch_state: process(rst_n, curr_state, RX, count, baud_count)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if RX = '0' then
					next_state <= WAIT_BAUD;
				else
					next_state <= IDLE;
				end if;
			
			when WAIT_BAUD => 
				if baud_count = x"028B"	then
					next_state <= CAPTURE_BYTE;
				else
					next_state <= WAIT_BAUD;
				end if;
			when WAIT_BAUD2 => 
				if baud_count = x"01B2" then
					next_state <= CAPTURE_BYTE;
				else
					next_state <= WAIT_BAUD2;
				end if;
				
			when CAPTURE_BYTE => 
				if count = x"07" then
					next_state <= WAIT_BAUD3;
				else
					next_state <= WAIT_BAUD2;
				end if;
				
			when WAIT_BAUD3 => 
				if baud_count = x"00FA" then
					next_state <= WRITE_TO_FIFO;
				else
					next_state <= WAIT_BAUD3;
				end if;
			
			when WRITE_TO_FIFO => 
				next_state <= FINISH;

			when FINISH =>
				--if RX = '1' then
					next_state <= IDLE;
				--else
				--	next_state <= FINISH;
				--end if;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


