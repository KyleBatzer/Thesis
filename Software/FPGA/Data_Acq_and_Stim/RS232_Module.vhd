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

entity RS232_Module is
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
end RS232_Module;

architecture Behavioral of RS232_Module is

-------------------------------------------------------------------------------
---------------------- TX_Module ----------------------------------------------
-------------------------------------------------------------------------------
component TX_Module 
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  TX						: out STD_LOGIC;
			  TX_led					: out STD_LOGIC;
			  
			  -- TX_FIFO Signals
			  FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  FIFO_RD_EN			: out STD_LOGIC;
			  FIFO_EMPTY			: in  STD_LOGIC
			  );
end component;

-------------------------------------------------------------------------------
---------------------- RX_Module ----------------------------------------------
-------------------------------------------------------------------------------
component RX_Module 
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  RX						: in  STD_LOGIC;
			  RX_led					: out STD_LOGIC;
			  
			  -- RX_FIFO Signals
			  FIFO_WR_CLK			: out  STD_LOGIC;
			  FIFO_DIN				: out  STD_LOGIC_VECTOR (7 downto 0);
			  FIFO_WR_EN			: out  STD_LOGIC
			  );
end component;

-------------------------------------------------------------------------------
---------------------- Clock_Divider ------------------------------------------
-------------------------------------------------------------------------------
signal RS232_CLK						: STD_LOGIC;
signal RS232_divide_count			: STD_LOGIC_VECTOR(7 downto 0);

component Clock_Divider
    Port ( clk_in : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  divide_count : in STD_LOGIC_VECTOR(7 downto 0);
           clk_out : out  STD_LOGIC);
end component;

-------------------------------------------------------------------------------
---------------------- FIFO_8_512 ---------------------------------------------
-------------------------------------------------------------------------------
signal reset_inv 						: STD_LOGIC;

signal RX_FIFO_DIN					: STD_LOGIC_VECTOR(7 downto 0);
--signal RX_FIFO_RD_CLK				: STD_LOGIC;
--signal RX_FIFO_RD_EN					: STD_LOGIC;
signal RX_FIFO_DOUT_sig				: STD_LOGIC_VECTOR(7 downto 0);
signal RX_FIFO_WR_CLK				: STD_LOGIC;
signal RX_FIFO_WR_EN					: STD_LOGIC;
--signal RX_FIFO_EMPTY					: STD_LOGIC;
signal RX_FIFO_FULL					: STD_LOGIC;

--signal TX_FIFO_DIN					: STD_LOGIC_VECTOR(7 downto 0);
signal TX_FIFO_RD_CLK				: STD_LOGIC;
signal TX_FIFO_RD_EN					: STD_LOGIC;
signal TX_FIFO_DOUT					: STD_LOGIC_VECTOR(7 downto 0);
--signal TX_FIFO_WR_CLK				: STD_LOGIC;
--signal TX_FIFO_WR_EN					: STD_LOGIC;
signal TX_FIFO_EMPTY					: STD_LOGIC;
signal TX_FIFO_FULL					: STD_LOGIC;

component FIFO_8_512 IS
	port (
	din: IN std_logic_VECTOR(7 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(7 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
END component;

begin

reset_inv <= not reset;

RX_FIFO_DOUT <= RX_FIFO_DOUT_sig;

-------------------------------------------------------------------------------
---------------------- TX_Module ----------------------------------------------
-------------------------------------------------------------------------------
TX_Mod : TX_Module 
port map( 
	clk 								=> RS232_CLK,
   reset 							=> reset,
	TX									=> TX,
	TX_led							=> TX_led,
	FIFO_DOUT						=> TX_FIFO_DOUT,
	FIFO_RD_EN						=> TX_FIFO_RD_EN,
	FIFO_EMPTY						=> TX_FIFO_EMPTY
	);

-------------------------------------------------------------------------------
---------------------- RX_Module ----------------------------------------------
-------------------------------------------------------------------------------
RX_Mod : RX_Module 
port map( 
	clk 								=> clk,
   reset 							=> reset,
	RX									=> RX,
	RX_led							=> RX_led,
	FIFO_WR_CLK						=> RX_FIFO_WR_CLK,
	FIFO_DIN							=> RX_FIFO_DIN,
	FIFO_WR_EN						=> RX_FIFO_WR_EN
	);

-------------------------------------------------------------------------------
---------------------- Clock Divider ------------------------------------------
-------------------------------------------------------------------------------
RS232_divide_count <= x"D8";

RS232_Clock : Clock_Divider
port map( 
	clk_in 							=> clk,
   reset 							=> reset,
	divide_count					=> RS232_divide_count,
   clk_out							=> RS232_CLK
	);

-------------------------------------------------------------------------------
---------------------- RX_FIFO_8_512 ------------------------------------------
-------------------------------------------------------------------------------

RX_FIFO : FIFO_8_512
port map(
	din								=> RX_FIFO_DIN,
	rd_clk							=> clk,
	rd_en								=> RX_FIFO_RD_EN,
	rst								=> reset_inv,
	wr_clk							=> RX_FIFO_WR_CLK,
	wr_en								=> RX_FIFO_WR_EN,
	dout								=> RX_FIFO_DOUT_sig,
	empty								=> RX_FIFO_EMPTY,
	full								=> RX_FIFO_FULL
	);
	
	
-------------------------------------------------------------------------------
---------------------- TX_FIFO_8_512 ------------------------------------------
-------------------------------------------------------------------------------

TX_FIFO : FIFO_8_512
port map(
	din								=> TX_FIFO_DIN,
	rd_clk							=> RS232_CLK,
	rd_en								=> TX_FIFO_RD_EN,
	rst								=> reset_inv,
	wr_clk							=> TX_FIFO_WR_CLK,
	wr_en								=> TX_FIFO_WR_EN,
	dout								=> TX_FIFO_DOUT,
	empty								=> TX_FIFO_EMPTY,
	full								=> TX_FIFO_FULL
	);

end Behavioral;

