
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY PAUSE_SCREEN IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        score : IN INTEGER;
        level : IN INTEGER;
        lives : IN INTEGER;
        video_on : OUT STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END PAUSE_SCREEN;

ARCHITECTURE a OF PAUSE_SCREEN IS

SIGNAL msg_paused : text_string(1 to 6) := "PAUSED";
SIGNAL r_paused, g_paused, b_paused : std_logic_vector(3 downto 0);

SIGNAL box_row_int, box_col_int : integer := 0;
SIGNAL box_on : std_logic;

SIGNAL box_r, box_g, box_b : std_logic_vector(3 downto 0);

SIGNAL msg_score : text_string(1 to 9) := "SCORE 000";
SIGNAL msg_level : text_string(1 to 7) := "LEVEL 0";

SIGNAL button_play : text_string(1 to 10) := "PRESS PLAY";

SIGNAL r_score, g_score, b_score : std_logic_vector(3 downto 0);
SIGNAL r_level, g_level, b_level : std_logic_vector(3 downto 0);
SIGNAL r_lives, g_lives, b_lives : std_logic_vector(3 downto 0);
SIGNAL r_button, g_button, b_button : std_logic_vector(3 downto 0);
-- Signals for hearts
signal r_heart1, g_heart1, b_heart1 : std_logic_vector(3 downto 0);
signal r_heart2, g_heart2, b_heart2 : std_logic_vector(3 downto 0);
signal r_heart3, g_heart3, b_heart3 : std_logic_vector(3 downto 0);
  
signal heart1_vis, heart2_vis, heart3_vis : std_logic;


begin

    box_row_int <= to_integer(unsigned(pixel_row));
    box_col_int <= to_integer(unsigned(pixel_column));

    box_on <= '1' when ( box_row_int >= 140 and box_row_int <= 400 and box_col_int >= 136 and box_col_int <= 504) else '0';

    box_r <= "1111" when box_on = '1' else "0000";
    box_g <= "0101" when box_on = '1' else "0000";
    box_b <= "0111" when box_on = '1' else "0000";



     process(score)
    begin
        msg_score(7) <= character'val(score / 100 + 48);
    msg_score(8) <= character'val((score mod 100) / 10 + 48);
    msg_score(9) <= character'val(score mod 10 + 48);
        
    end process;

    process(level)
    begin
        msg_level(7) <= character'val(level + 48);
    end process;

    -- process(lives)
    -- begin
    --     msg_lives(8) <= character'val(lives + 48);
    -- end process;

    -- Paused text
     VGA_TEXT_PAUSE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_paused,
    start_row => 160,
    start_col => 224,
    scale => 4,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_paused,
    green_out => g_paused,
    blue_out => b_paused
    );

    --Score, level, lives text
     VGA_TEXT_SCORE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_score,
    start_row => 230,
    start_col => 240,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_score,
    green_out => g_score,
    blue_out => b_score
    );

    heart1_vis <= '1' when lives >= 1 else '0';
    heart2_vis <= '1' when lives >= 2 else '0';
    heart3_vis <= '1' when lives >= 3 else '0';
    
    -- Hearts for lives : 
   HEART1 : entity work.heart
    port map(
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => clock_25Mhz,
        start_row => 10,
        start_col => 10,
        visible => heart1_vis,
        red_out => r_heart1,
        green_out => g_heart1,
        blue_out => b_heart1
    );

HEART2 : entity work.heart
    port map(
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => clock_25Mhz,
        start_row => 10,
        start_col => 40,
        visible => heart2_vis,
        red_out => r_heart2,
        green_out => g_heart2,
        blue_out => b_heart2
    );

HEART3 : entity work.heart
    port map(
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => clock_25Mhz,
        start_row => 150,
        start_col => 70,
        visible => heart3_vis,
        red_out => r_heart3,
        green_out => g_heart3,
        blue_out => b_heart3
    );


    -- Text for level
     VGA_TEXT_LEVEL : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_level,
    start_row => 310,
    start_col => 240,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_level,
    green_out => g_level,
    blue_out => b_level
    );

    -- Text for play button
     VGA_TEXT_BUTTON : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => button_play,
    start_row => 370,
    start_col => 144,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_button,
    green_out => g_button,
    blue_out => b_button
    );





red_out   <= r_paused or r_score or r_level or r_button when box_on = '1' else "0000";
green_out <= g_paused or g_score or g_level or g_button when box_on = '1' else "0000";
blue_out  <= b_paused or b_score or b_level or b_button when box_on = '1' else "0000";

video_on <= box_on;

END a;


