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

use work.RS232_Test_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232_Test is
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  
			  RX							: in  STD_LOGIC;
			  TX							: out STD_LOGIC;
			  RX_led						: out STD_LOGIC;
			  TX_led						: out STD_LOGIC
			  );
end RS232_Test;

architecture Behavioral of RS232_Test is

signal async_flags					: STD_LOGIC_VECTOR(5 downto 0);

-------------------------------------------------------------------------------
---------------------- RS232_Module -------------------------------------------
-------------------------------------------------------------------------------
signal RX_FIFO_RD_CLK				: STD_LOGIC; 
signal RX_FIFO_DOUT					: STD_LOGIC_VECTOR (7 downto 0);
signal RX_FIFO_RD_EN					: STD_LOGIC;
signal RX_FIFO_EMPTY					: STD_LOGIC;

signal TX_FIFO_WR_CLK				: STD_LOGIC;
signal TX_FIFO_DIN					: STD_LOGIC_VECTOR(7 downto 0);
signal TX_FIFO_WR_EN					: STD_LOGIC;

component RS232_Module is
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  
			  RX							: in  STD_LOGIC;
			  TX							: out STD_LOGIC;
			  RX_led						: out STD_LOGIC;
			  TX_led						: out STD_LOGIC;

			  -- RX_FIFO Signals 
			  RX_FIFO_RD_CLK			: in STD_LOGIC; 
			  RX_FIFO_DOUT				: out STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: in STD_LOGIC;
			  RX_FIFO_EMPTY			: out STD_LOGIC;
			  
			  -- TX_FIFO Signals
			  TX_FIFO_WR_CLK			: in STD_LOGIC; 
			  TX_FIFO_DIN				: in STD_LOGIC_VECTOR (7 downto 0);
			  TX_FIFO_WR_EN			: in STD_LOGIC
			  );
end component;

component RS232_Test_states    
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RX_FIFO_EMPTY				: in  STD_LOGIC;		
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);		
end component;


begin

TX_FIFO_DIN <= RX_FIFO_DOUT;
RX_FIFO_RD_CLK <= clk;
TX_FIFO_WR_CLK <= clk;

-- FIFO_WR_EN
process(clk, reset) 
begin
   if reset = '0' then
		RX_FIFO_RD_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(RX_RD_EN_FLAG) = '1' then		
			RX_FIFO_RD_EN <= '1';
		else
			RX_FIFO_RD_EN <= '0';
		end if;
	end if;
end process;

-- TX_FIFO_WR_EN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_WR_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(TX_WR_EN_FLAG) = '1' then		
			TX_FIFO_WR_EN <= '1';
		else
			TX_FIFO_WR_EN <= '0';
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RS232_Module -------------------------------------------
-------------------------------------------------------------------------------
RS232 : RS232_Module 
port map( 
	clk 									=> clk,
   reset 								=> reset,
			  
	RX										=> RX,
	TX										=> TX,
	RX_led								=> RX_led,
	TX_led								=> TX_led,
	
	RX_FIFO_RD_CLK						=> RX_FIFO_RD_CLK,
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,

	TX_FIFO_WR_CLK						=> TX_FIFO_WR_CLK,
	TX_FIFO_DIN							=> TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> TX_FIFO_WR_EN
	);	


States : RS232_Test_states    
port map( 	
	clk       					=> clk,
	rst_n     					=> reset,
	RX_FIFO_EMPTY				=> RX_FIFO_EMPTY,
	async_flags					=> async_flags
	);		

end Behavioral;



