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

use work.MSG_01_Config_Chan_pkg.all;

entity MSG_01_Config_Chan is 
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
end MSG_01_Config_Chan;

architecture Behavioral of MSG_01_Config_Chan is

signal Channel1_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel2_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel3_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel4_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel5_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel6_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel7_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);
signal Channel8_Config_reg 		: STD_LOGIC_VECTOR(7 downto 0);

signal async_flags					: STD_LOGIC_VECTOR(15 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal reply_length					: STD_LOGIC_VECTOR(7 downto 0);
signal status							: STD_LOGIC_VECTOR(7 downto 0) := x"45";

-------------- MSG_ID 0x01 - CONFIG_CHAN signals -----------------------------
signal CONFIG_CHAN_return_reg 	: STD_LOGIC_VECTOR(7 downto 0);


component MSG_01_Config_Chan_states     
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
--CONFIG_CHAN_return_reg
process(clk, reset) 
begin
   if reset = '0' then
		CONFIG_CHAN_return_reg <= (others => '0');
   elsif rising_edge(clk) then
		case MSG_Channel is
			when x"01" =>	CONFIG_CHAN_return_reg <= Channel1_Config_reg;
			when x"02" =>	CONFIG_CHAN_return_reg <= Channel2_Config_reg;
			when x"03" =>	CONFIG_CHAN_return_reg <= Channel3_Config_reg;
			when x"04" =>	CONFIG_CHAN_return_reg <= Channel4_Config_reg;
			when x"05" =>	CONFIG_CHAN_return_reg <= Channel5_Config_reg;
			when x"06" =>	CONFIG_CHAN_return_reg <= Channel6_Config_reg;
			when x"07" =>	CONFIG_CHAN_return_reg <= Channel7_Config_reg;
			when x"08" =>	CONFIG_CHAN_return_reg <= Channel8_Config_reg;
			when others => CONFIG_CHAN_return_reg <= Channel1_Config_reg;
		end case;
	end if;
end process;

-- TX_FIFO_DIN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_DIN <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(SET_REPLY_BYTE_FLAG) = '1' then -- MSG_ID x"01" - CONFIG_CHAN
			reply_length <= x"07";
			case count is 
				when x"00" => TX_FIFO_DIN <= x"5A"; 								-- Start Byte
				when x"01" => TX_FIFO_DIN <= x"81";		-- Reply MSG_ID
				when x"02" => TX_FIFO_DIN <= x"00";									-- Reply Length_H
				when x"03" => TX_FIFO_DIN <= x"07";									-- Reply Length_L
				when x"04" => TX_FIFO_DIN <= MSG_Channel;									-- MSG_Channel
				when x"05" => TX_FIFO_DIN <= CONFIG_CHAN_return_reg;
				when x"06" => TX_FIFO_DIN <= x"FF";
				when others => TX_FIFO_DIN <= x"25";
			end case;
		elsif async_flags(READ_MESSAGE_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		end if;
	end if;
end process;


-------------------------------------------------------------------------------
---------------------- Channel Configuration Registers ------------------------
-------------------------------------------------------------------------------
-- ChannelX_Config_reg
process(clk, reset) 
begin
   if reset = '0' then
		Channel1_Config_reg <= (others => '0');
		Channel2_Config_reg <= (others => '0');
		Channel3_Config_reg <= (others => '0');
		Channel4_Config_reg <= (others => '0');
		Channel5_Config_reg <= (others => '0');
		Channel6_Config_reg <= (others => '0');
		Channel7_Config_reg <= (others => '0');
		Channel8_Config_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(READ_MESSAGE_FLAG) = '1' and count = x"00" then  		-- Config Channel
			case MSG_Channel is
				when x"01" =>	Channel1_Config_reg <= RX_FIFO_DOUT;
				when x"02" =>	Channel2_Config_reg <= RX_FIFO_DOUT;
				when x"03" =>	Channel3_Config_reg <= RX_FIFO_DOUT;
				when x"04" =>	Channel4_Config_reg <= RX_FIFO_DOUT;
				when x"05" =>	Channel5_Config_reg <= RX_FIFO_DOUT;
				when x"06" =>	Channel6_Config_reg <= RX_FIFO_DOUT;
				when x"07" =>	Channel7_Config_reg <= RX_FIFO_DOUT;
				when x"08" =>	Channel8_Config_reg <= RX_FIFO_DOUT;
				when others =>
			end case;
		end if;
	end if;
end process;

Channel1_Config <= Channel1_Config_reg;
Channel2_Config <= Channel2_Config_reg;
Channel3_Config <= Channel3_Config_reg;
Channel4_Config <= Channel4_Config_reg;
Channel5_Config <= Channel5_Config_reg;
Channel6_Config <= Channel6_Config_reg;
Channel7_Config <= Channel7_Config_reg;
Channel8_Config <= Channel8_Config_reg;
	
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
---------------------- MSG_01_Config_Chan_states ------------------------------
-------------------------------------------------------------------------------
states : MSG_01_Config_Chan_states
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

