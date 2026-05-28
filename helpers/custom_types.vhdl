library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package custom_types is

  type game_state is (START_MENU, PLAY_GAME, PAUSE_GAME, GAME_OVER);
  type binary_coded_decimal is array (0 to 2) of std_logic_vector(3 downto 0);
  
end package;
