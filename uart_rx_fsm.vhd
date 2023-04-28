-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Yelyzaveta Ovsiannikova (xovsia00)

library ieee;
use ieee.std_logic_1164.all;

entity UART_FSM is
port(
   CLK: in std_logic; -- clock
   RST: in std_logic; -- reset
   DIN: in std_logic; -- data 
   CNTR: in std_logic_vector(4 downto 0); -- counter
   CNTR1: in std_logic_vector(3 downto 0); -- counter for bits
   LASTBIT: in std_logic_vector(3 downto 0); -- counter for last bit
   VALIDDATA: out std_logic; -- valid data
   READER: out std_logic; -- reciever
   COUNTERENABLED: out std_logic -- counter enabled
   );
end entity UART_FSM;

architecture behavioral of UART_FSM is
type my_state is (START, START_BIT, READ_BIT, LAST_BIT, VALIDATE); -- states
signal state : my_state := START; -- initial state
begin 
  READER <= '1' when state = READ_BIT else '0'; -- when we are in READ_BIT state, then we are reading data
  VALIDDATA <= '1' when state = VALIDATE else '0'; -- when we are in VALIDATE state, then we are validating data
  COUNTERENABLED <= '1' when state = START_BIT or state = READ_BIT else '0'; -- when we are in START_BIT or READ_BIT state, then counter is enabled
  process (CLK) begin 
    if rising_edge(CLK) then
      if RST = '1' then -- when reset is pressed
        state <= START; -- then we go to START state
      else
          case state is
                when START => if DIN = '0' then -- when no data is received
                                    state <= START_BIT; 
                                elsif RST = '1' then -- when reset is pressed
                                    state <= START;  -- then we go to START state
                                end if;
                when START_BIT => if CNTR = "10110" then -- when counter is 22 it means that all 10 bits of UART data were received
                                        state <= READ_BIT; -- then we go to READ_BIT state
                                    else 
                                        state <= START_BIT; -- if not, then we are still in START_BIT state
                                    end if;
                when READ_BIT => if CNTR1 = "1000" then  -- when bit counter is 8 it means that all 8 bits of  data were received and it was the last bit
                                        state <= LAST_BIT; -- then we go to LAST_BIT state
                                    else
                                        state <= READ_BIT; -- if not, then we are still in READ_BIT state
                                    end if;
                when LAST_BIT  => if LASTBIT = "1000" then -- when last bit counter is 8 it means that all 8 bits were received
                                        state <= VALIDATE;  -- then we go to VALIDATE state
                                    else
                                        state <= LAST_BIT; -- if not, then we are still in LAST_BIT state
                                    end if;
                when VALIDATE  => state <= START;   -- when validation finished then we go to START state             
                -- when others => null; --for unknown state
          end case; 
      end if;
    end if;
  end process;
end behavioral;