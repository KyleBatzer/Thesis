--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:24:32 02/29/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/SVN_Thesis/FPGA Code/RS232_Module_Test_Rev_0.3/Command_Handler_tb.vhd
-- Project Name:  RS232_Module_Test_Rev_0.3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Command_Handler
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
 
ENTITY Command_Handler_tb IS
END Command_Handler_tb;
 
ARCHITECTURE behavior OF Command_Handler_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Command_Handler
    Port ( clk 						: in  STD_LOGIC;
           reset 						: in  STD_LOGIC;

			  Channel1_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel2_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel3_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel4_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel5_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel6_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel7_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  Channel8_Config 		: out STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX_FIFO Signals
			  RX_FIFO_RD_CLK			: out STD_LOGIC; 
			  RX_FIFO_DOUT				: in  STD_LOGIC_VECTOR (7 downto 0);
			  RX_FIFO_RD_EN			: out STD_LOGIC;
			  RX_FIFO_EMPTY			: in  STD_LOGIC;
			  
			  -- TX FIFO Signals
			  TX_FIFO_WR_CLK			: out STD_LOGIC;
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
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal RX_FIFO_DOUT : std_logic_vector(7 downto 0) := (others => '0');
   signal RX_FIFO_EMPTY : std_logic := '0';
	signal RAM_Op_Done : std_logic := '0';
	signal RAM_DOUT : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Channel1_Config : std_logic_vector(7 downto 0);
   signal Channel2_Config : std_logic_vector(7 downto 0);
   signal Channel3_Config : std_logic_vector(7 downto 0);
   signal Channel4_Config : std_logic_vector(7 downto 0);
   signal Channel5_Config : std_logic_vector(7 downto 0);
   signal Channel6_Config : std_logic_vector(7 downto 0);
   signal Channel7_Config : std_logic_vector(7 downto 0);
   signal Channel8_Config : std_logic_vector(7 downto 0);
   signal RX_FIFO_RD_CLK : std_logic;
   signal RX_FIFO_RD_EN : std_logic;
   signal TX_FIFO_WR_CLK : std_logic;
   signal TX_FIFO_DIN : std_logic_vector(7 downto 0);
   signal TX_FIFO_WR_EN : std_logic;
	signal RAM_Start_Op : std_logic;
	signal RAM_WE : std_logic;
	signal RAM_ADDR : std_logic_vector(22 downto 0);
	signal RAM_DIN : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20ns;
 
BEGIN

	-- RAM_Op_Done
process(clk, reset) 
begin
   if reset = '0' then
		RAM_Op_Done <= '0';
   elsif rising_edge(clk) then		
		if RAM_Start_Op = '1' then
			RAM_Op_Done <= '1';
		else
			RAM_Op_Done <= '0';
		end if;
	end if;
end process;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Command_Handler PORT MAP (
          clk => clk,
          reset => reset,
          Channel1_Config => Channel1_Config,
          Channel2_Config => Channel2_Config,
          Channel3_Config => Channel3_Config,
          Channel4_Config => Channel4_Config,
          Channel5_Config => Channel5_Config,
          Channel6_Config => Channel6_Config,
          Channel7_Config => Channel7_Config,
          Channel8_Config => Channel8_Config,
          RX_FIFO_RD_CLK => RX_FIFO_RD_CLK,
          RX_FIFO_DOUT => RX_FIFO_DOUT,
          RX_FIFO_RD_EN => RX_FIFO_RD_EN,
          RX_FIFO_EMPTY => RX_FIFO_EMPTY,
          TX_FIFO_WR_CLK => TX_FIFO_WR_CLK,
          TX_FIFO_DIN => TX_FIFO_DIN,
          TX_FIFO_WR_EN => TX_FIFO_WR_EN,
			 RAM_Start_Op				=> RAM_Start_Op,
			 RAM_Op_Done				=> RAM_Op_Done,
			 RAM_WE						=> RAM_WE,
			 RAM_ADDR					=> RAM_ADDR,
			 RAM_DOUT					=> RAM_DOUT,
			 RAM_DIN						=> RAM_DIN
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
		RX_FIFO_EMPTY <= '1';
      wait for 100ns;	
		reset <= '1';
		
		RX_FIFO_EMPTY <= '0';
		RX_FIFO_DOUT <= x"5A";
		wait for 20ns;
		
-- config chan
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"01";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
--		
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"00";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
--		
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"07";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
--		
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"01";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
--		
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"1F";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
--		
--		RX_FIFO_EMPTY <= '1';
--		wait for 500ns;
--		RX_FIFO_DOUT <= x"82";
--		RX_FIFO_EMPTY <= '0';
--		wait for 20ns;
		
-- SetWaveform
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"05";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"00";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"0B";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"01";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"01";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"12";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"34";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"56";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"78";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		RX_FIFO_EMPTY <= '1';
		wait for 500ns;
		RX_FIFO_DOUT <= x"FF";
		RX_FIFO_EMPTY <= '0';
		wait for 20ns;
		
		
	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
