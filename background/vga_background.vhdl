
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.text_pkg.all;



ENTITY VGA_BACKGROUND IS
	PORT(
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        clock_25Mhz : IN STD_LOGIC;
        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)

    );
END VGA_BACKGROUND;

ARCHITECTURE a OF VGA_BACKGROUND IS

    
    
SIGNAL sig : std_logic_vector(14 downto 0);
    SIGNAL rom_data : std_logic_vector(11 downto 0); -- 

  
begin

    -- instance of ROM for background pattern
    VGA_ROM_inst : entity work.background_rom
    port map (
        address => sig,
        clock => clock_25Mhz,
        q => rom_data
    );
    


    sig <= std_logic_vector(
    to_unsigned(to_integer(unsigned(pixel_row(8 downto 2))) * 160 
    + to_integer(unsigned(pixel_column(9 downto 2))), 15)
);

red_out   <= rom_data(11 downto 8);
green_out <= rom_data(7  downto 4);
blue_out  <= rom_data(3  downto 0);


END a;


