----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:43:56 01/27/2012 
-- Design Name: 
-- Module Name:    Main - Behavioral 
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

entity Main is
    Port ( main_clk 		: in  STD_LOGIC;
	        reset 			: in  STD_LOGIC;
			  
			  -- USB Module IO
			  USB_clk 		: in  STD_LOGIC;
			  Data 			: out  STD_LOGIC_VECTOR (7 downto 0);
			  FlagB_out		: out  STD_LOGIC;
			  idle_out		: out  STD_LOGIC;
			  --done_out		: out  STD_LOGIC;
           PktEnd 		: out  STD_LOGIC;
           --FlagA 			: in   STD_LOGIC;				
           FlagB 			: in   STD_LOGIC;				
           --FlagC 			: in   STD_LOGIC;				
           SLRD 			: out  STD_LOGIC;				
           SLWR 			: out  STD_LOGIC;				
           SLOE 			: out  STD_LOGIC;				
			  FIFOADDR_in	: in   STD_LOGIC_VECTOR (1 downto 0);
           FIFOADDR 		: out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  --ADC_Capture IO
			  CS						: out STD_LOGIC;
			  adcRANGE				: out STD_LOGIC;
			  adcRESET				: out STD_LOGIC;
			  adcSTDBY				: out STD_LOGIC;
			  convStA				: out STD_LOGIC;
			  convStB				: out STD_LOGIC;
			  ovrSAMPLE				: out STD_LOGIC_VECTOR(2 downto 0);
			  refSEL					: out STD_LOGIC;
			  sCLK					: out STD_LOGIC;
			  serSEL					: out STD_LOGIC;
			  doutA					: in  STD_LOGIC;
			  doutB					: in  STD_LOGIC;
			  Busy					: in  STD_LOGIC;
			  
			  --RS232_Module
			  RX						: in  STD_LOGIC;
			  TX						: out STD_LOGIC;
			  RX_led					: out STD_LOGIC;
			  TX_led					: out STD_LOGIC;
			  
			  -- MT45W8MW16BGX Signals
			  MT_ADDR				: out STD_LOGIC_VECTOR(22 downto 0);
			  MT_DATA				: inout STD_LOGIC_VECTOR(15 downto 0);
			  MT_OE					: out STD_LOGIC; -- active low
			  MT_WE					: out STD_LOGIC; -- active low
			  MT_ADV					: out STD_LOGIC; -- active low
			  MT_CLK					: out STD_LOGIC; -- during asynch operation, hold the clock low
			  MT_UB					: out STD_LOGIC; -- active low
			  MT_LB					: out STD_LOGIC; -- active low
			  MT_CE					: out STD_LOGIC; -- active low	
			  MT_CRE					: out STD_LOGIC; -- held low, active high
			  --MT_WAIT				: in  STD_LOGIC; -- ignored
			  
			  -- SPI Signals
			  Stim_Active_led			: out STD_LOGIC;
			  SPI_CLK					: out STD_LOGIC;
           DAC_CS 					: out STD_LOGIC;
           MOSI 						: out STD_LOGIC
			  );
end Main;

architecture Behavioral of Main is

signal reset_inv						: STD_LOGIC;



signal Channel1_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel2_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel3_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel4_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel5_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel6_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel7_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel8_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);

signal Stimulation_reg		 		: STD_LOGIC_VECTOR(7 downto 0); -- current stim setting for each channel (currently only supports 1 at a time)
signal Acquisition_reg		 		: STD_LOGIC_VECTOR(7 downto 0); -- current acq setting for each channel (currently only supports all or nothing)

-------------------------------------------------------------------------------
---------------------- DAC_Module ---------------------------------------------
-------------------------------------------------------------------------------
signal DAC_RAM_Start_Op				: STD_LOGIC;
signal DAC_RAM_WE						: STD_LOGIC;
signal DAC_RAM_ADDR					: STD_LOGIC_VECTOR(22 downto 0);
signal DAC_RAM_DIN					: STD_LOGIC_VECTOR(15 downto 0);

signal Stim_Active					: STD_LOGIC;

