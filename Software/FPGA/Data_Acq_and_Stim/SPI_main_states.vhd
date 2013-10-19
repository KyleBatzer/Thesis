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
-- Description:   This module contains the S.M. to control functions of pred_lt3. 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.SPI_pkg.all;

---- Uncomment the following library declaration if instantiating    
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SPI_states is    
Port ( 	clk       				: in  STD_LOGIC;
			rst	     				: in  STD_LOGIC;
			SPI_start 				: in  STD_LOGIC;			--start S.M. into motion
		--	count						: in  STD_LOGIC_VECTOR(4 downto 0);
			async_flags				: out STD_LOGIC_VECTOR(33 downto 0)	--flags to enable functions
			  );	
end SPI_states;

architecture Behavioral of SPI_states is

		--Control signals

signal curr_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM current state
signal next_state 	: std_logic_vector(7 downto 0) := IDLE;  -- FSM next state
     
begin
-------------------------------------------------------------------------------
		-- synchronous part of state machine here
data_in_latch: process(clk, rst)
begin
   if rst = '0' then
		curr_state <= (others => '0');
   elsif rising_edge(clk) then
		curr_state <= next_state;
   end if;
end process;

		-- async part of state machine to set function flags
SPI_state: process(rst, curr_state)
begin
   if rst = '0' then
		async_flags <= (others => '0');    
   else
		async_flags <= (others => '0');
		case curr_state is
			when IDLE =>
				async_flags(INIT_FLAG) <= '1';
			--when OUTPUT_DATA =>
				--async_flags(OUTPUT_FLAG) <= '1';
			
			when OUTPUT_B31 =>
				async_flags(B31_FLAG) <= '1';
			when OUTPUT_B30 =>
				async_flags(B30_FLAG) <= '1';
			when OUTPUT_B29 =>
				async_flags(B29_FLAG) <= '1';
			when OUTPUT_B28 =>
				async_flags(B28_FLAG) <= '1';
			when OUTPUT_B27 =>
				async_flags(B27_FLAG) <= '1';
			when OUTPUT_B26 =>
				async_flags(B26_FLAG) <= '1';
			when OUTPUT_B25 =>
				async_flags(B25_FLAG) <= '1';
			when OUTPUT_B24 =>
				async_flags(B24_FLAG) <= '1';
			when OUTPUT_B23 =>
				async_flags(B23_FLAG) <= '1';
			when OUTPUT_B22 =>
				async_flags(B22_FLAG) <= '1';
			when OUTPUT_B21 =>
				async_flags(B21_FLAG) <= '1';
			when OUTPUT_B20 =>
				async_flags(B20_FLAG) <= '1';
			when OUTPUT_B19 =>
				async_flags(B19_FLAG) <= '1';
			when OUTPUT_B18 =>
				async_flags(B18_FLAG) <= '1';
			when OUTPUT_B17 =>
				async_flags(B17_FLAG) <= '1';
			when OUTPUT_B16 =>
				async_flags(B16_FLAG) <= '1';
			when OUTPUT_B15 =>
				async_flags(B15_FLAG) <= '1';
			when OUTPUT_B14 =>
				async_flags(B14_FLAG) <= '1';
			when OUTPUT_B13 =>
				async_flags(B13_FLAG) <= '1';
			when OUTPUT_B12 =>
				async_flags(B12_FLAG) <= '1';
			when OUTPUT_B11 =>
				async_flags(B11_FLAG) <= '1';
			when OUTPUT_B10 =>
				async_flags(B10_FLAG) <= '1';
			when OUTPUT_B9 =>
				async_flags(B9_FLAG) <= '1';
			when OUTPUT_B8 =>
				async_flags(B8_FLAG) <= '1';
			when OUTPUT_B7 =>
				async_flags(B7_FLAG) <= '1';
			when OUTPUT_B6 =>
				async_flags(B6_FLAG) <= '1';
			when OUTPUT_B5 =>
				async_flags(B5_FLAG) <= '1';
			when OUTPUT_B4 =>
				async_flags(B4_FLAG) <= '1';
			when OUTPUT_B3 =>
				async_flags(B3_FLAG) <= '1';
			when OUTPUT_B2 =>
				async_flags(B2_FLAG) <= '1';
			when OUTPUT_B1 =>
				async_flags(B1_FLAG) <= '1';
			when OUTPUT_B0 =>
				async_flags(B0_FLAG) <= '1';
				
			when TX_COMPLETE =>
				async_flags(DONE_FLAG) <= '1';
			when others =>
				async_flags <= (others => '0');
		end case;
	end if;
