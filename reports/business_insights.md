# Insights business

**Périmètre** : commandes livrées, janvier 2017 - août 2018. CA = somme de `price` (hors frais de port), en BRL.
**Chiffres de référence** : CA 13 181 027,13 BRL, 96 211 commandes, 109 880 unités, 93 104 clients, panier moyen 137,00 BRL.

Chaque insight suit la même structure : **observation**, **donnée**, **interprétation** (lecture, jamais présentée comme un fait), **implication business** (ce que cela change pour l'entreprise, sans recommander d'action) et **limite**. Les recommandations sont dans `recommendations.md`.
Aucun insight n'a été écrit avant l'analyse : chaque donnée vient d'une requête SQL, du notebook EDA ou du modèle Power BI, et a été recoupée entre outils.

---

## A. Insights commerciaux

### C1. La croissance vient du volume, pas du panier
- **Observation** : janvier-août 2018 dépasse nettement janvier-août 2017, et l'écart tient au nombre de commandes.
- **Donnée** : CA 7 218 125 BRL contre 2 993 456 BRL (+141,1 %). Commandes 52 783 contre 21 998 (+139,9 %). Panier moyen 136,08 contre 136,75 BRL (+0,5 %).
- **Interprétation** : l'activité a gagné en volume (clients et commandes) sans que la valeur d'une commande évolue.
- **Implication** : la croissance dépend de la capacité à générer des commandes supplémentaires. Le panier est stable.
- **Limite** : deux périodes de 8 mois. 2017 part d'une base très faible (750 commandes livrées en janvier 2017), ce qui gonfle les taux de croissance.

### C2. Plateau en 2018, puis fléchissement de juin à août
- **Observation** : après un plateau de mars à mai 2018, le CA et les commandes reculent.
- **Donnée** : CA 953 356 (mars), 973 534 (avril), 977 545 (mai), puis 856 078 (juin, -12,4 %), 867 953 (juillet) et 838 577 BRL (août, -3,4 %). Commandes 6 749 (mai) puis 6 099 (juin). La part de commandes non livrées vaut 1,1 % en juin et 2,5 % en août.
- **Interprétation** : le fléchissement est réel : le nombre de commandes tous statuts confondus baisse aussi (6 873 en mai, 6 167 en juin). Ce n'est pas un artefact du filtre « livrées ». Le YoY mensuel passe de +727 % (janvier 2018) à +51 % (août 2018), en partie par effet de base.
- **Implication** : la dynamique de 2017 ne se prolonge pas au même rythme en 2018.
- **Limite** : trois mois seulement, dernier mois en août 2018. Les causes (marketing, concurrence, saisonnalité) ne sont pas observables dans ces données.

### C3. Pic de novembre 2017 concentré sur une journée
- **Observation** : novembre 2017 est le meilleur mois, avec une journée très au-dessus des autres.
- **Donnée** : 987 765 BRL (rang 1 sur 20 mois, +52,4 % par rapport à octobre, puis -26,5 % en décembre). Le 24 novembre 2017 compte 1 147 commandes (149 917 BRL) contre 487 le lendemain. Hors ce jour, novembre atteint environ 837 849 BRL, soit +29 % par rapport à octobre.
- **Interprétation** : le pic est cohérent avec le Black Friday (24 novembre 2017, un vendredi). Le mois entier reste élevé, pas seulement cette journée.
- **Implication** : une journée événementielle génère environ 4,7 fois la moyenne quotidienne du mois, donc des pics de charge.
- **Limite** : un seul événement observé, aucune donnée sur les promotions : la cause n'est pas démontrée. Les délais de livraison pendant le pic ne sont pas analysés.

