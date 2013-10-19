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

use work.RAM_Module_pkg.all;
 
entity RAM_Module is
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
			  MT_CRE					: out STD_LOGIC; 
			  --MT_WAIT				: in  STD_LOGIC; -- ignored
			  
			  -- RAM_Module Control
			  RAM_Start_Op			: in  STD_LOGIC;
			  RAM_Op_Done			: out STD_LOGIC;
			  RAM_WE					: in  STD_LOGIC;
			  RAM_ADDR				: in  STD_LOGIC_VECTOR(22 downto 0);
			  RAM_DOUT				: out STD_LOGIC_VECTOR(15 downto 0);
			  RAM_DIN				: in 	STD_LOGIC_VECTOR(15 downto 0)	  
			  );
end RAM_Module;

architecture Behavioral of RAM_Module is

signal async_flags					: STD_LOGIC_VECTOR(4 downto 0);
signal count							: STD_LOGIC_VECTOR(7 downto 0);

signal init_counter 					: STD_LOGIC_VECTOR(15 downto 0) := x"0000";

signal RAM_ADDR_reg					: STD_LOGIC_VECTOR(22 downto 0);
signal RAM_DATA_reg					: STD_LOGIC_VECTOR(15 downto 0);
signal RAM_WE_sig						: STD_LOGIC;

component RAM_Module_states     
Port ( 	clk       					: in  STD_LOGIC;
			rst_n     					: in  STD_LOGIC;
			RAM_Start_Op				: in  STD_LOGIC;			--start S.M. into motion
			count							: in  STD_LOGIC_VECTOR(7 downto 0);
			init_counter				: in  STD_LOGIC_VECTOR(15 downto 0);
			async_flags					: out STD_LOGIC_VECTOR(4 downto 0)	--flags to enable functions
			);	
end component;

begin

-------------------------------------------------------------------------------
---------------------- RAM_Module_Control -------------------------------------
-------------------------------------------------------------------------------
RAM_Op_Done 		<= async_flags(DONE_FLAG);
							
-- RAM_DOUT
process(clk, reset) 
begin
   if reset = '0' then
		RAM_DOUT <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(PERFORM_OP_FLAG) = '1' and count = 5 and RAM_WE_sig = '1' then -- read op
			RAM_DOUT <= RAM_DATA_reg;
		end if;
	end if;
end process;

-- RAM_DATA_reg
process(clk, reset) 
begin
   if reset = '0' then
		RAM_DATA_reg <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(PERFORM_OP_FLAG) = '1' and count = 0 and RAM_WE_sig = '0' then -- write op
			RAM_DATA_reg <= RAM_DIN;
		elsif async_flags(PERFORM_OP_FLAG) = '1' and count = 4 and RAM_WE_sig = '1' then -- read op
			RAM_DATA_reg <= MT_DATA;
		end if;
	end if;
end process;

-- RAM_ADDR_reg
process(clk, reset) 
begin
   if reset = '0' then
		RAM_ADDR_reg <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(IDLE_FLAG) = '1' then
			RAM_ADDR_reg <= RAM_ADDR;
		end if;
	end if;
end process; 

-- RAM_WE_sig
process(clk, reset) 
begin
   if reset = '0' then
		RAM_WE_sig <= '0';
   elsif rising_edge(clk) then		
		if async_flags(IDLE_FLAG) = '1' then
			RAM_WE_sig <= RAM_WE;
		end if;
	end if;
end process; 

-------------------------------------------------------------------------------
---------------------- MT45W8MW16BGX Signals ----------------------------------
-------------------------------------------------------------------------------
MT_DATA 				<= RAM_DATA_reg when RAM_WE_sig = '0' else -- write op
							(others => 'Z');
							
MT_CLK <= '0';		

MT_CRE <= '0';	-- hold low, active high, control register enable				
							
MT_ADDR <= RAM_ADDR_reg;	

-- MT_WE
process(clk, reset) 
begin
   if reset = '0' then
		MT_WE <= '1';
   elsif rising_edge(clk) then		
		if async_flags(PERFORM_OP_FLAG) = '1' then
			MT_WE <= RAM_WE_sig;
		else
			MT_WE <= '1';
		end if;
	end if;
end process; 

-- Control Signals
process(clk, reset) 
begin
   if reset = '0' then
		MT_OE 	<= '1';
		MT_ADV 	<= '1';
		MT_UB 	<= '1';
		MT_LB 	<= '1';
		MT_CE 	<= '1';
   elsif rising_edge(clk) then		
		if async_flags(PERFORM_OP_FLAG) = '1' then
			MT_OE 	<= '0';
			MT_ADV 	<= '0';
			MT_UB 	<= '0';
			MT_LB 	<= '0';
			MT_CE 	<= '0';
		else
			MT_OE 	<= '1';
			MT_ADV 	<= '1';
			MT_UB 	<= '1';
			MT_LB 	<= '1';
			MT_CE 	<= '1';
		end if;
	end if;
end process; 						

-------------------------------------------------------------------------------
---------------------- RAM_Module_states --------------------------------------
-------------------------------------------------------------------------------

states : RAM_Module_states
port map(
	clk 								=> clk,
	rst_n 							=> reset,
	RAM_Start_Op					=> RAM_Start_Op,	
	count								=> count,
	init_counter					=> init_counter,
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


-- init_counter
process(clk, reset) 
begin
   if reset = '0' then
		init_counter <= (others => '0');
   elsif rising_edge(clk) then		
		if async_flags(RAM_RESET_FLAG) = '1' then
			init_counter <= init_counter + 1;
		elsif async_flags(IDLE_FLAG) = '1' then
			init_counter <= (others => '0');
		end if;
	end if;
end process; 


end Behavioral;

