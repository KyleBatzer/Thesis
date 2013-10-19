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

use work.Arbiter_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Arbiter_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			Bus_Request					: in  STD_LOGIC_VECTOR(7 downto 0);
			Bus_Busy						: in  STD_LOGIC;
			async_flags					: out STD_LOGIC_VECTOR(3 downto 0)	--flags to enable functions
			);	
end Arbiter_states;

architecture Behavioral of Arbiter_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM next state
     
begin
-------------------------------------------------------------------------------
		-- synchronous part of state machine here
data_in_latch: process(clk, rst_n)
begin
   if rst_n = '0' then
		curr_state <= IDLE;
   elsif rising_edge(clk) then
		curr_state <= next_state;
   end if;
end process;

		-- async part of state machine to set function flags
Arbiter_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
		
			when IDLE => 
				async_flags(IDLE_FLAG) <= '1';
				
			when SET_BUS_GRANT => 
				async_flags(SET_BG_FLAG) <= '1';
			
			when WAIT1 =>
				async_flags(INC_COUNT_FLAG) <= '1';
				
			when CLEAR_BUS_GRANT => 
				async_flags(CLEAR_BG_FLAG) <= '1';

			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- Arbiter state machine 
Arbiter_asynch_state: process(rst_n, curr_state, Bus_Request, Bus_Busy, count)
begin
   if rst_n = '0' then
		next_state <= IDLE;    
   else
		case curr_state is    
   		
			when IDLE =>					
				if Bus_Request /= 0 then
					next_state <= SET_BUS_GRANT;
				else
					next_state <= IDLE;
				end if;
				
			when SET_BUS_GRANT => 
				next_state <= WAIT1;
			
			when WAIT1 =>
				if count = 3 then
					next_state <= CLEAR_BUS_GRANT;
				else
					next_state <= WAIT1;
				end if;
				
			when CLEAR_BUS_GRANT => 
				next_state <= WAIT_FOR_BUSY;
			
			when WAIT_FOR_BUSY =>
				if Bus_Busy = '0' then
					next_state <= IDLE;
				else
					next_state <= WAIT_FOR_BUSY;
				end if;
					
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        

