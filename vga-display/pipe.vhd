LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY pipe IS
	PORT
		(enable, start, vert_sync	: IN std_logic;
		clk : IN STD_LOGIC;
        pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          randomiser_value: IN std_logic_vector(7 DOWNTO 0);
		  pipe_x_pos: OUT std_logic_vector(10 DOWNTO 0);
		  pipe_y_pos: OUT std_logic_vector(9 DOWNTO 0);
		  pipe_r,pipe_b,pipe_g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		  pipe_on, pipe_enable: OUT std_logic);		
END pipe;

architecture behavior of pipe is
SIGNAL pipe_gap_on			: std_logic;
SIGNAL pipe_width_radius	: std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_height_radius  : std_logic_vector(9 DOWNTO 0);
SIGNAL gap_constant			: std_logic_vector (9 DOWNTO 0);
SIGNAL pipe_x_temp_pos		: std_logic_vector (10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(639, 11);
SIGNAL pipe_y_temp_pos		: std_logic_vector (9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(479 - 200, 10);
SIGNAL pipe_gap_pos		   : std_logic_vector (9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(479 - 200, 10);
SIGNAL started					: std_logic:= '0';
SIGNAL pipe_on_sig        : std_logic;

signal rom_address : std_logic_vector(12 downto 0);
signal rom_data    : std_logic_vector(3 downto 0);
signal sprite_x, sprite_y : integer;
BEGIN           

gap_constant <= CONV_STD_LOGIC_VECTOR(50, 10) ; 
pipe_width_radius <= CONV_STD_LOGIC_VECTOR(10, 11); -- pipe width is 20 pixels 
pipe_height_radius <= CONV_STD_LOGIC_VECTOR(200, 10); -- pipe height is 400 pixels 
    
-- Determine the pixels where the pipe should be drawn 



pipe_gap_on <= '1' when (('0' & pipe_x_temp_pos <= '0' & pixel_column + pipe_width_radius) 
								and ('0' & pixel_column <= '0' & pipe_x_temp_pos + pipe_width_radius) 
								and ('0' & pipe_gap_pos <= '0' & pixel_row + gap_constant) 
								and ('0' & pixel_row <= '0' & pipe_gap_pos + gap_constant))
					else
				'0';
				
pipe_on_sig <= '1' when ( ('0' & pipe_x_temp_pos <= '0' & pixel_column + pipe_width_radius) 
                    and ('0' & pixel_column <= '0' & pipe_x_temp_pos + pipe_width_radius)
                    and ('0' & pipe_y_temp_pos <= '0' & pixel_row + pipe_height_radius) 
                    and ('0' & pixel_row <= '0' & pipe_y_temp_pos + pipe_height_radius)
                    and pipe_gap_on = '0')  
               else '0';
				
pipe_on <= pipe_on_sig;

-- ROM INSTANTIATION
PIPE_ROM_INST : entity work.pipe_rom
    port map(
        address => rom_address,
        clock   => clk,
        q       => rom_data
    );

	--Address calculation
sprite_x <= CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe_x_temp_pos(9 downto 0)) + 10;
sprite_y <= CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe_y_temp_pos) + 200;

rom_address <= CONV_STD_LOGIC_VECTOR(sprite_y * 20 + sprite_x, 13)
               when (sprite_x >= 0 and sprite_x < 20 and
                     sprite_y >= 0 and sprite_y < 400)
               else (others => '0');

-- Colour outputs
pipe_r <= rom_data when pipe_on_sig = '1' else "0000";
pipe_g <= ('0' & rom_data(3 downto 1)) when pipe_on_sig = '1' else "0000";
pipe_b <= "0000";

Move_Pipe: process (vert_sync) 
VARIABLE pipe_x_motion: std_logic_vector(10 DOWNTO 0):= -CONV_STD_LOGIC_VECTOR(1, 11); 	
VARIABLE starting_pos: std_logic_vector (10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(639, 11); 
VARIABLE end_pos: std_logic_vector (10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(0, 11); 

begin
	-- Move ball once every vertical sync
	if (rising_edge(vert_sync) and (enable = '1')) then
	
			-- So that pipes still move after they have been started
		  if (start = '1') then
            started <= '1';
				pipe_enable <= '1';
		  else 
				pipe_enable <= '0';
        end if;
	
		 if (start = '1' or started = '1') then
		 
			  if (pipe_x_temp_pos <= end_pos) then
					pipe_x_temp_pos <= starting_pos;
					pipe_gap_pos <= CONV_STD_LOGIC_VECTOR(100, 10) + ("00" & randomiser_value);
					
					
			  else
					pipe_x_temp_pos <= pipe_x_temp_pos + pipe_x_motion;
			  end if;
			  
		 end if;
	end if;

end process Move_Pipe;

-- Assign to outputs
pipe_x_pos <= pipe_x_temp_pos;
pipe_y_pos <= pipe_y_temp_pos;



END behavior;