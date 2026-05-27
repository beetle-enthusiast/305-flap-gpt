
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY GAMEPLAY_SCREEN IS
	PORT(
        vert_sync : IN std_logic;
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        mode : IN STD_LOGIC;
        score : IN INTEGER;
        level : IN INTEGER;
        lives : IN INTEGER;
        left_click : IN std_logic;
        video_on : OUT STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END GAMEPLAY_SCREEN;

ARCHITECTURE a OF GAMEPLAY_SCREEN IS

-- Difficulty controls - 
signal points : integer range 0 to 127;
signal scroll_speed : integer range 0 to 15;

SIGNAL box_row_int, box_col_int : integer := 0;
SIGNAL box_on : std_logic;
SIGNAL box_r, box_g, box_b : std_logic_vector(3 downto 0);


SIGNAL msg_score : text_string(1 to 10) := "SCORE  000";
SIGNAL msg_level : text_string(1 to 8) := "LEVEL  0";
SIGNAL msg_lives : text_string(1 to 8) := "LIVES  0";

SIGNAL r_score, g_score, b_score : std_logic_vector(3 downto 0);
SIGNAL r_level, g_level, b_level : std_logic_vector(3 downto
    0);
SIGNAL r_lives, g_lives, b_lives : std_logic_vector(3 downto 0);


-- Signals for hearts
signal r_heart1, g_heart1, b_heart1 : std_logic_vector(3 downto 0);
signal r_heart2, g_heart2, b_heart2 : std_logic_vector(3 downto 0);
signal r_heart3, g_heart3, b_heart3 : std_logic_vector(3 downto 0);
  
signal heart1_vis, heart2_vis, heart3_vis : std_logic;


--Signals for training mode text
signal msg_training : text_string(1 to 13) := "TRAINING MODE";
signal r_training, g_training, b_training : std_logic_vector(3 downto 0);

--Signals for single player mode text
signal msg_sp : text_string(1 to 13) := "SINGLE PLAYER";
signal r_sp, g_sp, b_sp : std_logic_vector(3 downto 0);

--Mode rgb
signal r_mode,g_mode,b_mode : std_logic_vector(3 downto 0 );

--SIGNALS ADDED
  signal red_in, green_in, blue_in : std_logic_vector (3 downto 0);

--Signals for ball
  signal ball_r, ball_g, ball_b : std_logic_vector (3 downto 0);
  SIGNAL ball_on : std_logic;
  signal ball_enable: std_logic:= '1';
  signal size				: std_logic_vector(9 DOWNTO 0);

  --Signals for collision
  SIGNAL collision				: std_logic:= '0';
  SIGNAL pipe_x_pos, ball_x_pos : std_logic_vector(10 downto 0);
  SIGNAL pipe_y_pos, ball_y_pos : std_logic_vector(9 DOWNTO 0);
  
  --Signals for pipe
  signal pipe_r, pipe_g, pipe_b, 
		   pipe2_start, pipe3_start, 
		   pipe_on, pipe1_on, pipe2_on, pipe3_on, 
         pipe_enable, pipe1_enable, pipe2_enable, pipe3_enable: std_logic;
  signal pipe_start: std_logic := '1';
  signal pipe1_x_pos, pipe2_x_pos, pipe3_x_pos: std_logic_vector(10 downto 0);
  signal pipe1_y_pos, pipe2_y_pos, pipe3_y_pos: std_logic_vector(9 downto 0);
  
  
  --Signals for lfsr
  signal randomiser_value : std_logic_vector (7 downto 0);
-- SIGNALS ADDED ENDS

begin

    LEVEL_CALC : entity work.levels
    port map (
      points => points,
      scroll_speed => scroll_speed
    );

    box_row_int <= to_integer(unsigned(pixel_row));
    box_col_int <= to_integer(unsigned(pixel_column));

    box_on <= '1' when ( box_row_int <= 40 and box_col_int <= 639) else '0';

    box_r <= "0010" when box_on = '1' else "0000";
    box_g <= "0001" when box_on = '1' else "0000";
    box_b <= "0000" when box_on = '1' else "0000";

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


    --  -- text for lives for now 
    -- VGA_TEXT_LIVE : entity work.VGA_TEXT
    -- port map (
    -- pixel_row => pixel_row,
    -- pixel_column => pixel_column,
    -- clock_25MhzMhz => clock_25MhzMhz,
    -- message => msg_lives,
    -- start_row => 12,
    -- start_col => 10,
    -- scale => 1,
    -- text_r => "1111",
    -- text_g => "1111",
    -- text_b => "1111",
    -- red_out => r_lives,
    -- green_out => g_lives,
    -- blue_out => b_lives
    -- );

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

    -- Text for tm
          -- text for lives for now 
    VGA_TRAINING_MODE : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_training,
    start_row => 12,
    start_col => 100,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_training,
    green_out => g_training,
    blue_out => b_training
    );

    VGA_SP_MODE : entity work.VGA_TEXT
   port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_sp,
    start_row => 12,
    start_col => 100,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_sp,
    green_out => g_sp,
    blue_out => b_sp
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
        start_row => 10,
        start_col => 70,
        visible => heart3_vis,
        red_out => r_heart3,
        green_out => g_heart3,
        blue_out => b_heart3
    );



    -- ADDED COMPONENTS
    --For ball movement
    -- Instantiate BOUNCY_BALL component
    BOUNCY_BALL_COMPONENT: entity work.bouncy_ball
    PORT MAP (enable=> ball_enable, 
            click => left_click, 
            clk => clock_25Mhz, 
            vert_sync => vert_sync,
            pixel_row => pixel_row, 
            pixel_column => pixel_column,
            ball_on_out => ball_on, 
            red => ball_r, 
            green => ball_g, 
            blue => ball_b,
            ball_y_pos => ball_y_pos,
            ball_x_pos => ball_x_pos,
            size => size);
    
    --LFSR for random pipe gap position
    LFSR_COMPONENT: entity work.lfsr
    PORT MAP (clk => clock_25Mhz, 
            enable => pipe_enable, 
            random_value => randomiser_value);

    -- For pipe movement
    -- Instantiate PIPE component
    PIPE1_COMPONENT: entity work.pipe
    PORT MAP (enable => pipe_start, 
				  vert_sync => vert_sync, 
				  start=> '1', 
				  pixel_row => pixel_row, 
				  pixel_column => pixel_column,
                  randomiser_value => randomiser_value,
				  pipe_x_pos => pipe1_x_pos,
				  pipe_y_pos => pipe1_y_pos,
				  pipe_on => pipe1_on,
				  pipe_enable => pipe1_enable);
				  
	PIPE2_COMPONENT: entity work.pipe
    PORT MAP (enable => pipe_start,
				  vert_sync => vert_sync, 
				  start=> pipe2_start, 
				  pixel_row => pixel_row, 
				  pixel_column => pixel_column,
                  randomiser_value => randomiser_value,
				  pipe_x_pos => pipe2_x_pos,
				  pipe_y_pos => pipe2_y_pos,
				  pipe_on => pipe2_on,
				  pipe_enable => pipe2_enable);
				  
	PIPE3_COMPONENT: entity work.pipe
    PORT MAP (enable => pipe_start,
				  vert_sync => vert_sync, 
				  start=> pipe3_start, 
				  pixel_row => pixel_row, 
				  pixel_column => pixel_column,
                  randomiser_value => randomiser_value,
				  pipe_x_pos => pipe3_x_pos,
				  pipe_y_pos => pipe3_y_pos,
				  pipe_on => pipe3_on,
				  pipe_enable => pipe3_enable);
    

  COLLISION_COMPONENT: entity work.collision
  PORT MAP (clk => clock_25Mhz,
        vert_sync => vert_sync,
		  ball_on => ball_on,
		  pipe_on => pipe_on,
        ball_y_pos => ball_y_pos,
        ball_size => size,
        collision => collision,
		  pipe_start => pipe_start,
		  ball_enable => ball_enable);

