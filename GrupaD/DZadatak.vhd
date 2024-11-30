library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Definicija entiteta (glavni modul)
entity grupaD is
	port(
		iCLK : in std_logic;                     -- Ulazni takt
		iRST : in std_logic;                     -- Ulazni signal za reset
		iLOAD : in std_logic;                    -- Signal za učitavanje podataka
		iEN : in std_logic;                      -- Signal za omogućavanje rada
		iDATA : in std_logic_vector(7 downto 0); -- Ulazni podaci (8 bita)
		iSEL : in std_logic;                     -- Signal za izbor izlaza na multiplekseru
		oCODE : out std_logic_vector(2 downto 0);-- Izlaz prioritetnog kodera (3 bita)
		oRES : out std_logic_vector(3 downto 0); -- Izlaz brojača (4 bita)
		oEQU : out std_logic                     -- Izlaz komparatora
	);
end entity;

-- Arhitektura implementira funkcionalnost modula
architecture Behavioral of grupaD is
	-- Deklaracija signala za unutrašnju upotrebu
	signal sROR : std_logic_vector(7 downto 0); -- Registrator za rotaciju
	signal sCNT12 : std_logic_vector(3 downto 0); -- Brojač modula 12
	signal sCNT10 : std_logic_vector(3 downto 0); -- Brojač modula 10

begin

	-- **Proces za registrator sa rotacijom (ROR - Rotate Right)**
	-- Rotira bitove udesno: desni krajnji bit prelazi na levo mesto.
	process(iCLK) begin
		if(rising_edge(iCLK)) then -- Aktivira se na uzlaznu ivicu takta
			if(iRST = '1') then    -- Reset postavlja sve na nulu
				sROR <= (others => '0');
			else
				if(iEN = '1') then -- Provera da li je rad omogućen
					if(iLOAD = '1') then -- Učitavanje ulaznih podataka
						sROR <= iDATA;
					else
						sROR <= sROR(0) & sROR(7 downto 1); -- Rotacija udesno
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- **Komparator**
	-- Proverava da li je sadržaj registratora jednak broju 4
	oEQU <= '1' when sROR = 4 else '0';

	-- **Prioritetni koder**
	-- Pronalazi poziciju prvog bita koji je jednak '1'.
	process(sROR) begin
		if(sROR(0) = '1') then
			oCODE <= "000"; -- Ako je prvi bit (pozicija 0) stavi da je binarno 0
		elsif(sROR(1) = '1') then
			oCODE <= "001"; -- Ako je drugi bit (pozicija 1) stavi da je binarno 1
		elsif(sROR(2) = '1') then
			oCODE <= "010"; -- Treći bit...
		elsif(sROR(3) = '1') then
			oCODE <= "011";
		elsif(sROR(4) = '1') then
			oCODE <= "100";
		elsif(sROR(5) = '1') then
			oCODE <= "101";
		elsif(sROR(6) = '1') then
			oCODE <= "110";
		else
			oCODE <= "111"; -- Ako nije ni jedan od ponudjenih stavi da je zadnja vrednost 7 binarno
		end if;
	end process;

	-- **Brojač modula 12**
	-- Broji od 0 do 11, a zatim se resetuje na 0.
	process(iCLK) begin
		if(rising_edge(iCLK)) then
			if(iRST = '1') then
				sCNT12 <= "0000"; -- Reset brojača
			else
				if(sROR(7) = '1') then -- Ako je najviši bit registratora '1'
					if(sCNT12 = 11) then -- Provera da li je dostignut maksimum
						sCNT12 <= "0000"; -- Resetovanje brojača
					else
						sCNT12 <= sCNT12 + 1; -- Inkrementacija
					end if;
				end if;
			end if;
		end if;
	end process;

	-- **Brojač modula 10**
	-- Broji od 0 do 9, a zatim se resetuje na 0.
	process(iCLK) begin
		if(rising_edge(iCLK)) then
			if(iRST = '1') then
				sCNT10 <= "0000"; -- Reset brojača
			else
				if(sROR(0) = '1') then -- Ako je najmanji bit registratora '1'
					if(sCNT10 = 9) then -- Provera da li je dostignut maksimum
						sCNT10 <= "0000"; -- Resetovanje brojača
					else
						sCNT10 <= sCNT10 + 1; -- Inkrementacija
					end if;
				end if;
			end if;
		end if;
	end process;

	-- **Multiplekser (MUX)**
	-- Bira između dva brojača (sCNT12 ili sCNT10) na osnovu vrednosti `iSEL`.
	oRES <= sCNT12 when iSEL = '0' else sCNT10;

end Behavioral;
