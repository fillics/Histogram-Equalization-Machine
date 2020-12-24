----------------------------------------------------------------------------------
--
-- Prova Finale (Progetto di Reti Logiche)
-- Prof. William Fornaciari - Anno 2020/2021
--
-- Filippo Calio' (Codice Persona 10628126 Matricola 907675)
-- Giovanni Caleffi (Codice Persona 10665233  Matricola 907455 )
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
        i_clk: in std_logic; -- segnale di CLOCK in ingresso generato dal TestBench
        i_start: in std_logic; -- segnale di START generato dal TestBench
        i_rst: in std_logic; -- segnale di RESET che inizializza la macchina pronta per ricevere il primo segnale di START
        i_data: in std_logic_vector(7 downto 0); -- segnale (vettore) che arriva dalla memoria in seguito ad una richiesta di lettura
        o_address: out std_logic_vector(15 downto 0); -- segnale (vettore) di uscita che manda l'indirizzo alla memoria
        o_done: out std_logic; -- segnale di uscita che comunica la fine dell'elaborazione e il dato di uscita scritto in memoria
        o_en: out std_logic; -- segnale di ENABLE da dover mandare alla memoria per poter comunicarci (sia in lettura che in scrittura)
        o_we: out std_logic; --  segnale di WRITE ENABLE da dover mandare alla memoria (=1) per poter scriverci. Per leggere da memoria esso deve essere 0.
        o_data: out std_logic_vector(7 downto 0) -- segnale (vettore) di uscita dal componente verso la memoria
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
        -- segnali per l'o_address
        signal roAddr_sel, roAddr_load : std_logic := '0' ;
        signal mux_roAddr, o_roAddr, sum_oAddr  : std_logic_vector(15 downto 0) := "0000000000000000" ;
        
        -- segnali per il calcolo di righe e colonne e termine ciclo di lettura pixel
        signal righeIn_load, righeAgg_load, righeAgg_sel, colonneIn_load, colonneAgg_sel, colonneAgg_load, o_end_righe, o_end_colonne : std_logic := '0';
        signal o_righeAgg, o_colonneAgg, o_righeIn, o_colonneIn : std_logic_vector(7 downto 0) := "00000000"; --segnale in uscita dei registri
        signal mux_righeAgg, mux_colonneAgg  : std_logic_vector (7 downto 0):= "00000000"; --segnale in uscita dai vari multiplexer dei valori aggiornati
        signal sub_righe, sub_colonne : std_logic_vector (7 downto 0):= "00000000";  --sottrattori

        
        -- segnali per il calcolo del pixel massimo e minimo
        signal pixelIn_load, pixelMin1_sel, pixelMin2_sel, pixelMin_load, pixelMax1_sel, pixelMax2_sel, pixelMax_load: std_logic := '0';
        signal o_pixelIn, o_pixelMax : std_logic_vector(7 downto 0):= "00000000"; --segnale in uscita dei registri
        signal o_pixelMin : std_logic_vector(7 downto 0) := "11111111";
        signal mux1_pixelMax, mux1_pixelMin, mux2_pixelMin, mux2_pixelMax : std_logic_vector (7 downto 0):= "00000000"; --segnale in uscita dai mux

        
        -- segnali per il delta_value
        signal delta_value_load : std_logic := '0';
        signal delta_value : std_logic_vector(7 downto 0):= "00000000"; --segnale in uscita del delta value
        
        --segnali dello shift level
        signal delta_value_sum : std_logic_vector(8 downto 0) := "000000000";
        signal o_floor, shift_level : std_logic_vector(3 downto 0) := "0000";
        
        signal shift_level_load : std_logic := '0';
        
        
        
        type S is (S0, S1, S2, S3, S_LOOP1, S_LOOP2, S5, S6, S7, S8, S9, S_FINAL);
        signal cur_state, next_state : S;
