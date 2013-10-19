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

use work.DAC_Module_pkg.all;

entity DAC_Module is
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
end DAC_Module;

architecture Behavioral of DAC_Module is

signal DAC_Start						: STD_LOGIC;

signal async_flags					: STD_LOGIC_VECTOR(23 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal time_count						: STD_LOGIC_VECTOR(15 downto 0);
signal time_count_div				: STD_LOGIC_VECTOR(15 downto 0);
signal sample_count					: STD_LOGIC_VECTOR(7 downto 0);

signal num_samples				 	: STD_LOGIC_VECTOR(7 downto 0);
signal amplitude_reg			 		: STD_LOGIC_VECTOR(15 downto 0);
signal time_reg				 		: STD_LOGIC_VECTOR(15 downto 0);
signal RAM_ADDR_reg					: STD_LOGIC_VECTOR(22 downto 0);

signal MSG_Channel_reg				: STD_LOGIC_VECTOR(7 downto 0);

signal continuous 					: STD_LOGIC;

-------------------------------------------------------------------------------
---------------------- SPI ----------------------------------------------------
-------------------------------------------------------------------------------
signal SPI_start 						: STD_LOGIC;
signal SPI_Done 						: STD_LOGIC;
signal SPI_data_reg 					: STD_LOGIC_VECTOR(31 downto 0);

component SPI  -- Only supports sending 32 bits
Port (  data_reg 						: in STD_LOGIC_VECTOR(31 downto 0);
		  SPI_start 					: in STD_LOGIC;
		  CLK 							: in  STD_LOGIC;
		  rst 							: in STD_LOGIC;
		  CS 								: out  STD_LOGIC;
		  MOSI 							: out  STD_LOGIC;
		  SPI_Done 						: out STD_LOGIC);
end component;

-------------------------------------------------------------------------------
---------------------- Clock_Divider ------------------------------------------
-------------------------------------------------------------------------------

--signal Clock_Divider_1us			: STD_LOGIC; -- used for incrementing time_count
signal Clock_Divider_200ns			: STD_LOGIC;
--signal ADC_divide_count_1us		: STD_LOGIC_VECTOR(7 downto 0);
signal ADC_divide_count_200ns		: STD_LOGIC_VECTOR(7 downto 0);

component Clock_Divider
	 Port ( clk_in : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  divide_count : in STD_LOGIC_VECTOR(7 downto 0);
           clk_out : out  STD_LOGIC);
end component;

-------------------------------------------------------------------------------
---------------------- DAC_Module_states --------------------------------------
-------------------------------------------------------------------------------

component DAC_Module_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			DAC_Module_start			: in  STD_LOGIC;			--start S.M. into motion
			SPI_Done						: in  STD_LOGIC;
			RAM_Op_Done					: in  STD_LOGIC;
			--continuous					: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			time_count					: in  STD_LOGIC_VECTOR(15 downto 0);
			time_val						: in  STD_LOGIC_VECTOR(15 downto 0);
			sample_count				: in  STD_LOGIC_VECTOR(7 downto 0);
			num_samples					: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(23 downto 0)	--flags to enable functions
			);	
end component;


begin

Stim_Active <= not async_flags(IDLE_FLAG);

DAC_Start <= '0' when Stimulation = x"00" else
				 '1';
				 
SPI_CLK <= Clock_Divider_200ns;

---- continuous
--process(clk, reset) 
--begin
--   if reset = '0' then
--		continuous <= '0';
--   elsif rising_edge(clk) then
--		case MSG_Channel_reg is
--				when x"01" =>			continuous <= Channelx_Continuous(0);
--				when x"02" =>			continuous <= Channelx_Continuous(1);
--				when x"03" =>			continuous <= Channelx_Continuous(2);
--				when x"04" =>			continuous <= Channelx_Continuous(3);
--				when x"05" =>			continuous <= Channelx_Continuous(4);
--				when x"06" =>			continuous <= Channelx_Continuous(5);
--				when x"07" =>			continuous <= Channelx_Continuous(6);
--				when x"08" =>			continuous <= Channelx_Continuous(7);
--				when others =>			continuous <= '0';
--			end case;
--	end if;
--end process;

