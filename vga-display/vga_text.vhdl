
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

    -- SIGNAL character_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    -- SIGNAL font_row, font_col : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rom_mux_output : STD_LOGIC;


SIGNAL character_address_reg : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL font_row_reg, font_col_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL text_on : STD_LOGIC;
SIGNAL text_r_reg, text_g_reg, text_b_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);

  
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

-- Compute address
Stage1 : process(clock_25Mhz)

    variable col_offset : INTEGER;
    variable row_offset : INTEGER;
    variable active_len :INTEGER;
    variable char_index : INTEGER;
begin 
    if rising_edge(clock_25Mhz) then 

        --DEFAULTS
        character_address_reg <= ( others=> '0');
        font_row_reg <= (others => '0');
        font_col_reg <= (others => '0');
        text_on <= '0';
        text_r_reg <= text_r;
        text_g_reg <= text_g;
        text_b_reg <= text_b;

        active_len := message'length;


        

        if active_len > 0 and scale > 0 then
            if unsigned(pixel_row) >= start_row and
               unsigned(pixel_row) < start_row + (8 * scale) and
               unsigned(pixel_column) >= start_col and
               unsigned(pixel_column) < start_col + (active_len * 8 * scale) then

                col_offset := to_integer(unsigned(pixel_column)) - start_col;
                row_offset := to_integer(unsigned(pixel_row)) - start_row;
                char_index := (col_offset / (8 * scale)) + 1;

                if char_index >= 1 and char_index <= active_len then
                    character_address_reg <= std_logic_vector(
                        to_unsigned(character'pos(message(char_index)), 6));
                end if;

                font_row_reg <= std_logic_vector(to_unsigned(row_offset / scale, 3));
                font_col_reg <= std_logic_vector(to_unsigned((col_offset / scale) mod 8, 3));
                text_on <= '1';
            end if;
        end if;
    end if;
end process;

Stage2 : process(clock_25Mhz)
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
