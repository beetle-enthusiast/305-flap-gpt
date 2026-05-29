
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
SIGNAL button_play : text_string(1 to 10) := "PRESS PLAY";
SIGNAL r_button, g_button, b_button : std_logic_vector(3 downto 0);

SIGNAL box_row_int, box_col_int : integer := 0;
SIGNAL box_on : std_logic;

SIGNAL box_r, box_g, box_b : std_logic_vector(3 downto 0);


begin


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


    -- Text for play button
     VGA_TEXT_BUTTON : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => button_play,
    start_row => 370,
    start_col => 240,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_button,
    green_out => g_button,
    blue_out => b_button
    );


Output_assignments : process(clock_25Mhz)
begin
    if rising_edge(clock_25Mhz) then 
        video_on <= '1';

        -- generate the box
        box_row_int <=to_integer(unsigned(pixel_row));
        box_col_int <= to_integer(unsigned(pixel_column));

         if box_row_int >= 140 and box_row_int <= 400 and
           box_col_int >= 136 and box_col_int <= 504 then
            box_on <= '1';
        else
            box_on <= '0';
        end if;

        if box_on = '1' then  
            red_out   <= "1111" or r_paused or r_button;
            green_out <= "0101" or g_paused or g_button;
            blue_out  <= "0111" or b_paused or b_button;
        else 
            red_out <= "0000";
            green_out <= "0000";
            blue_out <= "0000";
        end if;

    end if;
end process;

END a;