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

use work.MSG_SET_STIM_pkg.all;

entity MSG_SET_STIM is 
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
end MSG_SET_STIM;

architecture Behavioral of MSG_SET_STIM is

signal Stimulation_reg		 		: STD_LOGIC_VECTOR(7 downto 0);  -- Current stim setting for each channel (currently only supports 1 at a time)
signal Continuous_reg		 		: STD_LOGIC_VECTOR(7 downto 0); 	-- Overwrites Stim reg, causing single pulse for those channels that 
																						-- are not set for continuous stim

signal async_flags					: STD_LOGIC_VECTOR(15 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal reply_length					: STD_LOGIC_VECTOR(7 downto 0);
signal status							: STD_LOGIC_VECTOR(7 downto 0) := x"45";

component MSG_SET_STIM_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			MSG_Start					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;		
			reply_length				: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);		
end component;

begin

MSG_Complete <= async_flags(DONE_FLAG);

-------------------------------------------------------------------------------
---------------------- MSG_Reply Information ----------------------------------
-------------------------------------------------------------------------------

-- TX_FIFO_DIN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_DIN <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(SET_REPLY_BYTE_FLAG) = '1' then 
			reply_length <= x"07";
			case count is 
				when x"00" => TX_FIFO_DIN <= x"5A"; 								-- Start Byte
				when x"01" => TX_FIFO_DIN <= x"87";									-- Reply MSG_ID
				when x"02" => TX_FIFO_DIN <= x"00";									-- Reply Length_H
				when x"03" => TX_FIFO_DIN <= x"07";									-- Reply Length_L
				when x"04" => TX_FIFO_DIN <= MSG_Channel;							-- MSG_Channel
				when x"05" => TX_FIFO_DIN <= Stimulation_reg;					-- Send back current stim reg setting (only those with continuous will remain set)
				when x"06" => TX_FIFO_DIN <= x"FF";
				when others => TX_FIFO_DIN <= x"25";
			end case;
		elsif async_flags(READ_MESSAGE_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		end if;
	end if;
end process;


-------------------------------------------------------------------------------
---------------------- Stimulation_reg ----------------------------------------
-------------------------------------------------------------------------------
-- Continuous_reg
process(clk, reset) 
begin
   if reset = '0' then
		Continuous_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(READ_MESSAGE_FLAG) = '1' and count = x"00" then  		-- Config Channel
			Continuous_reg <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-- Stimulation_reg
process(clk, reset) 
begin
   if reset = '0' then
		Stimulation_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(READ_MESSAGE_FLAG) = '1' and count = x"00" then  		-- Config Channel
			Stimulation_reg <= MSG_Channel;
		elsif async_flags(SET_CONTINUOUS_FLAG) = '1'  then  		-- Config Channel
			Stimulation_reg <= Continuous_reg;
		end if;
	end if;
end process;

Stimulation <= Stimulation_reg;


-------------------------------------------------------------------------------
---------------------- RX_FIFO ------------------------------------------------
-------------------------------------------------------------------------------
-- RX_FIFO_RD_EN
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

-------------------------------------------------------------------------------
---------------------- TX_FIFO ------------------------------------------------
-------------------------------------------------------------------------------
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
---------------------- MSG_SINGLE_STIM_states ---------------------------------
-------------------------------------------------------------------------------
states : MSG_SET_STIM_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	MSG_Start						=> MSG_Start,
	FIFO_EMPTY						=> RX_FIFO_EMPTY,
	reply_length					=> reply_length,
	count								=> count,
	async_flags						=> async_flags
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

