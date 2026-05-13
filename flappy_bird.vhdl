library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flappy_bird is
  port (
    CLOCK_50  : in  std_logic;
    KEY       : in  std_logic_vector(3 downto 0);
    LEDR      : out std_logic_vector(9 downto 0);
    HEX3, HEX2, HEX1, HEX0  : out std_logic_vector(6 downto 0);
    PS2_CLK, PS2_DAT  : inout std_logic
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
  
  end architecture;
