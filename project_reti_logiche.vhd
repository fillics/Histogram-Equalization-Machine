----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2020 15:21:30
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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

entity project_reti_logiche is --descrive un componente solo come interfaccia da e verso l'esterno
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
-- descrive la lista di porte
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is -- specifica il funzionamento di una entità

TYPE State_type IS (RST,S1 ...);

begin


end Behavioral;
