LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY lfsr IS
	PORT
		(clk, enable: IN std_logic;
		  random_value1: OUT std_logic_vector(7 DOWNTO 0);
		  random_value2: OUT std_logic_vector(7 DOWNTO 0));		
END lfsr;

architecture behavior of lfsr is

SIGNAL lfsr_reg1 : std_logic_vector(7 DOWNTO 0) := "10101010"; -- Initial value for the LFSR
SIGNAL lfsr_reg2 : std_logic_vector(7 DOWNTO 0) := "01010101"; -- Initial value for the second LFSR

BEGIN

Randomiser: process (clk) 
VARIABLE feedback1 : std_logic;
VARIABLE feedback2 : std_logic;


BEGIN
	if (rising_edge(clk)) then
		  if (enable = '1') then
			  -- Calculate feedback using taps at positions 8, 4, 3, and 1 (0-based indexing)
			  feedback1 := lfsr_reg1(7) XOR lfsr_reg1(3) XOR lfsr_reg1(2) XOR lfsr_reg1(1);
			  feedback2 := lfsr_reg2(7) XOR lfsr_reg2(3) XOR lfsr_reg2(2) XOR lfsr_reg2(1);
			  
			  -- Shift the register to the right and insert feedback at the leftmost bit
			  lfsr_reg1 <= feedback1 & lfsr_reg1(7 downto 1);
			  lfsr_reg2 <= feedback2 & lfsr_reg2(7 downto 1);

		  end if;
	end if;
end process Randomiser;

random_value1 <= lfsr_reg1; -- Output the current value of the LFSR
random_value2 <= lfsr_reg2; -- Output the current value of the second LFSR

END behavior;