component DAC_Module 
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  Stimulation				: in  STD_LOGIC_VECTOR(7 downto 0); -- Pulse to single stim, Hold to multi stim
			  Stim_Active				: out STD_LOGIC;
			  
			  -- SPI Signals
			  SPI_CLK					: out STD_LOGIC;
           CS 							: out STD_LOGIC;
           MOSI 						: out STD_LOGIC;
			  
			  -- RAM_Module Control
			  RAM_Start_Op				: out STD_LOGIC;
			  RAM_Op_Done				: in  STD_LOGIC;
			  RAM_WE						: out STD_LOGIC;
			  RAM_ADDR					: out STD_LOGIC_VECTOR(22 downto 0);
			  RAM_DOUT					: in  STD_LOGIC_VECTOR(15 downto 0);
			  RAM_DIN					: out	STD_LOGIC_VECTOR(15 downto 0)
			  );
end component;


-------------------------------------------------------------------------------
---------------------- RAM_Module ---------------------------------------------
-------------------------------------------------------------------------------
signal RAM_Start_Op 				: STD_LOGIC;
signal RAM_Op_Done 				: STD_LOGIC;
signal RAM_WE 						: STD_LOGIC;
signal RAM_ADDR 					: STD_LOGIC_VECTOR(22 downto 0);
signal RAM_DOUT 					: STD_LOGIC_VECTOR(15 downto 0);
signal RAM_DIN 					: STD_LOGIC_VECTOR(15 downto 0);

component RAM_Module 
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  
			  -- MT45W8MW16BGX Signals
			  MT_ADDR				: out STD_LOGIC_VECTOR(22 downto 0);
			  MT_DATA				: inout STD_LOGIC_VECTOR(15 downto 0);
			  MT_OE					: out STD_LOGIC; -- active low
			  MT_WE					: out STD_LOGIC; -- active low
			  MT_ADV					: out STD_LOGIC; -- active low
			  MT_CLK					: out STD_LOGIC; -- during asynch operation, hold the clock low
			  MT_UB					: out STD_LOGIC; -- active low
			  MT_LB					: out STD_LOGIC; -- active low
			  MT_CE					: out STD_LOGIC; -- active low	
			  MT_CRE					: out STD_LOGIC; -- held low, active high
			  --MT_WAIT				: in  STD_LOGIC; -- ignored
			  
			  -- RAM_Module Control
			  RAM_Start_Op			: in  STD_LOGIC;
			  RAM_Op_Done			: out STD_LOGIC;
			  RAM_WE					: in  STD_LOGIC;
			  RAM_ADDR				: in  STD_LOGIC_VECTOR(22 downto 0);
			  RAM_DOUT				: out STD_LOGIC_VECTOR(15 downto 0);
			  RAM_DIN				: in 	STD_LOGIC_VECTOR(15 downto 0)  
			  );
end component;

---------------------------------------------------------------------------------
------------------------ FIFO Componenet ----------------------------------------
---------------------------------------------------------------------------------
signal FIFO_DOUT					: STD_LOGIC_VECTOR (7 downto 0);
signal FIFO_RD_CLK				: STD_LOGIC;
signal FIFO_RD_EN					: STD_LOGIC;
signal FIFO_EMPTY					: STD_LOGIC;
signal FIFO_ALMOST_EMPTY		: STD_LOGIC;
signal FIFO_DIN					: STD_LOGIC_VECTOR (7 downto 0);
signal FIFO_WR_EN		 			: STD_LOGIC;
signal FIFO_WR_CLK		 		: STD_LOGIC;
signal FIFO_FULL					: STD_LOGIC;
signal FIFO_ALMOST_FULL			: STD_LOGIC;
signal FIFO_PROG_EMPTY			: STD_LOGIC; -- set to 16
signal FIFO_PROG_FULL			: STD_LOGIC; -- set to 32256

