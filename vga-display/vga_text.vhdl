
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

    SIGNAL character_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL font_row, font_col : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rom_mux_output : STD_LOGIC;

  
begin



    -- Create an instance of the char_rom component
    char_rom_inst : char_rom
    PORT MAP (
        character_address => character_address,
        font_row => font_row,
        font_col => font_col,
        clock => clock_25Mhz,
        rom_mux_output => rom_mux_output
    );

    -- Logic to determine if the current pixel is part of the text and set the output color accordingly
    process(pixel_row, pixel_column, rom_mux_output,message, start_row, start_col, scale)

    variable col_offset : INTEGER;
    variable row_offset : INTEGER;
    variable active_len :INTEGER;
    variable char_index : INTEGER;
    variable i : INTEGER;

    begin   

        --Default outputs
        red_out <= "0000";
        green_out <= "0000";
        blue_out <= "0000";
        character_address <= (others => '0');
        font_row <= (others => '0');
        font_col <= (others => '0');


        -- Message length
       active_len := message'length;


        -- If char is not null
        if active_len > 0 and scale > 0 then

         -- If current pixel is inside bounds of the text area
            if((unsigned(pixel_row) >= start_row) and 
            (unsigned(pixel_row) < start_row + (8 * scale)) and 
            (unsigned(pixel_column) >= start_col) and
            (unsigned(pixel_column) < start_col + ( active_len * 8  * scale))) then
            

                -- Pixel position relative to the start of the text area
                col_offset := to_integer(unsigned(pixel_column)) - start_col;
                row_offset := to_integer(unsigned(pixel_row)) - start_row;


           
                char_index := (col_offset / (8 * scale)) + 1; -- Determine which character we are on based on the column offset
 
                if (char_index >= 1) and (char_index <= active_len) then                
                   character_address <= std_logic_vector(
                    to_unsigned(character'pos(MESSAGE(char_index)), 6)); -- convert to numeric ascii value and then to std_logic_vector
                else
                character_address <= (others => '0'); -- blank
                end if;

                -- determine which row/col of 8x8 char to sample
                font_row <= std_logic_vector(to_unsigned(row_offset / scale, 3)); -- Use the row offset to determine which row of the character to display
                font_col <= std_logic_vector(to_unsigned((col_offset / scale) mod 8, 3)); -- Use the column offset to determine which column of the character to display

                -- If pixel on, output text color
                if rom_mux_output = '1' then 
                    red_out <= text_r;
                    green_out <= text_g;
                    blue_out <= text_b;
                else
                    red_out <= "0000";
                    green_out <= "0000";
                    blue_out <= "0000";
                end if;
            end if;
        end if;
    end process;

END a;


