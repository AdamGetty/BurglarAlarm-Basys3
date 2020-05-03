----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2019 01:28:42 PM
-- Design Name: 
-- Module Name: Alarm_testBench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Alarm_testBench is
--  Port ( );
end Alarm_testBench;

architecture Behavioral of Alarm_testBench is

component Alarm is 
    port ( ArmSystemCode      : in std_logic_vector(3 downto 0);    
       DisarmSystemCode       : in std_logic_vector(3 downto 0);    
       Sensor                 : in std_logic;
       CLK_in                 : in std_logic;
       LEDs                   : out std_logic_vector(15 downto 0);
       SegmentCount           : out std_logic_vector(6 downto 0);
       SegmentSelect          : out std_logic_vector( 3 downto 0));
    end component;
    
signal ArmSystemCode, DisarmSystemCode    : std_logic_vector(3 downto 0);
signal Sensor, CLK_in                     : std_logic;
signal LEDs                               : std_logic_vector (15 downto 0);
signal SegmentCount                       : std_logic_vector(6 downto 0);
signal SegmentSelect                      : std_logic_vector(3 downto 0);
 
constant ClockPeriod    : time    := 10 ns;
constant sim_clk : time := 5 * ClockPeriod;        -- divided clock period (useful for specifying stimulus - short periods between changes)
constant N_Cycles       : integer := 10000;         -- number of clock cycles to simulate
begin

   DUT : ALARM
    port map(
     ArmSystemCode     => ArmSystemCode,  
     DisarmSystemCode  => DisarmSystemCode,         
     Sensor  => Sensor,    
     CLK_in  => CLK_in,     
     LEDs    => LEDs,     
     SegmentCount   => SegmentCount,     
     SegmentSelect => SegmentSelect);

    -- clock generator process
   ----------------------------  
   clk_gen : process is
   begin
     while now <= (N_Cycles*sim_clk) loop       
         clk_in <= '1'; wait for ClockPeriod/2;
         clk_in <= '0'; wait for ClockPeriod/2;
     end loop;
	 wait;   
   end process;
   
  -- stimuli : process
  -- begin
        
--        ArmSystemCode <= "1101" after 0.5 sec; 
--        Sensor <= '1' after 1.5 sec;
--        DisarmSystemCode <= "0010" after 10.5 sec;
--        wait;
--        end process;
   
   ARM_gen : process is
   begin
     while now <= (N_Cycles*sim_clk) loop
        ArmSystemCode <= "0000"; wait for 2 * sim_clk;
        ArmSystemCode <= "1101"; wait;
     end loop;
     wait;
   end process;
   
   Disarm_gen : process is
   begin
    while now <= (N_Cycles*sim_clk) loop
        DisarmSystemCode <= "0000"; wait for 5 * sim_clk;
        DisarmSystemCode <= "1101"; wait;
    end loop;
    wait;
  end process;
  
  Sensor_gen : process is 
  begin 
    while now <= (N_Cycles*sim_clk) loop
        Sensor <= '0'; wait for 4 * sim_clk;
        Sensor <= '1'; wait;
     end loop;
     wait;
   end process;

end Behavioral;

