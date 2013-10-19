------------------------------------------------------ package ---

library IEEE;
use IEEE.std_logic_1164.all;

package UART_behavioural_model is

procedure UART_tx (

-- The signal that is to be driven by this model...
signal tx_line: out std_logic;

-- Inputs to control how to send one character:
data: in std_logic_vector; -- usually 8 bits
baud_rate:in integer -- e.g. 9600
);

end package UART_behavioural_model;

--------------------------------------------------- package body ---

package body UART_behavioural_model is

procedure UART_tx (

-- The signal that is to be driven by this model...
signal tx_line: out std_logic;

-- Inputs to control how to send one character:
data: in std_logic_vector; -- usually 8 bits
baud_rate:in integer -- e.g. 9600
) is

constant bit_time: time := 1 sec / baud_rate;

begin
 
-- Send the start bit
tx_line <= '0';
wait for bit_time;

-- Send the data bits, least significant first
for i in data'reverse_range loop
tx_line <= data(i);
wait for bit_time;
end loop;

-- Send the stop bit
tx_line <= '1';
wait for bit_time;

end; -- procedure UART_tx

end package body UART_behavioural_model;