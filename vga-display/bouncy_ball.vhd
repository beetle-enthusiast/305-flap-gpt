LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
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
SIGNAL size_temp : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(16, 10));
SIGNAL ball_y_pos_temp : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(479-8, 10));
SIGNAL ball_x_pos_temp : std_logic_vector(10 DOWNTO 0) := std_logic_vector(to_unsigned(400, 11));
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
		if (unsigned(pixel_row) >= unsigned(ball_y_pos_temp) - 16 and
    unsigned(pixel_row) <  unsigned(ball_y_pos_temp) + 16 and
    unsigned(pixel_column) >= unsigned(ball_x_pos_temp(9 downto 0)) - 16 and
    unsigned(pixel_column) <  unsigned(ball_x_pos_temp(9 downto 0)) + 16) then 
		in_sprite_bounds <= '1';
	else 
		in_sprite_bounds <= '0';
	end if;

	row_offset <= std_logic_vector(unsigned(pixel_row) - (unsigned(ball_y_pos_temp) - 16));
	col_offset <= std_logic_vector(unsigned(pixel_column) - (unsigned(ball_x_pos_temp(9 downto 0)) - 16));

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

	ball_on <= sprite_on;
	ball_on_out <= ball_on;
end if;
end process;


Move_Ball: process (clk) 
VARIABLE ball_y_motion : signed(9 DOWNTO 0) := (others => '0');
VARIABLE at_top : std_logic := '0';
begin
    if rising_edge(clk) then
        enable_reg <= enable;
        vs_prev    <= vert_sync;

        if vs_prev = '1' and vert_sync = '0' and enable_reg = '1' then

            if signed(ball_y_pos_temp) >= to_signed(479,10) - signed(size_temp) then
                ball_y_motion := (others => '0');
                at_top := '0';

            elsif signed(ball_y_pos_temp) <= signed(size_temp) then
                at_top := '1';
                ball_collision <= not ball_collision;
                ball_y_motion := ball_y_motion + 1;

            else
                at_top := '0';
                ball_y_motion := ball_y_motion + 1;
            end if;

            if click = '1' and prev_click = '0' and at_top = '0' then
                ball_y_motion := to_signed(-8, 10);
                prev_click <= '1';
            else
                prev_click <= click;
            end if;

            ball_y_pos_temp <= std_logic_vector(signed(ball_y_pos_temp) + ball_y_motion);

            if signed(ball_y_pos_temp) + ball_y_motion <= signed(size_temp) then
                ball_y_pos_temp <= size_temp;
            end if;

            if signed(ball_y_pos_temp) + ball_y_motion >= to_signed(479,10) - signed(size_temp) then
                ball_y_pos_temp <= std_logic_vector(to_signed(479,10) - signed(size_temp));
            end if;

        end if;
    end if;
end process Move_Ball;


--Output signal assignments
ball_y_pos <= ball_y_pos_temp;
ball_x_pos <= ball_x_pos_temp;
size <= size_temp;


END behavior;