### C4. Une commande typique modeste, quelques grosses commandes pèsent lourd
- **Observation** : la distribution de la valeur des commandes est très asymétrique.
- **Donnée** : moyenne 137,00 BRL, médiane 86,50 BRL. 90 % des commandes valent moins de 269 BRL. 963 commandes (1 %) dépassent 991,71 BRL et représentent 11,5 % du CA. Maximum : 13 440 BRL.
- **Interprétation** : la commande typique est modeste, et une petite minorité de commandes pèse sur le CA bien au-delà de son effectif.
- **Implication** : le panier moyen surestime la commande typique. Le CA est sensible à un petit nombre de grosses commandes.
- **Limite** : les commandes extrêmes n'ont pas été auditées une à une.

### C5. Les frais de port pèsent surtout sur les petites commandes
- **Observation** : le poids des frais de port diminue fortement quand la valeur de la commande augmente.
- **Donnée** : frais de port 2 192 093 BRL, soit 16,6 % du CA. Frais médians : 73,1 % de la valeur pour les 10 % de commandes les moins chères (valeur médiane 19 BRL), 6,4 % pour les 10 % les plus chères (399 BRL). Corrélation de Spearman entre frais et valeur : 0,47.
- **Interprétation** (hypothèse) : les frais augmentent avec la valeur, mais beaucoup moins vite. Ils dépendent vraisemblablement d'autres facteurs (poids, distance).
- **Implication** : sur les petites commandes, la livraison coûte au client presque autant que le produit.
- **Limite** : poids, volume et distance ne sont pas analysés. Il s'agit de la médiane des ratios par commande, qui ne se compare pas au ratio global de 16,6 %. Ce sont des frais facturés, pas le coût logistique supporté par l'entreprise.

### C6. Des achats en semaine, en journée et en soirée
- **Observation** : l'activité suit un rythme régulier.
- **Donnée** : lundi 16,3 %, mardi 16,1 %, mercredi 15,6 %, jeudi 14,8 %, vendredi 14,2 %, samedi 10,9 %, dimanche 12,1 %. Le week-end pèse 23,0 % des commandes (28,6 % si les jours étaient équivalents). Environ 81 % des commandes ont lieu entre 10h et 22h59, environ 5 % entre 0h et 6h59.
- **Interprétation** : les achats se concentrent en semaine, en journée et en soirée. Le samedi est le jour le plus faible.
- **Implication** : la charge (support, traitement des commandes) est plus forte en début de semaine et en journée.
- **Limite** : le fuseau horaire des horodatages n'est pas documenté. Le Black Friday 2017 (un vendredi) pèse légèrement dans la part du vendredi.

---

## B. Insights clients

### U1. La croissance suit l'acquisition de nouveaux clients
- **Observation** : l'essentiel des clients actifs chaque mois sont des nouveaux clients.
- **Donnée** : nouveaux clients janvier-août 2018 : 50 968, contre 21 404 en 2017 (+138 %). Ils représentent environ 97 à 98 % des clients actifs de chaque mois de 2018. Les clients récurrents pèsent 1,7 à 3 % des actifs.
- **Interprétation** : la croissance du CA suit l'acquisition. La base de clients existante contribue peu.
- **Implication** : sans acquisition constante, le CA est exposé : la base installée ne le soutient pas.
- **Limite** : « nouveau » signifie premier achat dans la fenêtre d'analyse. Un client ayant acheté en 2016 est compté nouveau en 2017.

### U2. L'acquisition cesse de progresser en 2018
- **Observation** : les nouveaux clients mensuels plafonnent puis reculent au premier semestre 2018.
- **Donnée** : pic de 7 061 en novembre 2017. En 2018 : 6 843 (janvier), 6 288, 6 775, 6 582, 6 508, 5 879 (juin, -14,1 % par rapport à janvier), 5 949, 6 144 (août).
- **Interprétation** : le plateau du CA s'explique par la stagnation de l'acquisition, cohérente avec C2.
- **Implication** : ni le panier (stable), ni le réachat (faible) ne compensent un ralentissement de l'acquisition.
- **Limite** : les canaux d'acquisition et les dépenses marketing sont absents du dataset.

