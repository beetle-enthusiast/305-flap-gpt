-- =============================================================================
-- double_dabble.vhd
-- Converts a 10-bit binary number (0–1023) to Binary-Coded Decimal (BCD)
-- using the Double Dabble (shift-and-add-3) algorithm.
--
-- Output: three 4-bit BCD digits
--   hundreds : BCD digit for 100s place (0–9)
--   tens     : BCD digit for 10s  place (0–9)
--   ones     : BCD digit for 1s   place (0–9)
--
-- Example: 7-bit input "1111111" (127 decimal)
--   hundreds = "0001" (1), tens = "0010" (2), ones = "0111" (7)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.custom_types.all;

entity double_dabble is
    port (
      bin     : in  std_logic_vector(9 downto 0);  -- 7-bit binary input
      dec     : out binary_coded_decimal
      -- hundreds : out std_logic_vector(3 downto 0); -- BCD hundreds digit (0-1)
      -- tens : out std_logic_vector(3 downto 0); -- BCD hundreds digit (0-9)
      -- ones : out std_logic_vector(3 downto 0) -- BCD hundreds digit (0-9)
    );
end entity double_dabble;

architecture rtl of double_dabble is
    signal hundreds : std_logic_vector(3 downto 0); -- BCD hundreds digit (0-1)
    signal tens : std_logic_vector(3 downto 0); -- BCD hundreds digit (0-9)
    signal ones : std_logic_vector(3 downto 0); -- BCD hundreds digit (0-9)
begin

    process(bin)
        -- Scratch register: 12 BCD bits (3 digits × 4 bits) + 10 binary bits = 22 bits
        -- Layout: [21:15] = BCD scratch space, [9:0] = binary input (shifted in left)
        variable scratch : std_logic_vector(21 downto 0);
    begin
        -- Initialise: BCD fields zeroed, binary value in the lower 7 bits
        scratch := "000000000000" & bin;

        -- Double Dabble: iterate once per binary bit (10 shifts total)
        for i in 0 to 9 loop

            -- Add-3 step: if any BCD nibble >= 5, add 3 to it before shifting
            -- Hundreds nibble: bits [21:18]
            if to_integer(unsigned(scratch(21 downto 18))) >= 5 then
                scratch(21 downto 18) :=
                    std_logic_vector(unsigned(scratch(21 downto 18)) + 3);
            end if;

            -- Tens nibble: bits [17:14]
            if to_integer(unsigned(scratch(17 downto 14))) >= 5 then
                scratch(17 downto 14) :=
                    std_logic_vector(unsigned(scratch(17 downto 14)) + 3);
            end if;

            -- Ones nibble: bits [13:10]
            if to_integer(unsigned(scratch(13 downto 10))) >= 5 then
                scratch(13 downto 10) :=
                    std_logic_vector(unsigned(scratch(13 downto 10)) + 3);
            end if;

            -- Shift the entire scratch register one bit to the left
            scratch := scratch(20 downto 0) & '0';

        end loop;

        -- Extract the three BCD digits from the upper 12 bits
        hundreds <= scratch(21 downto 18);
        tens     <= scratch(17 downto 14);
        ones     <= scratch(13 downto 10);

        dec(2) <= hundreds;
        dec(1) <= tens;
        dec(0) <= ones;

    end process;

end architecture rtl;
