LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;


ENTITY points IS
	PORT
		( vert_sync, pipe_passed, coffee_hit: IN std_logic;
		  total_points: OUT integer);		
END points;

architecture behavior of points is

SIGNAL total_points_temp: integer := 0;

BEGIN           

Calculate_points: process (vert_sync) 
begin
    -- Calculate points every vertical sync
    -- Pipe passed = 1 point, coffee bean hit = 2 points
    if (rising_edge(vert_sync)) then
        if (pipe_passed = '1') then
            total_points_temp <= total_points_temp + 1;
        end if;
        
        if (coffee_hit = '1') then
            total_points_temp <= total_points_temp + 2;
        end if;
    end if;
	
	
end process Calculate_points;

--Signal assignments to output
total_points <= total_points_temp;

END behavior;