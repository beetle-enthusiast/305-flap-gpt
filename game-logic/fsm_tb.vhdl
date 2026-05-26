library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.custom_types.all;


entity fsm_tb is
end fsm_tb;

architecture rtl of fsm_tb is
  signal clk : std_logic;
  signal PLAY, RESTART, MODE  : std_logic;
  signal state  : game_state;
  signal game_mode, reset, pause, player_dead : std_logic;

  component game_fsm is
    port (
      clk : in  std_logic;  -- 25MHz Clock

      -- Control inputs
      PLAY, RESTART : in  std_logic; -- Active HIGH (must invert button inputs)
      MODE          : in  std_logic;

      -- Control signals
      state         : out game_state;
      game_mode     : out std_logic;
      reset, pause  : out std_logic;

      -- Status signals
      player_dead   : in  std_logic
    );
  end component;

begin

  FSM: game_fsm port map (
    clk =>  clk,
    PLAY =>  PLAY,
    RESTART => RESTART,
    MODE => MODE,
    state => state,
    game_mode => game_mode,
    reset => reset,
    pause => pause,
    player_dead => player_dead
  );


  init : process
  begin
    PLAY <= '0', '1' after 60 ns, '0' after 100 ns, '1' after 140 ns;
    RESTART <= '0';
    MODE <= '0';
    player_dead <= '0';
    wait;
  end process;

  clk_gen : process
  begin
    clk <= '0';
    wait for 20 ns;
    clk <= '1';
    wait for 20 ns;
  end process;

end architecture;