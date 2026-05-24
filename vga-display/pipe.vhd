LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;


ENTITY pipe IS
	PORT
		( vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END pipe;

architecture behavior of pipe is

SIGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(500, 11);
SIGNAL pipe_y_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_width_radius, pipe_height_radius : std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_on					: std_logic;


BEGIN           

pipe_width_radius <= CONV_STD_LOGIC_VECTOR(10, 10); -- pipe width is 20 pixels 
pipe_height_radius <= CONV_STD_LOGIC_VECTOR(200, 10); -- pipe height is 400 pixels 

-- pipe_x_pos and pipe_y_pos show the (x,y) for position for the pipe
pipe_y_pos <= CONV_STD_LOGIC_VECTOR(479 - 200, 10); -- Example y position for the pipe 

-- Determine the pixels where the pipe should be drawn 
pipe_on <= '1' when ( ('0' & pipe_x_pos <= '0' & pixel_column + pipe_width_radius) 
								and ('0' & pixel_column <= '0' & pipe_x_pos + pipe_width_radius) 	-- x_pos <= pixel_column <= x_pos + pipe_width_radius
								and ('0' & pipe_y_pos <= '0' & pixel_row + pipe_height_radius) 
								and ('0' & pixel_row <= '0' & pipe_y_pos + pipe_height_radius) )  
					else	
				'0';

-- Colours for pixel data on video signal
Red   <= pipe_on;
Green <= not pipe_on;
Blue  <= not pipe_on;

Move_Pipe: process (vert_sync) 
VARIABLE pipe_x_motion: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(0, 10); 	
VARIABLE at_end: std_logic:= '0';
VARIABLE starting_pos: integer:= 600; -- arbitrary constant 

begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then
			
		-- Move the pipe to the left
		pipe_x_motion := - CONV_STD_LOGIC_VECTOR(1, 10);
		
		-- Clamp to boundaries
		if (pipe_x_pos + pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0, 11) - pipe_width_radius) then
			 pipe_x_motion := CONV_STD_LOGIC_VECTOR(starting_pos,10);
		end if;
		
		-- Compute next ball Y position (if at top or bottom, then don't go further up)
		pipe_x_pos <= pipe_x_pos + pipe_x_motion;

		
	end if;
end process Move_Pipe;

END behavior;

