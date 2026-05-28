LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY pipe IS
	PORT
		(enable, start, vert_sync	: IN std_logic;
		clk : IN STD_LOGIC;
        pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        randomiser_value1: IN std_logic_vector(7 DOWNTO 0);
		pipe_x_pos: OUT std_logic_vector(10 DOWNTO 0);
		pipe_y_pos: OUT std_logic_vector(9 DOWNTO 0);
		pipe_r,pipe_b,pipe_g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		pipe_on, pipe_enable, pipe_passed: OUT std_logic);		
END pipe;

architecture behavior of pipe is

SIGNAL gap_on_comb         : std_logic;
SIGNAL pipe_width_radius   : unsigned(10 DOWNTO 0);
SIGNAL pipe_height_radius  : unsigned(9 DOWNTO 0);
SIGNAL gap_constant        : unsigned(9 DOWNTO 0);
SIGNAL pipe_x_temp_pos     : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
SIGNAL pipe_y_temp_pos     : unsigned(9 DOWNTO 0)  := to_unsigned(279, 10);
SIGNAL pipe_gap_pos        : unsigned(9 DOWNTO 0)  := to_unsigned(279, 10);
SIGNAL started             : std_logic := '0';
SIGNAL pipe_on_sig         : std_logic;

signal rom_address : std_logic_vector(12 downto 0);
signal rom_data    : std_logic_vector(3 downto 0);
signal sprite_x, sprite_y : integer;

BEGIN           

gap_constant       <= to_unsigned(50, 10);
pipe_width_radius  <= to_unsigned(10, 11);
pipe_height_radius <= to_unsigned(200, 10);


gap_on_comb <= '1' when (
    (pipe_x_temp_pos <= unsigned(pixel_column) + pipe_width_radius) and
    (unsigned(pixel_column) <= pipe_x_temp_pos + pipe_width_radius) and
    (pipe_gap_pos <= unsigned(pixel_row) + gap_constant) and
    (unsigned(pixel_row) <= pipe_gap_pos + gap_constant)
) else '0';

pipe_on_sig <= '1' when (
    (pipe_x_temp_pos <= unsigned(pixel_column) + pipe_width_radius) and
    (unsigned(pixel_column) <= pipe_x_temp_pos + pipe_width_radius) and
    (pipe_y_temp_pos <= unsigned(pixel_row) + pipe_height_radius) and
    (unsigned(pixel_row) <= pipe_y_temp_pos + pipe_height_radius) and
    gap_on_comb = '0'
) else '0';

pipe_on <= pipe_on_sig;

-- ROM INSTANTIATION
PIPE_ROM_INST : entity work.pipe_rom
    port map(
        address => rom_address,
        clock   => clk,
        q       => rom_data
    );

Sprite : process(clk)
begin
	if rising_edge(clk) then 
		sprite_x <= to_integer(unsigned(pixel_column)) - to_integer(unsigned(pipe_x_temp_pos(9 downto 0))) + 10;
        sprite_y <= to_integer(unsigned(pixel_row)) - to_integer(unsigned(pipe_y_temp_pos)) + 200;

		if (sprite_x >= 0 and sprite_x < 20 and sprite_y >= 0 and sprite_y < 400) then 
			rom_address <= std_logic_vector(to_unsigned(sprite_y * 20 + sprite_x, 13));
		else 
			rom_address <= (others => '0');
		end if;

		if (pipe_on_sig = '1') then 
			pipe_r <= rom_data;
			pipe_g <= ('0' & rom_data(3 downto 1));
			pipe_b <= "0000";
		else 
			pipe_r <= "0000";
			pipe_g <= "0000";
			pipe_b <= "0000";
		end if;
	end if;
end process; 

Move_Pipe: process (vert_sync) 
VARIABLE pipe_x_motion : signed(10 DOWNTO 0)   := to_signed(-1, 11);
VARIABLE starting_pos  : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
VARIABLE end_pos       : unsigned(10 DOWNTO 0) := to_unsigned(0, 11);
begin
	if (rising_edge(vert_sync) and (enable = '1')) then
		if (start = '1') then
            started     <= '1';
			pipe_enable <= '1';
		else 
			pipe_enable <= '0';
        end if;
	
		if (start = '1' or started = '1') then
			if (pipe_x_temp_pos <= end_pos) then
				pipe_x_temp_pos <= starting_pos;
				pipe_gap_pos    <= to_unsigned(100, 10) + unsigned("00" & randomiser_value1);
			else
				pipe_x_temp_pos <= unsigned(signed(pipe_x_temp_pos) + pipe_x_motion);
			end if;

			--Detect if ball passed pipe
			if (pipe_x_temp_pos < to_unsigned(200 - 8, 11)) then
				pipe_passed <= '1';
			else
				pipe_passed <= '0';
			end if;
		end if;
	end if;
end process Move_Pipe;

pipe_x_pos <= std_logic_vector(pipe_x_temp_pos);
pipe_y_pos <= std_logic_vector(pipe_y_temp_pos);

END behavior;