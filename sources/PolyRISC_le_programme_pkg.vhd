---------------------------------------------------------------------------------------------------
--
-- PolyRISC_le_programme_pkg.vhd
--
-- contenu de la m�moire des instructions
--
---------------------------------------------------------------------------------------------------
use work.PolyRISC_utilitaires_pkg.all;

package PolyRISC_le_programme_pkg is

    -----------------------------------------------------------------------------------------------
    -- partie 0 : programme de d�monstration, suite de Fibonacci
    -- constant memoireInstructions : memoireInstructions_type := (
    -- (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in
    -- (reg_valeur, passeB, 1, 0, 2),                 -- 1 : R1 := #2
    -- (reg_valeur, passeB, 3, 0, 0),                 -- 2 : R3 := #0
    -- (memoire, ecrireGPIO_out, 3, 0, 0),            -- 3 : GPIO_out := R3
    -- (reg_valeur, passeB, 4, 0, 1),                 -- 4 : R4 := #1
    -- (memoire, ecrireGPIO_out, 4, 0, 0),            -- 5 : GPIO_out := R4
    -- (reg, AplusB, 5, 3, 4),                        -- 6 : R5 := R3 + R4
    -- (reg, passeA, 3, 4, 0),                        -- 7 : R3 := R4
    -- (reg, passeA, 4, 5, 0),                        -- 8 : R4 := R5
    -- (memoire, ecrireGPIO_out, 4, 0, 0),            -- 9 : GPIO_out := R4
    -- (reg_valeur, AplusB, 1, 1, 1),                 -- 10 : R1 := R1 + #1
    -- (branchement, ppe, 0, 1, -5),                  -- 11 : si R1 <= R0 goto CP + -5
    -- STOP,
    -- NOP);
    
    -----------------------------------------------------------------------------------------------
    -- parties 1 et 2 : votre code � d�velopper
    -- placez le code de la partie 0 en commentaires
    -- utilisez le code de la partie 0 pour vous inspirer

--    constant memoireInstructions : memoireInstructions_type := (
--    (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in
--
    constant memoireInstructions : memoireInstructions_type := (
    -- Initialisation
    (memoire, lireGPIO_in, 0, 0, 0),               -- Initialiser nombre (R0)
    (memoire, ecrireGPIO_out, 0, 0, 0),            -- GPIO_out := valeur initiale
    (reg_valeur, passeB, 1, 0, 32767),             -- Initialiser haut (R1) 
    (reg_valeur, passeB, 2, 0, 0),                 -- Initialiser bas (R2)
    (reg_valeur, passeB, 3, 0, 16),                -- Initialiser compteur (R3)
    (reg_valeur, passeB, 10, 0, 0),                -- R10 := 0 pour comparaison dans la boucle while
    
    -- Boucle while
    (branchement, pgq, 10, 3, 1),                  -- Si compteur (R3) > 0 (R10) continue
    (reg, AplusB, 4, 1, 2),                        -- R4 := R1 + R2 (somme avant diviser par 2)
    (reg, Adiv2, 5, 4, 0),                         -- pivot := somme / 2
    (reg, passeA, 6, 5, 0),                        -- copie de pivot 
    (reg, AmulB, 7, 6, 5),                         -- carre := pivot * copie de pivot
    (memoire, ecrireGPIO_out, 5, 0, 0),            -- GPIO_out := pivot
    
    -- if else
    (branchement, pgq, 0, 7, 3),                   -- si R7 > R0 goto CP + 2
    (reg, passeA, 2, 5, 0),                        -- bas (R2) := pivot (R5)  
    (branchement, toujours, 0, 0, 2),              -- 
    (reg, passeA, 1, 5, 0),                        -- haut (R1) := pivot (R5)  

    (reg_valeur, AmoinsB, 3, 3, 1),                -- Decrementer compteur (R3)
    
    (branchement, pgq, 10, 3, -10),                 -- Si compteur (R3) > 0 (R10) reste dans la boucle
    (memoire, ecrireGPIO_out, 5, 0, 0),            -- GPIO_out := racine carree
    STOP,
    NOP);

    -----------------------------------------------------------------------------------------------
    -- PROGRAMME POUR TESTER MULTIPLICATION
    constant memoireInstructionsMultiplication : memoireInstructions_type := (
    (reg_valeur, passeB, 3, 0, 3), 
    (reg, passeA, 4, 3, 0),                
    (reg_valeur, passeB, 2, 0, 2),                 
    (reg, AmulB, 5, 2, 4),
    STOP,
    NOP);
    
    -----------------------------------------------------------------------------------------------
    -- PROGRAMME POUR TESTER DIVISION PAR 2
    constant memoireInstructionsDivision : memoireInstructions_type := (
    (reg_valeur, passeB, 3, 0, 6), 
    (reg, passeA, 4, 3, 0),                        
    (reg, Adiv2, 5, 4, 0),
    STOP,
    NOP);

end package;
