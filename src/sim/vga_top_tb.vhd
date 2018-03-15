
library ieee;
use ieee.std_logic_1164.all;

use work.vga_top;

entity vga_top_tb is
end entity vga_top_tb;

architecture arch_vga_top_tb of vga_top_tb is

	-- Inputs:
	signal i_clk       : std_logic := '0';
	signal in_rst      : std_logic := '0';
	signal i_sw        : std_logic_vector(7 downto 0) := (others => '0');
	
	-- Outputs
	signal o_vga_clk   : std_logic;
	signal o_red       : std_logic_vector(7 downto 0);
	signal o_green     : std_logic_vector(7 downto 0);
	signal o_blue      : std_logic_vector(7 downto 0);
	signal on_blank    : std_logic;
	signal on_h_sync   : std_logic;
	signal on_v_sync   : std_logic;
	signal on_sync     : std_logic;
	signal on_pow_save : std_logic;
	
	-- Clock period definitions
	constant i_clk_period : time := 10 ns;

begin
	
	-- Instantiate the Unit Under Test (UUT)
	uut: entity vga_top 
	port map(
		i_clk       => i_clk,
		in_rst      => in_rst,
		i_sw        => i_sw,
		o_vga_clk   => o_vga_clk,
		o_red       => o_red,
		o_green     => o_green,
		o_blue      => o_blue,
		on_blank    => on_blank, 
		on_h_sync   => on_h_sync, 
		on_v_sync   => on_v_sync,
		on_sync     => on_sync,
		on_pow_save => on_pow_save
	);

	-- Clock process definitions
	i_clk_process: process
	begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
	end process;
	
	tb: process
	begin
		in_rst <= '0';
		i_sw <= x"00";
		wait for i_clk_period*10;
		in_rst <= '1';


		wait; -- Wait forever.
	end process;
	
end architecture arch_vga_top_tb;
