LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;


ENTITY bouncy_ball IS
	PORT
		( enable, click, clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  ball_on_out: OUT std_logic;
		  red, green, blue : OUT std_logic_vector (3 DOWNTO 0);
		  ball_y_pos, size: OUT std_logic_vector(9 DOWNTO 0);
		  ball_x_pos: OUT std_logic_vector(10 DOWNTO 0));		
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on, ball_white: std_logic;
SIGNAL prev_click, ball_collision: std_logic := '0';
SIGNAL size_temp 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos_temp				: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(479 - 8, 10);
SIGNAL ball_x_pos_temp				: std_logic_vector(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(400, 11);

BEGIN           

size_temp <= CONV_STD_LOGIC_VECTOR(8,10); -- ball radius is 8 pixels

-- Determine the pixels where the ball should be drawn 
ball_on <= '1' when ( ('0' & ball_x_pos_temp <= '0' & pixel_column + size_temp) 
							and ('0' & pixel_column <= '0' & ball_x_pos_temp + size_temp) 	-- x_pos - size <= pixel_column <= x_pos + size
							and ('0' & ball_y_pos_temp <= pixel_row + size_temp) 
							and ('0' & pixel_row <= ball_y_pos_temp + size_temp) )  
					else	-- y_pos - size <= pixel_row <= y_pos + size
				'0';
				
-- Colours for pixel data on video signal

Red   <= (others => ball_on and ball_collision);
Green <= (others => ball_on and ball_collision);
Blue  <= (others => ball_on and ball_collision);

ball_on_out <= ball_on;

Move_Ball: process (vert_sync) 
VARIABLE ball_y_motion			: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(0, 10); 	
VARIABLE at_top: std_logic:= '0';

begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync) and (enable = '1')) then
	
			
		-- Bounce off top or bottom of the screen
		if ( ('0' & ball_y_pos_temp >= CONV_STD_LOGIC_VECTOR(479,10) - size_temp) ) then
		   -- We have hit the bottom => stay still (move zero pixels)
			ball_y_motion := CONV_STD_LOGIC_VECTOR(0,10);
			at_top := '0';
			
		elsif (ball_y_pos_temp <= size_temp) then 
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
			ball_y_motion := -CONV_STD_LOGIC_VECTOR(8,10);
			prev_click <= '1';
		else
			-- Reset prev_click to '0' when click goes low
			prev_click <= click;  
		end if;	
	

		-- Compute next ball Y position (if at top or bottom, then don't go further up)
		ball_y_pos_temp <= ball_y_pos_temp + ball_y_motion;
		
		-- Clamp to boundaries
		if (ball_y_pos_temp + ball_y_motion <= size_temp) then
			 ball_y_pos_temp <= size_temp; -- if at top, let it stay at top
		end if;

		
		if (ball_y_pos_temp + ball_y_motion >= CONV_STD_LOGIC_VECTOR(479,10) - size_temp) then
			 ball_y_pos_temp <= CONV_STD_LOGIC_VECTOR(479,10) - size_temp; -- if at bottom, let it stay at bottom
		end if;
		
	end if;
end process Move_Ball;

--Output signal assignments
ball_y_pos <= ball_y_pos_temp;
ball_x_pos <= ball_x_pos_temp;
size <= size_temp;


END behavior;