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

use work.ADC_Module_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADC_Module_states is    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			ADC_Module_start			: in  STD_LOGIC;			--start S.M. into motion
			FIFO_Full_Flag				: in  STD_LOGIC;			
			count							: in  STD_LOGIC_VECTOR(9 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);	
end ADC_Module_states;

architecture Behavioral of ADC_Module_states is

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
ADC_Module_state: process(rst_n, curr_state)
begin
   if rst_n = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			when IDLE =>
				async_flags(IDLE_FLAG) <= '1';			-- init
			
						
			when FIFO_WR_2 =>
				async_flags(SET_WR_EN_FLAG) <= '1';
				async_flags(SET_DATA_FLAG) <= '1';
				async_flags(INC_COUNT_FLAG) <= '1';
			

			when FINISH =>
				async_flags(DONE_FLAG) <= '1';			-- done flag
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- ADC_Module state machine 
ADC_Module_asynch_state: process(rst_n, curr_state, ADC_Module_start, count, FIFO_Full_Flag)
begin
   if rst_n = '0' then
		next_state <= (others => '0');    
   else
		case curr_state is    
   		when IDLE =>					
				--if Synch_Slave_FIFO_start = '1' and FlagA = '1' then
				if ADC_Module_start = '1' then
					next_state <= FIFO_WR_1;
				else
					next_state <= IDLE;
				end if;
				
			when FIFO_WR_1 =>
				if FIFO_Full_Flag = '0' then  -- mapped to prog_full - 32256
					next_state <= FIFO_WR_2;
				else
					next_state <= FIFO_WR_1;
				end if;
			when FIFO_WR_2 =>
				if count = 31 then
					next_state <= FINISH;
				else
					next_state <= FIFO_WR_2;
				end if;
		
			when FINISH =>
					next_state <= IDLE;
				
			when OTHERS =>
				next_state <= IDLE;
		end case;
   end if;
end process;        


end Behavioral;        

