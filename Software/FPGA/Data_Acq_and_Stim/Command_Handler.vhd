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

use work.Command_Handler_pkg.all;

entity Command_Handler is 
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
end Command_Handler;

architecture Behavioral of Command_Handler is

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

signal async_flags					: STD_LOGIC_VECTOR(15 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal MSG_Length						: STD_LOGIC_VECTOR(15 downto 0);
signal MSG_ID							: STD_LOGIC_VECTOR(7 downto 0);
signal MSG_Channel					: STD_LOGIC_VECTOR(7 downto 0);

signal MSG_Complete					: STD_LOGIC;

signal status							: STD_LOGIC_VECTOR(7 downto 0) := x"45";


-------------- MSG_ID 0x01 - CONFIG_CHAN signals -----------------------------
signal MSG_01_Start					: STD_LOGIC;
signal MSG_01_Complete				: STD_LOGIC;
signal MSG_01_RX_FIFO_RD_EN		: STD_LOGIC;
signal MSG_01_TX_FIFO_DIN			: STD_LOGIC_VECTOR(7 downto 0);
signal MSG_01_TX_FIFO_WR_EN		: STD_LOGIC; 

component MSG_01_Config_Chan  
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  MSG_Start					: in  STD_LOGIC;
			  MSG_Complete				: out STD_LOGIC;
			  
			  -- Header Information
			  MSG_Channel				: in STD_LOGIC_VECTOR(7 downto 0);

			  -- Channel Configuration
			  Channel1_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel2_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel3_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel4_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel5_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel6_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel7_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel8_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX_FIFO Signals
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;
			  
			  -- TX FIFO Signals
			  TX_FIFO_DIN				: out STD_LOGIC_VECTOR(7 downto 0);
			  TX_FIFO_WR_EN			: out STD_LOGIC
			  );
end component;

-------------- MSG_ID 0x05 - SET_WAVEFORM signals ----------------------------
signal MSG_05_Start					: STD_LOGIC;
signal MSG_05_Complete				: STD_LOGIC;
signal MSG_05_RX_FIFO_RD_EN		: STD_LOGIC;
signal MSG_05_TX_FIFO_DIN			: STD_LOGIC_VECTOR(7 downto 0);
signal MSG_05_TX_FIFO_WR_EN		: STD_LOGIC;
signal MSG_05_RAM_Start_Op			: STD_LOGIC;
signal MSG_05_RAM_WE					: STD_LOGIC;
signal MSG_05_RAM_ADDR				: STD_LOGIC_VECTOR(22 downto 0);
signal MSG_05_RAM_DIN				: STD_LOGIC_VECTOR(15 downto 0);

component MSG_SET_WAVEFORM 
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  MSG_Start					: in  STD_LOGIC;
			  MSG_Complete				: out STD_LOGIC;
			  
			  -- Header Information
			  MSG_Channel				: in STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX_FIFO Signals
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;
			  
			  -- TX FIFO Signals
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

-------------- MSG_ID 0x06 - GET_WAVEFORM signals ----------------------------
signal MSG_06_Start					: STD_LOGIC;
signal MSG_06_Complete				: STD_LOGIC;
signal MSG_06_RX_FIFO_RD_EN		: STD_LOGIC;
signal MSG_06_TX_FIFO_DIN			: STD_LOGIC_VECTOR(7 downto 0);
signal MSG_06_TX_FIFO_WR_EN		: STD_LOGIC;
signal MSG_06_RAM_Start_Op			: STD_LOGIC;
signal MSG_06_RAM_WE					: STD_LOGIC;
signal MSG_06_RAM_ADDR				: STD_LOGIC_VECTOR(22 downto 0);
signal MSG_06_RAM_DIN				: STD_LOGIC_VECTOR(15 downto 0);

component MSG_GET_WAVEFORM 
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  MSG_Start					: in  STD_LOGIC;
			  MSG_Complete				: out STD_LOGIC;
			  
			  -- Header Information
			  MSG_Channel				: in STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX_FIFO Signals
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;
			  
			  -- TX FIFO Signals
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


