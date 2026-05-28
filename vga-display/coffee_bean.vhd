LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


ENTITY coffee_bean IS
	PORT
		(enable, start, vert_sync, pipe_on	: IN std_logic;
        pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
			randomiser_value_y: IN std_logic_vector(7 DOWNTO 0);
			bean_r: OUT std_logic_vector(3 DOWNTO 0);
			bean_g: OUT std_logic_vector(3 DOWNTO 0);
			bean_b: OUT std_logic_vector(3 DOWNTO 0);
		  bean_x_pos: OUT std_logic_vector(10 DOWNTO 0);
		  bean_y_pos: OUT std_logic_vector(9 DOWNTO 0);
		  bean_on, bean_enable: OUT std_logic);		
END coffee_bean;

architecture behavior of coffee_bean is
SIGNAL bean_size        : unsigned(9 DOWNTO 0);
SIGNAL bean_x_temp_pos  : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
SIGNAL bean_y_temp_pos  : unsigned(9 DOWNTO 0)  := to_unsigned(300, 10);
SIGNAL started, bean_on_temp				: std_logic:= '0';

BEGIN           
-- Random values determine starting x and y position of the bean when it starts
bean_size <= to_unsigned(5, 10);

--Colour signals

bean_r <= "0000";
bean_g <= "1111" when bean_on_temp = '1' else "0000";
bean_b <= "0000";


-- Determine the pixels where the bean should be drawn 				
bean_on_temp <= '1' when (bean_x_temp_pos <= unsigned(pixel_column) + bean_size AND
									unsigned(pixel_column) <= bean_x_temp_pos + bean_size AND
									bean_y_temp_pos <= unsigned(pixel_row) + bean_size AND
									unsigned(pixel_row) <= bean_y_temp_pos + bean_size AND 
									pipe_on = '0') 
						else	
					'0';
				

Move_Bean: process (vert_sync) 
VARIABLE bean_x_motion : integer := -1;
VARIABLE starting_pos  : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
VARIABLE end_pos       : unsigned(10 DOWNTO 0) := to_unsigned(0, 11);

begin
	-- Move bean once every vertical sync
	if (rising_edge(vert_sync) and (enable = '1')) then
	
        -- So that pipes still move after they have been started
        if (start = '1') then
				started <= '1';
            bean_enable <= '1';

        else 
            bean_enable <= '0';
        end if;
	
		if (start = '1' or started = '1') then
            if (bean_x_temp_pos <= end_pos) then
					 -- Determine the bean position using lfsr everytime we are at the end
							bean_y_temp_pos <= to_unsigned(to_integer(unsigned(randomiser_value_y)) mod (480 - to_integer(bean_size)), 10);

							bean_x_temp_pos <= starting_pos;
            else
                -- Moving beans to the left of the screen every VGA sync
                bean_x_temp_pos <= bean_x_temp_pos -1 ;
            end if;	  
		 end if;
	end if;

end process Move_Bean;

-- Assign to outputs
bean_x_pos <= std_logic_vector(bean_x_temp_pos);
bean_y_pos <= std_logic_vector(bean_y_temp_pos);
bean_on <= bean_on_temp;

END behavior;