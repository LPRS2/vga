-------------------------------------------------------------------------------
--
-- @author Milos Subotic <milos.subotic.sm@gmail.com>
-- @license MIT
--
-- @brief VGA controller.
--
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity vga_ctrl is
	port(
		i_clk_100MHz : in  std_logic;
		in_rst       : in  std_logic;
		-- To GPU.
		o_phase      : out std_logic_vector(1 downto 0);
		o_pixel_x    : out std_logic_vector(9 downto 0);
		o_pixel_y    : out std_logic_vector(8 downto 0);
		i_rgb        : in  std_logic_vector(23 downto 0);
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
end entity vga_ctrl;

architecture arch_v1 of vga_ctrl is

	signal phase      : std_logic_vector(1 downto 0);
	signal en_25MHz   : std_logic;

	signal pixel_x    : std_logic_vector(9 downto 0);
	signal pixel_y    : std_logic_vector(8 downto 0);

	signal vga_clk    : std_logic;

	signal red        : std_logic_vector(7 downto 0);
	signal green      : std_logic_vector(7 downto 0);
	signal blue       : std_logic_vector(7 downto 0);
		
	signal n_blank    : std_logic;
	signal n_h_sync   : std_logic;
	signal n_v_sync   : std_logic;
	signal n_sync     : std_logic;
begin
	
	phase_cnt: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			if in_rst = '0' then
				phase <= "00";
			else
				if phase = "11" then
					phase <= "00";
				else
					phase <= phase + 1;
				end if;
			end if;
		end if;
	end process phase_cnt;
	o_phase <= phase;
	
	-- Setting enable in 0th phase so we could have change on FFs between 3rd and 0th phase.
	en_25MHz <= '1' when phase = "11" else '0';
	
	pixel_x_cnt: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			if in_rst = '0' then
				pixel_x <= (others => '0');
			else
				if en_25MHz = '1' then
					if pixel_x = (640+16+96+48)-1 then
						pixel_x <= (others => '0');
					else
						pixel_x <= pixel_x + 1;
					end if;
				end if;
			end if;
		end if;
	end process pixel_x_cnt;
	o_pixel_x <= pixel_x;
	
	pixel_y_cnt: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			if in_rst = '0' then
				pixel_y <= (others => '0');
			else
				if en_25MHz = '1' and pixel_x = (640+16+96+48)-1 then
					if pixel_y = (480+10+2+33)-1 then
						pixel_y <= (others => '0');
					else
						pixel_y <= pixel_y + 1;
					end if;
				end if;
			end if;
		end if;
	end process pixel_y_cnt;
	o_pixel_y <= pixel_y;
	
	
	vga_clk_reg: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			vga_clk <= phase(1);
		end if;
	end process vga_clk_reg;
	o_vga_clk <= vga_clk;

	rgb_reg: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			if en_25MHz = '1' then
				red   <= i_rgb( 7 downto  0);
				green <= i_rgb(15 downto  8);
				blue  <= i_rgb(23 downto 16);
			end if;
		end if;
	end process rgb_reg;
	o_red   <= red;
	o_green <= green;
	o_blue  <= blue;
	
	sync: process(i_clk_100MHz)
	begin
		if rising_edge(i_clk_100MHz) then
			if en_25MHz = '1' then
				if pixel_x >= 640 or pixel_y >= 480 then
					n_blank <= '0';
				else
					n_blank <= '1';
				end if;
				if 640+16 <= pixel_x and pixel_x < 640+16+96 then
					n_h_sync <= '0';
				else
					n_h_sync <= '1';
				end if;
				if 480+10 <= pixel_y and pixel_y < 480+10+2 then
					n_v_sync <= '0';
				else
					n_v_sync <= '1';
				end if;
				if (640+16 <= pixel_x and pixel_x < 640+16+96) or (480+10 <= pixel_y and pixel_y < 480+10+2) then
					n_sync <= '0';
				else
					n_sync <= '1';
				end if;
			end if;
		end if;
	end process sync;
	-- #TODO Should be delayed for delay in GPU.
	on_blank  <= n_blank;
	on_h_sync <= n_h_sync;
	on_v_sync <= n_v_sync;
	on_sync   <= n_sync;
	
	on_pow_save <= '1';
	
end architecture arch_v1;
