
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY GAMEOVER_SCREEN IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        score : IN INTEGER;
        is_high_score : IN STD_LOGIC;
        video_on : OUT STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END GAMEOVER_SCREEN;

ARCHITECTURE a OF GAMEOVER_SCREEN IS


SIGNAL msg_gameover : text_string(1 to 19) := "WOMP WOMP YOU LOSE!";
signal msg_score : text_string(1 to 10) := "SCORE: 000";
SIGNAL msg_highscore : text_string(1 to 15) := "NEW HIGH SCORE!";
SIGNAL msg_growths : text_string(1 to 28) := "AND HONESTLY - THATS GROWTH!";

SIGNAL r_gameover, g_gameover, b_gameover : std_logic_vector(3 downto 0);
SIGNAL r_score, g_score, b_score : std_logic_vector(3 downto 0);
SIGNAL r_highscore, g_highscore, b_highscore : std_logic_vector(3 downto 0);
SIGNAL r_growths, g_growths, b_growths : std_logic_vector(3 downto 0);

SIGNAL box_row_int, box_col_int : integer := 0;
SIGNAL box_on : std_logic;
SIGNAL box_r, box_g, box_b : std_logic_vector(3 downto 0);


signal r_gameover_gated, g_gameover_gated, b_gameover_gated : std_logic_vector(3 downto 0);
signal r_highscore_gated, g_highscore_gated, b_highscore_gated : std_logic_vector(3 downto 0);
signal r_growths_gated, g_growths_gated, b_growths_gated : std_logic_vector(3 downto 0);

  

begin

    box_row_int <= to_integer(unsigned(pixel_row));
    box_col_int <= to_integer(unsigned(pixel_column));

    box_on <= '1' when (box_row_int >= 140 and box_row_int <= 340 and box_col_int >= 136 and box_col_int <= 504) else '0';

    box_r <= "1111" when box_on = '1' else "0000";
    box_g <= "0101" when box_on = '1' else "0000";
    box_b <= "0111" when box_on = '1' else "0000";


    -- process for score
    process(score)
    begin
        msg_score(8) <= character'val(score / 100 + 48);
        msg_score(9) <= character'val((score mod 100) / 10 + 48);
        msg_score(10) <= character'val(score mod 10 + 48);
    end process;


    -- Game Over Text
     VGA_TEXT_GAMEOVER : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_gameover,
    start_row => 160,
    start_col => 168,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_gameover,
    green_out => g_gameover,
    blue_out => b_gameover
    );


    -- Score Text
     VGA_TEXT_SCORE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_score,
    start_row => 220,
    start_col => 240,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_score,
    green_out => g_score,
    blue_out => b_score
    );

    -- High score text
    VGA_TEXT_HIGHSCORE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_highscore,
    start_row => 160,
    start_col => 200,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_highscore,
    green_out => g_highscore,
    blue_out => b_highscore
    );

    -- Honestly thats growth text 
    VGA_TEXT_GROWTH : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_growths,
    start_row => 280,
    start_col => 204,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_growths,
    green_out => g_growths,
    blue_out => b_growths
    );


r_gameover_gated <= r_gameover ;
g_gameover_gated <= g_gameover ;
b_gameover_gated <= b_gameover ;

r_highscore_gated <= r_highscore when is_high_score = '1' else "0000";
g_highscore_gated <= g_highscore when is_high_score = '1' else "0000";
b_highscore_gated <= b_highscore when is_high_score = '1' else "0000";

r_growths_gated <= r_growths when is_high_score = '1' else "0000";
g_growths_gated <= g_growths when is_high_score = '1' else "0000";
b_growths_gated <= b_growths when is_high_score = '1' else "0000";
    
red_out <= r_gameover_gated or r_highscore_gated or r_growths_gated or r_score or box_r;
green_out <= g_gameover_gated or g_highscore_gated or g_growths_gated or g_score or box_g;
blue_out <= b_gameover_gated or b_highscore_gated or b_growths_gated or b_score or box_b;


video_on <= '1' when (
    box_on = '1' or
    r_gameover /= "0000" or g_gameover /= "0000" or b_gameover /= "0000" or
    r_score /= "0000" or g_score /= "0000" or b_score /= "0000" or
    r_highscore_gated /= "0000" or g_highscore_gated /= "0000" or b_highscore_gated /= "0000" or
    r_growths_gated /= "0000" or g_growths_gated /= "0000" or b_growths_gated /= "0000"
) else '0';

END a;


