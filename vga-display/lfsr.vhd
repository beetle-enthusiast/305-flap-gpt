LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY lfsr IS
	PORT
		(clk, enable: IN std_logic;
		  random_value: OUT std_logic_vector(7 DOWNTO 0));		
END lfsr;

architecture behavior of lfsr is

SIGNAL lfsr_reg : std_logic_vector(7 DOWNTO 0) := "10101010"; -- Initial value for the LFSR
BEGIN

Randomiser: process (clk) 
VARIABLE feedback : std_logic;

BEGIN
	if (rising_edge(clk)) then
		  if (enable = '1') then
		  
			  -- Calculate feedback using taps at positions 8, 4, 3, and 1 (0-based indexing)
			  feedback := lfsr_reg(7) XOR lfsr_reg(3) XOR lfsr_reg(2) XOR lfsr_reg(1);
			  
			  -- Shift the register to the right and insert feedback at the leftmost bit
			  lfsr_reg <= feedback & lfsr_reg(7 downto 1);
		  end if;
	end if;
end process Randomiser;

random_value <= lfsr_reg; -- Output the current value of the LFSR

END behavior;

