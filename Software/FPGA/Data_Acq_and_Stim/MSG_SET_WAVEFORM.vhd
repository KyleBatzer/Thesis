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

use work.MSG_SET_WAVEFORM_pkg.all;

entity MSG_SET_WAVEFORM is 
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
end MSG_SET_WAVEFORM;

architecture Behavioral of MSG_SET_WAVEFORM is



signal async_flags					: STD_LOGIC_VECTOR(15 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal reply_length					: STD_LOGIC_VECTOR(7 downto 0);
signal status							: STD_LOGIC_VECTOR(7 downto 0) := x"45";

-------------- MSG_ID 0x05 - SET_WAVEFORM signals -----------------------------
signal num_samples				 	: STD_LOGIC_VECTOR(7 downto 0);
signal amplitude_reg			 		: STD_LOGIC_VECTOR(15 downto 0);
signal time_reg				 		: STD_LOGIC_VECTOR(15 downto 0);
signal RAM_ADDR_reg					: STD_LOGIC_VECTOR(22 downto 0);


component MSG_SET_WAVEFORM_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			MSG_Start					: in  STD_LOGIC;
			FIFO_EMPTY					: in  STD_LOGIC;		
			RAM_Op_Done					: in  STD_LOGIC;
			reply_length				: in  STD_LOGIC_VECTOR(7 downto 0);
			num_samples					: in  STD_LOGIC_VECTOR(7 downto 0);
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(15 downto 0)	--flags to enable functions
			);				
end component;

begin

MSG_Complete <= async_flags(DONE_FLAG);

-------------------------------------------------------------------------------
---------------------- MSG Payload --------------------------------------------
-------------------------------------------------------------------------------
-- num_samples
process(clk, reset) 
begin
   if reset = '0' then
		num_samples <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(NUM_SAMPLES_RD_FLAG) = '1' then		
			num_samples <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-- amplitude_reg
process(clk, reset) 
begin
   if reset = '0' then
		amplitude_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(AMPLITUDE_H_RD_FLAG) = '1' then		
			amplitude_reg(15 downto 8) <= RX_FIFO_DOUT;
		elsif async_flags(AMPLITUDE_L_RD_FLAG) = '1' then		
			amplitude_reg(7 downto 0) <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-- time_reg
process(clk, reset) 
begin
   if reset = '0' then
		time_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(TIME_H_RD_FLAG) = '1' then		
			time_reg(15 downto 8) <= RX_FIFO_DOUT;
		elsif async_flags(TIME_L_RD_FLAG) = '1' then		
			time_reg(7 downto 0) <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- MSG_Reply Information ----------------------------------
-------------------------------------------------------------------------------

-- TX_FIFO_DIN
process(clk, reset) 
begin
   if reset = '0' then
		TX_FIFO_DIN <= (others => '0');
		reply_length <= x"00";
   elsif rising_edge(clk) then
		if async_flags(SET_REPLY_BYTE_FLAG) = '1' then -- MSG_ID x"01" - CONFIG_CHAN
			reply_length <= x"07";
			case count is 
				when x"00" => TX_FIFO_DIN <= x"5A"; 								-- Start Byte
				when x"01" => TX_FIFO_DIN <= x"85";									-- Reply MSG_ID
				when x"02" => TX_FIFO_DIN <= x"00";									-- Reply Length_H
				when x"03" => TX_FIFO_DIN <= x"07";									-- Reply Length_L
				when x"04" => TX_FIFO_DIN <= status;									-- status
				when x"05" => TX_FIFO_DIN <= status;
				when x"06" => TX_FIFO_DIN <= x"FF";
				when others => TX_FIFO_DIN <= x"25";
			end case;
		elsif async_flags(NUM_SAMPLES_RD_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		elsif async_flags(AMPLITUDE_H_RD_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		elsif async_flags(AMPLITUDE_L_RD_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		elsif async_flags(TIME_H_RD_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		elsif async_flags(TIME_L_RD_FLAG) = '1' then
			TX_FIFO_DIN <= RX_FIFO_DOUT;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
---------------------- RAM ----------------------------------------------------
-------------------------------------------------------------------------------
RAM_WE <= '0';  -- always in set to write
RAM_ADDR <= RAM_ADDR_reg;

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

-- RAM_DIN
process(clk, reset) 
begin
   if reset = '0' then
		RAM_DIN <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(NUM_SAMPLES_WR_FLAG) = '1' then
			RAM_DIN <= x"00" & num_samples;
		elsif async_flags(AMPLITUDE_WR_FLAG) = '1' then
			RAM_DIN <= amplitude_reg;
		elsif async_flags(TIME_WR_FLAG) = '1' then
			RAM_DIN <= time_reg;
		end if;
	end if;
end process;
			  
-- RAM_ADDR_reg
process(clk, reset) 
begin
   if reset = '0' then
		RAM_ADDR_reg <= (others => '0');
   elsif rising_edge(clk) then
		if async_flags(NUM_SAMPLES_WR_FLAG) = '1' then
			RAM_ADDR_reg(22 downto 16) <= (others => '0');
			case MSG_Channel is
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
		elsif async_flags(AMPLITUDE_WR_FLAG) = '1' then
			RAM_ADDR_reg <= RAM_ADDR_reg + 1;
		elsif async_flags(TIME_WR_FLAG) = '1' then
			RAM_ADDR_reg <= RAM_ADDR_reg + 1;
		end if;
	end if;
end process;
			  
			  
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
---------------------- MSG_SET_WAVEFORM_states ------------------------------
-------------------------------------------------------------------------------
states : MSG_SET_WAVEFORM_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	MSG_Start						=> MSG_Start,
	FIFO_EMPTY						=> RX_FIFO_EMPTY,
	RAM_Op_Done						=> RAM_Op_Done,
	reply_length					=> reply_length,
	num_samples						=> num_samples,
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

