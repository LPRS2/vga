-------------------------------------------------------------------------------
--
-- @author Milos Subotic <milos.subotic.sm@gmail.com>
-- @license MIT
--
-- @brief 24MHz to 100MHz clock generator.
--
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;

library unisim;
	use unisim.vcomponents.all;

entity clk_gen_100MHz is
	port(
		i_clk_24MHz  : in  std_logic;
		in_rst       : in  std_logic;
		o_clk_100MHz : out std_logic;
		o_locked     : out std_logic
	);
end entity clk_gen_100MHz;
	
architecture arch_v1 of clk_gen_100MHz is
	signal rst    : std_logic;
	signal clk_fx : std_logic;
	signal clk_in : std_logic;
	signal clk_fb : std_logic;
	signal clk_0  : std_logic;
begin

	rst <= not in_rst;
	
	-- Input buffering.
	buf_clk_24MHz: IBUFG
	port map(
		I => i_clk_24MHz,
		O => clk_in
	);

	-- Clocking primitive
	dcm_24MHz_to_100MHz: DCM_SP
	generic map(
		CLKDV_DIVIDE          => 2.000,
		CLKFX_DIVIDE          => 6,
		CLKFX_MULTIPLY        => 25,
		CLKIN_DIVIDE_BY_2     => FALSE,
		CLKIN_PERIOD          => 41.66667,
		CLKOUT_PHASE_SHIFT    => "NONE",
		CLK_FEEDBACK          => "1X",
		DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
		PHASE_SHIFT           => 0,
		STARTUP_WAIT          => FALSE
	)
	port map(
		-- Input clocks
		CLKIN                 => clk_in,
		CLKFB                 => clk_fb,
		-- Output clocks
		CLK0                  => clk_0,
		CLK90                 => open,
		CLK180                => open,
		CLK270                => open,
		CLK2X                 => open,
		CLK2X180              => open,
		CLKFX                 => clk_fx,
		CLKFX180              => open,
		CLKDV                 => open,
		-- Ports for dynamic phase shift
		PSCLK                 => '0',
		PSEN                  => '0',
		PSINCDEC              => '0',
		PSDONE                => open,
		-- Other control and status signals
		LOCKED                => o_locked,
		STATUS                => open,
		RST                   => rst,
		-- Unused pin, tie low
		DSSEN                 => '0'
	);

	-- Output buffering
	buf_clk_0: BUFG
	port map(
		I => clk_0,
		O => clk_fb
	);

	buf_clk_fx: BUFG
	port map(
		I => clk_fx,
		O => o_clk_100MHz
	);

end architecture arch_v1;
