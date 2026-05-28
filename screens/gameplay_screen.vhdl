
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;

--TO DO FIX WITH FSM RESET .


ENTITY GAMEPLAY_SCREEN IS
	PORT(
        vert_sync : IN std_logic;
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        mode : IN STD_LOGIC;
        left_click : IN std_logic;
        reset : IN STD_LOGIC;
        pause : IN STD_LOGIC;
        player_dead : OUT STD_LOGIC; 
        is_high_score : out STD_LOGIC;
        score : out integer range 0 to 999;
        level : out integer range 1 to 3;
        lives : out integer range 0 to 3; -- Is probably not needed
        video_on : OUT STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END GAMEPLAY_SCREEN;

ARCHITECTURE a OF GAMEPLAY_SCREEN IS

-- Difficulty controls - 
signal points : integer range 0 to 127	:= 0;
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

--Signals for lives,score,level
-- In the signals section, add:
signal score_int : integer range 0 to 999 := 0;
signal level_int : integer range 1 to 3   := 1;
signal lives_int : integer range 0 to 3   := 3;


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
  signal ball_enable: std_logic;
  signal size				: std_logic_vector(9 DOWNTO 0);

  --Signals for collision
  SIGNAL collision				: std_logic:= '0';
  SIGNAL pipe_x_pos, ball_x_pos : std_logic_vector(10 downto 0);
  SIGNAL pipe_y_pos, ball_y_pos : std_logic_vector(9 DOWNTO 0);
  
  --Signals for pipe
signal pipe2_start, pipe3_start,
       pipe_on, pipe1_on, pipe2_on, pipe3_on,
       pipe_enable, pipe1_enable, pipe2_enable, pipe3_enable : std_logic;
  signal pipe_start: std_logic;
  signal pipe1_x_pos, pipe2_x_pos, pipe3_x_pos: std_logic_vector(10 downto 0);
  signal pipe1_y_pos, pipe2_y_pos, pipe3_y_pos: std_logic_vector(9 downto 0);

signal pipe1_r, pipe1_g, pipe1_b : std_logic_vector(3 downto 0);
signal pipe2_r, pipe2_g, pipe2_b : std_logic_vector(3 downto 0);
signal pipe3_r, pipe3_g, pipe3_b : std_logic_vector(3 downto 0);
signal pipe_r, pipe_g, pipe_b    : std_logic_vector(3 downto 0);
  
  --Signals for lfsr
  signal randomiser_value : std_logic_vector (7 downto 0);
-- SIGNALS ADDED ENDS

begin

    LEVEL_CALC : entity work.levels
    port map (
      points => points,
      scroll_speed => scroll_speed
    );
		score <= points;

    ball_enable <= '1';
		pipe_start  <= '1';

    -- FOR NOW assigning outputs to score, level and lives 
    score <= score_int;
    level <= level_int;
    lives <= lives_int;

    --HARDCODED HIGH SCORE
    is_high_score <= '0';

    process(score_int)
    begin
        msg_score(8) <= character'val(score_int / 100 + 48);
        msg_score(9) <= character'val((score_int mod 100) / 10 + 48);
        msg_score(10) <= character'val(score_int mod 10 + 48);
    end process;

    process(level_int)
    begin
        msg_level(8) <= character'val(level_int + 48);
    end process;

    process(lives_int)
    begin
        msg_lives(8) <= character'val(lives_int + 48);
    end process;



         -- text for levels
    VGA_TEXT_LEVEL : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => clock_25Mhz,
    message => msg_level,
    start_row => 22,
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
    start_row => 22,
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
    start_row => 22,
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
    start_row => 22,
    start_col => 100,
    scale => 1,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_sp,
    green_out => g_sp,
    blue_out => b_sp
    );
    
    -- Hearts for lives : 
   HEART1 : entity work.heart
    port map(
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => clock_25Mhz,
        start_row => 22,
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
        start_row => 22,
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
        start_row => 22,
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
                  clk => clock_25Mhz,
                  pipe_r => pipe1_r,
                  pipe_g => pipe1_g,
                  pipe_b => pipe1_b,
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
                  clk => clock_25Mhz,
                  pipe_r => pipe2_r,
                  pipe_g => pipe2_g,
                  pipe_b => pipe2_b,
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
                  clk => clock_25Mhz,
                  pipe_r => pipe3_r,
                  pipe_g => pipe3_g,
                  pipe_b => pipe3_b,
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
        collision => collision
		--   pipe_start => pipe_start,
		--   ball_enable => ball_enable
    );

