LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( click, pb1, pb2, clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on, ball_white: std_logic;
SIGNAL prev_click, ball_collision : std_logic := '0';
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(479 - 15, 10);
SIGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(500, 11);
SIGNAL pipe_y_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_width_radius, pipe_height_radius : std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_on					: std_logic;


BEGIN           

size <= CONV_STD_LOGIC_VECTOR(15,10); -- ball radius is 8 pixels
pipe_width_radius <= CONV_STD_LOGIC_VECTOR(10, 10); -- pipe width is 20 pixels 
pipe_height_radius <= CONV_STD_LOGIC_VECTOR(50, 10); -- pipe height is 100 pixels 

-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(400,11);

-- pipe_x_pos and pipe_y_pos show the (x,y) for position for the pipe
pipe_y_pos <= CONV_STD_LOGIC_VECTOR(479 - 50, 10); -- Example y position for the pipe 

-- Determine the pixels where the ball should be drawn 
ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) 
							and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
							and ('0' & ball_y_pos <= pixel_row + size) 
							and ('0' & pixel_row <= ball_y_pos + size) )  
					else	-- y_pos - size <= pixel_row <= y_pos + size
				'0';
				

pipe_on <= '1' when ( ('0' & pipe_x_pos <= '0' & pixel_column + pipe_width_radius) 
								and ('0' & pixel_column <= '0' & pipe_x_pos + pipe_width_radius) 	-- x_pos <= pixel_column <= x_pos + pipe_width_radius
								and ('0' & pipe_y_pos <= '0' & pixel_row + pipe_height_radius) 
								and ('0' & pixel_row <= '0' & pipe_y_pos + pipe_height_radius) )  
					else	
				'0';

-- Colours for pixel data on video signal
-- Changing the background colour by pushbuttons
-- Ball colour alternates between white and black
ball_white <= ball_on and ball_collision;

Red   <= (pb1 and (not ball_on) and (not pipe_on)) or ball_white or pipe_on;
Green <= ((not pb2) and (not ball_on) and (not pipe_on)) or ball_white;
Blue  <= (pb2 and (not ball_on) and (not pipe_on)) or ball_white;



Move_Ball: process (vert_sync) 
VARIABLE ball_y_motion			: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(0, 10); 	
VARIABLE at_top: std_logic:= '0';

begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then
	
			
		-- Bounce off top or bottom of the screen
		if ( ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - size) ) then
		   -- We have hit the bottom => stay still (move zero pixels)
			ball_y_motion := CONV_STD_LOGIC_VECTOR(0,10);
			at_top := '0';
			
		elsif (ball_y_pos <= size) then 
		   -- We have hit the top => move to bottom of screen
			at_top:= '1';
			-- Alternate ball colour
			ball_collision <= not ball_collision;
			
			--Implement gravity every frame
			ball_y_motion := ball_y_motion + CONV_STD_LOGIC_VECTOR(1,10);
		
			
		else
			at_top := '0';
			--Implement gravity every frame
			ball_y_motion := ball_y_motion + CONV_STD_LOGIC_VECTOR(1,10);
		

		end if;

		
		if (click = '1' and prev_click = '0' and at_top='0') then
			-- Move ball up by 10 pixels
			ball_y_motion := -CONV_STD_LOGIC_VECTOR(10,10);
			prev_click <= '1';
		else
			-- Reset prev_click to '0' when click goes low
			prev_click <= click;  
		end if;	
	

		-- Compute next ball Y position (if at top or bottom, then don't go further up)
		ball_y_pos <= ball_y_pos + ball_y_motion;
		
		-- Clamp to boundaries
		if (ball_y_pos + ball_y_motion <= size) then
			 ball_y_pos <= size; -- if at top, let it stay at top
		end if;

		
		if (ball_y_pos + ball_y_motion >= CONV_STD_LOGIC_VECTOR(479,10) - size) then
			 ball_y_pos <= CONV_STD_LOGIC_VECTOR(479,10) - size; -- if at bottom, let it stay at bottom
		end if;
		
	end if;
end process Move_Ball;


Move_Pipe: process (vert_sync) 
VARIABLE pipe_x_motion: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(0, 10); 	
VARIABLE at_end: std_logic:= '0';

begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then
			
		-- Move the pipe to the left
		pipe_x_motion := - CONV_STD_LOGIC_VECTOR(1, 10);
		
		-- Clamp to boundaries
		if (pipe_x_pos + pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0, 11) + pipe_width_radius) then
			 --pipe_x_pos<= CONV_STD_LOGIC_VECTOR(500, 11); -- if at left end of screen, bring it back to the right
			 pipe_x_motion := CONV_STD_LOGIC_VECTOR(500,10);
		end if;
		
		-- Compute next ball Y position (if at top or bottom, then don't go further up)
		pipe_x_pos <= pipe_x_pos + pipe_x_motion;

		
	end if;
end process Move_Pipe;

END behavior;

