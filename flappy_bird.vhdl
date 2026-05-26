library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.text_pkg.all;

entity flappy_bird is
  port (
    push_button_1, push_button_2, CLOCK_50  : in  std_logic;
    LEDR      : out std_logic_vector(9 downto 0);
    HEX3, HEX2, HEX1, HEX0  : out std_logic_vector(6 downto 0);
    PS2_CLK, PS2_DAT  : inout std_logic;


    -- FOR TEXT_DISPLAY

   
    SW : in std_logic_vector(9 downto 0);
    VGA_R : out std_logic_vector(3 downto 0);
    VGA_G : out std_logic_vector(3 downto 0);
    VGA_B : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
    
  );
end flappy_bird;

architecture hw_interface of flappy_bird is

  signal CLOCK_25, hard_reset     : std_logic;
  signal mouse_data, mouse_clk    : std_logic;
  signal left_click, right_click  : std_logic;
  signal mouse_row, mouse_col     : std_logic_vector(9 downto 0);

  signal start_clicked_sig : std_logic; --  SIGNAL CONNECTS TO THE FSM PLAY BUTTON

  SIGNAL cursor_r, cursor_g, cursor_b : std_logic_vector(3 downto 0);
  SIGNAL cursor_on : std_logic;
  SIGNAL row_int, col_int : integer;
  SIGNAL mouse_row_int, mouse_col_int : integer;

  SIGNAL gameplay_video_on : std_logic;

  component pll_25mhz is
    port (
      refclk   : in  std_logic; --  refclk.clk
      rst      : in  std_logic; --  reset.reset
      outclk_0 : out std_logic; --  outclk0.clk
      locked   : out std_logic  --  locked.export
    );
  end component;

  -- Internal signals for VGA
  signal pixel_row, pixel_column : std_logic_vector(9 downto 0);
  signal red_in, green_in, blue_in : std_logic_vector(3 downto 0);
  signal red_sig, green_sig, blue_sig : std_logic_vector(3 downto 0);
  signal hs, vs : std_logic;

  -- -- Signals for text display
  -- signal r_start, g_start, b_start : std_logic_vector(3 downto 0);
  -- signal r_press,g_press,b_press : std_logic_vector(3 downto 0);
  -- signal scale_val : integer;

  -- signal msg_start : text_string(1 to 12) := "PRESS BUTTON";
  -- signal msg_pressed : text_string(1 to 14) := "BUTTON PRESSED";


  -- signal r_mux, g_mux, b_mux : std_logic_vector(3 downto 0);
  
  -- --Signals for ball
  -- signal ball_r, ball_g, ball_b : std_logic;

  -- Signals for background

  signal bg_r, bg_g, bg_b : std_logic_vector(3 downto 0);

  SIGNAL r_screen, g_screen, b_screen : std_logic_vector(3 downto 0);
  

  --Signal for mouse cursor


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
      rst => hard_reset,
      outclk_0 => CLOCK_25
    );

  MOUSE_PS2 : entity work.mouse
    port map (
      clock_25mhz => CLOCK_25,
      reset => hard_reset,
      mouse_data => PS2_DAT,
      mouse_clk => PS2_CLK,
      left_button => left_click,
      right_button => right_click,
      mouse_cursor_row => mouse_row,
      mouse_cursor_column => mouse_col
    );

   
    -- For text display 
    -- 1. A instance of VGA_SYNC to generate the sync signals and pixel coordinates
    VGA_SYNC_inst : entity work.VGA_SYNC
    port map (
    clock_25Mhz => CLOCK_25,
    red => red_in, -- Use the most significant bit of text_r for the red signal
    green => green_in, -- Use the most significant bit of text_g for the green signal
    blue => blue_in, -- Use the most significant bit of text_b for the blue signal
    
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


    VGA_START_screen : entity work.start_screen

    port map (
        pixel_row => pixel_row,
        pixel_column => pixel_column,
        clock_25Mhz => CLOCK_25,
        mode => SW(0),
        mouse_click  => left_click,
        mouse_row => mouse_row,
        mouse_col => mouse_col,
        start_clicked => start_clicked_sig,
        video_on => gameplay_video_on,
        red_out => r_screen,
        green_out => g_screen,
        blue_out => b_screen
    );


    -- VGA_GAMEPLAY_screen : entity work.gameplay_screen
    -- port map (
    --     pixel_row => pixel_row,
    --     pixel_column => pixel_column,
    --     clock_25Mhz => CLOCK_25,
    --     score => 10, -- Placeholder score value
    --     level => 3, -- Placeholder level value
    --     lives => 3, -- Placeholder lives value MAX 3 
    --     red_out => r_screen,
    --     green_out => g_screen,
    --     blue_out => b_screen,
    --     video_on => gameplay_video_on
    -- );

    -- -- VGA_Game over screen
    -- VGA_GAMEOVER_screen : entity work.gameover_screen
    -- port map (
    --     pixel_row => pixel_row,
    --     pixel_column => pixel_column,
    --     clock_25Mhz => CLOCK_25,
    --     score => 10, -- Placeholder score value
    --     is_high_score => '1', -- Placeholder high score flag
    --     red_out => r_screen,
    --     green_out => g_screen,
    --     blue_out => b_screen,
    --     video_on => gameplay_video_on
    -- );

    -- -- VGA_PAUSE_screen : entity work.pause_screen
    -- VGA_PAUSE_screen : entity work.pause_screen
    -- port map (
    --     pixel_row => pixel_row,
    --     pixel_column => pixel_column,
    --     clock_25Mhz => CLOCK_25,
    --     score => 10, -- Placeholder score value
    --     level => 3, -- Placeholder level value
    --     lives => 3, -- Placeholder lives value MAX 3 
    --     red_out => r_screen,
    --     green_out => g_screen,
    --     blue_out => b_screen,
    --     video_on => gameplay_video_on
    -- );

      

  -- Connect the mux outputs to the VGA outputs
  red_in   <= cursor_r when cursor_on = '1' else
            r_screen when gameplay_video_on = '1' else
            bg_r;
green_in <= cursor_g when cursor_on = '1' else
            g_screen when gameplay_video_on = '1' else
            bg_g;
blue_in  <= cursor_b when cursor_on = '1' else
            b_screen when gameplay_video_on = '1' else
            bg_b;


  VGA_R <= red_sig;
VGA_G <= green_sig;
VGA_B <= blue_sig;

  VGA_HS <= hs;
  VGA_VS <= vs;
    
	-- TEst
	LEDR <= (others => left_click);
	hard_reset <= '0';
 
  
  end architecture;