### U3. Le réachat est très faible
- **Observation** : presque tous les clients n'achètent qu'une fois.
- **Donnée** : 90 315 clients sur 93 104 (97,0 %) ont une seule commande. 2 789 (3,0 %) en ont plusieurs. 2 005 ont acheté sur au moins deux jours distincts, et 784 ont passé toutes leurs commandes le même jour. Le délai médian entre deux commandes est de 29 jours (moyenne 78,2 jours), et 28,6 % des intervalles ont lieu le même jour. Les clients à commandes multiples représentent 5,5 % du CA.
- **Interprétation** : la marketplace fonctionne par achats ponctuels, et une partie des « clients récurrents » le sont de façon artificielle (plusieurs commandes pour un même achat).
- **Implication** : la valeur d'un client se joue presque entièrement dans sa première commande. Le potentiel de fidélisation est très peu exploité, ou structurellement limité.
- **Limite** : fenêtre de 20 mois. Les clients récents ont eu moins de temps pour racheter. Les avis clients n'ont pas été exploités dans ce projet.

### U4. Les segments RFM : la valeur est concentrée sur des clients à forte dépense initiale
- **Observation** : les segments « fidèles » sont minuscules, et un segment pèse très lourd dans le CA.
- **Donnée** : At Risk : 15,5 % des clients, 30,5 % du CA, 277,75 BRL par client. Lost Customers : 24,4 % des clients, 9,6 % du CA, 56,09 BRL par client. Potential Loyalists : 38,9 % des clients, 38,7 % du CA. Champions et Loyal Customers ensemble : 1,5 % des clients, 3,0 % du CA. Parmi les 14 464 clients At Risk, 13 892 (96 %) n'ont acheté qu'une fois.
- **Interprétation** : la valeur est portée par des clients à forte dépense initiale, inactifs depuis plus de 270 jours. Leur fidélité n'a pas été observée.
- **Implication** : près d'un tiers du CA vient de clients dont on ignore s'ils reviendront.
- **Limite** : les noms de segments sont des étiquettes analytiques définies par nos règles. Les seuils sont des choix. Les clients récents n'ont pas eu autant de temps pour racheter, ce qui avantage les segments récents.

---

## C. Insights produits

### P1. Aucun produit vedette, une longue traîne
- **Observation** : le CA est très dispersé entre produits.
- **Donnée** : le premier produit pèse 0,48 % du CA (63 560 BRL, 194 unités). Les 10 premiers pèsent environ 3,4 %. 32 081 produits ont été vendus au moins une fois, dont 17 639 (55,0 %) une seule fois.
- **Interprétation** : marketplace de longue traîne, sans dépendance à un produit.
- **Implication** : le pilotage par produit est peu pertinent ; le pilotage par catégorie l'est davantage.
- **Limite** : les produits n'ont pas de nom dans le dataset (identifiants anonymisés). 870 produits du catalogue n'ont aucune vente dans le périmètre.

### P2. Concentration modérée par catégorie, classement CA différent du classement volume
- **Observation** : aucune catégorie ne domine, et le classement dépend de la mesure.
- **Donnée** : health_beauty 9,33 % du CA, watches_gifts 8,83 %, bed_bath_table 7,76 %. Top 5 : 39,9 %, top 10 : 62,5 %, top 15 : 76,3 %. Il faut 18 catégories sur 74 pour atteindre 80 % du CA. bed_bath_table est 1ʳᵉ en unités (10 945) mais 3ᵉ en CA ; watches_gifts réalise environ 199 BRL par unité contre environ 93 BRL pour bed_bath_table.
- **Interprétation** : assortiment large, avec des catégories à fort volume et prix bas, et d'autres à prix unitaire plus élevé.
- **Implication** : le risque de dépendance à une catégorie est faible.
- **Limite** : le CA n'est pas une marge. Certaines catégories proches sont distinctes dans la source (par exemple `home_appliances` et `home_appliances_2`). La catégorie `unknown` pèse 1,3 % du CA.

