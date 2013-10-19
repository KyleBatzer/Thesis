--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:12:09 01/27/2012
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Desktop/Dump to Desktop/Thesis/Cypress Compatible FPGA Code/Data_Acquisition_Test/Main_tb.vhd
-- Project Name:  Data_Acquisition_Test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Main
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

-- Import our UART tester package
use work.UART_behavioural_model.all;
 
ENTITY Main_tb IS
END Main_tb;
 
ARCHITECTURE behavior OF Main_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
COMPONENT Main
    Port ( main_clk 		: in  STD_LOGIC;
	        reset 			: in  STD_LOGIC;
			  
			  -- USB Module IO
			  USB_clk 		: in  STD_LOGIC;
			  Data 			: out  STD_LOGIC_VECTOR (7 downto 0);
			  FlagA_out		: out  STD_LOGIC;
			  idle_out		: out  STD_LOGIC;
			  --done_out		: out  STD_LOGIC;
           PktEnd 		: out  STD_LOGIC;
           FlagA 			: in   STD_LOGIC;				
           FlagB 			: in   STD_LOGIC;				
           FlagC 			: in   STD_LOGIC;				
           SLRD 			: out  STD_LOGIC;				
           SLWR 			: out  STD_LOGIC;				
           SLOE 			: out  STD_LOGIC;				
			  FIFOADDR_in	: in   STD_LOGIC_VECTOR (1 downto 0);
           FIFOADDR 		: out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  --ADC_Capture IO
			  CS						: out STD_LOGIC;
			  adcRANGE				: out STD_LOGIC;
			  adcRESET				: out STD_LOGIC;
			  adcSTDBY				: out STD_LOGIC;
			  convStA				: out STD_LOGIC;
			  convStB				: out STD_LOGIC;
			  ovrSAMPLE				: out STD_LOGIC_VECTOR(2 downto 0);
			  refSEL					: out STD_LOGIC;
			  sCLK					: out STD_LOGIC;
			  serSEL					: out STD_LOGIC;
			  doutA					: in  STD_LOGIC;
			  doutB					: in  STD_LOGIC;
			  Busy					: in  STD_LOGIC;
			   --RS232_Module
			  RX						: in  STD_LOGIC;
			  TX						: out STD_LOGIC;
			  RX_led					: out STD_LOGIC;
			  TX_led					: out STD_LOGIC;
			  
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
			  MT_CRE					: out STD_LOGIC; -- held low, active high
			  MT_WAIT				: in  STD_LOGIC; -- ignored
			  
			  -- SPI Signals
			  Stim_Active_led		: out STD_LOGIC;
			  SPI_CLK				: out STD_LOGIC;
           DAC_CS 				: out STD_LOGIC;
           MOSI 					: out STD_LOGIC
			  );
END COMPONENT;
    

   --Inputs
   signal main_clk 		: std_logic := '0';
   signal reset 			: std_logic := '1';
   signal USB_clk 		: std_logic := '0';
   signal FlagA 			: std_logic := '0';
   signal FlagB 			: std_logic := '1';
   signal FlagC 			: std_logic := '0';
   signal FIFOADDR_in 	: std_logic_vector(1 downto 0) := (others => '0');
	signal Busy				: std_logic:= '0';
	signal doutA			: std_logic:= '0';
	signal doutB			: std_logic:= '0';
	signal RX				: std_logic:= '1';
	signal MT_WAIT			: std_logic:= '0';
	
	--BiDirs
   signal MT_DATA 		: std_logic_vector(15 downto 0);

 	--Outputs
   signal Data 			: std_logic_vector(7 downto 0);
   signal FlagA_out 		: std_logic;
   signal idle_out 		: std_logic;
   --signal done_out 		: std_logic;
   signal PktEnd 			: std_logic;
   signal SLRD 			: std_logic;
   signal SLWR 			: std_logic;
   signal SLOE 			: std_logic;
   signal FIFOADDR 		: std_logic_vector(1 downto 0);
	signal CS	 			: std_logic;
	signal adcRANGE	 	: std_logic;
	signal adcRESET	 	: std_logic;
	signal adcSTDBY	 	: std_logic;
	signal convStA	 		: std_logic;
	signal convStB	 		: std_logic;
	signal ovrSAMPLE 		: std_logic_vector(2 downto 0);
	signal refSEL	 		: std_logic;
	signal sCLK	 			: std_logic;
	signal serSEL	 		: std_logic;
	signal MT_ADDR 		: std_logic_vector(22 downto 0);
   signal MT_OE 			: std_logic;
   signal MT_WE 			: std_logic;
   signal MT_ADV 			: std_logic;
   signal MT_CLK 			: std_logic;
   signal MT_UB 			: std_logic;
   signal MT_LB 			: std_logic;
   signal MT_CE 			: std_logic;
   signal MT_CRE 			: std_logic;
	signal TX	 			: std_logic;
   signal RX_LED 			: std_logic;
   signal TX_LED 			: std_logic;
	signal SPI_CLK	 		: std_logic;
   signal DAC_CS 			: std_logic;
   signal MOSI 			: std_logic;
	signal Stim_Active_led :std_logic;
	
   -- Clock period definitions
   constant main_clk_period : time := 20ns;
   constant USB_clk_period : time := 30ns;
	
	signal MT_DATA_reg : STD_LOGIC_VECTOR(15 downto 0);
 
