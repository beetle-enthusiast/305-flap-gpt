library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
  port (
    clk_25MHz, r, g, b  : in  std_logic;
    r_out, g_out, b_out : out std_logic;
    px_col, px_row      : out std_logic_vector(9 downto 0)
  );
end vga_sync;

architecture a of vga_sync is
  signal h_sync, v_sync                   : std_logic;
  signal video_on, video_on_h, video_on_v : std_logic;
  signal h_count, v_count                 : unsigned(9 downto 0);
begin

  scroll : process(clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      --  Generate Horizontal and Vertical Timing Signals for Video Signal

      --  h_count counts pixels (640 + sync time = 800 pixels/line)
      -- 
      --  h_sync      rgbrgbrgbrgbrgbrgb-------__________--------
      --  h_count     0                 640    656       752    799
      if (h_count = 799) then
        h_count <= (others => '0');
      else
        h_count <= h_count + 1;
      end if;

      -- Generate h_sync signal
      if (h_count >= 656) and (h_count < 752) then
        h_sync <= '0';
      else
        h_sync <= '1';
      end if;


      --  v_count counts rows of pixels (480 + sync time = 525 lines/frame)
      --  
      --  v_sync      rgbrgbrgbrgb-----___________-------
      --  v_count     0           480  490        492   524
      if (h_count = 699) then
        if (v_count = 525) then
          v_count <= (others => '0');
        else
          v_count <= v_count + 1;
        end if;
      end if;

      -- Generate v_sync
      if (v_count >= 490) and (v_count < 492) then
        v_sync <= '0';
      else
        v_sync <= '1';
      end if;

    end if;
  end process;

  display : process(clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then

      -- Generate pixel data for other modules
      if (h_count < 640) then
        video_on_h <= '1';
        px_col <= std_logic_vector(h_count);
      else
        video_on_h <= '0';
      end if;

      if (v_count < 480) then
        video_on_v <= '1';
        px_row <= std_logic_vector(v_count);
      else
        video_on_v <= '0';
      end if;

    end if;
  end process;


  -- video_on controls when rgb data is ready to be displayed
  video_on <= video_on_h and video_on_v;

  r_out <= r and video_on;
  g_out <= g and video_on;
  b_out <= b and video_on;

end architecture;