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

  -- Internal signals for VGA
  signal pixel_row, pixel_column    : std_logic_vector(9 downto 0);
  signal red_in, green_in, blue_in : std_logic_vector(3 downto 0);
  signal red_sig, green_sig, blue_sig : std_logic_vector(3 downto 0);
  signal hs, vs : std_logic;

  -- signals for background

  signal bg_r, bg_g, bg_b : std_logic_vector(3 downto 0);

  component pll_25mhz is
    port (
      refclk   : in  std_logic; --  refclk.clk
      rst      : in  std_logic; --  reset.reset
      outclk_0 : out std_logic --  outclk0.clk
    );
  end component;

begin

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


  -- VGA background assignment
  red_in <= bg_r;
  green_in <= bg_g;
  blue_in <= bg_b;

  -- VGA driver assignment
  VGA_R <= red_sig;
  VGA_G <= green_sig;
  VGA_B <= blue_sig;

  VGA_HS <= hs;
  VGA_VS <= vs;
  
  
  -- Button/Switch controls
  PLAY <= not KEY(0);
  RESTART <= not KEY(1);
  MODE <= SW(0);

  -- For testing
  LEDR(1) <=  '1' when game_pause = '1'
              else '0';
  LEDR(0) <=  '1' when game_reset = '1'
              else '0';

  end architecture;
