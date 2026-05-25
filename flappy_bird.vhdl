library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.text_pkg.all;

entity flappy_bird is
  port (
    PLAY, RESTART, CLOCK_50  : in  std_logic;
    LEDR      : out std_logic_vector(9 downto 0);
    HEX3, HEX2, HEX1, HEX0  : out std_logic_vector(6 downto 0);
    PS2_CLK, PS2_DAT  : inout std_logic;
   
    SW : in std_logic_vector(9 downto 0);
    VGA_R : out std_logic_vector(3 downto 0);
    VGA_G : out std_logic_vector(3 downto 0);
    VGA_B : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
  );
end flappy_bird;

architecture hw_interface of flappy_bird is

  signal CLOCK_25                 : std_logic;
  signal mouse_data, mouse_clk    : std_logic;
  signal left_click, right_click  : std_logic;
  signal mouse_row, mouse_col     : std_logic_vector(9 downto 0);

  -- Internal signals for VGA
  signal pixel_row, pixel_column : std_logic_vector(9 downto 0);
  signal red_in, green_in, blue_in : std_logic_vector(3 downto 0);
  signal hs, vs : std_logic;

  component pll_25mhz is
    port (
      refclk   : in  std_logic; --  refclk.clk
      rst      : in  std_logic; --  reset.reset
      outclk_0 : out std_logic; --  outclk0.clk
      locked   : out std_logic  --  locked.export
    );
  end component;

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

  -- Drives signal on VGA IO, and provides pixel sync to other components
  VGA_SYNC_inst : entity work.VGA_SYNC
    port map (
    clock_25Mhz => CLOCK_25,
    red => red_in, -- Use the most significant bit of text_r for the red signal
    green => green_in, -- Use the most significant bit of text_g for the green signal
    blue => blue_in, -- Use the most significant bit of text_b for the blue signal
    
    -- Assuming c_out signals have been changed to 4 bit
    red_out => VGA_R,
    green_out => VGA_G,
    blue_out => VGA_B,
    horiz_sync_out => VGA_HS,
    vert_sync_out => VGA_VS,
    pixel_row => pixel_row,
    pixel_column => pixel_column
  );
  
  end architecture;
