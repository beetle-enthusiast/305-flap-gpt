LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gift_collision IS
    PORT (
        clk, vert_sync      : IN std_logic;
        ball_on, gift_on    : IN std_logic;
        ball_y_pos, ball_size : IN std_logic_vector(9 DOWNTO 0);
        collision           : OUT std_logic;
        gift_start, ball_enable : OUT std_logic
    );
END gift_collision;

ARCHITECTURE behavior OF gift_collision IS

    SIGNAL collision_temp            : std_logic := '0';
    SIGNAL collision_reset           : std_logic := '0';
    SIGNAL reset                     : std_logic := '0';  -- external reset not wired yet
    SIGNAL collision_per_frame       : std_logic := '0';
    SIGNAL prev_collision_per_frame  : std_logic := '0';

BEGIN

    -- Collision detection on pixel clock
    Check_Collision : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN

            IF reset = '1' THEN
                collision_temp <= '0';

            ELSE

                IF collision_reset = '1' THEN
                    collision_temp <= '0';

                -- hit ceiling or gift
                ELSIF (unsigned(ball_y_pos) <= unsigned(ball_size)) OR
                      (ball_on = '1' AND gift_on = '1') THEN
                    collision_temp <= '1';

                -- hit bottom
                ELSIF unsigned(ball_y_pos) >=
                      (to_unsigned(479, 10) - unsigned(ball_size)) THEN
                    -- TODO: treat as death if needed
                    collision_temp <= '0';
                END IF;

                -- generate one-cycle reset pulse when collision_per_frame rises
                IF (collision_per_frame = '1' AND prev_collision_per_frame = '0') THEN
                    collision_reset <= '1';
                ELSE
                    collision_reset <= '0';
                END IF;

            END IF;

            -- track previous frame collision state
            prev_collision_per_frame <= collision_per_frame;

        END IF;
    END PROCESS Check_Collision;

    -- Frame-based collision handling on vert_sync
    Reset_collision : PROCESS(vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN

            IF reset = '1' THEN
                collision_per_frame <= '0';
                gift_start          <= '1';
                ball_enable         <= '1';

            ELSE
                collision_per_frame <= collision_temp;

                IF collision_temp = '1' THEN
                    gift_start  <= '0';
                    ball_enable <= '0';
                ELSE
                    gift_start  <= '1';
                    ball_enable <= '1';
                END IF;

            END IF;

        END IF;
    END PROCESS Reset_collision;

    -- Output
    collision <= collision_temp;

END behavior;
