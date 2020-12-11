library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
        --segnali per l'o_address
        signal roAddr_sel, roAddr_load : std_logic;
        signal roAddr, mux_roAddr, o_roAddr, sum_oAddr  : std_logic_vector(15 downto 0);
        
        --segnali per il calcolo di righe e colonne e termine ciclo di lettura pixel
        signal righeIn_load, righeAgg_load, righeAgg_sel, colonneIn_load, colonneAgg_sel, colonneAgg_load, o_end_righe, o_end_colonne : std_logic;
        signal o_righeAgg, o_colonneAgg, o_righeIn, o_colonneIn : std_logic_vector(7 downto 0); --segnale in uscita dei registri
        signal mux_righeAgg, mux_colonneAgg  : std_logic_vector (7 downto 0); --segnale in uscita dai vari multiplexer dei valori aggiornati
        signal sub_righe, sub_colonne : std_logic_vector (7 downto 0);  --sottrattori

        
        --segnali per il calcolo del pixel massimo e minimo
        signal pixelIn_load, pixelMin1_sel, pixelMin2_sel, pixelMin_load, o_endMin, pixelMax1_sel, pixelMax2_sel, pixelMax_load,  o_endMax   : std_logic;
        signal o_pixelIn, o_pixelMax, o_pixelMin : std_logic_vector(7 downto 0); --segnale in uscita dei registri
        signal mux1_pixelMax, mux1_pixelMin, mux2_pixelMin, mux2_pixelMax : STD_LOGIC_VECTOR (7 downto 0); --segnale in uscita dai mux

        
        --segnali per il delta_value
        signal delta_value_load : std_logic;
        signal delta_value : std_logic_vector(7 downto 0);
        
        type S is(S0, S1, S2, S3, S4, S5, S6, S7);
        signal cur_state, next_state : S;
begin
    --processo per il clock
    process(i_clk, i_rst)     
        begin         
            if(i_rst = '1') then             
            cur_state <= S0;
            o_pixelMin <= "11111111";
            o_pixelMax <= "00000000";
            o_pixelIn <= "00000000";
            delta_value <= "000000000";
            o_righeAgg <= "000000000";
            o_righeIn <= "000000000";
            o_colonneAgg <= "000000000";
            o_colonneIn <= "000000000";          
        elsif i_clk'event and i_clk = '1' then             
            cur_state <= next_state;                   
        end if;     
    end process;
    
     --definizione della macchina a stati
     process(cur_state, i_start, o_end_colonne, o_end_righe)
        begin    
            next_state <= cur_state; 
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
                    next_state <= S4;
                when S4 =>
                    if o_end_colonne = '0' then
                        next_state <= S4;
                    elsif o_end_colonne = '1' and o_end_righe = '1' then
                        next_state <= S6;  
                    elsif o_end_colonne = '1' and o_end_righe = '0' then
                        next_state <= S5;
                    end if;
                when S5 =>
                    next_state <= S4;
                when S6 =>
                    next_state <= S7;
                when S7 =>
            end case;
    end process;  
    
     with pixelMax1_sel select
        mux1_pixelMax <= o_pixelMax when '0',
                    o_pixelIn when '1',
                    "XXXXXXXXXXXXXXXX" when others;
                    
     with pixelMin1_sel select
        mux1_pixelMin <= o_pixelMin when '0',
                    o_pixelIn when '1',
                    "XXXXXXXXXXXXXXXX" when others; 
        
     with pixelMax2_sel select
        mux2_pixelMax <= "00000000" when '0',
                    mux1_pixelMax when '1',
                    "XXXXXXXXXXXXXXXX" when others; 
        
     with pixelMin2_sel select
        mux2_pixelMin <= "11111111" when '0',
                    mux1_pixelMin when '1',
                    "XXXXXXXXXXXXXXXX" when others; 
    
    --processo per determinare max e min pixel e calcolare i delta_value   
    process(cur_state)
        begin
        pixelIn_load <= '0';
        pixelMin1_sel <= o_endMin;
        pixelMin2_sel <= '0';
        pixelMin_load <= '0';
        pixelMax1_sel <= o_endMax;
        pixelMax2_sel <= '0';
        pixelMax_load <= '0';
        delta_value_load <= '0';
        next_state <= cur_state;
        case cur_state is 
            when S0 =>
            
            when S1 =>
            
            when S2 =>
            
            when S3 =>
                pixelIn_load <= '1';
                pixelMin2_sel <= '1';
                pixelMin_load <= '1';
                pixelMax2_sel <= '1';
                pixelMax_load <= '1';
            when S4 =>
            
            when S5 =>
            
            when S6 =>
                pixelIn_load <= '1';
                pixelMin2_sel <= '1';
                pixelMin_load <= '1';
                pixelMax2_sel <= '1';
                pixelMax_load <= '1';
                delta_value_load <= '1';                
            when S7 =>
        end case;
    end process;
    
    --definizione dei sottrattori
    sub_colonne <= o_colonneAgg - "00000001"; 
    sub_righe <= o_righeAgg - "00000001";
    
    --definizione dei mux
    with righeAgg_sel select
        mux_righeAgg <= o_righeIn when '0',
                    sub_righe when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    with colonneAgg_sel select
        mux_colonneAgg <= o_colonneIn when '0',
                    sub_colonne when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    
    --processo per la gestione di righe e colonne
    process(cur_state)
        begin
        righeIn_load <= '0';
        righeAgg_sel <= '0';
        righeAgg_load <= '0';
        colonneIn_load <= '0';
        colonneAgg_sel <= '0';
        colonneAgg_load <= '0';
        next_state <= cur_state;
        case cur_state is 
            when S0 =>
            
            when S1 =>
                righeIn_load <= '1';
                righeAgg_sel <= '0';
                righeAgg_load <= '1';
            when S2 =>
                righeIn_load <= '0';
                colonneIn_load <= '1';
                colonneAgg_sel <= '0';
                colonneAgg_load <= '1';
            when S3 =>
                righeIn_load <= '0';
                colonneIn_load <= '0';
            when S4 =>
                colonneAgg_sel <= '1';
                colonneAgg_load <= '0';
                righeAgg_sel <= '0';
                righeAgg_load <= '0';
            when S5 =>
                colonneAgg_sel <= '0';
                colonneAgg_load <= '1';
                righeAgg_sel <= '1';
                righeAgg_load <= '1';
            when S6 =>
            when S7 =>
        end case;
    end process; 
    
    --incremento il valore di o_addr
    sum_oAddr <= "00000001" + o_roAddr; 
    
    --creazione del mux dell' o_address
    with roAddr_sel select
        mux_roAddr <= "0000000000000000" when '0',
                    sum_oAddr when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    --processo per la gestione dell'o_address, dell'enable e dell'o_done
    process(cur_state)
        begin
        o_address <= "0000000000000000";
        roAddr_sel <= '0';
        roAddr_load <= '0';
        case cur_state is  
            when S0 =>
                roAddr_sel <= '0';
                roAddr_load <= '1';
            when S1 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
                o_en <= '1';
                o_we <= '0';   
            when S2 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S3 =>
                roAddr_sel <= '1';
                roAddr_load <= '1';
            when S4 =>
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
                o_done <= '1';                
        end case;
    end process;                             
end Behavioral;