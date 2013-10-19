----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:58:29 01/13/2012 
-- Design Name: 
-- Module Name:    Synch_Slave_FIFO - Behavioral 
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
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.Synch_Slave_FIFO_pkg.all;

entity Synch_Slave_FIFO is
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
end Synch_Slave_FIFO;

architecture Behavioral of Synch_Slave_FIFO is



signal async_flags					: STD_LOGIC_VECTOR(5 downto 0);
signal count							: STD_LOGIC_VECTOR(9 downto 0);

--signal start_sig						: STD_LOGIC;
--signal data_sig						: STD_LOGIC_VECTOR(7 downto 0);

component Synch_Slave_FIFO_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			--Synch_Slave_FIFO_start	: in  STD_LOGIC;			--start S.M. into motion
			USB_Full_Flag				: in  STD_LOGIC;	
			FIFO_EMPTY					: in  STD_LOGIC;
			FIFO_ALMOST_EMPTY			: in  STD_LOGIC;
			FIFO_PROG_EMPTY			: in  STD_LOGIC;
			count							: in  STD_LOGIC_VECTOR(9 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(5 downto 0)	--flags to enable functions
			);	
end component;

begin

SLOE 		<= '1';
FIFOADDR <= FIFOADDR_in;
SLRD 		<= '1';

FlagB_out <= FlagB;
idle_out  <= async_flags(IDLE_FLAG);
--done_out  <= async_flags(DONE_FLAG);

FIFO_RD_CLK <= Clk;

--FIFO_RD_EN <= async_flags(SET_RD_EN_FLAG);

-- FIFO_RD_EN
process(Clk, reset)   
begin
   if reset = '0' then
		FIFO_RD_EN <= '0';
   elsif rising_edge(Clk) then		
		if async_flags(SET_RD_EN_FLAG) = '1' then
			FIFO_RD_EN <= '1';
		else
			FIFO_RD_EN <= '0';
		end if;
	end if;
end process;

Data <= FIFO_DOUT;
---- Data
--process(Clk, reset)   
--begin
--   if reset = '0' then
--		Data <= x"FF";
--   elsif rising_edge(Clk) and async_flags(SET_DATA_FLAG) = '1' then	
--		Data <= FIFO_DOUT;
--	end if;
--end process;


-- SLWR
process(Clk, reset)   
begin
   if reset = '0' then
		SLWR <= '1';
   elsif rising_edge(Clk) then		
		if async_flags(SET_SLWR_FLAG) = '1' then
			SLWR <= '0';
		else
			SLWR <= '1';
		end if;
	end if;
end process;


PktEnd <= '1';

-------------------------------------------------------------------------------
---------------------- Synch_Slave_FIFO_states -------------------------------
-------------------------------------------------------------------------------

states : Synch_Slave_FIFO_states
port map(
	clk 								=> Clk,
	rst_n 							=> reset,
	--Synch_Slave_FIFO_start		=> start_sig,	
	USB_Full_Flag					=> FlagB,	
	FIFO_EMPTY						=> FIFO_EMPTY,
	FIFO_ALMOST_EMPTY				=> FIFO_ALMOST_EMPTY,
	FIFO_PROG_EMPTY				=> FIFO_PROG_EMPTY,
	count								=> count,
	async_flags						=> async_flags
	);


-------------------------------------------------------------------------------
---------------------- Counter ------------------------------------------------
-------------------------------------------------------------------------------

-- count
process(Clk, reset) 
begin
   if reset = '0' then
		count <= (others => '0');
   elsif rising_edge(Clk) then		
		if async_flags(INC_COUNT_FLAG) = '1' then
			count <= count + 1;
		elsif async_flags(IDLE_FLAG) = '1' then
			count <= "00" & x"00";
		end if;
	end if;
end process; 





end Behavioral;

