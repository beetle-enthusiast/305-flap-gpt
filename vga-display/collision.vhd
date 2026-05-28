LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY collision IS
    PORT (
        clk, vert_sync      : IN std_logic;
        bird_on, pipe_on    : IN std_logic;
        bird_y_pos, bird_size : IN std_logic_vector(9 DOWNTO 0);
        collision, death           : OUT std_logic;
        pipe_start, bird_enable : OUT std_logic
    );
END collision;

ARCHITECTURE behavior OF collision IS

    SIGNAL death_temp, collision_temp            : std_logic := '0';
    SIGNAL collision_reset           : std_logic := '0';
    SIGNAL reset                     : std_logic := '0';
    SIGNAL collision_per_frame       : std_logic := '0';
    SIGNAL prev_collision_per_frame  : std_logic := '0';

    
    -- 1‑frame delayed bird_on to fix pipe‑clipping glitch
    
    SIGNAL bird_on_delayed, pipe_on_delayed : std_logic := '0';

BEGIN

    
    -- Update delayed bird_on once per frame
    
    Delay: PROCESS(vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN
            bird_on_delayed <= bird_on;
				pipe_on_delayed <= pipe_on;
        END IF;
    END PROCESS Delay;


    
    -- Pixel-clock collision detection 
    
    Check_Collision : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN

            IF reset = '1' THEN
                collision_temp <= '0';

            ELSE

                IF collision_reset = '1' THEN
                    collision_temp <= '0';

                -- Use bird_on_delayed instead of bird_on to avoid glitches with pipe
                
                ELSIF (bird_on_delayed = '1' AND pipe_on_delayed = '1') THEN
                    collision_temp <= '1';

                -- hit ceiling
                ELSIF (unsigned(bird_y_pos) <= unsigned(bird_size)) THEN
                    collision_temp <= '1';

                -- hit bottom = death
                ELSIF unsigned(bird_y_pos) >=
                      (to_unsigned(479, 10) - unsigned(bird_size)) THEN
                    death_temp <= '1';
                END IF;

                -- existing one-cycle reset pulse logic
                IF (collision_per_frame = '1' AND prev_collision_per_frame = '0') THEN
                    collision_reset <= '1';
                ELSE
                    collision_reset <= '0';
                END IF;

            END IF;

            prev_collision_per_frame <= collision_per_frame;

        END IF;
    END PROCESS Check_Collision;


    -- Frame-based collision handling 
    Reset_collision : PROCESS(vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN

            IF reset = '1' THEN
                collision_per_frame <= '0';
                pipe_start          <= '1';
                bird_enable         <= '1';

            ELSE
                collision_per_frame <= collision_temp;

                IF collision_temp = '1' THEN
                    pipe_start  <= '0';
                    bird_enable <= '0';
                ELSE
                    pipe_start  <= '1';
                    bird_enable <= '1';
                END IF;

            END IF;

        END IF;
    END PROCESS Reset_collision;

    collision <= collision_temp;
    death <= death_temp;

END behavior;
