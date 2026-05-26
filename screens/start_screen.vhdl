
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY START_SCREEN IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        mode : IN STD_LOGIC;
        mouse_click : IN STD_LOGIC;
        mouse_row, mouse_col : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        video_on : OUT STD_LOGIC;
        start_clicked : OUT STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

    );
END START_SCREEN;

ARCHITECTURE a OF START_SCREEN IS

-- Signals for text display

  SIGNAL msg_start : text_string(1 to 8) := "FLAP-GPT";  
  SIGNAL r_title, g_title, b_title : std_logic_vector(3 downto 0);


  SIGNAL r_subtitle, g_subtitle, b_subtitle : std_logic_vector(3 downto 0);
  SIGNAL msg_subtitle : text_string(1 to 29) := "SELECT MODE WITH DIP SWITCHES";

  -- Signals for mode selection text
    SIGNAL r_tm, g_tm, b_tm : std_logic_vector(3 downto 0);
    SIGNAL r_sp, g_sp, b_sp : std_logic_vector(3 downto 0);
    SIGNAL msg_TM : text_string(1 to 13) := "TRAINING-MODE";
    SIGNAL msg_SP : text_string(1 to 13) := "SINGLE-PLAYER";

-- Signals for start button
    SIGNAL r_Sbutton,g_Sbutton,b_Sbutton : std_logic_vector(3 downto 0);
    SIGNAL msg_Sbutton : text_string(1 to 19) := "PRESS START TO PLAY";


-- SIGNA for boxs 
    SIGNAL row_int, col_int : integer := 0;
    SIGNAL tm_box_on, sp_box_on, tm_box, sp_box, start_box_border,start_box_fill,start_box_shadow, start_box_clicked, start_box_hovered: std_logic;
    SIGNAL mouse_row_int, mouse_col_int : integer := 0;

-- COLORS FOR BOXES

    SIGNAL tm_box_r, tm_box_g, tm_box_b : std_logic_vector(3 downto 0);
    SIGNAL tm_box_fill_r, tm_box_fill_g, tm_box_fill_b : std_logic_vector(3 downto 0);

    SIGNAL sp_box_r, sp_box_g, sp_box_b : std_logic_vector(3 downto 0);
    SIGNAL sp_box_fill_r, sp_box_fill_g, sp_box_fill_b : std_logic_vector(3 downto 0);

    SIGNAL start_box_r, start_box_g, start_box_b : std_logic_vector(3 downto 0);
    SIGNAL start_box_fill_r, start_box_fill_g, start_box_fill_b : std_logic_vector(3 downto 0);
    SIGNAL start_box_shadow_r, start_box_shadow_g, start_box_shadow_b : std_logic_vector(3 downto 0);
    SIGNAL start_box_hover_r, start_box_hover_g, start_box_hover_b : std_logic_vector(3 downto 0);

   

  
  

begin

-- Instance of Text display for start screen message
   -- Text display instance for start_text
  VGA_TEXT_TITLE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_start,
    start_row => 80,
    start_col => 192,
    scale => 4,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_title,
    green_out => g_title,
    blue_out => b_title
    );


VGA_TEXT_SUBTITLE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_subtitle,
    start_row => 160,
    start_col => 88,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_subtitle,
    green_out => g_subtitle,
    blue_out => b_subtitle
    );

-- Buttons for selecting game mode

-- Training mode text 

