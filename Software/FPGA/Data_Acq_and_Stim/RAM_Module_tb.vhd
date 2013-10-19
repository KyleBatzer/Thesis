--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:03:04 03/07/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/SVN_Thesis/FPGA Code/Micron_RAM_Test/RAM_Module_tb.vhd
-- Project Name:  Micron_RAM_Test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RAM_Module
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
 
ENTITY RAM_Module_tb IS
END RAM_Module_tb;
 
ARCHITECTURE behavior OF RAM_Module_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM_Module
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         MT_ADDR : OUT  std_logic_vector(22 downto 0);
         MT_DATA : INOUT  std_logic_vector(15 downto 0);
         MT_OE : OUT  std_logic;
         MT_WE : OUT  std_logic;
         MT_ADV : OUT  std_logic;
         MT_CLK : OUT  std_logic;
         MT_UB : OUT  std_logic;
         MT_LB : OUT  std_logic;
         MT_CE : OUT  std_logic;
         MT_CRE : OUT  std_logic;
         MT_WAIT : IN  std_logic;
         RAM_Start_Op : IN  std_logic;
         RAM_Op_Done : OUT  std_logic;
         RAM_WE : IN  std_logic;
         RAM_ADDR : IN  std_logic_vector(22 downto 0);
         RAM_DOUT : OUT  std_logic_vector(15 downto 0);
         RAM_DIN : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal MT_WAIT : std_logic := '0';
   signal RAM_Start_Op : std_logic := '0';
   signal RAM_WE : std_logic := '0';
   signal RAM_ADDR : std_logic_vector(22 downto 0) := (others => '0');
   signal RAM_DIN : std_logic_vector(15 downto 0) := (others => '0');

	--BiDirs
   signal MT_DATA : std_logic_vector(15 downto 0);

 	--Outputs
   signal MT_ADDR : std_logic_vector(22 downto 0);
   signal MT_OE : std_logic;
   signal MT_WE : std_logic;
   signal MT_ADV : std_logic;
   signal MT_CLK : std_logic;
   signal MT_UB : std_logic;
   signal MT_LB : std_logic;
   signal MT_CE : std_logic;
   signal MT_CRE : std_logic;
   signal RAM_Op_Done : std_logic;
   signal RAM_DOUT : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20ns;
	
	signal MT_DATA_reg : STD_LOGIC_VECTOR(15 downto 0);
 
BEGIN
MT_DATA 				<= MT_DATA_reg when MT_WE = '1' else -- read op
							(others => 'Z');
	
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM_Module PORT MAP (
          clk => clk,
          reset => reset,
          MT_ADDR => MT_ADDR,
          MT_DATA => MT_DATA,
          MT_OE => MT_OE,
          MT_WE => MT_WE,
          MT_ADV => MT_ADV,
          MT_CLK => MT_CLK,
          MT_UB => MT_UB,
          MT_LB => MT_LB,
          MT_CE => MT_CE,
          MT_CRE => MT_CRE,
          MT_WAIT => MT_WAIT,
          RAM_Start_Op => RAM_Start_Op,
          RAM_Op_Done => RAM_Op_Done,
          RAM_WE => RAM_WE,
          RAM_ADDR => RAM_ADDR,
          RAM_DOUT => RAM_DOUT,
          RAM_DIN => RAM_DIN
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
		reset <= '0';

      wait for 100ns;	
		reset <= '1';
		
		wait for 150us;
		
		RAM_WE <= '0';
		RAM_ADDR <= "0000000" & x"0010";
		RAM_DIN <= x"A55A";
		wait for 20ns;
		RAM_Start_Op <= '1';
		wait for 20ns;
		RAM_Start_Op <= '0';
		
		wait for 500ns;
		
		RAM_WE <= '1';
		RAM_ADDR <= "0000000" & x"0010";
		--RAM_DIN <= x"A55A";
		MT_DATA_reg <= x"F0F0";
		wait for 20ns;
		RAM_Start_Op <= '1';
		wait for 20ns;
		RAM_Start_Op <= '0';
		
		

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
