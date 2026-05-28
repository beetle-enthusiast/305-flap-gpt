LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pipe IS
    PORT (
        enable, start, vert_sync : IN std_logic;
        clk                      : IN std_logic;
        pixel_row, pixel_column  : IN std_logic_vector(9 DOWNTO 0);
        randomiser_value1        : IN std_logic_vector(7 DOWNTO 0);
        pipe_x_pos               : OUT std_logic_vector(10 DOWNTO 0);
        pipe_y_pos               : OUT std_logic_vector(9 DOWNTO 0);
        pipe_r, pipe_b, pipe_g   : OUT std_logic_vector(3 DOWNTO 0);
        pipe_on, pipe_enable,
        pipe_passed              : OUT std_logic
    );
END pipe;

ARCHITECTURE behavior OF pipe IS

    SIGNAL pipe_gap_on        : std_logic;
    SIGNAL pipe_width_radius  : unsigned(10 DOWNTO 0) := to_unsigned(10, 11);   -- width = 20
    SIGNAL pipe_height_radius : unsigned(9 DOWNTO 0)  := to_unsigned((479-55)/2, 10);  -- height = from banner to down
    SIGNAL gap_constant       : unsigned(9 DOWNTO 0)  := to_unsigned(50, 10);

    SIGNAL pipe_x_temp_pos    : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
    SIGNAL pipe_y_temp_pos    : unsigned(9 DOWNTO 0)  := to_unsigned(479 - 200, 10);
    SIGNAL pipe_gap_pos       : unsigned(9 DOWNTO 0)  := to_unsigned(479 - 200, 10);

    SIGNAL started            : std_logic := '0';
    SIGNAL pipe_on_sig        : std_logic;

    SIGNAL rom_address        : std_logic_vector(12 DOWNTO 0);
    SIGNAL rom_data           : std_logic_vector(3 DOWNTO 0);
    SIGNAL sprite_x, sprite_y : integer;

BEGIN

    -- Gap region
    pipe_gap_on <= '1' WHEN
        (pipe_x_temp_pos <= unsigned(pixel_column) + pipe_width_radius AND
         unsigned(pixel_column) <= pipe_x_temp_pos + pipe_width_radius AND
         pipe_gap_pos <= unsigned(pixel_row) + gap_constant AND
         unsigned(pixel_row) <= pipe_gap_pos + gap_constant)
        ELSE '0';

    -- Pipe body (excluding gap)
    pipe_on_sig <= '1' WHEN
        (pipe_x_temp_pos <= unsigned(pixel_column) + pipe_width_radius AND
         unsigned(pixel_column) <= pipe_x_temp_pos + pipe_width_radius AND
         pipe_y_temp_pos <= unsigned(pixel_row) + pipe_height_radius AND
         unsigned(pixel_row) <= pipe_y_temp_pos + pipe_height_radius AND
         pipe_gap_on = '0')
        ELSE '0';

    pipe_on <= pipe_on_sig;

    -- ROM
    PIPE_ROM_INST : ENTITY work.pipe_rom
        PORT MAP (
            address => rom_address,
            clock   => clk,
            q       => rom_data
        );

    -- Sprite coordinates
    sprite_x <= to_integer(unsigned(pixel_column)) - to_integer(pipe_x_temp_pos(9 DOWNTO 0)) + 10;
    sprite_y <= to_integer(unsigned(pixel_row))    - to_integer(pipe_y_temp_pos) + 200;

    rom_address <= std_logic_vector(
                       to_unsigned(sprite_y * 20 + sprite_x, 13)
                   ) WHEN (sprite_x >= 0 AND sprite_x < 20 AND
                           sprite_y >= 0 AND sprite_y < 400)
                   ELSE (OTHERS => '0');

    -- Colours
    pipe_r <= rom_data                   WHEN pipe_on_sig = '1' ELSE "0000";
    pipe_g <= '0' & rom_data(3 DOWNTO 1) WHEN pipe_on_sig = '1' ELSE "0000";
    pipe_b <= "0000";

    -- Movement
    Move_Pipe : PROCESS(vert_sync)
        VARIABLE starting_pos : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
        VARIABLE end_pos      : unsigned(10 DOWNTO 0) := to_unsigned(0, 11);
    BEGIN
        IF rising_edge(vert_sync) AND enable = '1' THEN

            IF start = '1' THEN
                started     <= '1';
                pipe_enable <= '1';
            ELSE
                pipe_enable <= '0';
            END IF;

            IF start = '1' OR started = '1' THEN

                IF pipe_x_temp_pos = end_pos THEN
                    pipe_x_temp_pos <= starting_pos;
                    pipe_gap_pos    <= to_unsigned(100, 10) +
                                       unsigned("00" & randomiser_value1);
                ELSE
                    -- scroll left by 1
                    pipe_x_temp_pos <= pipe_x_temp_pos - 1;

                    -- passed check: RHS of pipe < bird x (200 - 8)
                    IF pipe_x_temp_pos + pipe_width_radius <
                       to_unsigned(200 - 8, 11) THEN
                        pipe_passed <= '1';
                    ELSE
                        pipe_passed <= '0';
                    END IF;
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Outputs
    pipe_x_pos <= std_logic_vector(pipe_x_temp_pos);
    pipe_y_pos <= std_logic_vector(pipe_y_temp_pos);

END behavior;