VGA_TEXT_TM : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_TM,
    start_row => 240,
    start_col => 80,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_tm,
    green_out => g_tm,
    blue_out => b_tm
    );

    -- Single play mode text

    VGA_TEXT_SP : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_SP,
    start_row => 240,
    start_col => 352,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_sp,
    green_out => g_sp,
    blue_out => b_sp
    );


    -- Confirm click start game
    VGA_TEXT_START : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_Sbutton,
    start_row => 380,
    start_col => 168,
    scale => 2,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_Sbutton,
    green_out => g_Sbutton,
    blue_out => b_Sbutton
    );

    --Logic for box

    row_int <= to_integer(unsigned(pixel_row));
    col_int <= to_integer(unsigned(pixel_column));

    -- Border box for training mode
    tm_box <= '1' when(

        -- Top edge
        (row_int >= 230 and row_int <= 232 and col_int >= 70 and col_int <= 370) or 
        -- Bottom edge
        (row_int >= 264 and row_int <= 266 and col_int >= 70 and col_int <= 370) or
        -- Left edge
        (row_int >= 230 and row_int <= 266 and col_int >= 70 and col_int <= 72) or
        -- Right edge
        (row_int >= 230 and row_int <= 266 and col_int >= 296 and col_int <= 298)

    ) else '0';

    -- Fill for training mode box
    tm_box_on <= '1' when (
        ( row_int >= 233 and col_int >= 73 and row_int <= 263 and col_int <= 295) and mode = '0' -- Only fill when training mode is selected    
    )
    else '0';


    tm_box_r <= "1111" when tm_box = '1' else "0000";
    tm_box_g <= "1111" when tm_box = '1' else "0000";
    tm_box_b <= "1111" when tm_box = '1' else "0000";
    tm_box_fill_r <= "1111" when tm_box_on = '1' else "0000";
    tm_box_fill_g <= "0110" when tm_box_on = '1' else "0000";
    tm_box_fill_b <= "0000" when tm_box_on = '1' else "0000";

    -- Border box for single player mode
    sp_box <= '1' when(
        -- Top edge
        (row_int >= 230 and row_int <= 232 and col_int >= 340 and col_int <= 570) or 
        -- Bottom edge
        (row_int >= 264 and row_int <= 266 and col_int >= 340 and col_int <= 570) or
        -- Left edge
        (row_int >= 230 and row_int <= 266 and col_int >= 342 and col_int <= 344) or
        -- Right edge
        (row_int >= 230 and row_int <= 266 and col_int >= 568 and col_int <= 570)

    ) else '0';

    -- Fill for single player mode box
    sp_box_on <= '1' when (
        ( row_int >= 233 and col_int >= 344 and row_int <= 263 and col_int <= 568) and mode = '1' -- Only fill when single player mode is selected    
    )
    else '0';


    sp_box_r <= "1111" when sp_box = '1' else "0000";
    sp_box_g <= "1111" when sp_box = '1' else "0000";
    sp_box_b <= "1111" when sp_box = '1' else "0000";
    sp_box_fill_r <= "1111" when sp_box_on = '1' else "0000";
    sp_box_fill_g <= "0110" when sp_box_on = '1' else "0000";
    sp_box_fill_b <= "0000" when sp_box_on = '1' else "0000";



    -- start button 

    mouse_row_int <= to_integer(unsigned(mouse_row));
    mouse_col_int <= to_integer(unsigned(mouse_col));
    

    start_box_border <= '1' when(

   
        -- Top edge
        (row_int >= 370 and row_int <= 372 and col_int >= 158 and col_int <= 482) or 
        -- Bottom edge
        (row_int >= 414 and row_int <= 416 and col_int >= 158 and col_int <= 482) or
        -- Left edge
        (row_int >= 370 and row_int <= 416 and col_int >= 158 and col_int <= 160) or
        -- Right edge
        (row_int >= 370 and row_int <= 416 and col_int >= 480 and col_int <= 482)

    ) else '0';

    start_box_fill <= '1' when (
        ( row_int >= 370 and col_int >= 161 and row_int <= 413 and col_int <= 480) 
    )
    else '0';

    

    start_box_hovered <= '1' when (
        ( mouse_row_int >= 370 and mouse_row_int <= 416 and
        mouse_col_int >= 158 and mouse_col_int <= 482)  
    )
    else '0';

    start_box_clicked <= '1' when (
        (mouse_row_int >= 370 and mouse_row_int <= 416 and
        mouse_col_int >= 158 and mouse_col_int <= 482) and mouse_click = '1'
    )
    else '0';

    start_box_shadow <= '1' when (
        ( row_int >= 417 and col_int >= 483 and row_int <= 423 and col_int <= 486) and start_box_clicked = '0' 
    )
    else '0';

    start_clicked <= '1' when start_box_clicked = '1' else '0';


    start_box_r <= "1111" when start_box_border = '1' else "0000";
    start_box_g <= "1111" when start_box_border = '1' else "0000";
    start_box_b <= "1111" when start_box_border = '1' else "0000";
    start_box_fill_r <= "1111" when start_box_fill = '1' else "0000";
    start_box_fill_g <= "0110" when start_box_fill = '1' else "0000";
    start_box_fill_b <= "0000" when start_box_fill = '1' else "0000";
    start_box_shadow_r <= "0100" when start_box_shadow = '1' else "0000";
    start_box_shadow_g <= "0000" when start_box_shadow = '1' else "0000";
    start_box_shadow_b <= "0100" when start_box_shadow = '1' else "0000";
    start_box_hover_r <= "1111" when (start_box_hovered = '1' and row_int >= 370 and row_int <= 416 and col_int >= 158 and col_int <= 482) else "0000";
    start_box_hover_g <= "1111" when (start_box_hovered = '1' and row_int >= 370 and row_int <= 416 and col_int >= 158 and col_int <= 482) else "0000";
    start_box_hover_b <= "0000" when (start_box_hovered = '1' and row_int >= 370 and row_int <= 416 and col_int >= 158 and col_int <= 482) else "0000";




    red_out <= r_title or r_subtitle or r_tm or r_sp or r_Sbutton or tm_box_r or tm_box_fill_r or sp_box_r or sp_box_fill_r or start_box_r or start_box_fill_r or start_box_shadow_r or start_box_hover_r ;
    green_out <= g_title or g_subtitle or g_tm or g_sp or g_Sbutton or tm_box_g or tm_box_fill_g or sp_box_g or sp_box_fill_g or start_box_g or start_box_fill_g or start_box_shadow_g or start_box_hover_g;
    blue_out <= b_title or b_subtitle or b_tm or b_sp or b_Sbutton or tm_box_b or tm_box_fill_b or sp_box_b or sp_box_fill_b or start_box_b or start_box_fill_b or start_box_shadow_b or start_box_hover_b;



    
    video_on <= '1' when (
    r_title /= "0000" or
    r_subtitle /= "0000" or
    r_tm /= "0000" or
    r_sp /= "0000" or
    r_Sbutton /= "0000" or
    tm_box = '1' or
    tm_box_on = '1' or
    sp_box = '1' or
    sp_box_on = '1' or
    start_box_border = '1' or
    start_box_fill = '1' or
    start_box_shadow = '1'
) else '0';

END a;


