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

use work.ADC_Capture_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADC_Capture_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			ADC_Capture_start			: in  STD_LOGIC;			--start S.M. into motion
			Busy							: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			reset_counter				: in  STD_LOGIC_VECTOR(23 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(6 downto 0)	--flags to enable functions
			);		
end ADC_Capture_states;

architecture Behavioral of ADC_Capture_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := ADC_RESET;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := ADC_RESET;  -- FSM next state
     
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
ADC_Capture_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			
			when ADC_RESET =>
				async_flags(ADC_RESET_FLAG) <= '1';
			
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
			when CONVST => 
				async_flags(CONVST_FLAG) <= '1';
				
			when CAPTURE_1 => 
				async_flags(SET_CS_FLAG) <= '1';
			
			when CAPTURE_2 => 
				async_flags(SET_CS_FLAG) <= '1';
				async_flags(CAPTURE_DATA_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- ADC_Capture state machine 
ADC_Capture_asynch_state: process(rst_n, curr_state, ADC_Capture_start, count, Busy, reset_counter)
begin
   if rst_n = '0' then
		next_state <= ADC_RESET;    
   else
		case curr_state is 
			when ADC_RESET =>
				if reset_counter = x"0249F0" then
					next_state <= IDLE;
				else
					next_state <= ADC_RESET;
				end if;
		
   		when IDLE =>					
				if ADC_Capture_start = '1' then
					next_state <= CONVST;
				else
					next_state <= IDLE;
				end if;
				
			when CONVST => 
				next_state <= WAIT_BUSY_HIGH;
				
			when WAIT_BUSY_HIGH => 
				if Busy = '1' then --commment for internal data
					next_state <= WAIT_BUSY_LOW;
				else
					next_state <= WAIT_BUSY_HIGH;
				end if;
			
			when WAIT_BUSY_LOW => 
				if Busy = '0' then --commment for internal data
					next_state <= CAPTURE_1;
				else
					next_state <= WAIT_BUSY_LOW;
				end if;
				
			when CAPTURE_1 => 
				next_state <= CAPTURE_2;
			
			when CAPTURE_2 => 
				if count = 31 then -- 31 for 4 channel model
					next_state <= FINISH;
				else
					next_state <= CAPTURE_2;
				end if;
				
			
		
			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        