-- ADDITIONAL COMPOENNETS END

  -- Pipe logic
  pipe3_start<= '1' when pipe2_x_pos <= std_logic_vector(to_unsigned(425, 11))
						  else 
					 '0';
					 
  pipe2_start<= '1' when pipe1_x_pos <= std_logic_vector(to_unsigned(425, 11))
						  else 
					 '0';
		
  pipe_on <= pipe1_on or pipe2_on or pipe3_on;
  
  pipe_enable <= pipe1_enable or pipe2_enable or pipe3_enable;
  	 








r_mode <= r_training when mode = '0' else r_sp;
g_mode <= g_training when mode = '0' else g_sp;
b_mode <= b_training when mode = '0' else b_sp;


 red_in   <= "0000" when pipe_on = '1' else ball_r when ball_on = '1' ;
 green_in <= "1111" when pipe_on = '1' else ball_g when ball_on = '1';
 blue_in  <= "0000" when pipe_on = '1' else ball_b when ball_on = '1';

red_out <= box_r or r_score or r_level or r_heart1 or r_heart2 or r_heart3 or r_mode  or red_in;
green_out <= box_g or g_score or g_level or g_heart1 or g_heart2 or g_heart3 or g_mode or green_in;
blue_out <= box_b or b_score or b_level or b_heart1 or b_heart2 or b_heart3 or b_mode or blue_in;

    -- VIDEO ON SIGNAL
  video_on <= '1' when (
    box_on = '1' or
    r_score /= "0000" or g_score /= "0000" or b_score /= "0000" or
    r_level /= "0000" or g_level /= "0000" or b_level /= "0000" or
    r_heart1 /= "0000" or g_heart1 /= "0000" or b_heart1 /= "0000" or
    r_heart2 /= "0000" or g_heart2 /= "0000" or b_heart2 /= "0000" or
    r_heart3 /= "0000" or g_heart3 /= "0000" or b_heart3 /= "0000" or
    r_mode /= "0000" or g_mode /= "0000" or b_mode /= "0000" or 
    red_in = "1111" or green_in = "1111" or blue_in = "1111"
) else '0';

END a;


