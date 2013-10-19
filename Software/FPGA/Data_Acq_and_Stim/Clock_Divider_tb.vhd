--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:36:11 02/10/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/Thesis/2-10-12/Cypress Compatible FPGA Code/Data_Acq_8Channel_ADC_Test/Clock_Divider_tb.vhd
-- Project Name:  Data_Acq_8Channel_ADC_Test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Clock_Divider
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
 
ENTITY Clock_Divider_tb IS
END Clock_Divider_tb;
 
ARCHITECTURE behavior OF Clock_Divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Clock_Divider
    PORT(
         clk_in : IN  std_logic;
         reset : IN  std_logic;
         clk_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal clk_out : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 20ns;
  -- constant clk_out_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Clock_Divider PORT MAP (
          clk_in => clk_in,
          reset => reset,
          clk_out => clk_out
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 
   
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		reset <= '0';
      wait for 1ms;	
		reset <= '1';

      wait for clk_in_period*100;

      -- insert stimulus here 

      wait;
   end process;

END;
