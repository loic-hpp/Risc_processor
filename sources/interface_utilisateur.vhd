---------------------------------------------------------------------------------------------------
--
-- interface_utilisateur.vhd
--
-- v. 1.0 Pierre Langlois 2022-03-16 pour le labo #5, INF3500
--
-- TODO : comme les �tats sont tr�s semblables, on pourrait les param�trer selon quelques cat�gories, et utiliser une machine
-- g�n�rale pour les parcourir. La machine lirait les param�tres et les appliquerait.
-- 		message ou non, le message ou un pointeur
-- 		entr�e ou non
-- 		pause ou non
-- 		prochain �tat
-- 		etc.
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity interface_utilisateur is
    generic (
        f_clk      : positive := 100e6;     -- fr�quence de l'horloge de r�f�rence, en Hz
        taux_tx    : positive := 9600       -- taux de transmission en baud (symboles par seconde), ici des bits par seconde
    );
    port (
	    reset, clk : in  std_logic; 
	    resultat_cpu : in unsigned(31 downto 0); -- Entr�e pour r�cup�rer le r�sultat du calcul
        RsRx       : in  std_logic;         -- interface USB-RS-232 r�ception
        RsTx       : out std_logic;         -- interface USB-RS-232 transmission
        nombre       : out unsigned(31 downto 0);
        input_ok   : out std_logic          -- on a re�u toutes les entr�es des utilisateurs
    );
end;