-------------- MSG_ID 0x07 - SET_STIM signals ----------------------------
signal MSG_07_Start					: STD_LOGIC;
signal MSG_07_Complete				: STD_LOGIC;
signal MSG_07_RX_FIFO_RD_EN		: STD_LOGIC;
signal MSG_07_TX_FIFO_DIN			: STD_LOGIC_VECTOR(7 downto 0);
signal MSG_07_TX_FIFO_WR_EN		: STD_LOGIC;

component MSG_SET_STIM  
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;
			  MSG_Start					: in  STD_LOGIC;
			  MSG_Complete				: out STD_LOGIC;
			  
			  -- Header Information
			  MSG_Channel				: in STD_LOGIC_VECTOR(7 downto 0);

			  -- Channel Configuration
			  Stimulation 				: out STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX_FIFO Signals
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;
			  
			  -- TX FIFO Signals
			  TX_FIFO_DIN				: out STD_LOGIC_VECTOR(7 downto 0);
			  TX_FIFO_WR_EN			: out STD_LOGIC
			  );
end component;


component Command_Handler_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;	
			MSG_Complete				: in  STD_LOGIC;			
			RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);	
end component;

begin

MSG_Complete <= MSG_01_Complete or MSG_05_Complete or MSG_06_Complete or MSG_07_Complete;

Channel1_Config <= Channel1_Config_reg;
Channel2_Config <= Channel2_Config_reg;
Channel3_Config <= Channel3_Config_reg;
Channel4_Config <= Channel4_Config_reg;
Channel5_Config <= Channel5_Config_reg;
Channel6_Config <= Channel6_Config_reg;
Channel7_Config <= Channel7_Config_reg;
Channel8_Config <= Channel8_Config_reg;

Stimulation <= Stimulation_reg;

-------------------------------------------------------------------------------
---------------------- MSG_Header Information ---------------------------------
-------------------------------------------------------------------------------
-- MSG_Length
process(clk, reset) 
begin
   if reset = '0' then
		MSG_Length <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(READ_MESSAGE_FLAG) = '1' and count = x"02" then
			MSG_Length(15 downto 8) <= RX_FIFO_DOUT;
		elsif async_flags(READ_MESSAGE_FLAG) = '1' and count = x"03" then
			MSG_Length(7 downto 0) <= RX_FIFO_DOUT;
		elsif async_flags(IDLE_FLAG) = '1' then	
			MSG_Length <= x"0008";
		end if;
	end if;
end process;

-- MSG_ID
process(clk, reset) 
begin
   if reset = '0' then
		MSG_ID <= (others => '0');
   elsif rising_edge(clk) and async_flags(READ_MESSAGE_FLAG) = '1' and count = x"01" then	
		MSG_ID <= RX_FIFO_DOUT;
	end if;
end process;

-- MSG_Channel
process(clk, reset) 
begin
   if reset = '0' then
		MSG_Channel <= (others => '0');
   elsif rising_edge(clk) and async_flags(READ_MESSAGE_FLAG) = '1' and count = x"04" then	
		MSG_Channel <= RX_FIFO_DOUT;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RAM ----------------------------------------------------
-------------------------------------------------------------------------------	
-- RAM_DIN
process(clk, reset) 
begin
   if reset = '0' then
		RAM_DIN <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then
			RAM_DIN <= MSG_05_RAM_DIN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then
			RAM_DIN <= MSG_06_RAM_DIN;
		end if;
	end if;
end process;	
	
-- RAM_ADDR
process(clk, reset) 
begin
   if reset = '0' then
		RAM_ADDR <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then
			RAM_ADDR <= MSG_05_RAM_ADDR;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then
			RAM_ADDR <= MSG_06_RAM_ADDR;
		end if;
	end if;
end process;
	
-- RAM_Start_Op
process(clk, reset) 
begin
   if reset = '0' then
		RAM_Start_Op <= '0';
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then
			RAM_Start_Op <= MSG_05_RAM_Start_Op;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then
			RAM_Start_Op <= MSG_06_RAM_Start_Op;
		else
			RAM_Start_Op <= '0';
		end if;
	end if;
end process;

