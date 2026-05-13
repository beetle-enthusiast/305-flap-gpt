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
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(479 - 8, 10);
SIGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);


BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(590,11);

ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & ball_y_pos <= pixel_row + size) and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';


-- Colours for pixel data on video signal
-- Changing the background colour by pushbuttons
-- Ball colour alternates between white and black
ball_white <= ball_on and ball_collision;

Red   <= (pb1 and (not ball_on)) or ball_white;
Green <= ((not pb2) and (not ball_on)) or ball_white;
Blue  <= (pb2 and (not ball_on)) or ball_white;



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

END behavior;

