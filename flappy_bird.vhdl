library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.custom_types.all;
use work.text_pkg.all;

entity flappy_bird is
  port (
    CLOCK_50  : in  std_logic;
    LEDR      : out std_logic_vector(9 downto 0);
    HEX3, HEX2, HEX1, HEX0  : out std_logic_vector(6 downto 0);
    PS2_CLK, PS2_DAT  : inout std_logic;
   
    SW : in std_logic_vector(9 downto 0);
    KEY : in  std_logic_vector(3 downto 0);
    VGA_R : out std_logic_vector(3 downto 0);
    VGA_G : out std_logic_vector(3 downto 0);
    VGA_B : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
  );
end flappy_bird;

architecture hw_interface of flappy_bird is

  -- TEMPORARY: DELETE ONCE DDONE
  -- signal CLOCK_50 : std_logic;



  signal CLOCK_25       : std_logic;
  signal PLAY, RESTART  : std_logic;
  signal MODE           : std_logic;

  signal state          : game_state;
  signal game_mode      : std_logic;
  signal game_reset, game_pause   : std_logic;
  signal player_dead    : std_logic;


  signal mouse_data, mouse_clk    : std_logic;
  signal left_click, right_click  : std_logic;
  signal mouse_row, mouse_col     : std_logic_vector(9 downto 0);

  SIGNAL cursor_r, cursor_g, cursor_b : std_logic_vector(3 downto 0);
  SIGNAL cursor_on : std_logic;
  SIGNAL row_int, col_int : integer;
  SIGNAL mouse_row_int, mouse_col_int : integer;


  -- Internal signals for VGA
  signal pixel_row, pixel_column    : std_logic_vector(9 downto 0);
  signal red_in, green_in, blue_in : std_logic_vector(3 downto 0);
  signal red_sig, green_sig, blue_sig : std_logic_vector(3 downto 0);
  signal hs, vs : std_logic;

  -- signals for background

  signal bg_r, bg_g, bg_b : std_logic_vector(3 downto 0);

-- Signals for start screen
  signal start_clicked : std_logic;
  signal start_r, start_g, start_b : std_logic_vector(3 downto 0);
  signal start_video_on : std_logic;



  -- Signals for gameplay screen  
  signal r_game, g_game, b_game : std_logic_vector(3 downto 0);
  signal game_video_on : std_logic;
  signal current_score : integer range 0 to 999;
  signal current_level : integer range 1 to 3;
  signal current_lives : integer range 0 to 3;
  signal is_high_score : std_logic;


  --Signals for pause
  signal r_pause,    g_pause,    b_pause    : std_logic_vector(3 downto 0);
  signal pause_video_on : std_logic;

  --Signals for gameover 
  signal r_gameover,g_gameover,b_gameover : std_logic_vector(3 downto 0);
  signal gameover_video_on : std_logic;
  signal gameover_clicked : std_logic;
  signal gameover_screen_click : std_logic;

  -- Gated the mouse clicks

 signal gate_left_click  : std_logic;
signal gate_start_click : std_logic;





  component pll_25mhz is
    port (
      refclk   : in  std_logic; --  refclk.clk
      rst      : in  std_logic; --  reset.reset
      outclk_0 : out std_logic --  outclk0.clk
    );
  end component;

begin


   -- GENERATE CURSOR TEMP.

  row_int <= to_integer(unsigned(pixel_row));
  col_int <= to_integer(unsigned(pixel_column));
  mouse_row_int <= to_integer(unsigned(mouse_row));
  mouse_col_int <= to_integer(unsigned(mouse_col));

  cursor_on <= '1' when (row_int >= mouse_row_int and row_int < mouse_row_int + 8 and col_int >= mouse_col_int and col_int < mouse_col_int + 8) else '0';

  cursor_r <= "1111" when cursor_on = '1' else "0000";
  cursor_g <= "0000" when cursor_on = '1' else "0000";
  cursor_b <= "1111" when cursor_on = '1' else "0000";




  CLK_DIV_2 : pll_25mhz
    port map (
      refclk => CLOCK_50,
      rst => '0',
      outclk_0 => CLOCK_25
  );

  MOUSE_PS2 : entity work.mouse
    port map (
      clock_25mhz => CLOCK_25,
      reset => '0',
      mouse_data => PS2_DAT,
      mouse_clk => PS2_CLK,
      left_button => left_click,
      right_button => right_click,
      mouse_cursor_row => mouse_row,
      mouse_cursor_column => mouse_col
  );

  -- Drives signal on VGA IO, and provides pixel sync to other components
  VGA_SYNC_inst : entity work.VGA_SYNC
    port map (
    clock_25Mhz => CLOCK_25,
    red => red_in, -- Use the most significant bit of text_r for the red signal
    green => green_in, -- Use the most significant bit of text_g for the green signal
    blue => blue_in, -- Use the most significant bit of text_b for the blue signal
    
    -- Assuming c_out signals have been changed to 4 bit
    red_out => red_sig,
    green_out => green_sig,
    blue_out => blue_sig,
    horiz_sync_out => hs,
    vert_sync_out => vs,
    pixel_row => pixel_row,
    pixel_column => pixel_column
  );

  VGA_BACKGROUND_inst : entity work.VGA_BACKGROUND
    port map (
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => CLOCK_25,
        red_out => bg_r,
        green_out => bg_g,
        blue_out => bg_b
  );


  -- Button/Switch controls
  -- assignments
  gate_left_click  <= left_click when state = PLAY_GAME else '0';
  gate_start_click <= left_click when state = START_MENU else '0';
  gameover_clicked <=  gameover_screen_click when state = GAME_OVER else '0';
 PLAY <= not KEY(0) or gate_start_click or gameover_clicked;
  RESTART <= not KEY(1);
  MODE <= SW(0);


  STATUS_FSM  : entity work.game_fsm
    port map (
      clk => CLOCK_25,
      PLAY => PLAY,
      RESTART => RESTART,
      MODE => MODE,
      state => state,
      game_mode => game_mode,
      reset => game_reset,
      pause => game_pause,
      player_dead => player_dead
  );

  -- START SCREEN

  START_SCREEN : entity work.start_screen
    port map (
      pixel_row => pixel_row,
      pixel_column => pixel_column,
      clock_25Mhz => CLOCK_25,
      mode => MODE,
      mouse_click => gate_start_click,
      mouse_row => mouse_row,
      mouse_col => mouse_col,
      video_on => start_video_on,
      start_clicked => start_clicked,
      red_out => start_r,
      green_out => start_g,
      blue_out => start_b
  );  


  -- Game play screen