component FIFO 
	port (
	din: IN std_logic_VECTOR(7 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	almost_empty: OUT std_logic;
	almost_full: OUT std_logic;
	dout: OUT std_logic_VECTOR(7 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic;
	prog_empty: OUT std_logic;
	prog_full: OUT std_logic);
END component;


-------------------------------------------------------------------------------
---------------------- Synch_Slave_FIFO Componenet  ---------------------------
-------------------------------------------------------------------------------
component Synch_Slave_FIFO 
    Port ( Clk 					: in   STD_LOGIC;
			  reset 					: in   STD_LOGIC;
           Data 					: out  STD_LOGIC_VECTOR (7 downto 0);
			  FlagB_out				: out  STD_LOGIC;
			  idle_out				: out  STD_LOGIC;
			  --done_out				: out  STD_LOGIC;
           PktEnd 				: out  STD_LOGIC;
           --FlagA 					: in   STD_LOGIC;				
           FlagB 					: in   STD_LOGIC;				
           --FlagC 					: in   STD_LOGIC;				
           SLRD 					: out  STD_LOGIC;				
           SLWR 					: out  STD_LOGIC;				
           SLOE 					: out  STD_LOGIC;				
			  FIFOADDR_in			: in   STD_LOGIC_VECTOR (1 downto 0);
           FIFOADDR 				: out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  -- USB_FIFO signals
			  FIFO_DOUT				: in   STD_LOGIC_VECTOR (7 downto 0);
			  FIFO_RD_CLK			: out  STD_LOGIC;
			  FIFO_RD_EN			: out  STD_LOGIC;
			  FIFO_EMPTY			: in   STD_LOGIC;
			  FIFO_ALMOST_EMPTY	: in   STD_LOGIC;
			  FIFO_PROG_EMPTY		: in   STD_LOGIC
			  );
end component;

-------------------------------------------------------------------------------
---------------------- ADC_Module Componenet  ---------------------------------
-------------------------------------------------------------------------------
component ADC_Module
Port ( 	  clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
			  FIFO_DIN				: out STD_LOGIC_VECTOR (7 downto 0);		--Data going into FIFO
			  FIFO_WR_EN		 	: out STD_LOGIC;
			  FIFO_WR_CLK		 	: out STD_LOGIC;
			  FIFO_FULL				: in  STD_LOGIC;
			  FIFO_ALMOST_FULL	: in  STD_LOGIC;
			  FIFO_PROG_FULL		: in  STD_LOGIC;
			  
			  --ADC_Capture IO
			  CS						: out STD_LOGIC;
			  adcRANGE				: out STD_LOGIC;
			  adcRESET				: out STD_LOGIC;
			  adcSTDBY				: out STD_LOGIC;
			  convStA				: out STD_LOGIC;
			  convStB				: out STD_LOGIC;
			  ovrSAMPLE				: out STD_LOGIC_VECTOR(2 downto 0);
			  refSEL					: out STD_LOGIC;
			  sCLK					: out STD_LOGIC;
			  serSEL					: out STD_LOGIC;
			  doutA					: in  STD_LOGIC;
			  doutB					: in  STD_LOGIC;
			  Busy					: in  STD_LOGIC
			  );
end component;


-------------------------------------------------------------------------------
---------------------- Command_Handler ----------------------------------------
-------------------------------------------------------------------------------
signal CMD_RAM_Start_Op				: STD_LOGIC;
signal CMD_RAM_WE						: STD_LOGIC;
signal CMD_RAM_ADDR					: STD_LOGIC_VECTOR(22 downto 0);
signal CMD_RAM_DIN					: STD_LOGIC_VECTOR(15 downto 0);

component Command_Handler 
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;

			  Channel1_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel2_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel3_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel4_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel5_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel6_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel7_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel8_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  
			  Stimulation		 		: out STD_LOGIC_VECTOR(7 downto 0); -- current stim setting for each channel (currently only supports 1 at a time)
			  Acquisition		 		: out STD_LOGIC_VECTOR(7 downto 0); -- current acq setting for each channel (currently only supports all or nothing)
			  
			  -- RX_FIFO Signals
			  RX_FIFO_RD_CLK			: out STD_LOGIC; 
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;			  
			  
			  -- TX FIFO Signals
			  TX_FIFO_WR_CLK			: out STD_LOGIC;
			  TX_FIFO_DIN				: out STD_LOGIC_VECTOR(7 downto 0);
			  TX_FIFO_WR_EN			: out STD_LOGIC;
			  
			  -- RAM_Module Control
			  RAM_Start_Op				: out STD_LOGIC;
			  RAM_Op_Done				: in  STD_LOGIC;
			  RAM_WE						: out STD_LOGIC;
			  RAM_ADDR					: out STD_LOGIC_VECTOR(22 downto 0);
			  RAM_DOUT					: in  STD_LOGIC_VECTOR(15 downto 0);
			  RAM_DIN					: out	STD_LOGIC_VECTOR(15 downto 0) 
			  );
end component;


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

component RS232_Module
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  
			  RX							: in  STD_LOGIC;
			  TX							: out STD_LOGIC;
			  RX_led						: out STD_LOGIC;
			  TX_led						: out STD_LOGIC;

			  -- RX_FIFO Signals 
			  RX_FIFO_RD_CLK			: in  STD_LOGIC; 
			  RX_FIFO_DOUT				: out STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: in  STD_LOGIC;
			  RX_FIFO_EMPTY			: out STD_LOGIC;	
			  
			  -- TX_FIFO Signals
			  TX_FIFO_WR_CLK			: in  STD_LOGIC; 
			  TX_FIFO_DIN				: in  STD_LOGIC_VECTOR (7 downto 0);
			  TX_FIFO_WR_EN			: in  STD_LOGIC
			  );
