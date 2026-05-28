-- =============================================================================
-- double_dabble_tb.vhd
-- Testbench for the double_dabble component.
-- Exhaustively tests all 128 values (0–127) and reports pass/fail.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity double_dabble_tb is
end entity double_dabble_tb;

architecture sim of double_dabble_tb is

    -- Component under test
    component double_dabble is
        port (
            bin      : in  std_logic_vector(6 downto 0);
            hundreds : out std_logic_vector(3 downto 0);
            tens     : out std_logic_vector(3 downto 0);
            ones     : out std_logic_vector(3 downto 0)
        );
    end component;

    signal bin_s      : std_logic_vector(6 downto 0);
    signal hundreds_s : std_logic_vector(3 downto 0);
    signal tens_s     : std_logic_vector(3 downto 0);
    signal ones_s     : std_logic_vector(3 downto 0);

begin

    uut : double_dabble
        port map (
            bin      => bin_s,
            hundreds => hundreds_s,
            tens     => tens_s,
            ones     => ones_s
        );

    stim : process
        variable v_dec      : integer;
        variable v_hundreds : integer;
        variable v_tens     : integer;
        variable v_ones     : integer;
        variable v_pass     : boolean := true;
    begin

        -- Spot-check a handful of representative values
        for v_dec in 0 to 127 loop

            bin_s <= std_logic_vector(to_unsigned(v_dec, 7));
            wait for 10 ns;

            -- Expected BCD digits
            v_hundreds := v_dec / 100;
            v_tens     := (v_dec mod 100) / 10;
            v_ones     := v_dec mod 10;

            if to_integer(unsigned(hundreds_s)) /= v_hundreds or
               to_integer(unsigned(tens_s))     /= v_tens     or
               to_integer(unsigned(ones_s))     /= v_ones     then

                report "FAIL: bin=" & integer'image(v_dec)
                    & "  got H=" & integer'image(to_integer(unsigned(hundreds_s)))
                    & " T=" & integer'image(to_integer(unsigned(tens_s)))
                    & " O=" & integer'image(to_integer(unsigned(ones_s)))
                    & "  expected H=" & integer'image(v_hundreds)
                    & " T=" & integer'image(v_tens)
                    & " O=" & integer'image(v_ones)
                severity error;

                v_pass := false;
            end if;

        end loop;

        if v_pass then
            report "All 128 test cases PASSED." severity note;
        else
            report "One or more test cases FAILED." severity failure;
        end if;

        wait;
    end process;

end architecture sim;