-- RAM_WE
process(clk, reset) 
begin
   if reset = '0' then
		RAM_WE <= '0';
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then
			RAM_WE <= MSG_05_RAM_WE;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then
			RAM_WE <= MSG_06_RAM_WE;
		else
			RAM_WE <= '0';
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RX_FIFO ------------------------------------------------
-------------------------------------------------------------------------------
RX_FIFO_RD_CLK <= clk;

-- RX_FIFO_RD_EN
process(clk, reset) 
begin
   if reset = '0' then
		RX_FIFO_RD_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"01" then
			RX_FIFO_RD_EN <= MSG_01_RX_FIFO_RD_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then
			RX_FIFO_RD_EN <= MSG_05_RX_FIFO_RD_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then
			RX_FIFO_RD_EN <= MSG_06_RX_FIFO_RD_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"07" then
			RX_FIFO_RD_EN <= MSG_07_RX_FIFO_RD_EN;
		elsif async_flags(RX_RD_EN_FLAG) = '1' then		
			RX_FIFO_RD_EN <= '1';
		else
			RX_FIFO_RD_EN <= '0';
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- TX_FIFO ------------------------------------------------
-------------------------------------------------------------------------------
TX_FIFO_WR_CLK <= clk;

-- TX_FIFO_WR_EN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_WR_EN <= '0';
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"01" then		
			TX_FIFO_WR_EN <= MSG_01_TX_FIFO_WR_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then		
			TX_FIFO_WR_EN <= MSG_05_TX_FIFO_WR_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then		
			TX_FIFO_WR_EN <= MSG_06_TX_FIFO_WR_EN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"07" then		
			TX_FIFO_WR_EN <= MSG_07_TX_FIFO_WR_EN;
		elsif async_flags(TX_WR_EN_FLAG) = '1' then		
			TX_FIFO_WR_EN <= '1';
		else
			TX_FIFO_WR_EN <= '0';
		end if;
	end if;
end process;

-- TX_FIFO_DIN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_DIN <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"01" then		
			TX_FIFO_DIN <= MSG_01_TX_FIFO_DIN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"05" then		
			TX_FIFO_DIN <= MSG_05_TX_FIFO_DIN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"06" then		
			TX_FIFO_DIN <= MSG_06_TX_FIFO_DIN;
		elsif async_flags(PAYLOAD_FLAG) = '1' and MSG_ID = x"07" then		
			TX_FIFO_DIN <= MSG_07_TX_FIFO_DIN;
		elsif async_flags(READ_MESSAGE_FLAG) = '1' then		
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- Command_Handler_states ---------------------------------
-------------------------------------------------------------------------------
states : Command_Handler_states
port map(
	clk 									=> clk,
	rst_n 								=> reset,
	FIFO_EMPTY							=> RX_FIFO_EMPTY,
	MSG_Complete						=> MSG_Complete,
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	count									=> count,
	async_flags							=> async_flags
	);

-------------------------------------------------------------------------------
---------------------- MSG_01_Config_Chan -------------------------------------
-------------------------------------------------------------------------------
MSG_01_Start <= async_flags(PAYLOAD_START_FLAG) when MSG_ID = x"01" else
					 '0';

MSG_ID_01 : MSG_01_Config_Chan  
port map( 
	clk 									=> clk,
   reset 								=> reset,
	MSG_Start							=> MSG_01_Start,
	MSG_Complete						=> MSG_01_Complete,
			  
	-- Header Information
	MSG_Channel							=> MSG_Channel,

	-- Channel Configuration
	Channel1_Config 					=> Channel1_Config_reg,
	Channel2_Config 					=> Channel2_Config_reg,
	Channel3_Config 					=> Channel3_Config_reg,
	Channel4_Config 					=> Channel4_Config_reg,
	Channel5_Config 					=> Channel5_Config_reg,
	Channel6_Config 					=> Channel6_Config_reg,
	Channel7_Config 					=> Channel7_Config_reg,
	Channel8_Config 					=> Channel8_Config_reg,
			  
	-- RX_FIFO Signals
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> MSG_01_RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,
			  
	-- TX FIFO Signals
	TX_FIFO_DIN							=> MSG_01_TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> MSG_01_TX_FIFO_WR_EN
	);
	
	
