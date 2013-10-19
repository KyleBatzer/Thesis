----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:43 09/20/2010 
-- Design Name: 
-- Module Name:    SPI - Behavioral 
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

use work.SPI_pkg.all;

entity SPI is
    Port ( data_reg : in STD_LOGIC_VECTOR(31 downto 0);
			  SPI_start : in STD_LOGIC;
			  CLK : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           CS : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
			  SPI_Done :out STD_LOGIC);
end SPI;

architecture Behavioral of SPI is

component SPI_states
Port ( 	clk       				: in  STD_LOGIC;
			rst     					: in  STD_LOGIC;
			SPI_start		 		: in  STD_LOGIC;			--start S.M. into motion
			--count					: in  STD_LOGIC_VECTOR(4 downto 0);
			async_flags				: out STD_LOGIC_VECTOR(33 downto 0)	--flags to enable functions
			  );
end component;

signal count : integer range 0 to 7;
--signal count : STD_LOGIC_VECTOR(4 downto 0);
signal async_flags : STD_LOGIC_VECTOR(33 downto 0);	--flags to enable functions

begin

states : SPI_states
port map(
	clk 						=> clk,
	rst 						=> rst,
	SPI_start 				=> SPI_start,
	async_flags 			=> async_flags
	);

--CS <= not async_flags(OUTPUT_FLAG);
	
--process(clk, rst)
--begin
--	if rst = '0' then
--		CS <= '1';
--	elsif rising_edge(clk) then		
--		if async_flags(OUTPUT_FLAG) = '1' then
--			CS <= '0';
--		end if;
--		if async_flags(DONE_FLAG) = '1' then
--			CS <= '1';
--		end if;
--		if async_flags(INIT_FLAG) = '1' then
--			CS <= '1';
--		end if;
--	end if;
--end process;
	
process(clk, rst)
begin
	if rst = '0' then
		MOSI <= '0';
		CS <= '1';
	elsif rising_edge(clk) then		
--		if async_flags(OUTPUT_FLAG) = '1' then
--			--MOSI <= data_reg(CONV_INTEGER(count));
--			MOSI <= data_reg(count);
--			--count <= count - 1;
--			count <= count + 1;
--		end if;
--		if async_flags(DONE_FLAG) = '1' then
--			count <= (others => '0');
--		end if;
--		if async_flags(INIT_FLAG) = '1' then
--			--count <= "00111";
--			count <= 0;
--		end if;
		if async_flags(DONE_FLAG) = '1' then
			CS <= '1';
		end if;
		if async_flags(INIT_FLAG) = '1' then
			CS <= '1';
		end if;


		if async_flags(B31_FLAG) = '1' then
			MOSI <= data_reg(B31_FLAG);
			CS <= '0';
		elsif async_flags(B30_FLAG) = '1' then
			MOSI <= data_reg(B30_FLAG);
			CS <= '0';
		elsif async_flags(B29_FLAG) = '1' then
			MOSI <= data_reg(B29_FLAG);
			CS <= '0';
		elsif async_flags(B28_FLAG) = '1' then
			MOSI <= data_reg(B28_FLAG);
			CS <= '0';
		elsif async_flags(B27_FLAG) = '1' then
			MOSI <= data_reg(B27_FLAG);
			CS <= '0';
		elsif async_flags(B26_FLAG) = '1' then
			MOSI <= data_reg(B26_FLAG);
			CS <= '0';
		elsif async_flags(B25_FLAG) = '1' then
			MOSI <= data_reg(B25_FLAG);
			CS <= '0';
		elsif async_flags(B24_FLAG) = '1' then
			MOSI <= data_reg(B24_FLAG);
			CS <= '0';
		elsif async_flags(B23_FLAG) = '1' then
			MOSI <= data_reg(B23_FLAG);
			CS <= '0';
		elsif async_flags(B22_FLAG) = '1' then
			MOSI <= data_reg(B22_FLAG);
			CS <= '0';
		elsif async_flags(B21_FLAG) = '1' then
			MOSI <= data_reg(B21_FLAG);
			CS <= '0';
		elsif async_flags(B20_FLAG) = '1' then
			MOSI <= data_reg(B20_FLAG);
			CS <= '0';
		elsif async_flags(B19_FLAG) = '1' then
			MOSI <= data_reg(B19_FLAG);
			CS <= '0';
		elsif async_flags(B18_FLAG) = '1' then
			MOSI <= data_reg(B18_FLAG);
			CS <= '0';
		elsif async_flags(B17_FLAG) = '1' then
			MOSI <= data_reg(B17_FLAG);
			CS <= '0';
		elsif async_flags(B16_FLAG) = '1' then
			MOSI <= data_reg(B16_FLAG);
			CS <= '0';
		elsif async_flags(B15_FLAG) = '1' then
			MOSI <= data_reg(B15_FLAG);
			CS <= '0';
		elsif async_flags(B14_FLAG) = '1' then
			MOSI <= data_reg(B14_FLAG);
			CS <= '0';
		elsif async_flags(B13_FLAG) = '1' then
			MOSI <= data_reg(B13_FLAG);
			CS <= '0';
		elsif async_flags(B12_FLAG) = '1' then
			MOSI <= data_reg(B12_FLAG);
			CS <= '0';
		elsif async_flags(B11_FLAG) = '1' then
			MOSI <= data_reg(B11_FLAG);
			CS <= '0';
		elsif async_flags(B10_FLAG) = '1' then
			MOSI <= data_reg(B10_FLAG);
			CS <= '0';
		elsif async_flags(B9_FLAG) = '1' then
			MOSI <= data_reg(B9_FLAG);
			CS <= '0';
		elsif async_flags(B8_FLAG) = '1' then
			MOSI <= data_reg(B8_FLAG);
			CS <= '0';
		elsif async_flags(B7_FLAG) = '1' then
			MOSI <= data_reg(B7_FLAG);
			CS <= '0';
		elsif async_flags(B6_FLAG) = '1' then
			MOSI <= data_reg(B6_FLAG);
			CS <= '0';
		elsif async_flags(B5_FLAG) = '1' then
			MOSI <= data_reg(B5_FLAG);
			CS <= '0';
		elsif async_flags(B4_FLAG) = '1' then
			MOSI <= data_reg(B4_FLAG);
			CS <= '0';
		elsif async_flags(B3_FLAG) = '1' then
			MOSI <= data_reg(B3_FLAG);
			CS <= '0';
		elsif async_flags(B2_FLAG) = '1' then
			MOSI <= data_reg(B2_FLAG);
			CS <= '0';
		elsif async_flags(B1_FLAG) = '1' then
			MOSI <= data_reg(B1_FLAG);
			CS <= '0';
		elsif async_flags(B0_FLAG) = '1' then
			MOSI <= data_reg(B0_FLAG);
			CS <= '0';
		end if;
	end if;
end process;
	
SPI_Done <= async_flags(DONE_FLAG);
	
end Behavioral;

