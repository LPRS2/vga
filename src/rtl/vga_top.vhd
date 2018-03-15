-------------------------------------------------------------------------------
--
-- @author Milos Subotic <milos.subotic.sm@gmail.com>
-- @license MIT
--
-- @brief VGA test.
--
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.std_logic_arith.all;

entity vga_top is
	port(
		i_clk        : in  std_logic;
		in_rst       : in  std_logic;
		-- IO.
		i_sw         : in  std_logic_vector(7 downto 0);
		-- To VGA.
		o_vga_clk    : out std_logic;
		o_red        : out std_logic_vector(7 downto 0);
		o_green      : out std_logic_vector(7 downto 0);
		o_blue       : out std_logic_vector(7 downto 0);
		on_blank     : out std_logic;
		on_h_sync    : out std_logic;
		on_v_sync    : out std_logic;
		on_sync      : out std_logic;
		on_pow_save  : out std_logic
	);
end entity vga_top;

architecture arch_v1 of vga_top is
	signal clk   : std_logic;
	signal n_rst : std_logic;

	signal phase      : std_logic_vector(1 downto 0);
	signal pixel_x    : std_logic_vector(9 downto 0);
	signal pixel_y    : std_logic_vector(8 downto 0);

	signal mux_rgb   : std_logic_vector(23 downto 0);
	signal bar_rgb   : std_logic_vector(23 downto 0);
	signal patch_rgb : std_logic_vector(23 downto 0);
	signal line_rgb  : std_logic_vector(23 downto 0);
	
begin
	clk_gen_i: entity work.clk_gen_100MHz
	port map(
		i_clk_24MHz  => i_clk,
		in_rst       => '1',--in_rst,
		o_clk_100MHz => clk,
		o_locked     => open--n_rst
	);
	n_rst <= '1';
	
	ctrl_i: entity work.vga_ctrl
	port map(
		i_clk_100MHz => clk,
		in_rst       => n_rst,
		-- To GPU.
		o_phase      => phase,
		o_pixel_x    => pixel_x,
		o_pixel_y    => pixel_y,
		i_rgb        => mux_rgb,
		-- To VGA.
		o_vga_clk    => o_vga_clk,
		o_red        => o_red,
		o_green      => o_green,
		o_blue       => o_blue,
		on_blank     => on_blank,
		on_h_sync    => on_h_sync,
		on_v_sync    => on_v_sync,
		on_sync      => on_sync,
		on_pow_save  => on_pow_save
	);
	
	with i_sw(1 downto 0) select mux_rgb <=
		bar_rgb   when "00",
		patch_rgb when "01",
		line_rgb  when "10",
		x"00ff00" when others;
	
	-- Color BAR.
	bar_rgb <=
		x"000000" when pixel_x < 1*640/8 else
		x"0000ff";
	
	-- Color patches.
	patch_rgb <= (others => '1');
	
	-- Line.
	line_rgb  <= (others => '1');
	
	
end architecture arch_v1;
