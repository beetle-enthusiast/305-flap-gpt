LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bird_bc IS
    PORT (
        enable, click, clk, vert_sync : IN std_logic;
        pixel_row, pixel_column       : IN std_logic_vector(9 DOWNTO 0);
        bird_bc_on_out                   : OUT std_logic;
        red, green, blue              : OUT std_logic_vector(3 DOWNTO 0);
        bird_bc_y_pos, size              : OUT std_logic_vector(9 DOWNTO 0);
        bird_bc_x_pos                    : OUT std_logic_vector(10 DOWNTO 0)
    );
END bird_bc;

ARCHITECTURE behavior OF bird_bc IS

SIGNAL bird_bc_on, bird_bc_white: std_logic := '0';
SIGNAL prev_click, bird_bc_collision              : std_logic := '0';
SIGNAL start: std_logic:= '0';
SIGNAL size_temp        : std_logic_vector(9 DOWNTO 0)  := std_logic_vector(to_unsigned(8, 10));          -- radius = 8
SIGNAL bird_bc_y_pos_temp  : std_logic_vector(9 DOWNTO 0)  := std_logic_vector(to_unsigned(240 - 8, 10));    -- start near bottom
SIGNAL bird_bc_x_pos_temp  : std_logic_vector(10 DOWNTO 0) := std_logic_vector(to_unsigned(200, 11));        -- fixed X

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
		if (unsigned(pixel_row) >= unsigned(bird_bc_y_pos_temp) - 16 and
    unsigned(pixel_row) <  unsigned(bird_bc_y_pos_temp) + 16 and
    unsigned(pixel_column) >= unsigned(bird_bc_x_pos_temp(9 downto 0)) - 16 and
    unsigned(pixel_column) <  unsigned(bird_bc_x_pos_temp(9 downto 0)) + 16) then 
		in_sprite_bounds <= '1';
	else 
		in_sprite_bounds <= '0';
	end if;

	row_offset <= std_logic_vector(unsigned(pixel_row) - (unsigned(bird_bc_y_pos_temp) - 16));
	col_offset <= std_logic_vector(unsigned(pixel_column) - (unsigned(bird_bc_x_pos_temp(9 downto 0)) - 16));

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

	bird_bc_on <= sprite_on;
	bird_bc_on_out <= bird_bc_on;
end if;
end process;


Move_bird_bc: process (clk) 
VARIABLE bird_bc_y_motion : signed(9 DOWNTO 0) := (others => '0');
VARIABLE at_top : std_logic := '0';
begin
    if rising_edge(clk) then
        enable_reg <= enable;
        vs_prev    <= vert_sync;

        if (vs_prev = '1' and vert_sync = '0' and enable_reg = '1') then

            if signed(bird_bc_y_pos_temp) >= to_signed(479,10) - signed(size_temp) then
                bird_bc_y_motion := (others => '0');
                at_top := '0';

            elsif signed(bird_bc_y_pos_temp) <= signed(size_temp) then
                at_top := '1';
                bird_bc_collision <= not bird_bc_collision;
                bird_bc_y_motion := bird_bc_y_motion + 1;

            else
                at_top := '0';
                bird_bc_y_motion := bird_bc_y_motion + 1;
            end if;

            if click = '1' and prev_click = '0' and at_top = '0' then
                bird_bc_y_motion := to_signed(-8, 10);
                prev_click <= '1';
            else
                prev_click <= click;
            end if;

            bird_bc_y_pos_temp <= std_logic_vector(signed(bird_bc_y_pos_temp) + bird_bc_y_motion);

            if signed(bird_bc_y_pos_temp) + bird_bc_y_motion <= signed(size_temp) then
                bird_bc_y_pos_temp <= size_temp;
            end if;

            if signed(bird_bc_y_pos_temp) + bird_bc_y_motion >= to_signed(479,10) - signed(size_temp) then
                bird_bc_y_pos_temp <= std_logic_vector(to_signed(479,10) - signed(size_temp));
            end if;

        end if;
    end if;
end process Move_bird_bc;


--Output signal assignments
bird_bc_y_pos <= bird_bc_y_pos_temp;
bird_bc_x_pos <= bird_bc_x_pos_temp;
size <= size_temp;


END behavior;