### P3. Des catégories gagnent des parts, d'autres en perdent
- **Observation** : toutes les grandes catégories croissent, mais pas au même rythme.
- **Donnée** (janvier-août 2018 contre 2017, croissance moyenne +141 %) : baby +268,6 % (rang 14 → 9), watches_gifts +242,0 % (6 → 2), health_beauty +210,3 % (2 → 1), housewares +207,2 % (9 → 6), telephony +203,0 % (16 → 13). cool_stuff +10,4 % (5 → 10), bed_bath_table +109,2 % (1 → 3), garden_tools +53,7 %, perfumery +43,0 %, toys +41,9 %.
- **Interprétation** : toute catégorie qui croît moins que +141 % perd des parts de marché internes. Aucune catégorie du top 15 n'est en baisse absolue.
- **Implication** : le mix de CA se déplace vers les catégories en accélération.
- **Limite** : classement limité au top 15 de 2018, huit mois seulement. Certaines catégories partent d'une petite base (baby : 67 998 BRL en janvier-août 2017).

### P4. Le poids des frais de port varie selon la catégorie
- **Observation** : certaines catégories supportent des frais de port relativement bien plus lourds.
- **Donnée** (catégories à plus de 100 000 BRL de CA) : electronics 29,5 %, office_furniture 25,0 %, furniture_decor 23,7 %, housewares 23,2 %, telephony 22,4 %. À l'opposé : computers_accessories 16,2 %, toys 16,1 %.
- **Interprétation** (hypothèse) : les catégories volumineuses ou à faible prix unitaire sont les plus pénalisées. Les données ne l'établissent pas.
- **Implication** : l'expérience de livraison coûte plus cher au client dans ces catégories.
- **Limite** : indicateur logistique, pas une marge. Poids et dimensions ne sont pas analysés par catégorie.

---

## D. Insights géographiques

### G1. Le CA est concentré dans trois États
- **Observation** : São Paulo domine nettement.
- **Donnée** : SP 38,36 % du CA (5 055 587 BRL, 40 406 commandes, soit 42,0 % des commandes). SP, RJ et MG réunis : 63,4 %. La ville de São Paulo pèse environ 14,1 % du CA (1 856 067 BRL), Rio de Janeiro environ 7,2 % (949 363 BRL).
- **Interprétation** : l'activité est fortement concentrée géographiquement.
- **Implication** : l'entreprise dépend de trois États, et d'abord d'une seule ville.
- **Limite** : localisation du client, pas du vendeur. Un seul pays.

### G2. São Paulo gagne des parts de CA
- **Observation** : la croissance varie fortement d'un État à l'autre.
- **Donnée** (janvier-août 2018 contre 2017) : SP +170,5 %, DF +164,6 %, ES +161,7 %, MG +153,1 %, SC +145,7 %. RJ +104,5 %, RS +111,9 %, BA +114,7 %, GO +119,0 %. La part de SP passe de 36,1 % à 40,4 % du CA, celle de RJ de 14,3 % à 12,1 %.
- **Interprétation** : la croissance s'est concentrée davantage sur São Paulo qu'ailleurs.
- **Implication** : la dépendance à SP augmente.
- **Limite** : huit mois par année, les petits États ont des bases faibles.

### G3. États éloignés : panier plus élevé et frais de port plus lourds
- **Observation** : les États éloignés des trois premiers ont un profil différent.
- **Donnée** : panier moyen PB 218,09 BRL (516 commandes), AP 199,62, AL 199,00, AC 199,14, PA 184,06, contre 125,12 en SP. Poids des frais de port : RR 27,8 %, MA 26,2 %, RO 24,7 %, AM 24,5 %, contre 13,9 % en SP.
- **Interprétation** (hypothèse) : dans ces États, les clients n'achètent peut-être que des paniers plus importants.
- **Implication** : l'expérience de livraison y est plus coûteuse pour le client.
- **Limite** : très petits volumes (AP : 67 commandes, AC : 80), paniers moyens volatils. L'éloignement vendeur-client n'est pas analysé.