begin
    -- processo per il clock
    process(i_clk, i_rst)     
        begin         
            if(i_rst = '1') then             
            cur_state <= S0;       
        elsif i_clk'event and i_clk = '1' then             
            cur_state <= next_state;                   
        end if;     
    end process;

    o_address <= mux_roAddr;
    -- incremento il valore di o_addr
    sum_oAddr <= "00000001" + o_roAddr; 
    
    -- creazione del mux dell' o_address
    with roAddr_sel select
        mux_roAddr <= "0000000000000000" when '0',
                    sum_oAddr when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    -- processo per la gestione dell'o_address, dell'enable e dell'o_done
    process(cur_state)
        begin
        if(roAddr_load = '1') then
            o_roAddr <= mux_roAddr;
        end  if;
        
        
        case cur_state is  
            when S0 =>
                roAddr_sel <= '0';
                roAddr_load <= '1';
                o_en <= '1';
                o_we <= '0'; 
            when S1 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S2 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S3 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S_LOOP1 =>
            
            when S_LOOP2 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S5 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S6 =>
                o_en <= '1';
                o_we <= '1';
                roAddr_sel <= '0';
                roAddr_load <= '1';
            when S7 =>
            when S8 =>
            when S9 =>
            when S_FINAL =>
                o_done <= '1';                     
        end case;
    end process; 
    
    
     -- definizione della macchina a stati
     process(cur_state, i_start, o_end_colonne, o_end_righe)
        begin    
            case cur_state is 
                when S0 =>
                    if i_start = '1' then
                        next_state <= S1;
                    end if;
                when S1 =>
                    next_state <= S2;
                when S2 =>
                    next_state <= S3;
                when S3 =>
                    next_state <= S_LOOP1;
                    
                when S_LOOP1 =>
                    if o_end_colonne = '1' and o_end_righe = '1' then
                        next_state <= S6;  
                    elsif o_end_colonne = '1' and o_end_righe = '0' then
                        next_state <= S5;
                    else
                        next_state <= S_LOOP2;
                    end if;

                when S_LOOP2 =>
                    if o_end_colonne = '1' and o_end_righe = '1' then
                        next_state <= S6;  
                    elsif o_end_colonne = '1' and o_end_righe = '0' then
                        next_state <= S5;
                    else    
                        next_state <= S_LOOP1;
                    end if;
                when S5 =>
                    next_state <= S_LOOP1;
                when S6 =>
                    next_state <= S7;
                when S7 =>
                    next_state <= S8;
                when S8 =>
                    next_state <= S9;
                when S9 =>
                    next_state <= S_FINAL;                    
                when S_FINAL =>
            end case;
    end process;  
    
    
    -- multiplexer di max e min    
     with pixelMax1_sel select
        mux1_pixelMax <= o_pixelMax when '0',
                    o_pixelIn when '1',
                    "XXXXXXXX" when others;
                    
     with pixelMin1_sel select
        mux1_pixelMin <= o_pixelMin when '0',
                    o_pixelIn when '1',
                    "XXXXXXXX" when others; 
        
     with pixelMax2_sel select
        mux2_pixelMax <= "00000000" when '0',
                    mux1_pixelMax when '1',
                    "XXXXXXXX" when others; 
        
     with pixelMin2_sel select
        mux2_pixelMin <= "11111111" when '0',
                    mux1_pixelMin when '1',
                    "XXXXXXXX" when others; 
         
                    
    -- uscite comparatori maggiore e minore per trovare il massimo e minimo pixel
    pixelMax1_sel <= '1' when (o_pixelIn >= o_pixelMax) else '0';
    pixelMin1_sel <= '1' when (o_pixelIn <= o_pixelMin) else '0';                    
    
    -- definizione sommatore per calcolare delta_value_sum = deltavalue + 1
    delta_value_sum <= "000000001" + delta_value;

    -- processo per determinare max e min pixel e calcolare i delta_value e lo shift level  
    process(cur_state)
        begin
        
        --valore di o_floor in base a delta_value_sum
        if (delta_value_sum = "000000001") then
            o_floor <= "0000"; --floor = 0
        elsif(delta_value_sum >= "000000010" and delta_value_sum < "000000100") then
            o_floor <= "0001"; --floor = 1
        elsif(delta_value_sum >= "000000100" and delta_value_sum < "000001000") then
            o_floor <= "0010"; --floor = 2
        elsif(delta_value_sum >= "000001000" and delta_value_sum < "000010000") then
            o_floor <= "0011"; --floor = 3
        elsif(delta_value_sum >= "000010000" and delta_value_sum < "000100000") then
            o_floor <= "0100"; --floor = 4
        elsif(delta_value_sum >= "000100000" and delta_value_sum < "001000000") then
            o_floor <= "0101"; --floor = 5
        elsif(delta_value_sum >= "001000000" and delta_value_sum < "010000000") then
            o_floor <= "0110"; --floor = 6
        elsif(delta_value_sum >= "010000000" and delta_value_sum < "100000000") then
            o_floor <= "0111"; --floor = 7
        elsif(delta_value_sum = "100000000") then
            o_floor <= "1000"; --floor = 8
        end if;
        
        if(shift_level_load = '1') then
            shift_level <= "1000" -  o_floor;
        end if;
        
        if(pixelIn_load = '1') then
            o_pixelIn <= i_data;
        end  if;
        
        if(pixelMax_load = '1') then
            o_pixelMax <= mux2_pixelMax;
        end  if;
        
        if(pixelMin_load = '1') then
            o_pixelMin <= mux2_pixelMin;
        end  if;
        
        if(delta_value_load = '1') then
            delta_value <= o_pixelMax - o_pixelMin;
        end  if;
        
        case cur_state is 
            when S0 =>
            
            when S1 =>
            
            when S2 =>
            
            when S3 =>
                pixelIn_load <= '1';
                pixelMin_load <= '1';
                
                pixelMax2_sel <= '1';
                pixelMax_load <= '1';
            when S_LOOP1 =>
                pixelIn_load <= '1';
                pixelMin2_sel <= '1';
            
            when S_LOOP2 =>
            
            when S5 =>
                pixelIn_load <= '1';
            
            when S6 =>
                pixelIn_load <= '1';
                
                pixelMin2_sel <= '1';
                pixelMin_load <= '1';
                pixelMax2_sel <= '1';
                pixelMax_load <= '1';
                
                
            when S7 =>
                delta_value_load <= '1'; 
                pixelIn_load <= '0';
                
                pixelMin2_sel <= '0';
                pixelMin_load <= '0';
                pixelMax2_sel <= '0';
                pixelMax_load <= '0';
                
            when S8 =>
                delta_value_load <= '0';    
            when S9 =>
                shift_level_load <= '1';
                                 
            when S_FINAL =>
        end case;
    end process;
    
    
    -- definizione dei sottrattori per decrementare #righe e #colonne
    sub_colonne <= o_colonneAgg - "00000001"; 
    sub_righe <= o_righeAgg - "00000001";
    
    -- definizione comparatori delle righe e colonne
    o_end_righe <= '1' when (o_righeAgg = "00000001") else '0';
    o_end_colonne <= '1' when (o_colonneAgg = "00000010") else '0';
    
    -- definizione dei mux relativi al #righe e #colonne
    with righeAgg_sel select
        mux_righeAgg <= o_righeIn when '0',
                    sub_righe when '1',
                    "XXXXXXXX" when others;
    
    with colonneAgg_sel select
        mux_colonneAgg <= o_colonneIn when '0',
                    sub_colonne when '1',
                    "XXXXXXXX" when others;
    
    
    -- processo per la gestione di righe e colonne
    process(cur_state)
        begin
        if(righeIn_load = '1') then
            o_righeIn <= i_data;
        end  if;
        
        if(colonneIn_load = '1') then
            o_colonneIn <= i_data;
        end  if;
        
        if(righeAgg_load = '1') then
            o_righeAgg <= mux_righeAgg;
        end  if;
        
        if(colonneAgg_load = '1') then
            o_colonneAgg <= mux_colonneAgg;
        end  if;
        
        case cur_state is 
            when S0 =>
            
            when S1 =>
                righeIn_load <= '1';
                righeAgg_sel <= '0';
            when S2 =>
                righeIn_load <= '0';
                colonneIn_load <= '1';
                righeAgg_load <= '1';

            when S3 =>
                righeAgg_load <= '0';
                colonneIn_load <= '0';
                colonneAgg_load <= '1';

            when S_LOOP1 =>
                colonneAgg_sel <= '1';
                righeAgg_load <= '0';
                righeAgg_sel <= '0';


            when S_LOOP2 =>
                righeAgg_load <= '0';
            when S5 =>
                colonneAgg_sel <= '0';
                righeAgg_sel <= '1';
                righeAgg_load <= '1';
            when S6 =>
            when S7 =>
            when S8 =>
            when S9 =>

            when S_FINAL =>
        end case;
    end process;                             
end Behavioral;
