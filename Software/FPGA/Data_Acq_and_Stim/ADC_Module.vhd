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

use work.ADC_Module_pkg.all;

entity ADC_Module is
    Port ( clk 					: in  STD_LOGIC;
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
end ADC_Module;

architecture Behavioral of ADC_Module is

signal test_data_counter   	   : std_logic_vector(15 downto 0) := x"0000";
signal timestamp_counter   	   : std_logic_vector(31 downto 0) := x"00000000";

signal async_flags					: STD_LOGIC_VECTOR(5 downto 0);
signal count							: STD_LOGIC_VECTOR(9 downto 0);

signal start_sig						: STD_LOGIC := '0';
signal data_sig						: STD_LOGIC_VECTOR(7 downto 0);

-------------------------------------------------------------------------------
---------------------- ADC_Module_states --------------------------------------
-------------------------------------------------------------------------------

component ADC_Module_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			ADC_Module_start			: in  STD_LOGIC;			--start S.M. into motion
			FIFO_Full_Flag				: in  STD_LOGIC;			
			count							: in  STD_LOGIC_VECTOR(9 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);	
end component;

-------------------------------------------------------------------------------
---------------------- ADC_Capture  -------------------------------------------
-------------------------------------------------------------------------------
signal ADC_Capture_Done				: STD_LOGIC;
signal ADC_Channel1_Data 			: STD_LOGIC_VECTOR(15 downto 0);
signal ADC_Channel2_Data 			: STD_LOGIC_VECTOR(15 downto 0);
signal ADC_Channel3_Data 			: STD_LOGIC_VECTOR(15 downto 0);
signal ADC_Channel4_Data 			: STD_LOGIC_VECTOR(15 downto 0);

component ADC_Capture 
    Port ( clk 					: in  STD_LOGIC;
           reset 					: in  STD_LOGIC;
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
			  
			  ADC_Capture_Start	: in  STD_LOGIC;
			  ADC_Capture_Done	: out STD_LOGIC;
			  Channel1_Data		: out STD_LOGIC_VECTOR(15 downto 0);
			  Channel2_Data		: out STD_LOGIC_VECTOR(15 downto 0);
			  Channel3_Data		: out STD_LOGIC_VECTOR(15 downto 0);
			  Channel4_Data		: out STD_LOGIC_VECTOR(15 downto 0)
			  );
end component;

-------------------------------------------------------------------------------
---------------------- Clock_Divider ------------------------------------------
-------------------------------------------------------------------------------

signal Clock_Divider_200ns		: STD_LOGIC;
signal ADC_divide_count			: STD_LOGIC_VECTOR(7 downto 0);

component Clock_Divider
	 Port ( clk_in : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  divide_count : in STD_LOGIC_VECTOR(7 downto 0);
           clk_out : out  STD_LOGIC);
end component;



begin

FIFO_WR_CLK <= clk;

-- FIFO_WR_EN
process(clk, reset)   
begin
   if reset = '0' then
		FIFO_WR_EN <= '0';
   elsif rising_edge(clk) then		
		if async_flags(SET_WR_EN_FLAG) = '1' then
			FIFO_WR_EN <= '1';
		else
			FIFO_WR_EN <= '0';
		end if;
	end if;
end process;

-- FIFO_DIN
process(clk, reset)   
begin
   if reset = '0' then
		FIFO_DIN <= x"FF";
   elsif rising_edge(clk) and async_flags(SET_DATA_FLAG) = '1' then		
		case count is    
			when "00" & x"00" =>		FIFO_DIN <= x"A5";
			when "00" & x"01" =>		FIFO_DIN <= x"5A";
			when "00" & x"02" =>		FIFO_DIN <= timestamp_counter(7 downto 0);	
			when "00" & x"03" =>		FIFO_DIN <= timestamp_counter(15 downto 8);
			when "00" & x"04" =>		FIFO_DIN <= timestamp_counter(23 downto 16);			
			when "00" & x"05" =>		FIFO_DIN <= timestamp_counter(31 downto 24);
			
			--channel 1 data
			when "00" & x"06" =>		FIFO_DIN <= x"01";
			when "00" & x"07" =>		FIFO_DIN <= ADC_Channel1_Data(7 downto 0);
			when "00" & x"08" =>		FIFO_DIN <= ADC_Channel1_Data(15 downto 8);
			
			--channel 2 data
			when "00" & x"09" =>		FIFO_DIN <= x"02";
			when "00" & x"0A" =>		FIFO_DIN <= ADC_Channel2_Data(7 downto 0);
			when "00" & x"0B" =>		FIFO_DIN <= ADC_Channel2_Data(15 downto 8);
			
			--channel 3 data
			when "00" & x"0C" =>		FIFO_DIN <= x"03";
			when "00" & x"0D" =>		FIFO_DIN <= ADC_Channel3_Data(7 downto 0);
			when "00" & x"0E" =>		FIFO_DIN <= ADC_Channel3_Data(15 downto 8);
			
			--channel 4 data
			when "00" & x"10" =>		FIFO_DIN <= x"04";
			when "00" & x"11" =>		FIFO_DIN <= ADC_Channel4_Data(7 downto 0);
			when "00" & x"12" =>		FIFO_DIN <= ADC_Channel4_Data(15 downto 8);
			
			when "00" & x"0F" =>		FIFO_DIN <= x"FF";
			when "00" & x"1F" =>		FIFO_DIN <= x"FF";			
			when OTHERS =>				FIFO_DIN <= data_sig;
		end case;
	end if;
end process;

-- test_data_counter
process(clk, reset)   
begin
   if reset = '0' then
		test_data_counter <= (others => '0');
		start_sig <= '0';
		data_sig <= x"00";
   elsif rising_edge(clk) then
		if test_data_counter = x"044C" and FIFO_PROG_FULL = '0' then
			test_data_counter <= (others => '0');
			start_sig <= '1';
			data_sig <= data_sig + 1;
		elsif test_data_counter = x"044C" then
			test_data_counter <= (others => '0');
			data_sig <= data_sig + 1;
		elsif test_data_counter = x"000A" then
			test_data_counter <= test_data_counter + 1;
			start_sig <= '0';
		else 
			test_data_counter <= test_data_counter + 1;
		end if;
		
	end if;
end process;

-- timestamp_counter
process(clk, reset)   
begin
   if reset = '0' then
		timestamp_counter <= (others => '0');
   elsif rising_edge(clk) then		
		timestamp_counter <= timestamp_counter + 1;
	end if;
end process;


-------------------------------------------------------------------------------
---------------------- Clock_Divider ------------------------------------------
-------------------------------------------------------------------------------
ADC_divide_count <= x"04";

CLK_200ns : Clock_Divider
port map(
	clk_in							=> clk,
	reset								=> reset,
	divide_count					=> ADC_divide_count,
	clk_out							=> Clock_Divider_200ns
	);

-------------------------------------------------------------------------------
---------------------- ADC_Capture  -------------------------------------------
-------------------------------------------------------------------------------

AD7606_4 : ADC_Capture 
port map( 
	clk 								=> Clock_Divider_200ns,
	reset 							=> reset,
	CS									=> CS,
	adcRANGE							=> adcRANGE,
	adcRESET							=> adcRESET,
	adcSTDBY							=> adcSTDBY,
	convStA							=> convStA,
	convStB							=> convStB,
	ovrSAMPLE						=> ovrSAMPLE,
	refSEL							=> refSEL,
	sCLK								=> sCLK,
	serSEL							=> serSEL,
	doutA								=> doutA,
	doutB								=> doutB,
	Busy								=> Busy,
		  
	ADC_Capture_Start				=> start_sig,
	ADC_Capture_Done				=> ADC_Capture_Done,
	Channel1_Data					=> ADC_Channel1_Data,
	Channel2_Data					=> ADC_Channel2_Data,
	Channel3_Data					=> ADC_Channel3_Data,
	Channel4_Data					=> ADC_Channel4_Data
	);

-------------------------------------------------------------------------------
---------------------- ADC_Module_states --------------------------------------
-------------------------------------------------------------------------------

states : ADC_Module_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	ADC_Module_start				=> ADC_Capture_Done,	
	FIFO_Full_Flag					=> FIFO_PROG_FULL,
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
			count <= "00" & x"00";
		end if;
	end if;
end process; 


end Behavioral;

