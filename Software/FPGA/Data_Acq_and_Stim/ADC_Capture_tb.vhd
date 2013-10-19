--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:54:59 02/10/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/Thesis/2-10-12/Cypress Compatible FPGA Code/Data_Acq_8Channel_ADC_Test/ADC_Capture_tb.vhd
-- Project Name:  Data_Acq_8Channel_ADC_Test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ADC_Capture
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
 
ENTITY ADC_Capture_tb IS
END ADC_Capture_tb;
 
ARCHITECTURE behavior OF ADC_Capture_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ADC_Capture
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         CS : OUT  std_logic;
         adcRANGE : OUT  std_logic;
         adcRESET : OUT  std_logic;
         adcSTDBY : OUT  std_logic;
         convST : OUT  std_logic;
         ovrSAMPLE : OUT  std_logic_vector(2 downto 0);
         refSEL : OUT  std_logic;
         sCLK : OUT  std_logic;
         serSEL : OUT  std_logic;
         doutA : IN  std_logic;
         doutB : IN  std_logic;
         Busy : IN  std_logic;
         ADC_Capture_Start : IN  std_logic;
         ADC_Capture_Done : OUT  std_logic;
         Channel1_Data : OUT  std_logic_vector(15 downto 0);
         Channel2_Data : OUT  std_logic_vector(15 downto 0);
         Channel3_Data : OUT  std_logic_vector(15 downto 0);
         Channel4_Data : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal doutA : std_logic := '0';
   signal doutB : std_logic := '0';
   signal Busy : std_logic := '0';
   signal ADC_Capture_Start : std_logic := '0';

 	--Outputs
   signal CS : std_logic;
   signal adcRANGE : std_logic;
   signal adcRESET : std_logic;
   signal adcSTDBY : std_logic;
   signal convST : std_logic;
   signal ovrSAMPLE : std_logic_vector(2 downto 0);
   signal refSEL : std_logic;
   signal sCLK : std_logic;
   signal serSEL : std_logic;
   signal ADC_Capture_Done : std_logic;
   signal Channel1_Data : std_logic_vector(15 downto 0);
   signal Channel2_Data : std_logic_vector(15 downto 0);
   signal Channel3_Data : std_logic_vector(15 downto 0);
   signal Channel4_Data : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 200ns;  -- 5 MHz Clock
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ADC_Capture PORT MAP (
          clk => clk,
          reset => reset,
          CS => CS,
          adcRANGE => adcRANGE,
          adcRESET => adcRESET,
          adcSTDBY => adcSTDBY,
          convST => convST,
          ovrSAMPLE => ovrSAMPLE,
          refSEL => refSEL,
          sCLK => sCLK,
          serSEL => serSEL,
          doutA => doutA,
          doutB => doutB,
          Busy => Busy,
          ADC_Capture_Start => ADC_Capture_Start,
          ADC_Capture_Done => ADC_Capture_Done,
          Channel1_Data => Channel1_Data,
          Channel2_Data => Channel2_Data,
          Channel3_Data => Channel3_Data,
          Channel4_Data => Channel4_Data
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
		reset <= '0';
      wait for 1ms;	
		reset <= '1';
		wait for 35ms;			-- wait for adcReset
		
		ADC_Capture_Start <= '1';
		wait for clk_period;
		ADC_Capture_Start <= '0';
		Busy <= '1';
		wait for clk_period*2;
		Busy <= '0';
		doutA <= '1';
		
		
		wait for 50us;
		ADC_Capture_Start <= '1';
		wait for clk_period;
		ADC_Capture_Start <= '0';
		Busy <= '1';
		wait for clk_period*2;
		Busy <= '0';
		doutA <= '0';
		
		
		wait for 50us;
		ADC_Capture_Start <= '1';
		wait for clk_period;
		ADC_Capture_Start <= '0';
		Busy <= '1';
		wait for clk_period*2;
		Busy <= '0';	
		doutA <= '1';
		
		
		
		
		
		

      wait for clk_period*1000;

      -- insert stimulus here 

      wait;
   end process;

END;