BEGIN
MT_DATA 				<= MT_DATA_reg when MT_WE = '1' else -- read op
							(others => 'Z');
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Main PORT MAP (
          main_clk => main_clk,
          reset => reset,
          USB_clk => USB_clk,
          Data => Data,
          FlagA_out => FlagA_out,
          idle_out => idle_out,
          --done_out => done_out,
          PktEnd => PktEnd,
          FlagA => FlagA,
          FlagB => FlagB,
          FlagC => FlagC,
          SLRD => SLRD,
          SLWR => SLWR,
          SLOE => SLOE,
          FIFOADDR_in => FIFOADDR_in,
          FIFOADDR => FIFOADDR,
			 CS						=> CS,
			 adcRANGE				=> adcRANGE,
			 adcRESET				=> adcRESET,
			 adcSTDBY				=> adcSTDBY,
			 convStA					=> convStA,
			 convStB					=> convStB,
			 ovrSAMPLE				=> ovrSAMPLE,
			 refSEL					=> refSEL,
			 sCLK						=> sCLK,
			 serSEL					=> serSEL,
			 doutA					=> doutA,
			 doutB					=> doutB,
			 Busy						=> Busy,
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
			 RX									=> RX,
			 TX									=> TX,
			 RX_led								=> RX_led,
			 TX_led								=> TX_led,
			 Stim_Active_led					=> Stim_Active_led,
			 SPI_CLK	 							=> SPI_CLK,
			 DAC_CS 								=> DAC_CS,
			 MOSI 								=> MOSI
        );

   -- Clock process definitions
   main_clk_process :process
   begin
		main_clk <= '0';
		wait for main_clk_period/2;
		main_clk <= '1';
		wait for main_clk_period/2;
   end process;
 
   USB_clk_process :process
   begin
		USB_clk <= '0';
		wait for USB_clk_period/2;
		USB_clk <= '1';
		wait for USB_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		reset <= '0';
      wait for 60ns;
		reset <= '1';
		wait for 1ms;
		FlagB <= '0';
		wait for 1ms;
		FlagB <= '1';

      --wait for main_clk_period*100;

      -- insert stimulus here 

      wait;
   end process;
	
	Testing: process

	constant My_Baud_Rate: integer := 115200;
	-- Make a jacket procedure around UART_tx, for convenience
	procedure send (data: in std_logic_vector) is
	begin
	UART_tx(
	tx_line => RX,
	data => data,
	baud_rate => My_Baud_Rate
	);
	end;

	variable D: std_logic_vector(7 downto 0);

	begin
	
	MT_DATA_reg <= x"0003";

	-- Idle awhile
	wait for 150 us;

	-- Send Config_Chan
--	send(x"5A"); wait for 50 us;
--	send(x"01"); wait for 50 us;
--	send(x"00"); wait for 50 us;
--	send(x"07"); wait for 50 us;
--	send(x"01"); wait for 50 us;
--	send(x"1F"); wait for 50 us;
--	send(x"FF"); wait for 50 us;
	
	-- Send Set_Waveform
	send(x"5A"); wait for 50 us;
	send(x"05"); wait for 50 us;
	send(x"00"); wait for 50 us;
	send(x"0B"); wait for 50 us;
	send(x"01"); wait for 50 us;
	send(x"01"); wait for 50 us;
	send(x"12"); wait for 50 us;
	send(x"34"); wait for 50 us;
	send(x"56"); wait for 50 us;
	send(x"78"); wait for 50 us;
	send(x"FF"); wait for 50 us;
	
	wait for 100 us;
	
	
	-- Send Set_Stim to start multi stim
	send(x"5A"); wait for 50 us;
	send(x"07"); wait for 50 us;
	send(x"00"); wait for 50 us;
	send(x"07"); wait for 50 us;
	send(x"01"); wait for 50 us;
	send(x"01"); wait for 50 us;
	send(x"FF"); wait for 50 us;
	
	wait for 200 us;
	
	-- Send Set_Stim to stop multi stim
	send(x"5A"); wait for 50 us;
	send(x"07"); wait for 50 us;
	send(x"00"); wait for 50 us;
	send(x"07"); wait for 50 us;
	send(x"00"); wait for 50 us;
	send(x"00"); wait for 50 us;
	send(x"FF"); wait for 50 us;
	
	 

--	-- Some more characters - use a walking-ones pattern:
--	for i in D'range loop
--	D := (others => '0');
--	D(i) := '1';
--	send(D);
--	wait for 50 us;
--	end loop;
--	
--	-- Idle some more
--	wait for 50 us;
--	
--	-- And finally, just for fun, send a 10-bit character:
--	send("1111100000");

	wait; -- That's All Folks
	end process;
	
	-- Busy
process(main_clk, reset) 
begin
   if reset = '0' then
		Busy <= '0';
   elsif rising_edge(main_clk) and convStA = '0' then
		Busy <= '1';
	elsif rising_edge(main_clk) then
		Busy <= '0';
	end if;
end process; 

END;
