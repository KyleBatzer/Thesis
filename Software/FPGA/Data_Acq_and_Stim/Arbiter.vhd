----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:44:35 01/27/2012 
-- Design Name: 
-- Module Name:    Arbiter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.Arbiter_pkg.all;

entity Arbiter is
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  Bus_Request				: in  STD_LOGIC_VECTOR(7 downto 0);
			  Bus_Busy					: in  STD_LOGIC;
			  
			  Bus_Grant					: out  STD_LOGIC_VECTOR(7 downto 0)
			  );
end Arbiter;

architecture Behavioral of Arbiter is

signal async_flags					: STD_LOGIC_VECTOR(3 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

-------------------------------------------------------------------------------
---------------------- Arbiter_states --------------------------------------
-------------------------------------------------------------------------------

component Arbiter_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			Bus_Request					: in  STD_LOGIC_VECTOR(7 downto 0);
			Bus_Busy						: in  STD_LOGIC;
			async_flags					: out STD_LOGIC_VECTOR(3 downto 0)	--flags to enable functions
			);	
end component;


begin

-- count
process(clk, reset) 
begin
   if reset = '0' then
		Bus_Grant <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(SET_BG_FLAG) = '1' then
			if Bus_Request(0) = '1' then
				Bus_Grant(0) <= '1';
			elsif Bus_Request(1) = '1' then
				Bus_Grant(1) <= '1';
			elsif Bus_Request(2) = '1' then
				Bus_Grant(2) <= '1';
			elsif Bus_Request(3) = '1' then
				Bus_Grant(3) <= '1';
			elsif Bus_Request(4) = '1' then
				Bus_Grant(4) <= '1';
			elsif Bus_Request(5) = '1' then
				Bus_Grant(5) <= '1';
			elsif Bus_Request(6) = '1' then
				Bus_Grant(6) <= '1';
			elsif Bus_Request(7) = '1' then
				Bus_Grant(7) <= '1';
			end if;
				
		elsif async_flags(CLEAR_BG_FLAG) = '1' then
			Bus_Grant <= (others => '0');
		end if;
	end if;
end process; 

-------------------------------------------------------------------------------
---------------------- Arbiter_states -----------------------------------------
-------------------------------------------------------------------------------

states : Arbiter_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	count								=> count,
	Bus_Request						=> Bus_Request,
	Bus_Busy							=> Bus_Busy,
	async_flags						=> async_flags
	);

-------------------------------------------------------------------------------
---------------------- Counter ------------------------------------------------
-------------------------------------------------------------------------------

-- count
process(clk, reset) 
begin
   if reset = '0' then
		count <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(INC_COUNT_FLAG) = '1' then
			count <= count + 1;
		elsif async_flags(IDLE_FLAG) = '1' then
			count <= x"00";
		end if;
	end if;
end process; 


end Behavioral;

