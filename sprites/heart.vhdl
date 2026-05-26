
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY HEART IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        start_row : IN INTEGER;
        start_col : IN INTEGER;
        visible : in std_logic;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

    );
END HEART;

ARCHITECTURE a OF HEART IS

    SIGNAL heart_on : std_logic;
    SIGNAL heart_r, heart_g, heart_b : std_logic_vector(3 downto 0);
    SIGNAL row_int, col_int : integer := 0;



  
begin

    row_int <= to_integer(unsigned(pixel_row));
    col_int <= to_integer(unsigned(pixel_column));

    -- Heart shape 
    heart_on <= '1' when visible = '1' and (
    (row_int >= start_row and row_int <= start_row+6 and col_int >= start_col and col_int <= start_col+6) or
    (row_int >= start_row and row_int <= start_row+6 and col_int >= start_col+10 and col_int <= start_col+16) or
    (row_int >= start_row+4 and row_int <= start_row+12 and col_int >= start_col and col_int <= start_col+16) or
    (row_int >= start_row+12 and row_int <= start_row+16 and col_int >= start_col+2 and col_int <= start_col+14) or
    (row_int >= start_row+16 and row_int <= start_row+20 and col_int >= start_col+6 and col_int <= start_col+10)
) else '0';


    heart_r <= "1111" when heart_on = '1' else "0000";
    heart_g <= "0000" when heart_on = '1' else "0000";
    heart_b <= "0000" when heart_on = '1' else "0000";

    red_out <= heart_r;
    green_out <= heart_g;
    blue_out <= heart_b;


END a;