--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:07:59 05/11/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/SVN_Thesis/FPGA Code/Data_Acq_and_Stim_Ver_0.5/Arbiter_tb.vhd
-- Project Name:  Data_Acq_and_Stim_Ver_0.5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Arbiter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY Arbiter_tb IS
END Arbiter_tb;
 
ARCHITECTURE behavior OF Arbiter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Arbiter
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         Bus_Request : IN  std_logic_vector(7 downto 0);
         Bus_Busy : IN  std_logic;
         Bus_Grant : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal Bus_Request : std_logic_vector(7 downto 0) := (others => '0');
   signal Bus_Busy : std_logic := '0';

 	--Outputs
   signal Bus_Grant : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Arbiter PORT MAP (
          clk => clk,
          reset => reset,
          Bus_Request => Bus_Request,
          Bus_Busy => Bus_Busy,
          Bus_Grant => Bus_Grant
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		Bus_Request <= x"00";
		Bus_Busy <= '0';
		reset <= '0';
      wait for 100ns;	
		reset <= '1';
      wait for clk_period*5;
		
		Bus_Request(0) <= '1';
		Bus_Request(5) <= '1';
		wait for clk_period*3;
		Bus_Request(0) <= '0';	
		Bus_Busy <= '1';
		wait for clk_period*10;
		Bus_Busy <= '0';
		
		wait for clk_period*10;
		
		--Bus_Request(5) <= '1';		
		wait for clk_period*3;
		Bus_Request(5) <= '0';	
		Bus_Busy <= '1';
		wait for clk_period*10;
		Bus_Busy <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
