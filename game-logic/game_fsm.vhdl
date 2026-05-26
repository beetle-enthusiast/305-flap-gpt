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

  signal current_state  : game_state  := START_MENU; -- Initialised at start menu
  signal play_prev, restart_prev  : std_logic := '0';

begin

  fsm : process(clk, PLAY, RESTART)
    variable play_pressed             : std_logic := '0';
  begin
    if rising_edge(clk) then

      play_prev <= PLAY;
      restart_prev <= RESTART;

      -- Check if play button is pressed
      if (PLAY = '1') and (play_prev = '0') then
        -- If some states do not have a play button input, 
        -- play_pressed should not be set HIGH in those states
        -- Alternatively continuously set pray_pressed LOW
        play_pressed := '1';
      end if;

      -- Check if restart button is pressed
      if (RESTART = '1') and (restart_prev = '0') then
        current_state <= START_MENU;
      end if;

      -- FSM state logic
      case current_state is

        when START_MENU => 
          if (play_pressed = '1') then
            play_pressed := '0';
            -- Start game
            current_state <= PLAY_GAME;
            game_mode <= MODE; -- Mealy machine YAY
          end if;
          
        when PLAY_GAME => 
          if (player_dead = '1') then
            play_pressed := '0';
            -- Game is over
            current_state <= GAME_OVER;
          elsif (play_pressed = '1') then
            play_pressed := '0';
            -- Pause game
            current_state <= PAUSE_GAME;
          end if;
          
        when PAUSE_GAME => 
          if (play_pressed = '1') then
            play_pressed := '0';
            -- Resume game
            current_state <= PLAY_GAME;
          end if;

        when GAME_OVER => 
          if (play_pressed = '1') then
            play_pressed := '0';
            -- Press any button to go to start menu (but not actually)
            current_state <= START_MENU;
          end if;
      
        when others => 
          null;
      
      end case;
    end if;

  end process;

  state <= current_state;

  reset <=  '1' when (current_state = START_MENU)
            else '0';
  pause <=  '1' when (current_state = PAUSE_GAME) or (current_state = GAME_OVER)
            else '0';

end architecture;