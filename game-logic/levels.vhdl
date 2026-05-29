library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity levels is
  port (
    points  : in  integer range 0 to 67;
    scroll_speed  : out integer range 0 to 15
  );
end levels;

architecture calc of levels is
  signal level  : integer range 0 to 3;
  
begin
  level <=  1 when (points < 15) else 
            2 when (points < 35) else 
            3;

  scroll_speed  <=  1 when (level = 1) else
                    2 when (level = 2) else
                    3;
end architecture;