end component;

begin

reset_inv <= not Channel1_Config_reg(7);

--reset_inv <= not reset;

Stim_Active_led <= Stim_Active;

-------------------------------------------------------------------------------
---------------------- DAC_Module ---------------------------------------------
-------------------------------------------------------------------------------

DAC : DAC_Module 
port map( 
	clk 									=> main_clk,
   reset 								=> reset,
	Stimulation							=> Stimulation_reg,
	Stim_Active							=> Stim_Active,
			  
	-- SPI Signals
	SPI_CLK								=> SPI_CLK,
   CS 									=> DAC_CS,
   MOSI 									=> MOSI,
			  
	-- RAM_Module Control
	RAM_Start_Op						=> DAC_RAM_Start_Op,
	RAM_Op_Done							=> RAM_Op_Done,
	RAM_WE								=> DAC_RAM_WE,
	RAM_ADDR								=> DAC_RAM_ADDR,
	RAM_DOUT								=> RAM_DOUT,
	RAM_DIN								=> DAC_RAM_DIN
	);


-------------------------------------------------------------------------------
---------------------- RAM_Module ---------------------------------------------
-------------------------------------------------------------------------------
RAM_Start_Op 	<= DAC_RAM_Start_Op when Stim_Active = '1' else
						CMD_RAM_Start_Op;
					 
RAM_WE 			<= DAC_RAM_WE when Stim_Active = '1' else
						CMD_RAM_WE;
					 
RAM_ADDR 		<= DAC_RAM_ADDR when Stim_Active = '1' else
						CMD_RAM_ADDR;

RAM_DIN 			<= DAC_RAM_DIN when Stim_Active = '1' else
						CMD_RAM_DIN;					 

Onboard_RAM : RAM_Module 
port map(
	clk 									=> main_clk,
   reset 								=> reset,
			  
   -- MT45W8MW16BGX Signals
   MT_ADDR								=> MT_ADDR,
   MT_DATA								=> MT_DATA,
   MT_OE									=> MT_OE,
   MT_WE									=> MT_WE,
   MT_ADV								=> MT_ADV,
   MT_CLK								=> MT_CLK,
   MT_UB									=> MT_UB,
   MT_LB									=> MT_LB,
   MT_CE									=> MT_CE,	
   MT_CRE								=> MT_CRE,
   --MT_WAIT								=> MT_WAIT,
  
   -- RAM_Module Control
   RAM_Start_Op						=> RAM_Start_Op,
   RAM_Op_Done							=> RAM_Op_Done,
   RAM_WE								=> RAM_WE,
   RAM_ADDR								=> RAM_ADDR,
   RAM_DOUT								=> RAM_DOUT,
   RAM_DIN								=> RAM_DIN	  
   );
 
