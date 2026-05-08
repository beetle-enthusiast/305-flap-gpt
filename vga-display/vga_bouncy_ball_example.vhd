LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball_top_level IS
	--pb_colour_1 = KEY[0] and pb_colour_2 = KEY[1], clk = CLOCK_50
	--red_out = VGA_R[3], green_out = VGA_G[3], blue_out = VGA_B[3], h_sync_out = VGA_HS, v_sync_out = VGA_VS 
	PORT
		( KEY[0], KEY[1], CLOCK_50, reset: IN std_logic;
		  VGA_R[3], VGA_G[3], VGA_B[3], VGA_HS, VGA_VS: OUT std_logic);		
END bouncy_ball_top_level;

architecture behavior of bouncy_ball is
-- VGA SYNC component signals
COMPONENT VGA_SYNC
	PORT(	clock_25Mhz, red, green, blue		: IN	STD_LOGIC;
			red_out, green_out, blue_out, horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END COMPONENT;

--PLL component signals
COMPONENT PLL
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		locked   : out std_logic         --  locked.export
	);
END COMPONENT;

--BOUNCY_BALL component signals
COMPONENT bouncy_ball
	PORT
		( pb1, pb2, clk, vert_sync	: IN std_logic;
		  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END COMPONENT;

-- Signals to connect components
SIGNAL pixel_row, pixel_column	: std_logic_vector(9 DOWNTO 0);
SIGNAL vert_sync				: std_logic;
SIGNAL clk_25MHz				: std_logic;
SIGNAL red, green, blue			: std_logic;
SIGNAL pb_colour_1, pb_colour_2	: std_logic;
SIGNAL red_out, green_out, blue_out	: std_logic;
SIGNAL h_sync_out, v_sync_out	: std_logic;

BEGIN  


-- Instantiate PLL component to generate 25MHz clock from 50MHz input clock		
PLL: PLL
PORT MAP (refclk => CLOCK_50, rst => '0', outclk_0 => clk_25MHz, locked => open);

-- Instantiate BOUNCY_BALL component
BOUNCY_BALL: bouncy_ball
PORT MAP (	pb1 => pb_colour_1, pb2 => pb_colour_2, clk => clk_25MHz, vert_sync => vert_sync,
			pixel_row => pixel_row, pixel_column => pixel_column,
			red => red, green => green, blue => blue);

-- Instantiate VGA SYNC component
VGA_SYNC: VGA_SYNC   
PORT MAP (	clock_25Mhz => clk_25MHz, 
			red => red, green => green, blue => blue,
			red_out => red_out, green_out => green_out, blue_out => blue_out, 
			horiz_sync_out => h_sync_out, vert_sync_out => v_sync_out,
			pixel_row => pixel_row, pixel_column => pixel_column);

-- For readibility
pb_colour_1 <= KEY[0];
pb_colour_2 <= KEY[1];
red_out <= VGA_R[3];
green_out <= VGA_G[3];
blue_out <= VGA_B[3];
h_sync_out <= VGA_HS;
v_sync_out <= VGA_VS;

END behavior;