-- MSG_Channel_reg
process(clk, reset) 
begin
   if reset = '0' then
		MSG_Channel_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(IDLE_FLAG) = '1' then	
			if Stimulation(0) = '1' then
				MSG_Channel_reg <= x"01";
			elsif Stimulation(1) = '1' then
				MSG_Channel_reg <= x"02";
			elsif Stimulation(2) = '1' then
				MSG_Channel_reg <= x"03";
			elsif Stimulation(3) = '1' then
				MSG_Channel_reg <= x"04";
			elsif Stimulation(4) = '1' then
				MSG_Channel_reg <= x"05";
			elsif Stimulation(5) = '1' then
				MSG_Channel_reg <= x"06";
			elsif Stimulation(6) = '1' then
				MSG_Channel_reg <= x"07";
			elsif Stimulation(7) = '1' then
				MSG_Channel_reg <= x"08";
			end if;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- SPI ----------------------------------------------------
-------------------------------------------------------------------------------
-- SPI_data_reg
process(clk, reset)
begin
	if reset = '0' then
		SPI_data_reg <= (others => '0');
	elsif rising_edge(clk) then		
		if async_flags(RESET_OP_SET_FLAG) = '1' then
			SPI_data_reg <= x"07000000";
		elsif async_flags(INTERNAL_REF_REG_SET_FLAG) = '1' then
			--SPI_data_reg <= x"08000000"; -- External Reference
			SPI_data_reg <= x"08000001"; -- Internal Reference
		elsif async_flags(LDAC_REG_SET_FLAG) = '1' then
			SPI_data_reg <= x"060000FF"; 
		elsif async_flags(POWER_DAC_SET_FLAG) = '1' then
			SPI_data_reg <= x"040000FF"; 
		elsif async_flags(CLEAR_CODE_SET_FLAG) = '1' then
			SPI_data_reg <= x"05000000";
		--elsif async_flags(VOLTAGE_SET_FLAG) = '1' then
			--SPI_data_reg <= "000000110000" & test_data & "00000000" & "0000";
		elsif async_flags(VOLTAGE_SET_FLAG) = '1' then
			--SPI_data_reg <= "000000110000" & (x"7FFF" + (sample_array(CONV_INTEGER(sample_count)) * mult_sample)) & "0000";
			SPI_data_reg <= "000000110000" & (amplitude_reg) & "0000";
		elsif async_flags(VOLTAGE_DEFAULT_FLAG) = '1' then
			SPI_data_reg <= "000000110000" & x"7FFF" & "0000";
		else
			SPI_data_reg <= SPI_data_reg;
			--SPI_data_reg <= x"00000000";
		end if;
	
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- Waveform Information -----------------------------------
-------------------------------------------------------------------------------
-- num_samples
process(clk, reset) 
begin
   if reset = '0' then
		num_samples <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(NUM_SAMPLES_CAPTURE_FLAG) = '1' then		
			num_samples <= RAM_DOUT(7 downto 0);
		end if;
	end if;
end process;

-- amplitude_reg
process(clk, reset) 
begin
   if reset = '0' then
		amplitude_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(AMPLITUDE_CAPTURE_FLAG) = '1' then		
			amplitude_reg <= RAM_DOUT;
		end if;
	end if;
end process;

-- time_reg
process(clk, reset) 
begin
   if reset = '0' then
		time_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(TIME_CAPTURE_FLAG) = '1' then		
			time_reg <= RAM_DOUT;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RAM ----------------------------------------------------
-------------------------------------------------------------------------------
RAM_WE <= '1';  -- always in set to read
RAM_ADDR <= RAM_ADDR_reg;
RAM_DIN <= (others => '1'); -- RAM_DIN not used

-- RAM_Start_Op
process(clk, reset) 
begin
   if reset = '0' then
		RAM_Start_Op <= '0';
   elsif rising_edge(clk) then
		if async_flags(START_MEM_OP_FLAG) = '1' then		
			RAM_Start_Op <= '1';
		else
			RAM_Start_Op <= '0';
		end if;
	end if;
end process;
			  
