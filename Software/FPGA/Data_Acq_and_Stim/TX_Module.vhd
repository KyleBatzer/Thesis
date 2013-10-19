----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:44:35 01/27/2012 
-- Design Name: 
-- Module Name:    ADC_Module - Behavioral 
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

use work.TX_Module_pkg.all;

entity TX_Module is
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  TX						: out STD_LOGIC;
			  TX_led					: out STD_LOGIC;
			  
			  -- TX_FIFO Signals
			  FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  FIFO_RD_EN			: out STD_LOGIC;
			  FIFO_EMPTY			: in  STD_LOGIC
			  );
end TX_Module;

architecture Behavioral of TX_Module is

signal async_flags					: STD_LOGIC_VECTOR(5 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);



component TX_Module_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			FIFO_EMPTY 					: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);	
end component;

begin

TX_led <= not async_flags(IDLE_FLAG);	 

-- TX
process(clk, reset) 
begin
   if reset = '0' then
		TX <= '1';
   elsif rising_edge(clk) then		
		if async_flags(START_BIT_FLAG) = '1' then
			TX <='0';
		elsif async_flags(SEND_BYTE_FLAG) = '1' then
			case count is
				when x"00" =>				TX <= FIFO_DOUT(0);
				when x"01" =>				TX <= FIFO_DOUT(1);
				when x"02" =>				TX <= FIFO_DOUT(2);
				when x"03" =>				TX <= FIFO_DOUT(3);		
				when x"04" =>				TX <= FIFO_DOUT(4);
				when x"05" =>				TX <= FIFO_DOUT(5);
				when x"06" =>				TX <= FIFO_DOUT(6);
				when x"07" =>				TX <= FIFO_DOUT(7);
				when OTHERS =>				
			end case;
		elsif async_flags(END_BIT_FLAG) = '1' then
			TX <= '1';
		else
			TX <= '1';
		end if;
	end if;
end process; 

-- FIFO_RD_EN
process(clk, reset) 
begin
   if reset = '0' then
		FIFO_RD_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(RD_EN_FLAG) = '1' then		
			FIFO_RD_EN <= '1';
		else
			FIFO_RD_EN <= '0';
		end if;
	end if;
end process;
	





-------------------------------------------------------------------------------
---------------------- TX_Module_states ---------------------------------------
-------------------------------------------------------------------------------

states : TX_Module_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	FIFO_EMPTY						=> FIFO_EMPTY,	
	count								=> count,
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
		elsif async_flags(END_BIT_FLAG) = '1' then
			count <= x"00";
		end if;
	end if;
end process; 


end Behavioral;

