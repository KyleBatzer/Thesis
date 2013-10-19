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

use work.RS232_Test_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RS232_Test_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RX_FIFO_EMPTY				: in  STD_LOGIC;		
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);		
end RS232_Test_states;

architecture Behavioral of RS232_Test_states is

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
RS232_Test_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when IDLE =>
				--async_flags(IDLE_FLAG) <= '1';			-- init
				--async_flags(CAPTURE_BYTE_FLAG) <= '1';

			when RX_TO_TX => 
				async_flags(TX_WR_EN_FLAG) <= '1';
				async_flags(RX_RD_EN_FLAG) <= '1';

			when FINISH =>
				--async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- RS232_Test state machine 
RS232_Test_asynch_state: process(rst_n, curr_state, RX_FIFO_EMPTY)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is 
   		when IDLE =>					
				if RX_FIFO_EMPTY = '0' then
					next_state <= RX_TO_TX;
				else
					next_state <= IDLE;
				end if;
			
			when RX_TO_TX => 
				next_state <= WAIT_1;
				
			when WAIT_1 =>
				next_state <= WAIT_2;
			when WAIT_2 =>
				next_state <= WAIT_3;
			when WAIT_3 =>
				next_state <= FINISH;	
		
			when FINISH =>
				next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


