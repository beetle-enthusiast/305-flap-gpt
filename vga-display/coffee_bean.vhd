LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY coffee_bean IS
    PORT
        (
         enable, start, vert_sync, pipe_on : IN std_logic;
         clk                               : IN std_logic;
         pixel_row, pixel_column           : IN std_logic_vector(9 DOWNTO 0);
         randomiser_value_y                : IN std_logic_vector(7 DOWNTO 0);

         bean_r                            : OUT std_logic_vector(3 DOWNTO 0);
         bean_g                            : OUT std_logic_vector(3 DOWNTO 0);
         bean_b                            : OUT std_logic_vector(3 DOWNTO 0);

         bean_x_pos                        : OUT std_logic_vector(10 DOWNTO 0);
         bean_y_pos                        : OUT std_logic_vector(9 DOWNTO 0);

         bean_on, bean_enable              : OUT std_logic
        );
END coffee_bean;

ARCHITECTURE behavior OF coffee_bean IS

    SIGNAL bean_x_temp_pos : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
    SIGNAL bean_y_temp_pos : unsigned(9 DOWNTO 0)  := to_unsigned(240, 10);

    SIGNAL started         : std_logic := '0';
    SIGNAL bean_on_sig     : std_logic := '0';

    CONSTANT bean_size     : unsigned(9 DOWNTO 0) := to_unsigned(20, 10);

BEGIN

   Sprite : process(clk)
    variable px, py : integer;
    variable draw_bean : std_logic;
    variable temp_r, temp_g, temp_b : std_logic_vector(3 downto 0);
begin
    if rising_edge(clk) then

        px := to_integer(unsigned(pixel_column)) - to_integer(bean_x_temp_pos(9 downto 0));
        py := to_integer(unsigned(pixel_row)) - to_integer(bean_y_temp_pos);

        draw_bean := '0';
        temp_r := "0000";
        temp_g := "0000";
        temp_b := "0000";

        if px >= 0 and px < 8 and py >= 0 and py < 8 and pipe_on = '0' then

            draw_bean := '1';

            -- main bean colour
            temp_r := "1100";
            temp_g := "0111";
            temp_b := "0010";

            -- dark outline / bean details
            if    (py = 0 or py = 7) and (px >= 2 and px <= 5) then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            elsif (py = 1 or py = 6) and (px = 1 or px = 6) then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            elsif (py = 2 or py = 5) and (px = 0 or px = 7) then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            elsif (py = 3 or py = 4) and (px = 0 or px = 7) then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            elsif py = 3 and px = 3 then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            elsif py = 4 and px = 4 then
                temp_r := "1000";
                temp_g := "0101";
                temp_b := "0010";

            -- highlight pixels
            elsif py = 2 and px = 2 then
                temp_r := "1101";
                temp_g := "1001";
                temp_b := "0100";

            elsif py = 5 and px = 5 then
                temp_r := "1101";
                temp_g := "1001";
                temp_b := "0100";

            -- transparent corners
            elsif (py = 0 or py = 7) and not (px >= 2 and px <= 5) then
                draw_bean := '0';
                temp_r := "0000";
                temp_g := "0000";
                temp_b := "0000";

            elsif (py = 1 or py = 6) and (px = 0 or px = 7) then
                draw_bean := '0';
                temp_r := "0000";
                temp_g := "0000";
                temp_b := "0000";
            end if;

        end if;

        bean_on_sig <= draw_bean;
        bean_on     <= draw_bean;

        bean_r <= temp_r;
        bean_g <= temp_g;
        bean_b <= temp_b;

    end if;
end process;




    --------------------------------------------------------------------
    -- MOVE BEAN LEFT ACROSS SCREEN
    --------------------------------------------------------------------
    Move_Bean : process(vert_sync)
        variable starting_pos : unsigned(10 DOWNTO 0) := to_unsigned(639, 11);
    begin
        if rising_edge(vert_sync) then

            if enable = '1' then

                -- Once start is pressed, game has started
                if start = '1' then
                    started <= '1';
                end if;

                -- Keep bean active after start
                if start = '1' or started = '1' then

                    bean_enable <= '1';

                    -- If bean reaches left edge, reset to right side
                    if bean_x_temp_pos = 0 then

                        bean_x_temp_pos <= starting_pos;

                        -- Random Y position between around 100 and 163
                        bean_y_temp_pos <= to_unsigned(100, 10) +
                                           unsigned("00" & randomiser_value_y(5 downto 0));

                    else

                        -- Move bean left
                        bean_x_temp_pos <= bean_x_temp_pos - 1;

                    end if;

                else

                    bean_enable <= '0';

                end if;

            else

                bean_enable <= '0';

            end if;

        end if;
    end process Move_Bean;


    --------------------------------------------------------------------
    -- OUTPUT POSITIONS
    --------------------------------------------------------------------
    bean_x_pos <= std_logic_vector(bean_x_temp_pos);
    bean_y_pos <= std_logic_vector(bean_y_temp_pos);

END behavior;