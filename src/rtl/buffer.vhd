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
	use ieee.std_logic_arith.all;

entity dual_port_ram is
	generic(
		ADDR_WIDTH : positive;
		DATA_WIDTH : positive
	);
	port(
		i_clk        : in  std_logic;
		-- Port 0.
		i_addr0      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		i_data0      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		i_we0        : in  std_logic;
		o_data0      : out std_logic_vector(DATA_WIDTH-1 downto 0);
		-- Port 1.
		i_addr1      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		i_data1      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		i_we1        : in  std_logic;
		o_data1      : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity dual_port_ram;

architecture arch_v1 of dual_port_ram is

	constant MEM_LEN : positive := 2**ADDR_WIDTH;
	type t_mem is array(MEM_LEN-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal mem : t_mem := (
		others => (others => '0')
	);
	
begin
	
	process(i_clk)
	begin
		if rising_edge(i_clk) then
			o_data0 <= mem(conv_integer(i_addr0));
			if i_we0 = '1' then
				mem(conv_integer(i_addr0)) <= i_data0;
			end if;
			
			o_data1 <= mem(conv_integer(i_addr1));
			if i_we1 = '1' then
				mem(conv_integer(i_addr1)) <= i_data1;
			end if;
		end if;
	end process;
	
end architecture arch_v1;
