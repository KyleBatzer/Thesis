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

use work.RAM_Module_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RAM_Module_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RAM_Start_Op				: in  STD_LOGIC;			--start S.M. into motion
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			init_counter				: in  STD_LOGIC_VECTOR(15 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(4 downto 0)	--flags to enable functions
			);		
end RAM_Module_states;

architecture Behavioral of RAM_Module_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := RAM_RESET;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := RAM_RESET;  -- FSM next state
     
begin
-------------------------------------------------------------------------------
		-- synchronous part of state machine here
data_in_latch: process(clk, rst_n)
begin
   if rst_n = '0' then
		curr_state <= RAM_RESET;
   elsif rising_edge(clk) then
		curr_state <= next_state;
   end if;
end process;

		-- async part of state machine to set function flags
RAM_Module_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when RAM_RESET =>
				async_flags(RAM_RESET_FLAG) <= '1';
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
			when PERFORM_OP =>
				async_flags(PERFORM_OP_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
				async_flags(INC_COUNT_FLAG) <= '1';
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- RAM_Module state machine 
RAM_Module_asynch_state: process(rst_n, curr_state, RAM_Start_Op, count, init_counter)
begin
   if rst_n = '0' then
		next_state <= RAM_RESET;    
   else
		case curr_state is 
			when RAM_RESET =>
				if init_counter = x"1D4B" then
					next_state <= IDLE;
				else
					next_state <= RAM_RESET;
				end if;
		
   		when IDLE =>					
				if RAM_Start_Op = '1' then
					next_state <= PERFORM_OP;
				else
					next_state <= IDLE;
				end if;
			
			when PERFORM_OP =>
				if count = 5 then
					next_state <= FINISH;
				else
					next_state <= PERFORM_OP;
				end if;
			
				
		 	
		
			when FINISH =>
				--if count = 8 then
					next_state <= IDLE;
				--else
					--next_state <= FINISH;
				--end if;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


