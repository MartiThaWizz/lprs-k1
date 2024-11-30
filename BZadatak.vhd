-- Uvoz biblioteke IEEE za standardne tipove i funkcije
library ieee;
use ieee.std_logic_1164.all;
-- Dodavanje biblioteke za rad sa unsigned (nepotpisanim) brojevima
use ieee.std_logic_unsigned.all;

-- Definicija entiteta GrupaB sa ulazima i izlazima
entity GrupaB is
   port ( 
      iCLK    : in std_logic;               -- Ulazni takt
      iRST    : in std_logic;               -- Ulaz za reset
      iDATA   : in std_logic_vector(7 downto 0); -- Ulazni podaci (8 bita)
      iEN     : in std_logic;               -- Ulaz za omogućavanje rada
      iLOAD   : in std_logic;               -- Ulaz za učitavanje podataka
      oCODE   : out std_logic_vector(2 downto 0); -- Izlazni kod (prioritetni koder, 3 bita)
      oCNTG   : out std_logic_vector(3 downto 0); -- Brojač većih vrednosti
      oCNTN   : out std_logic_vector(3 downto 0)  -- Brojač manjih vrednosti
   );
end entity;

-- Arhitektura koja opisuje ponašanje entiteta
architecture Behavioral of GrupaB is
   -- Signali unutar arhitekture
   signal sCOMP  : std_logic_vector(7 downto 0); -- Izlaz komplementera (isti broj bitova kao i iDATA)
   signal sROR   : std_logic_vector(7 downto 0); -- Izlaz rotirajućeg registra
   signal sVECI  : std_logic_vector(3 downto 0); -- Brojač za veće vrednosti
   signal sMANJI : std_logic_vector(3 downto 0); -- Brojač za manje vrednosti
   signal sENG   : std_logic;                   -- Signal koji označava vrednosti veće ili jednake 5
   signal sENS   : std_logic;                   -- Signal koji označava vrednosti manje od 5

begin
	
	-- Komplementer
	-- Negacija ulaznog podatka (not) i dodavanje 1 (dodatak 2) za izračunavanje komplementa
	sCOMP <= not(iDATA) + 1;
	
	-- Rotirajući registar
	process(iCLK)
	begin
		if rising_edge(iCLK) then
			if iRST = '1' then
				-- Resetovanje rotirajućeg registra na nulu
				sROR <= (others => '0');
			elsif iEN = '1' then
				if iLOAD = '1' then
					-- Učitavanje komplementirane vrednosti u registar
					sROR <= sCOMP;
				else
					-- Rotacija ulazne vrednosti ulevo
					sROR <= sROR(6 downto 0) & sROR(7);
				end if;
			end if;
		end if;
	end process;
	
	-- Prioritetni koder
	-- Pronalazi najviši postavljeni bit (1) u rotirajućem registru i postavlja odgovarajući izlaz
	process(sROR)
	begin
		if sROR(7) = '1' then
			oCODE <= "111";  -- Binarni ekvivalent 7
		elsif sROR(6) = '1' then
			oCODE <= "110";  -- Binarni ekvivalent 6
		elsif sROR(5) = '1' then
			oCODE <= "101";  -- Binarni ekvivalent 5
		elsif sROR(4) = '1' then
			oCODE <= "100";  -- Binarni ekvivalent 4
		elsif sROR(3) = '1' then
			oCODE <= "011";  -- Binarni ekvivalent 3
		elsif sROR(2) = '1' then
			oCODE <= "010";  -- Binarni ekvivalent 2
		elsif sROR(1) = '1' then
			oCODE <= "001";  -- Binarni ekvivalent 1
		elsif sROR(0) = '1' then
			oCODE <= "000";  -- Binarni ekvivalent 0
		else
			oCODE <= "000";  -- Podrazumevana vrednost kada nema jedinica
		end if;
	end process;
	
	-- Komparator
	-- Proverava da li je vrednost manja od 5
	process(sROR)
	begin
		if sROR < 5 then
			sENS <= '1';  -- Signal za manje od 5
			sENG <= '0';  -- Signal za veće ili jednako 5
		else
			sENS <= '0';
			sENG <= '1';
		end if;
	end process;
	
	-- Brojač vrednosti većih od 5
	process(iCLK)
	begin
		if rising_edge(iCLK) then
			if iRST = '1' then
				sVECI <= (others => '0');  -- Resetovanje brojača
			elsif sENG = '1' then
				if sVECI = "1111" then
					sVECI <= (others => '0');  -- Resetovanje ako dostigne maksimum (15)
				else
					sVECI <= sVECI + 1;  -- Inkrement brojača
				end if;
			end if;
		end if;
	end process;
	
	-- Brojač vrednosti manjih od 5
	process(iCLK)
	begin
		if rising_edge(iCLK) then
			if iRST = '1' then
				sMANJI <= (others => '0');  -- Resetovanje brojača
			elsif sENS = '1' then
				if sMANJI = "1111" then
					sMANJI <= (others => '0');  -- Resetovanje ako dostigne maksimum (15)
				else
					sMANJI <= sMANJI + 1;  -- Inkrement brojača
				end if;
			end if;
		end if;
	end process;
	
	-- Dodeljivanje vrednosti izlazima za brojače
	oCNTG <= sVECI;  -- Brojač većih vrednosti
	oCNTN <= sMANJI; -- Brojač manjih vrednosti
	
end Behavioral;
