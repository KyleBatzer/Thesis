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

use work.RX_Module_pkg.all;

entity RX_Module is
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  RX						: in  STD_LOGIC;
			  RX_led					: out STD_LOGIC;
			  
			  -- RX_FIFO Signals
			  FIFO_WR_CLK			: out  STD_LOGIC;
			  FIFO_DIN				: out  STD_LOGIC_VECTOR (7 downto 0);
			  FIFO_WR_EN			: out  STD_LOGIC
			  );
end RX_Module;

architecture Behavioral of RX_Module is

signal async_flags					: STD_LOGIC_VECTOR(5 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);
signal baud_count						: STD_LOGIC_VECTOR(15 downto 0);

signal received_byte					: STD_LOGIC_VECTOR(7 downto 0);

component RX_Module_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RX			 					: in  STD_LOGIC;
			baud_count					: in  STD_LOGIC_VECTOR(15 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);	
end component;

begin

FIFO_WR_CLK <= clk;

RX_led <= not async_flags(IDLE_FLAG);

FIFO_DIN <= received_byte;

-- received_byte
process(clk, reset) 
begin
   if reset = '0' then
		received_byte <= (others => '0');
   elsif rising_edge(clk) and async_flags(CAPTURE_BYTE_FLAG) = '1' then		
		--received_byte <= RX & received_byte(7 downto 1);
		case count is    
			when x"00" =>				received_byte(0) <= RX;
			when x"01" =>				received_byte(1) <= RX;
			when x"02" =>				received_byte(2) <= RX;
			when x"03" =>				received_byte(3) <= RX;			
			when x"04" =>				received_byte(4) <= RX;
			when x"05" =>				received_byte(5) <= RX;
			when x"06" =>				received_byte(6) <= RX;
			when x"07" =>				received_byte(7) <= RX;
			when OTHERS =>				
		end case;
	end if;
end process; 

-- FIFO_WR_EN
process(clk, reset) 
begin
   if reset = '0' then
		FIFO_WR_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(WR_EN_FLAG) = '1' then		
			FIFO_WR_EN <= '1';
		else
			FIFO_WR_EN <= '0';
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RX_Module_states ---------------------------------------
-------------------------------------------------------------------------------

states : RX_Module_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	RX									=> RX,	
	baud_count						=> baud_count,
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
		end if;
	end if;
end process; 

-- baud_count
process(clk, reset) 
begin
   if reset = '0' then
		baud_count <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(INC_BAUD_COUNT_FLAG) = '1' then
			baud_count <= baud_count + 1;
		elsif async_flags(CLEAR_BAUD_COUNT_FLAG) = '1' then
			baud_count <= (others => '0');
		elsif async_flags(IDLE_FLAG) = '1' then
			baud_count <= (others => '0');
		end if;
	end if;
end process; 


end Behavioral;

