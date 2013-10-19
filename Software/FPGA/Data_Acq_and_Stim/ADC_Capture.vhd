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

use work.ADC_Capture_pkg.all;

entity ADC_Capture is
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
end ADC_Capture;

architecture Behavioral of ADC_Capture is

signal async_flags					: STD_LOGIC_VECTOR(6 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal reset_counter 				: STD_LOGIC_VECTOR(23 downto 0) := x"000000";

signal Channel1_data_reg			: STD_LOGIC_VECTOR(15 downto 0);
signal Channel2_data_reg			: STD_LOGIC_VECTOR(15 downto 0);
signal Channel3_data_reg			: STD_LOGIC_VECTOR(15 downto 0);
signal Channel4_data_reg			: STD_LOGIC_VECTOR(15 downto 0);

component ADC_Capture_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			ADC_Capture_start			: in  STD_LOGIC;			--start S.M. into motion
			Busy							: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			reset_counter				: in  STD_LOGIC_VECTOR(23 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(6 downto 0)	--flags to enable functions
			);	
end component;

begin

ADC_Capture_Done 		<= async_flags(DONE_FLAG);

adcRANGE			<= '1'; 			-- 0: -5V to +5V, 1: -10V to +10V
adcSTDBY			<= '1'; 			-- Standby mode not used
ovrSAMPLE 		<= "000"; 		-- allows rate of 50 kHz
refSEL 			<= '1'; 			-- internal reference
serSEL			<= '1';			-- Serial Selected
sCLK 				<= clk;			-- route internal clock to sCLK

Channel1_Data <= Channel1_data_reg;
Channel2_Data <= Channel2_data_reg;
Channel3_Data <= Channel3_data_reg;
Channel4_Data <= Channel4_data_reg;
	
			  

-- Channelx_Data
process(clk, reset)   
begin
   if reset = '0' then
		Channel1_data_reg <= (others => '0');
		Channel2_data_reg <= (others => '0');
		Channel3_data_reg <= x"5678";
		Channel4_data_reg <= x"9ABC";
   elsif rising_edge(clk) and async_flags(CAPTURE_DATA_FLAG) = '1' then		
		case count is    
			when x"00" =>				Channel1_data_reg(15) <= doutA;
											Channel2_data_reg(15) <= doutB; 		-- need to check what channel data comes from where and when
			when x"01" =>				Channel1_data_reg(14) <= doutA;
											Channel2_data_reg(14) <= doutB;
			when x"02" =>				Channel1_data_reg(13) <= doutA;
											Channel2_data_reg(13) <= doutB;
			when x"03" =>				Channel1_data_reg(12) <= doutA;
											Channel2_data_reg(12) <= doutB;			
			when x"04" =>				Channel1_data_reg(11) <= doutA;
											Channel2_data_reg(11) <= doutB;
			when x"05" =>				Channel1_data_reg(10) <= doutA;
											Channel2_data_reg(10) <= doutB;
			when x"06" =>				Channel1_data_reg(9)  <= doutA;
											Channel2_data_reg(9)  <= doutB;
			when x"07" =>				Channel1_data_reg(8)  <= doutA;
											Channel2_data_reg(8)  <= doutB;
			when x"08" =>				Channel1_data_reg(7)  <= doutA;
											Channel2_data_reg(7)  <= doutB;
			when x"09" =>				Channel1_data_reg(6)  <= doutA;
											Channel2_data_reg(6)  <= doutB;
			when x"0A" =>				Channel1_data_reg(5)  <= doutA;
											Channel2_data_reg(5)  <= doutB;
			when x"0B" =>				Channel1_data_reg(4)  <= doutA;
											Channel2_data_reg(4)  <= doutB;
			when x"0C" =>				Channel1_data_reg(3)  <= doutA;
											Channel2_data_reg(3)  <= doutB;
			when x"0D" =>				Channel1_data_reg(2)  <= doutA;
											Channel2_data_reg(2)  <= doutB;
			when x"0E" =>				Channel1_data_reg(1)  <= doutA;
											Channel2_data_reg(1)  <= doutB;
			when x"0F" =>				Channel1_data_reg(0)  <= doutA;
											Channel2_data_reg(0)  <= doutB;
			when OTHERS =>				
		end case;
	end if;
end process;


-- convST
process(clk, reset) 
begin
   if reset = '0' then
		convStA <= '1';
		convStB <= '1';
   elsif rising_edge(clk) then		
		if async_flags(CONVST_FLAG) = '1' then
			convStA <='0';
			convStB <='0';
		else
			convStA <= '1';
			convStB <= '1';
		end if;
	end if;
end process; 

-- CS
process(clk, reset) 
begin
   if reset = '0' then
		CS <= '1';
   elsif rising_edge(clk) then		
		if async_flags(SET_CS_FLAG) = '1' then
			CS <='0';
		else
			CS <= '1';
		end if;
	end if;
end process; 

-- adcRESET
process(clk, reset) 
begin
   if reset = '0' then
		adcRESET <= '1';
   elsif rising_edge(clk) then		
		if async_flags(ADC_RESET_FLAG) = '1' then
			adcRESET <='1';
		else
			adcRESET <= '0';
		end if;
	end if;
end process; 

-------------------------------------------------------------------------------
---------------------- ADC_Capture_states -------------------------------------
-------------------------------------------------------------------------------

states : ADC_Capture_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	ADC_Capture_start				=> ADC_Capture_Start,	
	Busy								=> Busy,
	count								=> count,
	reset_counter					=> reset_counter,
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


-- reset_counter
process(clk, reset) 
begin
   if reset = '0' then
		reset_counter <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(ADC_RESET_FLAG) = '1' then
			reset_counter <= reset_counter + 1;
		else
			reset_counter <= (others => '0');
		end if;
	end if;
end process; 


end Behavioral;