-- ADDITIONAL COMPOENNETS END
-- 1. box and mode signals
box_and_mode: process(clock_25Mhz)
begin 
    if rising_edge(clock_25Mhz) then 
        box_row_int <= to_integer(unsigned(pixel_row));
        box_col_int <= to_integer(unsigned(pixel_column));
        
        if box_row_int <= 55 and box_col_int <= 639 then
            box_on <= '1';
        else 
            box_on <= '0';
        end if;

        if box_on = '1' then 
            box_r <= "0010";
            box_g <= "0001";
            box_b <= "0000";
        else 
            box_r <= "0000"; box_g <= "0000"; box_b <= "0000";
        end if;

         if mode = '0' then
            r_mode <= r_training;
            g_mode <= g_training;
            b_mode <= b_training;
        else
            r_mode <= r_sp;
            g_mode <= g_sp;
            b_mode <= b_sp;
        end if;
    end if;
        
end process;

-- r_mode <= r_training when mode = '0' else r_sp;
-- g_mode <= g_training when mode = '0' else g_sp;
-- b_mode <= b_training when mode = '0' else b_sp;
        

-- Pipe logic 
Pipe_logic : process(clock_25Mhz)
begin
  if rising_edge(clock_25Mhz) then
    pipe_r <= pipe1_r or pipe2_r or pipe3_r;
    pipe_g <= pipe1_g or pipe2_g or pipe3_g;
    pipe_b <= pipe1_b or pipe2_b or pipe3_b;
    pipe_on <=  pipe1_on or pipe2_on or pipe3_on;
    pipe_enable <= pipe1_enable or pipe2_enable or pipe3_enable;

    if pipe2_x_pos <= std_logic_vector(to_unsigned(425,11)) then
      pipe3_start <= '1';
    else
      pipe3_start <= '0';
    end if;

    if pipe1_x_pos <= std_logic_vector(to_unsigned(425,11)) then
      pipe2_start <= '1';
    else
      pipe2_start <= '0';
    end if;
  end if;
end process;


  -- video on
  Video_on_proc : process(clock_25Mhz)
  begin 
      if rising_edge(clock_25Mhz)then 
          if (box_on = '1' or pipe_on = '1' or ball_on = '1') then video_on <= '1'; else video_on <= '0'; end if;
      end if; 
  end process;

  Output_assignments : process(clock_25Mhz)
begin 
    if rising_edge(clock_25Mhz) then 
        if box_on = '1' then 
            red_out <= box_r or r_score or r_level or r_heart1 or r_heart2 or r_heart3 or r_mode;
            green_out <= box_g or g_score or g_level or g_heart1 or g_heart2 or g_heart3 or g_mode;
            blue_out <= box_b or b_score or b_level or b_heart1 or b_heart2 or b_heart3 or b_mode;
        elsif pipe_on = '1' then 
            red_out <= pipe_r;
            green_out <= pipe_g;
            blue_out <= pipe_b;
        elsif ball_on = '1' then 
            red_out <= ball_r;
            green_out <= ball_g;
            blue_out <= ball_b;
        else 
            red_out <= "0000";
            green_out <= "0000";
            blue_out <= "0000";
        end if;
      end if;
  end process;

	DECR_LIVES: process(clock_25MHz)
		variable has_collided : std_logic := '0';
	begin
		if rising_edge(clock_25MHz) then
			-- Lives only decrement in SP mode
			if (mode = '1') then
				if (collision = '1') and (has_collided = '0') then
					lives_int <= lives_int - 1;
					has_collided := '1';
				end if;

				if (collision = '0') then
					has_collided := '0';
				end if;

				case lives_int is
					when 0 => 
						player_dead <= '1';
					when 1 => 
						heart1_vis <= '1';
						heart2_vis <= '0';
						heart3_vis <= '0';
					when 2 => 
						heart1_vis <= '1';
						heart2_vis <= '1';
						heart3_vis <= '0';
					when 3 => 
						heart1_vis <= '1';
						heart2_vis <= '1';
						heart3_vis <= '1';
					when others => -- Made this weird to catch bugs lol
						heart1_vis <= '1';
						heart2_vis <= '0';
						heart3_vis <= '1';
				end case;
			end if;

			if (reset = '1') then
        player_dead <= '0';
				lives_int <= 3;
			end if;

		end if;
	end process;

END a;


