-- Uvoz biblioteke IEEE koja sadrži definicije standardnih tipova i funkcija
library ieee;
use ieee.std_logic_1164.all;

-- Deklaracija entiteta za testbench (GrupaB_tb)
entity GrupaB_tb is
end GrupaB_tb;

-- Arhitektura testbencha
architecture Test OF GrupaB_tb is 

   -- Deklaracija komponente koja se testira (GrupaB)
   component GrupaB is
      port ( 
         iCLK    : in std_logic;               -- Ulazni takt
         iRST    : in std_logic;               -- Ulaz za reset
         iDATA   : in std_logic_vector(7 downto 0); -- Ulazni podatak (8 bita)
         iEN     : in std_logic;               -- Ulaz za omogućavanje
         iLOAD   : in std_logic;               -- Ulaz za učitavanje podataka
         oCODE   : out std_logic_vector(2 downto 0); -- Izlazni kod (3 bita)
         oCNTG   : out std_logic_vector(3 downto 0); -- Izlazni brojač za jednu funkciju (4 bita)
         oCNTN   : out std_logic_vector(3 downto 0)  -- Izlazni brojač za drugu funkciju (4 bita)
      );
   end component;
    
   -- Signali za povezivanje sa komponentom
   signal sCLK   : std_logic := '0';                   -- Signal takta
   signal sRST   : std_logic := '0';                   -- Signal reseta
   signal sDATA  : std_logic_vector(7 downto 0) := "00000000"; -- Ulazni podaci (inicijalno nula)
   signal sEN    : std_logic := '0';                   -- Signal omogućavanja
   signal sLOAD  : std_logic := '0';                   -- Signal za učitavanje
   signal sCODE  : std_logic_vector(2 downto 0);       -- Izlazni kod
   signal sCNTG  : std_logic_vector(3 downto 0);       -- Izlazni brojač G
   signal sCNTN  : std_logic_vector(3 downto 0);       -- Izlazni brojač N
   
   -- Definicija perioda takta
   constant iCLK_period : time := 10 ns;

begin
 
   -- Instanciranje testirane jedinice (Unit Under Test - UUT)
   uut: GrupaB PORT MAP (
      iCLK => sCLK,
      iRST => sRST,
      iDATA => sDATA,
      iEN => sEN,
      iLOAD => sLOAD,
      oCODE => sCODE,
      oCNTG => sCNTG,
      oCNTN => sCNTN
   );

   -- Proces za generisanje takta
   iCLK_process :process
   begin
      sCLK <= '1';                    -- Postavi takt na visoki nivo
      wait for iCLK_period/2;         -- Sačekaj pola perioda
      sCLK <= '0';                    -- Postavi takt na niski nivo
      wait for iCLK_period/2;         -- Sačekaj ostatak perioda
   end process;
 

   -- Glavni proces za generisanje stimulusa
   stim_proc: process
   begin	
      -- Resetovanje sistema na 3.25 perioda takta
      sRST <= '1';                        -- Aktiviraj reset
      wait for 3.25 * iCLK_period;        -- Sačekaj 3.25 perioda
      sRST <= '0';                        -- Deaktiviraj reset
      
      -- Učitavanje broja 2 u rotirajući registar
      -- Koristi se aritmetički dodatak: not(11111110) + 1 = 00000010 (dvojka)
      sEN <= '1';                         -- Omogući rad
      sLOAD <= '1';                       -- Aktiviraj učitavanje
      sDATA <= "11111110";                -- Postavi podatke na ulaz
      wait for iCLK_period;               -- Sačekaj jedan period
      
      -- Rotiranje dok broj ne postane veći od 5
      -- 00000010 -> 00000100 -> 00001000 (8 > 5)
      sLOAD <= '0';                       -- Deaktiviraj učitavanje
      wait for 2 * iCLK_period;           -- Sačekaj dva perioda
      sEN <= '0';                         -- Deaktiviraj rad
      
      wait for 10 * iCLK_period;          -- Sačekaj 10 perioda
      
      -- Rotiraj dok broj ne postane manji od 5
      -- 10000000 -> 00000001 (1 < 5)
      sEN <= '1';                         -- Ponovo omogući rad
      wait for iCLK_period;               -- Sačekaj jedan period

      wait for 10 * iCLK_period;          -- Sačekaj dodatnih 10 perioda
      sRST <= '1';                        -- Aktiviraj reset
      wait;                               -- Završi proces
   end process;

end;
