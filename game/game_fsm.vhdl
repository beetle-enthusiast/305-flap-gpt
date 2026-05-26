library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.custom_types.all;

--  Control inputs
--    PLAY: Selects options and play/pauses the active game
--    RESTART:  Quits game and goes to start menu without displaying score
--    MODE: 2-state switch which selects the game mode of the new game

--  Control signals
--    state:  Current game state (START_MENU, PLAY_GAME, PAUSE_GAME, GAME_OVER)
--    game_mode:  Game mode of active game
--    reset:  Resets all stored game data / components
--    pause:  Pause menu is displayed and game logic is halted

--  Status signals
--    player_dead:  Signals that the active game is over

entity game_fsm is
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
end game_fsm;

architecture shmoovement of game_fsm is

  signal current_state                : game_state := START_MENU;
  signal play_prev, restart_prev      : std_logic := '0';

begin

  fsm : process(clk)
  begin
    if rising_edge(clk) then

      -- Update edge detection registers
      play_prev    <= PLAY;
      restart_prev <= RESTART;

      -- RESTART from anywhere
      if (RESTART = '1' and restart_prev = '0') then
        current_state <= START_MENU;

      else
        case current_state is

          when START_MENU =>
            if (PLAY = '1' and play_prev = '0') then
              current_state <= PLAY_GAME;
              game_mode     <= MODE;
            end if;

          when PLAY_GAME =>
            if (player_dead = '1') then
              current_state <= GAME_OVER;
            elsif (PLAY = '1' and play_prev = '0') then
              current_state <= PAUSE_GAME;
            end if;

          when PAUSE_GAME =>
            if (PLAY = '1' and play_prev = '0') then
              current_state <= PLAY_GAME;
            end if;

          when GAME_OVER =>
            if (PLAY = '1' and play_prev = '0') then
              current_state <= START_MENU;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

  state <= current_state;
  reset <= '1' when current_state = START_MENU  else '0';
  pause <= '1' when current_state = PAUSE_GAME
               or   current_state = GAME_OVER   else '0';

end architecture;