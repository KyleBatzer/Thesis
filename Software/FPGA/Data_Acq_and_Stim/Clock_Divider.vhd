----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:29:16 02/10/2012 
-- Design Name: 
-- Module Name:    Clock_Divider - Behavioral 
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

entity Clock_Divider is
    Port ( clk_in : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  divide_count : in STD_LOGIC_VECTOR(7 downto 0);
           clk_out : out  STD_LOGIC);
end Clock_Divider;

architecture Behavioral of Clock_Divider is

signal clk_div_count : STD_LOGIC_VECTOR(7 downto 0) := x"00";
signal clk_out_sig   : STD_LOGIC := '0';

begin

clk_out <= clk_out_sig;

-- convST
process(clk_in, reset) 
begin
   if reset = '0' then
		clk_out_sig <= '0';
		clk_div_count <= (others => '0');
   elsif rising_edge(clk_in) then		
		if clk_div_count = divide_count then
			clk_div_count <= (others => '0');
			clk_out_sig <= not clk_out_sig;
		else
			clk_div_count <= clk_div_count + 1;
		end if;
	end if;
end process;


end Behavioral;

