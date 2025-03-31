
------------------------------------------------------------------------

# INF3500 - labo 6
# Équipe *nom-d-equipe-ici*
# Noms et prénoms des coéquipiers: 
**Nguemegne Temena, Loïc, 2180845**

**Roman Canizalez, Roman Alejandro, 2089991**

------------------------------------------------------------------------

## Partie 1 : Nouvelles instructions et programme en assembleur

Pour ajouter les nouvelles instructions et coder l'algorithme pour le calcul de la racine carrée, nous avons fait les modifications suivants:
- Nous avons modifié le processeur PolyRISC_v10c en ajoutant les opérations AmulB et Adiv2 dans l'énoncé case pour l'UAL
- Nous avons ajoutés les constantes associées aux nouvelles instructions dans PolyRISC_utilitaires_pkg.vhd
- Nous avons écrit le nouveau programme (l'algorithme du calcul de la racine carré) dans PolyRISC_le_programme_pkg.vhd
- Et nous avons ajouté de valeurs de test dans le test bench PolyRISC_v10_tb.vhd

En faisant les tests dans la simulations, nous avons remarqué le bon fonctionnement du système tout en regardant le changement de signaux et les resultats attendus dans les sorties du programme.

Parties 1B et 1C : fichiers modifiés [PolyRISC_v10c.vhd](sources/PolyRISC_v10c.vhd) et [PolyRISC_utilitaires_pkg.vhd](sources/PolyRISC_utilitaires_pkg.vhd).

(Remettre une seule version des fichiers pour les parties 1B et 1C.)

Partie 1D : fichier modifié [PolyRISC_le_programme_pkg.vhd](sources/PolyRISC_le_programme_pkg.vhd) utilisant vos nouvelles instructions.

Banc d'essai modifié [PolyRISC_v10_tb.vhd](sources/PolyRISC_v10_tb.vhd).

## Partie 2 : Implémentation sur la planchette

Nous utilisons la carte Basys 3.

Nous avons observé le bon fonctionnement du système sur la carte en faisant de tests avec des valeurs limites. Pour ce faire, nous avons affiché avec les 7 segments les valeurs de calculs de la racine carrée à chaque itération. 

Voici un lien vers notre fichier de configuration final : [top_labo_6.bit](synthese-implementation/top_labo_6.bit)

## Partie 3 : Ressources pour implémenter le processeur PolyRISC

Voici le nombre de ressources disponibles dans notre FPGA.

Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Bonded IOB
---------- | --------------- | -------- | -------- | ----------
20800 | 41600 | 16300 | 8150 | 106

Voici le nombre de ressources utilisées par le PolyRISC selon les valeurs demandées dans les instructions du labo.

Nreg | Wd | Mi | Md | version du processeur | Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Bonded IOB
---- | -- | -- | -- | --------------------- | ---------- | --------------- | -------- | -------- | ------------
16   | 32 | 8  | 8  | version de base       | 292    | 197         | 0  | 0  | 68
16   | 64 | 8  | 8  | version de base       | 555    | 389         | 0  | 0  | 132
32   | 32 | 8  | 8  | version de base       | 290    | 197         | 0  | 0  | 68
32   | 64 | 8  | 8  | version de base       | 555    | 389         | 0  | 0  | 132
16   | 32 | 8  | 8  | version partie 1      | 547    | 326         | 117  | 32  | 68
16   | 64 | 8  | 8  | version partie 1      | 1178   | 256         | 192  | 64  | 132
32   | 32 | 8  | 8  | version partie 1      | 558    | 326         | 117  | 32  | 68
32   | 64 | 8  | 8  | version partie 1      | 1200   | 646         | 134  | 64  | 132

Nous observons comment le nombre de ressources utilisées augmente quand les valeurs de Nreg et Wd augmentent (surtout Wd). Cela est logique car Wd représente le nombre de bits par registre (ou bien, le nombre de bascules en parallele pour un registre) et Nreg le nombre de registres, donc quand ils augmentent, nous pouvons stocker plus de valeurs. Par exemple, faire passer de 32 à 64 bits double environ le nombre de registres utilisés (cela n'est pas toujours vrai car la synthèse fait des optimisations et aussi des LUT sont utilisés aussi pour representer des éléments mémoire).

## Partie 4 : Bonus

*Faire un choix et garder seulement une option.*
- Nous n'avons pas complété le bonus. Nous nous concentrons sur notre réussite dans ce cours et dans d'autres.

### Partie 4A

Notre approche consiste à ...

### Partie 4B

Notre approche consiste à ...


## Observations et discussion générale

Dans ce laboratoire, nous avons remarqué que : ...

Nous avons appris que ....

Nous avons trouvé plus difficile de ...

Nous recommandons que ...
