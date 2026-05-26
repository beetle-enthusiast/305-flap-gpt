LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;


ENTITY collision IS
	PORT
		( vert_sync	: IN std_logic;
          ball_y_pos, ball_size	: IN std_logic_vector(9 DOWNTO 0);
		  collision: OUT std_logic);		
END collision;

architecture behavior of collision is

SIGNAL collision_temp : std_logic := '0';

BEGIN           

Check_Collision: process (vert_sync) 
begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then

		-- Bounce off top or bottom of the screen
		if ( ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - ball_size) ) then
		   -- We have hit the bottom => stay still (move zero pixels)
            collision_temp <= '0';
			
		elsif (ball_y_pos <= ball_size) then 
		   -- We have hit the top
			--Collision
			collision_temp <= '1';
		
			
		else
			--No collision
			collision_temp <= '0';

		end if;
		
	end if;
end process Check_Collision;


--Signal assignments to output
collision <= collision_temp;

END behavior;

