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
  type binary_coded_decimal is array (natural range <>) of std_logic_vector(3 downto 0);

  signal CLOCK_25, reset        : std_logic;
  signal mouse_data, mouse_clk  : std_logic;
  signal left, right            : std_logic;
  signal mouse_row, mouse_col   : std_logic_vector(9 downto 0);

  signal x_bcd, y_bcd : binary_coded_decimal(3 downto 0);

  component pll_25mhz is
    port (
      refclk   : in  std_logic; --  refclk.clk
      rst      : in  std_logic; --  reset.reset
      outclk_0 : out std_logic; --  outclk0.clk
      locked   : out std_logic  --  locked.export
    );
  end component;

begin

  PLL : pll_25mhz
    port map (
      refclk => CLOCK_50,
      rst => reset,
      outclk_0 => CLOCK_25
    );

  MOUSE_PS2 : entity work.mouse
    port map (
      clock_25mhz => CLOCK_25,
      reset => reset,
      mouse_data => PS2_DAT,
      mouse_clk => PS2_CLK,
      left_button => left,
      right_button => right,
      mouse_cursor_row => mouse_row,
      mouse_cursor_column => mouse_col
    );

  reset <= not KEY(0);

  LEDR(1) <= left;
  LEDR(0) <= right;

  -- Computationally expensive, experiment with "double dabble algorithm"
  process (CLOCK_25)
    variable int  : unsigned(9 downto 0);
  begin
    if rising_edge(CLOCK_25) then
      int := unsigned(mouse_col);

      for i in 0 to 3 loop
        x_bcd(i) <= std_logic_vector(resize(int mod 10, 4));
        int := int / 10;
      end loop;
    end if;
  end process;

  SEG3  : entity work.BCD_to_SevenSeg
    port map (
      BCD_digit => x_bcd(3),
      SevenSeg_out => HEX3
  );
  SEG2  : entity work.BCD_to_SevenSeg
    port map (
      BCD_digit => x_bcd(2),
      SevenSeg_out => HEX2
  );
  SEG1  : entity work.BCD_to_SevenSeg
    port map (
      BCD_digit => x_bcd(1),
      SevenSeg_out => HEX1
  );
  SEG0  : entity work.BCD_to_SevenSeg
    port map (
      BCD_digit => x_bcd(0),
      SevenSeg_out => HEX0
  );
  
  end architecture;