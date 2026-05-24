
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY GAMEPLAY_SCREEN IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        score : IN INTEGER;
        level : IN INTEGER;
        lives : IN INTEGER;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END GAMEPLAY_SCREEN;

ARCHITECTURE a OF GAMEPLAY_SCREEN IS

SIGNAL box_row_int, box_col_int : integer := 0;
SIGNAL box_on : std_logic;
SIGNAL box_r, box_g, box_b : std_logic_vector(3 downto 0);


SIGNAL msg_score : text_string(1 to 10) := "SCORE: 000";
SIGNAL msg_level : text_string(1 to 8) := "LEVEL: 0";
SIGNAL msg_lives : text_string(1 to 8) := "LIVES: 0";

SIGNAL r_score, g_score, b_score : std_logic_vector(3 downto 0);
SIGNAL r_level, g_level, b_level : std_logic_vector(3 downto
    0);
SIGNAL r_lives, g_lives, b_lives : std_logic_vector(3 downto 0);
  

begin

    box_row_int <= to_integer(unsigned(pixel_row));
    box_col_int <= to_integer(unsigned(pixel_column));

    box_on <= '1' when ( box_row_int <= 40 and box_col_int <= 639) else '0';

    box_r <= "0100" when box_on = '1' else "0000";
    box_g <= "0000" when box_on = '1' else "0000";
    box_b <= "0100" when box_on = '1' else "0000";

    process(score)
    begin
        msg_score(8) <= character'val(score / 100 + 48);
        msg_score(9) <= character'val((score mod 100) / 10 + 48);
        msg_score(10) <= character'val(score mod 10 + 48);
    end process;

    process(level)
    begin
        msg_level(8) <= character'val(level + 48);
    end process;

    process(lives)
    begin
        msg_lives(8) <= character'val(lives + 48);
    end process;


     -- text for lives for now 
    VGA_TEXT_LIVE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_lives,
    start_row => 12,
    start_col => 10,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_lives,
    green_out => g_lives,
    blue_out => b_lives
    );

         -- text for levels
    VGA_TEXT_LEVEL : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_level,
    start_row => 12,
    start_col => 280,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_level,
    green_out => g_level,
    blue_out => b_level
    );


         -- text for lives for now 
    VGA_TEXT_SCORE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_score,
    start_row => 12,
    start_col => 550,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_score,
    green_out => g_score,
    blue_out => b_score
    );
    

    -- Combine the outputs for the box and the text
    red_out <= box_r or r_score or r_level or r_lives;
    green_out <= box_g or g_score or g_level or g_lives;
    blue_out <= box_b or b_score or b_level or b_lives;

    


END a;


