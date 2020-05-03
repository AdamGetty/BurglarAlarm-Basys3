----------------------------------------------------------------------------------
-- Company: University of Strathclyde
-- Engineeras: Jamie Campbell, Robert Beech and Adam Getty 
-- 
-- Create Date: 20.03.2019 11:02:05
-- Design Name:  Burglar Alarm
-- Module Name: Alarm - Behavioral
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
use IEEE.numeric_std.all;

entity Alarm is
 port (ArmSystemCode :      in std_logic_vector(3 downto 0);     --Enable
       DisarmSystemCode:    in std_logic_vector(3 downto 0);   --Reset  
       Sensor :             in std_logic;
       CLK_in :             in std_logic;
       LEDs :               out std_logic_vector(15 downto 0);
       SegmentNumber:       out std_logic_vector(6 downto 0);
       SegmentSelect :      out std_logic_vector( 3 downto 0);
       BuzzerSound :        out std_logic);
end Alarm;

architecture Behavioral of Alarm is

constant max_count : integer := 50000000;    -- must count to this number to divide clock frequency from 100MHz to 1Hz.
--constant max_count : integer := 5;           -- for simulation only (easier to check output!)

-- internal signals
signal CLK_1Hz :                std_logic;                     
signal RefreshCounter  :        std_logic_vector(27 downto 0);
signal SEL :                    std_logic_vector(1 downto 0);
signal LED_BCD :                std_logic_vector(3 downto 0);
signal Segment_Display_Number : std_logic_vector (7 downto 0);

begin
  
  -- clock divider process
  ---------------------------------
  CLK_Divide : process (CLK_in) is
  
  variable count : unsigned(27 downto 0):= to_unsigned(0,28);   -- count up to x
  variable clk_int : std_logic := '0';                          -- this is a clock internal to the process
  
  begin
    
    if rising_edge(CLK_in) then
      
      if count < max_count-1 then     -- highest value count should reach is (50000000 - 1).
        count := count + 1;           -- increment counter
      else
        count := to_unsigned(0,28);   -- reset count to zero
        clk_int := not clk_int;       -- invert clock variable every time counter resets
      end if;
      
      CLK_1Hz <= clk_int;                 -- assign clock variable to internal clock signal
      RefreshCounter <= STD_LOGIC_VECTOR(count);              -- Provide a frequency that is integratable to the human eye
      
    end if;
    
  end process;
  
ALARM_PROCESS : process(CLK_in, Sensor, ArmSystemCode, DisarmSystemCode) is
  
  variable  VAL: unsigned(3 downto 0) := "1010";  
  --Possible inclusion of button signal to be insterted here.
  begin
      
      if ArmSystemCode = "1101" then         -- Cannot use AND here due to the nature of the process.
         if Sensor = '1' then
            if DisarmSystemCode /= "1101" then
               if VAL /= "0000" then
                  if rising_edge(CLK_1Hz) then 
                  VAL := VAL - 1;
                  end if;                      -- prevents timer from counting too quickly
               end if;
            end if;
        elsif DisarmSystemCode = "1101" then    -- Disarm System
            VAL  := "1010";
        end if;
      end if;
  
      
   case to_integer(VAL) is 
      
       when 0 =>
     Segment_Display_Number <= "00000000";
          LEDs <= (others => '1');
         --BuzzerSound <= '1';
       when 1 =>
        Segment_Display_Number <= "00000001";
        LEDs <= (others => '0');
      when 2 =>
       Segment_Display_Number <= "00000010";
        LEDs <= (others => '0');
      when 3 =>
       Segment_Display_Number <= "00000011";
        LEDs <= (others => '0');
      when 4 =>
       Segment_Display_Number <= "00000100";
        LEDs <= (others => '0');
      when 5 =>
       Segment_Display_Number <= "00000101";
        LEDs <= (others => '0');
      when 6 =>
        Segment_Display_Number <= "00000110";
        LEDs <= (others => '0');
      when 7 =>
       Segment_Display_Number <= "00000111";
        LEDs <= (others => '0');
      when 8 =>
       Segment_Display_Number <= "00001000";
        LEDs <= (others => '0');
      when 9 =>
       Segment_Display_Number <= "00001001";
        LEDs <= (others => '0');
      when 10 =>
       Segment_Display_Number <= "00010000";
        LEDs <= (others => '0');
      when others =>
        Segment_Display_Number <= "11111111";
        LEDs <= (others => '0');   
           
  end case;
end process;
-- Process for 4-1 Multiplexer, which iterates through individual 7-segments. (Second from Right, Furthest right). 

SEL <= RefreshCounter(11 downto 10);  
 
process(SEL)                                    
    begin
    
        case SEL is
        when "10" => SegmentSelect <= "1101";          -- Activates LED 3
        LED_BCD <= Segment_Display_Number(7 downto 4); 
        when "11" => SegmentSelect <= "1110";          --Activates LED 4
        LED_BCD <= Segment_Display_Number(3 downto 0);
        when others => SegmentSelect <= "1111";
        end case;
end process;
    
--Represents the vector value for the 7-segment display.
process (LED_BCD) is       
begin
     case LED_BCD is
     when "0000" => SegmentNumber <= "0000001"; -- 0
     when "0001" => SegmentNumber <= "1001111"; -- 1
     when "0010" => SegmentNumber <= "0010010"; -- 2
     when "0011" => SegmentNumber <= "0000110"; -- 3
     when "0100" => SegmentNumber <= "1001100"; -- 4
     when "0101" => SegmentNumber <= "0100100"; -- 5
     when "0110" => SegmentNumber <= "0100000"; -- 6
     when "0111" => SegmentNumber <= "0001101"; -- 7
     when "1000" => SegmentNumber <= "0000000"; -- 8
     when "1001" => SegmentNumber <= "0000100"; -- 9
     when others => SegmentNumber <= "0111000"; -- F for failed
     end case;
     
end process;
  
end Behavioral;

