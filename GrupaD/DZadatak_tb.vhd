library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Definicija entiteta
entity GrupaD_tb is end entity;

architecture test of GrupaD_tb is

    -- Komponenta koju testiramo
	component zad is
	port(
		iCLK : in std_logic;         -- Ulazni klok
		iRST : in std_logic;         -- Ulaz za reset
		iLOAD : in std_logic;        -- Ulaz za učitavanje
		iDATA : in std_logic_vector(7 downto 0); -- Ulazni podaci
		iEN : in std_logic;          -- Ulaz za omogućavanje
		iSEL : in std_logic;         -- Selekt signal
		oCODE : out std_logic_vector(2 downto 0); -- Izlazni kod
		oRES : out std_logic_vector(3 downto 0);  -- Rezultat
		oEQU : out std_logic        -- Izlaz za jednakost
	);
	end component;

    -- Signali za povezivanje sa komponentom
	signal sCLK :  std_logic := '0';                           -- Signal za klok
	signal sRST :  std_logic := '0';                           -- Signal za reset
	signal sLOAD :  std_logic := '0';                          -- Signal za učitavanje
	signal sDATA : std_logic_vector(7 downto 0) := (others => '0'); -- Signal za podatke
	signal sEN :  std_logic := '0';                            -- Signal za omogućavanje
	signal sSEL :  std_logic := '0';                           -- Selekt signal
	signal sCODE :  std_logic_vector(2 downto 0) := (others => '0'); -- Izlazni kod
	signal sRES :  std_logic_vector(3 downto 0) := (others => '0');  -- Izlazni rezultat
	signal sEQU :  std_logic;                                  -- Signal za jednakost

    -- Konstantna vrednost perioda takta
	constant pCLK : time := 2 ns;

begin

	-- Instanciranje komponente (jedinice pod testiranjem)
	uut : zad port map(
		iCLK => sCLK,       -- Povezivanje sa signalom za klok
		iRST => sRST,       -- Povezivanje sa signalom za reset
		iLOAD => sLOAD,     -- Povezivanje sa signalom za učitavanje
		iDATA => sDATA,     -- Povezivanje sa signalom za podatke
		iEN => sEN,         -- Povezivanje sa signalom za omogućavanje
		iSEL => sSEL,       -- Povezivanje sa selekt signalom
		oCODE => sCODE,     -- Povezivanje sa izlaznim kodom
		oRES => sRES,       -- Povezivanje sa izlaznim rezultatom
		oEQU => sEQU        -- Povezivanje sa izlazom za jednakost
	);

    -- Proces za generisanje kloka
	clkproc : process begin
		sCLK <= '0';                   -- Klok nizak
		wait for pCLK/2;               -- Sačekaj polovinu perioda
		sCLK <= '1';                   -- Klok visok
		wait for pCLK/2;               -- Sačekaj polovinu perioda
	end process;

    -- Proces za stimulaciju signala
	stim : process begin
		-- 1. Reset sistema
		sRST <= '1';                   -- Aktiviraj reset
		wait for 4.25 * pCLK;          -- Tacka 1. Aktivaraj Reset na 4.25 sec
		sRST <= '0';                   -- Deaktiviraj reset

		-- 2. Učitavanje podataka
		sEN <= '1';                    -- Omogući ulaz
		sLOAD <= '1';                  -- Učitavanje uključeno
		sDATA <= "01000100";           -- Dodela podataka tako da jedinice nisu susedne.	
		wait for 2 * pCLK;             -- Sačekaj

		-- 3. i 4. Selekt i brojač
		sLOAD <= '0';                  -- Učitavanje isključeno
		sSEL <= '1';                   -- Selekt uključen
		wait for 2 * pCLK;             -- Sačekaj (brojač mod 10 kreće)
		sEN <= '0';                    -- Isključi omogućavanje

		-- 5. i 6. Brojanje do kraja
		wait for 10 * pCLK;            -- Sačekaj da brojač završi
		sEN <= '1';                    -- Ponovno uključivanje
		wait for pCLK;                 -- Sačekaj
		sEN <= '0';                    -- Isključi omogućavanje
		sSEL <= '0';                   -- Isključi selekt
		wait for 12 * pCLK;            -- Sačekaj dalje

		-- 7. Novi reset
		sRST <= '1';                   -- Reset uključen
		wait for 5 * pCLK;             -- Sačekaj
		sRST <= '0';                   -- Reset isključen
		sEN <= '1';                    -- Omogući

		-- 8. Učitavanje novih podataka
		sLOAD <= '1';                  -- Učitavanje uključeno
		wait for pCLK;                 -- Sačekaj
		sDATA <= "00000010";           -- Novi podaci
		wait for pCLK;                 -- Sačekaj da postane 4
		sLOAD <= '0';                  -- Učitavanje isključeno
		sEN <= '1';                    -- Omogući
		sEN <= '0';                    -- Isključi
		wait for 15 * pCLK;            -- Sačekaj dalje

		-- 9. Završni reset
		sRST <= '1';                   -- Reset uključen
		wait for pCLK;                 -- Sačekaj
		sRST <= '0';                   -- Reset isključen
		wait;                          -- Kraj simulacije
	end process;

end architecture;
