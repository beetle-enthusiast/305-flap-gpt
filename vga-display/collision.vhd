LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;


ENTITY collision IS
	PORT
		( clk, vert_sync, ball_on, pipe_on	: IN std_logic;
          ball_y_pos, ball_size	: IN std_logic_vector(9 DOWNTO 0);
		  collision, pipe_start, ball_enable: OUT std_logic);		
END collision;

architecture behavior of collision is

SIGNAL collision_temp : std_logic := '0';
SIGNAL collision_reset : std_logic := '0';
SIGNAL reset : std_logic:= '0';
SIGNAL collision_per_frame: std_logic:= '0';
SIGNAL prev_collision_per_frame: std_logic:= '0';



BEGIN           

Check_Collision: process (clk) 

begin
	-- Move ball once every clk cycle
	if (rising_edge(clk)) then
	
		if (reset = '1') then
			-- reset everything
			collision_temp <= '0';
		else
	
			if (collision_reset = '1') then
				collision_temp <= '0';
			
			-- if collision detected with pipes or ceiling
			elsif ((ball_y_pos <= ball_size) or (ball_on = '1' and pipe_on = '1')) then
				collision_temp <= '1';
		
			-- bird hits bottom = dead
			elsif ( ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - ball_size) ) then
				-- We have hit the bottom => stay still (move zero pixels)
					collision_temp <= '0'; -- CHANGE LATER (make this a death signal)
			end if;
			
			-- Create reset pulse only once when collision detected
			if ((collision_per_frame = '1') and (prev_collision_per_frame = '0')) then
				collision_reset <= '1';
			
			else 
				collision_reset <= '0';
			end if;
			
		end if;
		
		-- For checking if reset pulse should be made 
		prev_collision_per_frame <= collision_per_frame;
		
	end if;
end process Check_Collision;

--Process during Vert_Sync to reset the collision signal
Reset_collision: process(vert_sync)
begin

	if (rising_edge(vert_sync)) then
	
		if (reset = '1') then
			collision_per_frame <= '0';
			pipe_start <= '1';
			ball_enable <= '1';
			
		else 
			-- if the collision temp is 1 then pull it down to zero
			collision_per_frame <= collision_temp;
			
			if (collision_temp = '1') then
				pipe_start <= '0';
				ball_enable <= '0';
			else 
				pipe_start <= '1';
				ball_enable <= '1';
			end if;
			
		end if;
		
	end if;
end process Reset_collision;


--Signal assignments to output
collision <= collision_temp;

END behavior;