-------------------------------------------------------------------------------
---------------------- MSG_SET_WAVEFORM -------------------------------------
-------------------------------------------------------------------------------
MSG_05_Start <= async_flags(PAYLOAD_START_FLAG) when MSG_ID = x"05" else
					 '0';
					 
MSG_ID_05 : MSG_SET_WAVEFORM 
port map( 
	clk 									=> clk,
   reset 								=> reset,
	MSG_Start							=> MSG_05_Start,
	MSG_Complete						=> MSG_05_Complete,
			  
	-- Header Information
	MSG_Channel							=> MSG_Channel,
			  
	-- RX_FIFO Signals
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> MSG_05_RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,
			  
	-- TX FIFO Signals
	TX_FIFO_DIN							=> MSG_05_TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> MSG_05_TX_FIFO_WR_EN,
			  
	-- RAM_Module Control
	RAM_Start_Op						=> MSG_05_RAM_Start_Op,
	RAM_Op_Done							=> RAM_Op_Done,
	RAM_WE								=> MSG_05_RAM_WE,
	RAM_ADDR								=> MSG_05_RAM_ADDR,
	RAM_DOUT								=> RAM_DOUT,
	RAM_DIN								=> MSG_05_RAM_DIN
	);


-------------------------------------------------------------------------------
---------------------- MSG_GET_WAVEFORM -------------------------------------
-------------------------------------------------------------------------------
MSG_06_Start <= async_flags(PAYLOAD_START_FLAG) when MSG_ID = x"06" else
					 '0';
					 
MSG_ID_06 : MSG_GET_WAVEFORM 
port map( 
	clk 									=> clk,
   reset 								=> reset,
	MSG_Start							=> MSG_06_Start,
	MSG_Complete						=> MSG_06_Complete,
			  
	-- Header Information
	MSG_Channel							=> MSG_Channel,
			  
	-- RX_FIFO Signals
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> MSG_06_RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,
			  
	-- TX FIFO Signals
	TX_FIFO_DIN							=> MSG_06_TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> MSG_06_TX_FIFO_WR_EN,
			  
	-- RAM_Module Control
	RAM_Start_Op						=> MSG_06_RAM_Start_Op,
	RAM_Op_Done							=> RAM_Op_Done,
	RAM_WE								=> MSG_06_RAM_WE,
	RAM_ADDR								=> MSG_06_RAM_ADDR,
	RAM_DOUT								=> RAM_DOUT,
	RAM_DIN								=> MSG_06_RAM_DIN
	);
	
	
-------------------------------------------------------------------------------
---------------------- MSG_SET_STIM -------------------------------------------
-------------------------------------------------------------------------------
MSG_07_Start <= async_flags(PAYLOAD_START_FLAG) when MSG_ID = x"07" else
					 '0';

MSG_ID_07 : MSG_SET_STIM  
port map( 
	clk 									=> clk,
   reset 								=> reset,
	MSG_Start							=> MSG_07_Start,
	MSG_Complete						=> MSG_07_Complete,
			  
	-- Header Information
	MSG_Channel							=> MSG_Channel,

	-- Stimulation Configuration
	Stimulation 						=> Stimulation_reg,
			  
	-- RX_FIFO Signals
	RX_FIFO_DOUT						=> RX_FIFO_DOUT,
	RX_FIFO_RD_EN						=> MSG_07_RX_FIFO_RD_EN,
	RX_FIFO_EMPTY						=> RX_FIFO_EMPTY,
			  
	-- TX FIFO Signals
	TX_FIFO_DIN							=> MSG_07_TX_FIFO_DIN,
	TX_FIFO_WR_EN						=> MSG_07_TX_FIFO_WR_EN
	);
	
---------------------------------------------------------------------------------
------------------------ Counter ------------------------------------------------
---------------------------------------------------------------------------------

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
		elsif async_flags(CLEAR_COUNT_FLAG) = '1' then
			count <= x"00";
		end if;
	end if;
end process; 


end Behavioral;