GAME_PLAY_SCREEN : entity work.gameplay_screen
    port map (
    vert_sync => vs,
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => CLOCK_25,
    mode => game_mode,
    score => current_score,
    level => current_level,
    lives => current_lives,
    is_high_score => is_high_score,
    reset => game_reset,
    pause => game_pause,
    player_dead => player_dead,
    left_click => gate_left_click,
    video_on => game_video_on,
    red_out => r_game,
    green_out => g_game,
    blue_out => b_game
  );

  -- Pause screeen
   -- VGA_PAUSE_screen : entity work.pause_screen
    VGA_PAUSE_screen : entity work.pause_screen
    port map (
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => CLOCK_25,
        score => current_score, -- Placeholder score value
        level => current_level, -- Placeholder level value
        lives => current_lives, -- Placeholder lives value MAX 3 
        red_out => r_pause,
        green_out => g_pause,
        blue_out => b_pause,
        video_on => pause_video_on
    );

  -- GAMEOVER SCREEN
      VGA_GAMEOVER_screen : entity work.gameover_screen
    port map (
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => CLOCK_25,
        score => current_score, 
        is_high_score => is_high_score, 
        mouse_click => left_click,
        mouse_row   => mouse_row,
        mouse_col   => mouse_col,
        go_to_menu  => gameover_screen_click,
        red_out => r_gameover,
        green_out => g_gameover,
        blue_out => b_gameover,
        video_on => gameover_video_on
    );


  



  -- VGA background assignment
red_in <= cursor_r when cursor_on = '1' else
          start_r when state = START_MENU and start_video_on = '1' else
          bg_r when state = START_MENU else
          r_game when state = PLAY_GAME and game_video_on = '1' else
          bg_r when state = PLAY_GAME else
          r_pause when state = PAUSE_GAME and pause_video_on = '1' else
          r_game when state = PAUSE_GAME and game_video_on = '1' else
          bg_r when state = PAUSE_GAME else
          r_gameover when state = GAME_OVER and gameover_video_on = '1' else 
          bg_r when STATE = GAME_OVER else
          bg_r;

green_in <= cursor_g when cursor_on = '1' else
            start_g when state = START_MENU and start_video_on = '1' else
            bg_g when state = START_MENU else
            g_game when state = PLAY_GAME and game_video_on = '1' else
            bg_g when state = PLAY_GAME else
            g_pause when state = PAUSE_GAME and pause_video_on = '1' else
            g_game when state = PAUSE_GAME and game_video_on = '1' else
            bg_g when state = PAUSE_GAME else
            g_gameover when state = GAME_OVER and gameover_video_on = '1' else 
            bg_g when STATE = GAME_OVER else
            bg_g;

blue_in <= cursor_b when cursor_on = '1' else
           start_b when state = START_MENU and start_video_on = '1' else
           bg_b when state = START_MENU else
           b_game when state = PLAY_GAME and game_video_on = '1' else
           bg_b when state = PLAY_GAME else
           b_pause when state = PAUSE_GAME and pause_video_on = '1' else
            b_game when state = PAUSE_GAME and game_video_on = '1' else
          bg_b when state = PAUSE_GAME else

           b_gameover when state = GAME_OVER and gameover_video_on = '1' else 
           bg_b when STATE = GAME_OVER else
			  bg_b;

  -- VGA driver assignment
  VGA_R <= red_sig;
  VGA_G <= green_sig;
  VGA_B <= blue_sig;

  VGA_HS <= hs;
  VGA_VS <= vs;
  
  
  

  -- For testing
  LEDR(1) <=  '1' when game_pause = '1'
              else '0';
  LEDR(0) <=  '1' when game_reset = '1'
              else '0';

  end architecture;