-------------------------------------------------------------------------------
---------------------- RS232_Module -------------------------------------------
-------------------------------------------------------------------------------
RS232 : RS232_Module 
port map( 
	clk 									=> main_clk,
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
	
-------------------------------------------------------------------------------
---------------------- Command_Handler ----------------------------------------
-------------------------------------------------------------------------------
CMD_Handler : Command_Handler 
port map( 
	clk 									=> main_clk,
   reset 								=> reset,
	  
	Channel1_Config 					=> Channel1_Config_reg,
	Channel2_Config 					=> Channel2_Config_reg,
	Channel3_Config 					=> Channel3_Config_reg,
	Channel4_Config 					=> Channel4_Config_reg,
	Channel5_Config 					=> Channel5_Config_reg,
	Channel6_Config 					=> Channel6_Config_reg,
	Channel7_Config 					=> Channel7_Config_reg,
	Channel8_Config 					=> Channel8_Config_reg,
	
	Stimulation		 					=> Stimulation_reg,
	Acquisition			 				=> Acquisition_reg,
			  
	-- RX_FIFO Signals
	RX_FIFO_RD_CLK						=> RX_FIFO_RD_CLK,
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,
	
	-- TX FIFO Signals
	TX_FIFO_WR_CLK						=> TX_FIFO_WR_CLK,
	TX_FIFO_DIN							=> TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> TX_FIFO_WR_EN,
	
	-- RAM_Module Control
   RAM_Start_Op						=> CMD_RAM_Start_Op,
   RAM_Op_Done							=> RAM_Op_Done,
   RAM_WE								=> CMD_RAM_WE,
   RAM_ADDR								=> CMD_RAM_ADDR,
   RAM_DOUT								=> RAM_DOUT,
   RAM_DIN								=> CMD_RAM_DIN	 
	);

-------------------------------------------------------------------------------
---------------------- ADC_Module ---------------------------------------------
-------------------------------------------------------------------------------
ADC : ADC_Module
port map(
	clk 						=> main_clk,
   --reset 					=> reset,
	reset 					=> Channel1_Config_reg(7),
	FIFO_DIN					=> FIFO_DIN,
	FIFO_WR_EN		 		=> FIFO_WR_EN,
	FIFO_WR_CLK		 		=> FIFO_WR_CLK,
	FIFO_FULL				=> FIFO_FULL,
	FIFO_ALMOST_FULL		=> FIFO_ALMOST_FULL,
	FIFO_PROG_FULL			=> FIFO_PROG_FULL,
	CS							=> CS,
	adcRANGE					=> adcRANGE,
	adcRESET					=> adcRESET,
	adcSTDBY					=> adcSTDBY,
	convStA					=> convStA,
	convStB					=> convStB,
	ovrSAMPLE				=> ovrSAMPLE,
	refSEL					=> refSEL,
	sCLK						=> sCLK,
	serSEL					=> serSEL,
	doutA						=> doutA,
	doutB						=> doutB,
	Busy						=> Busy
	);


-------------------------------------------------------------------------------
---------------------- Synch_Slave_FIFO ---------------------------------------
-------------------------------------------------------------------------------
USB_Module : Synch_Slave_FIFO
port map(
	Clk 						=> USB_clk,
	reset 					=> reset,
   Data 						=> Data,
	FlagB_out				=> FlagB_out,
	idle_out					=> idle_out,
	--done_out					=> done_out,
   PktEnd 					=> PktEnd,
   --FlagA 					=> FlagA,			
   FlagB 					=> FlagB,		
   --FlagC 					=> FlagC,		
   SLRD 						=> SLRD,		
   SLWR 						=> SLWR,		
   SLOE 						=> SLOE,		
	FIFOADDR_in				=> FIFOADDR_in,
   FIFOADDR 				=> FIFOADDR,
			  
	-- USB_FIFO signals
	FIFO_DOUT				=> FIFO_DOUT,
	FIFO_RD_CLK				=> FIFO_RD_CLK,
	FIFO_RD_EN				=> FIFO_RD_EN,
	FIFO_EMPTY				=> FIFO_EMPTY,
	FIFO_ALMOST_EMPTY		=> FIFO_ALMOST_EMPTY,
	FIFO_PROG_EMPTY		=> FIFO_PROG_EMPTY
	);

-------------------------------------------------------------------------------
---------------------- FIFO Port Map ------------------------------------------
-------------------------------------------------------------------------------
USB_FIFO : FIFO
port map(
	din					=> FIFO_DIN,
	rd_clk				=> FIFO_RD_CLK,
	rd_en				   => FIFO_RD_EN,
	rst					=> reset_inv,
	wr_clk				=> FIFO_WR_CLK,
	wr_en				   => FIFO_WR_EN,
	almost_empty		=> FIFO_ALMOST_EMPTY,
	almost_full			=> FIFO_ALMOST_FULL,
	dout					=> FIFO_DOUT,	
	empty					=> FIFO_EMPTY,
	full					=> FIFO_FULL,
	prog_empty			=> FIFO_PROG_EMPTY,
	prog_full			=> FIFO_PROG_FULL
	);

end Behavioral;