architecture arch of interface_utilisateur is

    -- ** Tous les messages doivent avoir la m�me taille **
    -- CR, "carriage return," est un retour de charriot au d�but de la ligne
    -- LF, "line feed,"       est un changement de ligne
    constant m0 : string := CR & LF & "Bonjour, bienvenue dans le programme de calcul de la racine carr�e d'un nombre .v1751                        " & CR & LF;
    constant m1 : string := CR & LF & "Entrez les 8 premiers bits (de poid fort) du nombre en utilisant deux chiffres hexad�cimaux {0 - 9, A - F}.  " & CR & LF;
    constant m2 : string := CR & LF & "Entrez les 8 derniers bits (de poid faible) du nombre en utilisant deux chiffres hexad�cimaux {0 - 9, A - F}." & CR & LF;
    constant m3 : string := CR & LF & "Veuillez consulter la carte ou regarder ci-dessous pour obtenir vos r�sultats.                               " & CR & LF;
    -- Formater le message pour l'affichage du r�sultat
	constant m4 : string := CR & LF & "La racine carr�e de " & hex_to_character(nombre(7 downto 4)) & hex_to_character(nombre(3 downto 0)) & hex_to_character(nombre(7 downto 4)) & hex_to_character(nombre(3 downto 0))  & " est : " & hex_to_character(resultat_cpu(7 downto 4)) & hex_to_character(resultat_cpu(3 downto 0))  & "                                                                            " & CR & LF;
    constant m9 : string := CR & LF & "Erreur, nombre invalide, chiffres hexad�cimaux seulement {0 - 9, A - F}.                                     " & CR & LF;

    signal message : string(1 to m0'length);
    signal caractere : character;

    type etat_type is (
        s_bienvenue, 
        s_n1_m, 
        s_n1_H, 
        s_n1_L, 
        s_n2_m, 
        s_n2_H, 
        s_n2_L, 
        s_calcul, 
        s_resultat, 
        s_erreur, 
        s_afficher_resultat
    );
    
    signal etat : etat_type := s_bienvenue;

    signal go_tx   : std_logic;
    signal tx_pret : std_logic;
    signal car_recu : std_logic;

    signal clk_1_MHz : std_logic;

begin

    transmetteur : entity uart_tx_message(arch)
		generic map (f_clk, taux_tx, m0'length)
		port map (reset, clk, message, go_tx, tx_pret, RsTx);

    recepteur : entity uart_rx_char(arch)
		generic map (f_clk, taux_tx)
		port map (reset, clk, RsRx, caractere, car_recu);

    -- une horloge pour ralentir l'interface et laisser le temps aux communications de se faire
    gen_horloge_1_MHz  : entity generateur_horloge_precis(arch) generic map (f_clk, 1e6)  port map (clk, clk_1_MHz);

    process(all)
    variable c : character;
    constant delai : natural := 4; -- d�lai entre deux transmissions, en 1 / secondes (10 == 0.1 s, 5 == 0.2 s, etc.)
    variable compteur_delai : natural range 0 to f_clk / delai - 1; -- pour ins�rer une pause dans les transmissions
    begin
        if reset = '1' then
            etat <= s_bienvenue;
            go_tx <= '0';
            compteur_delai := f_clk / delai - 1;
        elsif rising_edge(clk) then
            case etat is
            when s_bienvenue =>
                -- message de bienvenue
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m0;
                        go_tx <= '1';
                        etat <= s_n1_m;
                        compteur_delai := f_clk / delai - 1;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;

            when s_n1_m =>
                -- message pour le premier nombre
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m1;
                        go_tx <= '1';
                        etat <= s_n1_H;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;

            when s_n1_H =>
                -- recevoir le chiffre le plus significatif du premier nombre
                go_tx <= '0';
                if car_recu = '1' then
				if (character_to_hex(caractere) = "0000" and hex_to_character(0) /= caractere) then
					etat <= s_erreur;
				else
                	nombre(7 downto 4) <= character_to_hex(caractere);
                  	etat <= s_n1_L;
				end if;
                end if;
            when s_n1_L =>
                -- recevoir le chiffre le moins significatif du premier nombre
                go_tx <= '0';
                if car_recu = '1' then
				  if (character_to_hex(caractere) = "0000" and hex_to_character(0) /= caractere) then
					etat <= s_erreur;
				else	
                    nombre(3 downto 0) <= character_to_hex(caractere);
                    etat <= s_resultat;
				end if;
                end if;

            -- TODO: effacer 
            -- when s_n2_m =>
            --     -- message pour le 2e nombre
            --     go_tx <= '0';
            --     if tx_pret = '1' then
            --         message <= m2;
            --         go_tx <= '1';
            --         etat <= s_n2_H;
            --     end if;
            -- when s_n2_H =>
            --     -- recevoir le chiffre le plus significatif du 2e nombre
            --     go_tx <= '0';
            --     if car_recu = '1' then
			--    	 if (character_to_hex(caractere) = "0000" and hex_to_character(0) /= caractere) then
			-- 		etat <= s_erreur;
			-- 	 else		
            --        	B(7 downto 4) <= character_to_hex(caractere);
            --        	etat <= s_n2_L;
			-- 	end if;
            --     end if;
            -- when s_n2_L =>
            --     -- recevoir le chiffre moins significatif du 2e nombre
            --     go_tx <= '0';
            --     if car_recu = '1' then
			-- 	  if (character_to_hex(caractere) = "0000" and hex_to_character(0) /= caractere) then -- condition pour entr�e invalide
			-- 		etat <= s_erreur;
			-- 	  else
            --         	B(3 downto 0) <= character_to_hex(caractere);
            --         	etat <= s_resultat;	
			-- 	 end if;
            --     end if;	

		   when s_erreur =>
		   -- Ajouter la logique pour les entr�es invalides
		   -- message pour les erreurs
                go_tx <= '0';
                if tx_pret = '1' then
                    message <= m9;
                    go_tx <= '1';
                    etat <= s_bienvenue;
                    compteur_delai := f_clk / delai - 1;
			  end if;

            when s_resultat =>
                -- message pour les r�sultats
                go_tx <= '0';
                if tx_pret = '1' then
                    message <= m3;
                    go_tx <= '1';
                    etat <= s_afficher_resultat;
                    compteur_delai := f_clk / delai - 1;
                end if;

		   when s_afficher_resultat =>
		       -- Nouvel etat pour afficher le resultat sur putty
                -- Affichage des r�sultats
                go_tx <= '0';
			  -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail	
			  if compteur_delai = 0 then
                	if tx_pret = '1' then
                    	message <= m4;
                    	go_tx <= '1';
                    	etat <= s_bienvenue;
                    	compteur_delai := f_clk / delai - 1;
                	end if;
			  else
                    compteur_delai := compteur_delai - 1;
                end if;
            when others =>
                go_tx <= '0';
                etat <= s_bienvenue;
                compteur_delai := f_clk / delai - 1;
            end case;
        end if;
    end process;

    input_ok <= '1' when etat = s_resultat else '0';

end;
