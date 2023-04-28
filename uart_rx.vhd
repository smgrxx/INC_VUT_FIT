-- uart_rx.vhd: UART controller - receiving (RX) side
    -- Author(s): Yelyzaveta Ovsiannikova (xovsia00)

    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;
    --use ieee.std_logic_arith.all;

    -- Entity declaration (DO NOT ALTER THIS PART!)
    entity UART_RX is
    port(  
    CLK      : in std_logic;
    RST      : in std_logic;
    DIN      : in std_logic;
    DOUT     : out std_logic_vector(7 downto 0);
    DOUT_VLD : out std_logic
    );
    end UART_RX;   

    -- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
    architecture behavioral of UART_RX is
        signal counter:std_logic_vector(4 downto 0):= "00001" ;  -- counter for baud rate
        signal counter1:std_logic_vector(3 downto 0):= "0000" ; -- counter for bits
        signal last_bit:std_logic_vector(3 downto 0):= "0000" ; -- counter for stop bit
        signal valid_data:std_logic := '0'; -- checks data
        signal read_data:std_logic := '0'; -- reads data
        signal counter_enable:std_logic := '0';  -- enables counter
    begin
    
    -- Instance of RX FSM
    FSM: entity work.UART_FSM(behavioral)
        port map (
            CLK => CLK,  -- clock
            RST => RST,  -- reset 
            DIN => DIN,  -- input
            CNTR => counter,  -- counter 
            CNTR1 => counter1, -- counts bits
            LASTBIT => last_bit, -- counts to stop_bit
            VALIDDATA => valid_data, -- checks data
            READER => read_data,  -- reads data
            COUNTERENABLED => counter_enable -- enables counter
        );
        DOUT_VLD <= valid_data; -- valid data is valid_data
        process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then -- when reset pressed
                counter <= "00001"; -- counter is 1 
                counter1 <= "0000"; -- counter1 is 0
                last_bit <= "0000"; -- last_bit is 0
            end if;
            if counter1 = "1000" then -- when counter1 is 8
                last_bit <= std_logic_vector(unsigned(last_bit) + 1); -- last_bit is incremented 
            end if;         
            if last_bit = "1000" then -- when last_bit is 8
                counter1 <= "0000"; -- counter1 is 0
                last_bit <= "0000"; -- last_bit is 0
            else
                counter1 <= counter1; -- counter1 is counter1
            end if;
            if counter_enable = '1' then  -- when counter is enabled
                counter <= std_logic_vector(unsigned(counter) + 1); -- counter is incremented
            else
                counter <= "00000"; -- counter is 1
                counter1 <= counter1; -- counter1 is counter1
            end if;
            if read_data = '1' and (to_integer(unsigned(counter)) >= 16) then -- when read_data is 1 and counter is greater than 16
                DOUT(to_integer(unsigned(counter1))) <= DIN; -- output is input
                counter1 <= std_logic_vector(unsigned(counter1) + 1)  ;  -- counter1 is incremented
                counter <= "00001"; -- counter is 1
            end if;       
        end if;
    end process;
end behavioral;