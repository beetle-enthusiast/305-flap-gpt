LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bird IS
    PORT (
        enable, click, clk, vert_sync : IN std_logic;
        pixel_row, pixel_column       : IN std_logic_vector(9 DOWNTO 0);
        bird_on_out                   : OUT std_logic;
        red, green, blue              : OUT std_logic_vector(3 DOWNTO 0);
        bird_y_pos, size              : OUT std_logic_vector(9 DOWNTO 0);
        bird_x_pos                    : OUT std_logic_vector(10 DOWNTO 0)
    );
END bird;

ARCHITECTURE behavior OF bird IS

SIGNAL bird_on: std_logic := '0';
SIGNAL prev_click              : std_logic := '0';
SIGNAL start: std_logic:= '0';
SIGNAL size_temp        : unsigned(9 DOWNTO 0)  := to_unsigned(8, 10);          -- radius = 8
SIGNAL bird_y_pos_temp  : unsigned(9 DOWNTO 0)  := to_unsigned(240 - 8, 10);    -- start near bottom
SIGNAL bird_x_pos_temp  : unsigned(10 DOWNTO 0) := to_unsigned(200, 11);        -- fixed X

-- ROM SIGNALS
SIGNAL rom_data : std_logic_vector(11 downto 0);
SIGNAL rom_address : std_logic_vector(11 downto 0);
SIGNAL sprite_on : std_logic;
SIGNAL row_offset,col_offset : std_logic_vector( 9 downto 0);
SIGNAL in_sprite_bounds : std_logic;
SIGNAL in_sprite_bounds_reg : std_logic := '0';

SIGNAL vs_prev : std_logic := '0';
SIGNAL enable_reg : std_logic := '0';


BEGIN       


 -- bird coverage
bird_on <= '1' WHEN
    (unsigned(bird_x_pos_temp) <= unsigned(pixel_column) + size_temp AND
        unsigned(pixel_column)    <= unsigned(bird_x_pos_temp) + size_temp AND
        unsigned(bird_y_pos_temp) <= unsigned(pixel_row) + size_temp AND
        unsigned(pixel_row)       <= unsigned(bird_y_pos_temp) + size_temp)
    ELSE '0';


-- Rom component
SPRTIE_ROM : entity work.bird
    port map(
        address => rom_address,
        clock => clk,
        q => rom_data
    );

Sprite : process(clk) 
begin 
	if rising_edge(clk) then 
		if (unsigned(pixel_row) >= unsigned(bird_y_pos_temp) - 16 and
    unsigned(pixel_row) <  unsigned(bird_y_pos_temp) + 16 and
    unsigned(pixel_column) >= unsigned(bird_x_pos_temp(9 downto 0)) - 16 and
    unsigned(pixel_column) <  unsigned(bird_x_pos_temp(9 downto 0)) + 16) then 
		in_sprite_bounds <= '1';
	else 
		in_sprite_bounds <= '0';
	end if;

	row_offset <= std_logic_vector(unsigned(pixel_row) - (unsigned(bird_y_pos_temp) - 16));
	col_offset <= std_logic_vector(unsigned(pixel_column) - (unsigned(bird_x_pos_temp(9 downto 0)) - 16));

 		if (in_sprite_bounds = '1') then 
			rom_address <= (row_offset(4 downto 0) & "0") & (col_offset(4 downto 0) & "0");
		else 
			 rom_address <= (others => '0'); 
		end if;

		--register address
		in_sprite_bounds_reg <= in_sprite_bounds;
		
		if (in_sprite_bounds_reg = '1' and rom_data /= x"000") then 
			sprite_on <= '1'; 
		else 
		sprite_on <= '0'; 
		end if;
		

	if (sprite_on = '1') then 
		red <=  rom_data(11 downto 8);
		green <= rom_data(7  downto 4);
		blue <= rom_data(3  downto 0);
	else 
		red <= "0000";
		green <= "0000";
		blue <= "0000";
	end if;

	bird_on <= sprite_on;
	bird_on_out <= bird_on;
end if;
end process;


-- Movement
    Move_bird : PROCESS(vert_sync)
        VARIABLE bird_y_motion : signed(9 DOWNTO 0) := (OTHERS => '0'); -- Velocity of bird
		  VARIABLE at_top        : std_logic := '0';
        VARIABLE next_y        : signed(9 DOWNTO 0); -- Next y position of bird
        CONSTANT bottom_limit  : unsigned(9 DOWNTO 0) := to_unsigned(479, 10);
		  CONSTANT top_limit  : unsigned(9 DOWNTO 0) := to_unsigned(55, 10);

		  
    BEGIN
        IF (rising_edge(vert_sync) AND enable = '1') THEN
		  
			-- Game not started and user clicks on screen to start
			IF (start = '0' AND click = '1' AND prev_click = '0') THEN
				start <= '1';
	
			-- Begin the game
			ELSIF (start = '1') THEN
            -- Bottom hit
            IF unsigned(bird_y_pos_temp) >= (bottom_limit - size_temp) THEN
                bird_y_motion := (OTHERS => '0');
                at_top        := '0';

            -- Top hit
            ELSIF unsigned(bird_y_pos_temp) <= (top_limit- size_temp) THEN
                at_top        := '1';
                bird_y_motion := bird_y_motion + to_signed(1, 10);  -- gravity

            ELSE
                at_top        := '0';
                bird_y_motion := bird_y_motion + to_signed(1, 10);  -- gravity
            END IF;
				

            -- Click = jump
            IF (click = '1' AND prev_click = '0' AND at_top = '0') THEN
                bird_y_motion := -to_signed(8, 10);  -- jump up
                prev_click    <= '1';
            ELSE
                prev_click    <= click;
            END IF;
				

            -- Compute next position
            next_y := signed(bird_y_pos_temp) + bird_y_motion;

				
            -- Clamp to top
            IF next_y <= signed(size_temp) THEN
                next_y := signed(size_temp);
            END IF;
				

            -- Clamp to bottom
            IF next_y >= signed(bottom_limit - size_temp) THEN
                next_y := signed(bottom_limit - size_temp);
            END IF;

            bird_y_pos_temp <= unsigned(next_y);
				
			END IF;

        END IF;
    END PROCESS Move_bird;

    -- Outputs
    bird_y_pos <= std_logic_vector(bird_y_pos_temp);
    size       <= std_logic_vector(size_temp);
    bird_x_pos <= std_logic_vector(bird_x_pos_temp);

END behavior;