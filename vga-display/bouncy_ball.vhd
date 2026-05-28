LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bouncy_ball IS
    PORT (
        enable, click, clk, vert_sync : IN std_logic;
        pixel_row, pixel_column       : IN std_logic_vector(9 DOWNTO 0);
        ball_on_out                   : OUT std_logic;
        red, green, blue              : OUT std_logic_vector(3 DOWNTO 0);
        ball_y_pos, size              : OUT std_logic_vector(9 DOWNTO 0);
        ball_x_pos                    : OUT std_logic_vector(10 DOWNTO 0)
    );
END bouncy_ball;

ARCHITECTURE behavior OF bouncy_ball IS

    SIGNAL ball_on, ball_collision : std_logic := '0';
    SIGNAL prev_click              : std_logic := '0';

    SIGNAL size_temp        : unsigned(9 DOWNTO 0)  := to_unsigned(8, 10);          -- radius = 8
    SIGNAL ball_y_pos_temp  : unsigned(9 DOWNTO 0)  := to_unsigned(479 - 8, 10);    -- start near bottom
    SIGNAL ball_x_pos_temp  : unsigned(10 DOWNTO 0) := to_unsigned(400, 11);        -- fixed X

BEGIN

    -- Ball coverage
    ball_on <= '1' WHEN
        (unsigned(ball_x_pos_temp) <= unsigned(pixel_column) + size_temp AND
         unsigned(pixel_column)    <= unsigned(ball_x_pos_temp) + size_temp AND
         unsigned(ball_y_pos_temp) <= unsigned(pixel_row) + size_temp AND
         unsigned(pixel_row)       <= unsigned(ball_y_pos_temp) + size_temp)
        ELSE '0';

    -- Colours
    red   <= (OTHERS => ball_on AND ball_collision);
    green <= (OTHERS => ball_on AND ball_collision);
    blue  <= (OTHERS => ball_on AND ball_collision);

    ball_on_out <= ball_on;

    -- Movement
    Move_Ball : PROCESS(vert_sync)
        VARIABLE ball_y_motion : signed(9 DOWNTO 0) := (OTHERS => '0');
        VARIABLE at_top        : std_logic := '0';
        VARIABLE next_y        : signed(9 DOWNTO 0);
        CONSTANT bottom_limit  : unsigned(9 DOWNTO 0) := to_unsigned(479, 10);
    BEGIN
        IF rising_edge(vert_sync) AND enable = '1' THEN

            -- bottom hit
            IF unsigned(ball_y_pos_temp) >= (bottom_limit - size_temp) THEN
                ball_y_motion := (OTHERS => '0');
                at_top        := '0';

            -- top hit
            ELSIF unsigned(ball_y_pos_temp) <= size_temp THEN
                at_top        := '1';
                ball_collision <= NOT ball_collision;
                ball_y_motion := ball_y_motion + to_signed(1, 10);  -- gravity

            ELSE
                at_top        := '0';
                ball_y_motion := ball_y_motion + to_signed(1, 10);  -- gravity
            END IF;

            -- click = jump
            IF (click = '1' AND prev_click = '0' AND at_top = '0') THEN
                ball_y_motion := -to_signed(8, 10);  -- jump up
                prev_click    <= '1';
            ELSE
                prev_click    <= click;
            END IF;

            -- compute next position
            next_y := signed(ball_y_pos_temp) + ball_y_motion;

            -- clamp to top
            IF next_y <= signed(size_temp) THEN
                next_y := signed(size_temp);
            END IF;

            -- clamp to bottom
            IF next_y >= signed(bottom_limit - size_temp) THEN
                next_y := signed(bottom_limit - size_temp);
            END IF;

            ball_y_pos_temp <= unsigned(next_y);

        END IF;
    END PROCESS Move_Ball;

    -- Outputs
    ball_y_pos <= std_logic_vector(ball_y_pos_temp);
    size       <= std_logic_vector(size_temp);
    ball_x_pos <= std_logic_vector(ball_x_pos_temp);

END behavior;