-- RAM_ADDR_reg
process(clk, reset) 
begin
   if reset = '0' then
		RAM_ADDR_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(NUM_SAMPLES_RD_FLAG) = '1' then
			RAM_ADDR_reg(22 downto 16) <= (others => '0');
			case MSG_Channel_reg is
				when x"01" =>			RAM_ADDR_reg(15 downto 0) <= x"0000";
				when x"02" =>			RAM_ADDR_reg(15 downto 0) <= x"1000";
				when x"03" =>			RAM_ADDR_reg(15 downto 0) <= x"2000";
				when x"04" =>			RAM_ADDR_reg(15 downto 0) <= x"3000";
				when x"05" =>			RAM_ADDR_reg(15 downto 0) <= x"4000";
				when x"06" =>			RAM_ADDR_reg(15 downto 0) <= x"5000";
				when x"07" =>			RAM_ADDR_reg(15 downto 0) <= x"6000";
				when x"08" =>			RAM_ADDR_reg(15 downto 0) <= x"7000";
				when others =>			RAM_ADDR_reg(15 downto 0) <= x"8000";
			end case;
		elsif async_flags(AMPLITUDE_RD_FLAG) = '1' then
			RAM_ADDR_reg <= RAM_ADDR_reg + 1;
		elsif async_flags(TIME_RD_FLAG) = '1' then
			RAM_ADDR_reg <= RAM_ADDR_reg + 1;
		end if;
	end if;
end process;


-------------------------------------------------------------------------------
---------------------- SPI ----------------------------------------------------
-------------------------------------------------------------------------------

SPI_start <= async_flags(START_FLAG);

SPI_Module : SPI
port map(
	data_reg 						=> SPI_data_reg,
	SPI_start 						=> SPI_start,
	CLK 								=> Clock_Divider_200ns,
	rst 								=> reset,
	CS 								=> CS,
	MOSI 								=> MOSI,
	SPI_Done 						=> SPI_Done
	);

-------------------------------------------------------------------------------
---------------------- Clock_Divider - 200ns ----------------------------------
-------------------------------------------------------------------------------
ADC_divide_count_200ns <= x"04";

CLK_200ns : Clock_Divider
port map(
	clk_in							=> clk,
	reset								=> reset,
	divide_count					=> ADC_divide_count_200ns,
	clk_out							=> Clock_Divider_200ns
	);

---------------------------------------------------------------------------------
------------------------ Clock_Divider - 1us ------------------------------------
---------------------------------------------------------------------------------
--ADC_divide_count_1us <= x"18";
--
--CLK_1us : Clock_Divider
--port map(
--	clk_in							=> clk,
--	reset								=> reset,
--	divide_count					=> ADC_divide_count_1us,
--	clk_out							=> Clock_Divider_1us
--	);

-------------------------------------------------------------------------------
---------------------- DAC_Module_states --------------------------------------
-------------------------------------------------------------------------------

states : DAC_Module_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	DAC_Module_start				=> DAC_Start,
	SPI_Done							=> SPI_Done,
	RAM_Op_Done						=> RAM_Op_Done,
	--continuous						=> continuous,
	count								=> count,
	time_count						=> time_count,
	time_val							=> time_reg,
	sample_count					=> sample_count,
	num_samples						=> num_samples,
	async_flags						=> async_flags
	);

-------------------------------------------------------------------------------
---------------------- Counter ------------------------------------------------
-------------------------------------------------------------------------------
-- time_count
process(clk, reset) 
begin
   if reset = '0' then
		time_count <= (others => '0');
		time_count_div <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(TIME_COUNT_INC_FLAG) = '1' and time_count_div = 49 then
			time_count <= time_count + 1;
			time_count_div <= (others => '0');
		elsif async_flags(TIME_COUNT_INC_FLAG) = '1' then
			time_count_div <= time_count_div + 1;
		elsif async_flags(TIME_COUNT_RESET_FLAG) = '1' then
			time_count <= (others => '0');
			time_count_div <= (others => '0');
		elsif async_flags(IDLE_FLAG) = '1' then
			time_count <= (others => '0');
			time_count_div <= (others => '0');
		end if;
	end if;
end process; 

-- sample_count
process(clk, reset) 
begin
   if reset = '0' then
		sample_count <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(SAMPLE_COUNT_INC_FLAG) = '1' then
			sample_count <= sample_count + 1;
		elsif async_flags(SAMPLE_COUNT_RESET_FLAG) = '1' then
			sample_count <= x"01";
		elsif async_flags(IDLE_FLAG) = '1' then
			sample_count <= x"01";
		end if;
	end if;
end process; 

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
		elsif async_flags(RESET_COUNT_FLAG) = '1' then
			count <= x"00";
		end if;
	end if;
end process; 


end Behavioral;

