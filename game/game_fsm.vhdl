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