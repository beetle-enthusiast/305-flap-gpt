
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY GAMEOVER_SCREEN IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        score : IN INTEGER RANGE 0 TO 999;
        is_high_score : IN STD_LOGIC;
        mouse_click : in std_logic;
        mouse_row : in std_logic_vector(9 downto 0);
        mouse_col : in std_logic_vector(9 downto 0);
        go_to_menu : out std_logic;
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


signal mouse_row_int,mouse_col_int : integer;

-- button back to main menu
SIGNAL msg_menu : text_string(1 to 16) := "GO TO MAIN MENU!";
SIGNAL r_menu, g_menu, b_menu : std_logic_vector(3 downto 0);

  

begin



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

    -- Main menu
    VGA_TEXT_MENU : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_menu,
    start_row => 310,
    start_col => 190,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "0000",
    red_out => r_menu,
    green_out => g_menu,
    blue_out => b_menu
    );
    
   --processes
     process(score)
    begin
        msg_score(8) <= character'val(score / 100 + 48);
        msg_score(9) <= character'val((score mod 100) / 10 + 48);
        msg_score(10) <= character'val(score mod 10 + 48);
    end process;

  Output_assignments : process(clock_25Mhz)
  begin
    if rising_edge(clock_25Mhz) then 

        -- pixel and mouse 
        box_row_int <= to_integer(unsigned(pixel_row));
        box_col_int <= to_integer(unsigned(pixel_column));
        mouse_row_int <= to_integer(unsigned(mouse_row));
        mouse_col_int <= to_integer(unsigned(mouse_col));

        if (box_row_int >= 140 and box_row_int <= 340 and box_col_int >= 136 and box_col_int <= 504) then 
            box_on <= '1';
            box_r <= "1111"; box_g <= "0101"; box_b <= "0111";
        else 
            box_on <= '0';
            box_r  <= "0000"; box_g <= "0000"; box_b <= "0000";
        end if;

        --Gate gameover vs high score
        if is_high_score = '0' then
                r_gameover_gated <= r_gameover;
                g_gameover_gated <= g_gameover;
                b_gameover_gated <= b_gameover;
            else
                r_gameover_gated <= "0000";
                g_gameover_gated <= "0000";
                b_gameover_gated <= "0000";
            end if;

            if is_high_score = '1' then
                r_highscore_gated <= r_highscore;
                g_highscore_gated <= g_highscore;
                b_highscore_gated <= b_highscore;
                r_growths_gated   <= r_growths;
                g_growths_gated   <= g_growths;
                b_growths_gated   <= b_growths;
            else
                r_highscore_gated <= "0000";
                g_highscore_gated <= "0000";
                b_highscore_gated <= "0000";
                r_growths_gated   <= "0000";
                g_growths_gated   <= "0000";
                b_growths_gated   <= "0000";
            end if;

        -- Navigation to main menu
         if mouse_click = '1' and
               mouse_row_int >= 140 and mouse_row_int <= 340 and
               mouse_col_int >= 136 and mouse_col_int <= 504 then
                go_to_menu <= '1';
            else
                go_to_menu <= '0';
            end if;

        --Output 
        red_out   <= r_gameover_gated or r_highscore_gated or r_growths_gated or r_score or r_menu or box_r;
        green_out <= g_gameover_gated or g_highscore_gated or g_growths_gated or g_score or g_menu or box_g;
        blue_out  <= b_gameover_gated or b_highscore_gated or b_growths_gated or b_score or b_menu or box_b;
        video_on  <= '1';
    end if;
  end process;

END a;


