library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

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
  signal red_in, green_in, blue_in : std_logic;
  signal red_sig, green_sig, blue_sig : std_logic;
  signal hs, vs : std_logic;

  -- Signals for text display
  signal r_start, g_start, b_start : std_logic_vector(3 downto 0);
  signal r_press,g_press,b_press : std_logic_vector(3 downto 0);
  signal scale_val : integer;

  signal msg_start : text_string(1 to 12) := "PRESS BUTTON";
  signal msg_pressed : text_string(1 to 14) := "BUTTON PRESSED";


  signal r_mux, g_mux, b_mux : std_logic_vector(3 downto 0);
  
  --Signals for ball
  signal ball_on, ball_r, ball_g, ball_b : std_logic;
  signal ball_enable: std_logic:= '1';
  SIGNAL collision				: std_logic:= '0';

  
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


begin

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

    --For ball movement
    -- Instantiate BOUNCY_BALL component
    BOUNCY_BALL_COMPONENT: entity work.bouncy_ball
    PORT MAP (	enable=> ball_enable, click => left_click, pb1 => push_button_1, pb2 => push_button_2, clk => CLOCK_25, vert_sync => vs,
          pixel_row => pixel_row, pixel_column => pixel_column,
          ball_on_out => ball_on, 
			 red => ball_r, green => ball_g, blue => ball_b,
			 collision => collision);
    
    --LFSR for random pipe gap position
    LFSR_COMPONENT: entity work.lfsr
    PORT MAP (clk => CLOCK_25, enable => pipe_enable, random_value => randomiser_value);

    -- For pipe movement
    -- Instantiate PIPE component
    PIPE1_COMPONENT: entity work.pipe
    PORT MAP (enable => pipe_start, 
				  vert_sync => vs, 
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
				  vert_sync => vs, 
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
				  vert_sync => vs, 
				  start=> pipe3_start, 
				  pixel_row => pixel_row, 
				  pixel_column => pixel_column,
          randomiser_value => randomiser_value,
				  pipe_x_pos => pipe3_x_pos,
				  pipe_y_pos => pipe3_y_pos,
				  pipe_on => pipe3_on,
				  pipe_enable => pipe3_enable);

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

  -- Text display instance for start_text
  VGA_TEXT_inst : entity work.VGA_TEXT
    port map (
    pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => CLOCK_25,
    message => msg_start,
    start_row => 100,
    start_col => 80,
    scale => scale_val,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_start,
    green_out => g_start,
    blue_out => b_start
    );

  -- Text display instance for pressed_text
  VGA_PRESSED_TEXT : entity work.VGA_TEXT
    port map (
   pixel_row => pixel_row,
    pixel_column => pixel_column,
    clock_25Mhz => CLOCK_25,
    message => msg_pressed,
    start_row => 100,
    start_col => 80,
    scale => scale_val,
    text_r => "1111",
    text_g => "1111",
    text_b => "1111",
    red_out => r_press,
    green_out => g_press,
    blue_out => b_press
  );

  -- Pipe logic
  pipe3_start<= '1' when pipe2_x_pos <= std_logic_vector(to_unsigned(425, 11))
						  else 
					 '0';
					 
  pipe2_start<= '1' when pipe1_x_pos <= std_logic_vector(to_unsigned(425, 11))
						  else 
					 '0';
		
  pipe_on <= pipe1_on or pipe2_on or pipe3_on;
  
  pipe_enable <= pipe1_enable or pipe2_enable or pipe3_enable;
  
  -- Collision logic
  pipe_start <= '0' when collision = '1'
						  else 
					 '1';

  ball_enable <= '0' when collision = '1'
						  else 
					 '1';
					 
  

  -- Scale from switchs
  scale_val <= to_integer(unsigned(SW(1 downto 0))) + 1; -- Scale factor from 1 to 4 based on the value of the first two switches

  -- Mux to switch between start and pressed text based on button press
  r_mux <= r_press when push_button_1 = '0' else r_start;
  g_mux <= g_press when push_button_1 = '0' else g_start;
  b_mux <= b_press when push_button_1 = '0' else b_start;

  -- Connect the mux outputs to the VGA outputs
 red_in   <= '0' when pipe_on = '1' else ball_r when ball_on = '1' else r_mux(3);
 green_in <= '1' when pipe_on = '1' else ball_g when ball_on = '1' else g_mux(3) or '1';
 blue_in  <= '0' when pipe_on = '1' else ball_b when ball_on = '1' else b_mux(3) or '1';

  VGA_R <= (others => red_sig);
  VGA_G <= (others => green_sig);
  VGA_B <= (others => blue_sig);

  VGA_HS <= hs;
  VGA_VS <= vs;
    
	-- TEst
	LEDR <= (others => left_click);
	hard_reset <= '0';
 
  
  end architecture;
