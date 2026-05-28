
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY VGA_TEXT IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        start_row : IN INTEGER;
        start_col : IN INTEGER;
        scale : IN INTEGER; -- scale factor for the text size
        message : IN text_string; -- the text message to display
        text_r : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --COLOR OF TEXT
        text_g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        text_b : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

    );
END VGA_TEXT;

ARCHITECTURE a OF VGA_TEXT IS

    
    COMPONENT char_rom IS
    PORT
    (
        character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        clock				: 	IN STD_LOGIC ;
        rom_mux_output		:	OUT STD_LOGIC
    );
END COMPONENT char_rom;

 
SIGNAL rom_mux_output : STD_LOGIC;
SIGNAL character_address_reg : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL font_row_reg, font_col_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL text_on : STD_LOGIC;
SIGNAL text_r_reg, text_g_reg, text_b_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL col_offset_reg  : INTEGER;
SIGNAL row_offset_reg : INTEGER;
SIGNAL in_bounds_reg : STD_LOGIC;

  
begin

    -- Create an instance of the char_rom component
    char_rom_inst : char_rom
    PORT MAP (
        character_address => character_address_reg,
        font_row => font_row_reg,
        font_col => font_col_reg,
        clock => clock_25Mhz,
        rom_mux_output => rom_mux_output
    );

-- bounds, reg offsets
Stage1 : process(clock_25Mhz)
    variable in_text_area : boolean;
    variable msg_len      : integer;
    variable text_width   : integer;
    variable text_height  : integer;
begin
    if rising_edge(clock_25Mhz) then
        in_text_area  := false;
        in_bounds_reg <= '0';
        msg_len       := message'length;

        case scale is
            when 1 =>
                text_width := to_integer( unsigned(to_unsigned(msg_len, 16)) sll 3 );
                text_height := 8;
            when 2 =>
                text_width := to_integer( unsigned(to_unsigned(msg_len, 16)) sll 4 );
                text_height := 16;
            when 4 =>
                text_width := to_integer( unsigned(to_unsigned(msg_len, 16)) sll 5 );
                text_height := 32;
            when others =>
                text_width := to_integer( unsigned(to_unsigned(msg_len, 16)) sll 3);
                text_height := 8;
        end case;

        in_text_area :=
            unsigned(pixel_row)    >= start_row and
            unsigned(pixel_row)    <  start_row + text_height and
            unsigned(pixel_column) >= start_col and
            unsigned(pixel_column) <  start_col + text_width;

        if in_text_area then
            col_offset_reg <= to_integer(unsigned(pixel_column)) - start_col;
            row_offset_reg <= to_integer(unsigned(pixel_row))    - start_row;
            in_bounds_reg  <= '1';
        end if;
    end if;
end process;
-- Char address and font row/col 
Stage_2: process(clock_25Mhz)
    variable scaled_col : INTEGER;
    variable scaled_row : INTEGER;
    variable char_index : INTEGER;

    begin 
        if rising_edge(clock_25Mhz) then 
            character_address_reg <= ( others=> '0');
            font_row_reg <= (others => '0');
            font_col_reg <= (others => '0');
            text_on <= '0';
            text_r_reg <= text_r;
            text_g_reg <= text_g;
            text_b_reg <= text_b;

            if in_bounds_reg = '1' then 
                case scale is 
                    when 1 =>
                        scaled_col := col_offset_reg;
                        scaled_row := row_offset_reg;
                        char_index := to_integer( unsigned(to_unsigned(col_offset_reg, 16)) srl 3 ) + 1;
                    when 2 =>
                    scaled_col := to_integer(unsigned(to_unsigned(col_offset_reg, 16)) srl 1); 
                    scaled_row := to_integer(unsigned(to_unsigned(row_offset_reg, 16)) srl 1);
                    char_index := to_integer( unsigned(to_unsigned(col_offset_reg, 16)) srl 4) + 1;
                    when 4 =>
                    scaled_col := to_integer(unsigned(to_unsigned(col_offset_reg, 16)) srl 2); 
                    scaled_row := to_integer(unsigned(to_unsigned(row_offset_reg, 16)) srl 2);
                    char_index := to_integer( unsigned(to_unsigned(col_offset_reg, 16)) srl 5 ) + 1;
                   when others =>
                    scaled_col := col_offset_reg;
                    scaled_row := row_offset_reg;
                    char_index := to_integer(unsigned(to_unsigned(col_offset_reg, 16)) srl 3) + 1;

                end case;

                font_row_reg <= std_logic_vector(to_unsigned(scaled_row, 3));
                font_col_reg <= std_logic_vector(to_unsigned(scaled_col mod 8, 3));

                 if char_index >= 1 and char_index <= message'length then
                    character_address_reg <= std_logic_vector(
                        to_unsigned(character'pos(message(char_index)), 6));
                end if;

                text_on <= '1';
            end if;
        end if;
    end process;


   

Stage3 : process(clock_25Mhz)
begin
    if rising_edge(clock_25Mhz) then 
        if text_on = '1' and rom_mux_output = '1' then
            red_out   <= text_r_reg;
            green_out <= text_g_reg;
            blue_out  <= text_b_reg;
        else
            red_out   <= "0000";
            green_out <= "0000";
            blue_out  <= "0000";
        end if;
    end if;
end process;

END a;