end process;    
-------------------------------------------------    
		-- SPI state machine 
SPI_async_state: process(rst, curr_state, SPI_start)
begin
   if rst = '0' then
		next_state <= (others => '0');    
   else
		case curr_state is    
   		
			when IDLE =>					
				if SPI_start = '1' then
					next_state <= OUTPUT_B31;
				else
					next_state <= IDLE;
				end if;
			
--			when OUTPUT_DATA =>
--				if count < 7 then
--					--next_state <= TX_COMPLETE;
--					next_state <= OUTPUT_DATA;
--				else
--					next_state <= TX_COMPLETE;
--					--next_state <= OUTPUT_DATA;
--				end if;
			
			when OUTPUT_B31 =>
				next_state <= OUTPUT_B30;
			when OUTPUT_B30 =>
				next_state <= OUTPUT_B29;
			when OUTPUT_B29 =>
				next_state <= OUTPUT_B28;
			when OUTPUT_B28 =>
				next_state <= OUTPUT_B27;
			when OUTPUT_B27 =>
				next_state <= OUTPUT_B26;
			when OUTPUT_B26 =>
				next_state <= OUTPUT_B25;
			when OUTPUT_B25 =>
				next_state <= OUTPUT_B24;
			when OUTPUT_B24 =>
				next_state <= OUTPUT_B23;
			when OUTPUT_B23 =>
				next_state <= OUTPUT_B22;
			when OUTPUT_B22 =>
				next_state <= OUTPUT_B21;
			when OUTPUT_B21 =>
				next_state <= OUTPUT_B20;
			when OUTPUT_B20 =>
				next_state <= OUTPUT_B19;
			when OUTPUT_B19 =>
				next_state <= OUTPUT_B18;
			when OUTPUT_B18 =>
				next_state <= OUTPUT_B17;
			when OUTPUT_B17 =>
				next_state <= OUTPUT_B16;
			when OUTPUT_B16 =>
				next_state <= OUTPUT_B15;
			when OUTPUT_B15 =>
				next_state <= OUTPUT_B14;
			when OUTPUT_B14 =>
				next_state <= OUTPUT_B13;
			when OUTPUT_B13 =>
				next_state <= OUTPUT_B12;
			when OUTPUT_B12 =>
				next_state <= OUTPUT_B11;
			when OUTPUT_B11 =>
				next_state <= OUTPUT_B10;
			when OUTPUT_B10 =>
				next_state <= OUTPUT_B9;
			when OUTPUT_B9 =>
				next_state <= OUTPUT_B8;
			when OUTPUT_B8 =>
				next_state <= OUTPUT_B7;
			when OUTPUT_B7 =>
				next_state <= OUTPUT_B6;
			when OUTPUT_B6 =>
				next_state <= OUTPUT_B5;
			when OUTPUT_B5 =>
				next_state <= OUTPUT_B4;
			when OUTPUT_B4 =>
				next_state <= OUTPUT_B3;
			when OUTPUT_B3 =>
				next_state <= OUTPUT_B2;
			when OUTPUT_B2 =>
				next_state <= OUTPUT_B1;
			when OUTPUT_B1 =>
				next_state <= OUTPUT_B0;
			when OUTPUT_B0 =>
				next_state <= TX_COMPLETE;
				
			when TX_COMPLETE =>
				--if SPI_start = '0' then
					next_state <= IDLE;
				--else
				--	next_state <= TX_COMPLETE;
				--end if;
			
			when others =>
				next_state <= IDLE;
			
		end case;
   end if;
end process;        


end Behavioral;        

