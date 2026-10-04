# Recommandations business

**Principe** : chaque recommandation s'appuie uniquement sur des résultats de l'analyse (`business_insights.md`). Ce sont des **hypothèses à tester**, pas des certitudes. Les données (ni coûts, ni canaux d'acquisition, ni promotions) ne permettent pas d'estimer l'impact financier d'une action : les indicateurs de succès sont donc des indicateurs à mesurer lors d'un test.

---

## 1. Faits retenus

| # | Fait | Source |
|---|---|---|
| F1 | Janvier-août 2018 contre 2017 : CA +141,1 %, commandes +139,9 %, panier moyen +0,5 % | Q5 |
| F2 | Les nouveaux clients représentent environ 97 à 98 % des actifs mensuels en 2018 | C3 |
| F3 | Nouveaux clients mensuels : pic de 7 061 (novembre 2017), 6 843 en janvier 2018, 5 879 en juin 2018 | C2 |
| F4 | 97,0 % des clients n'ont acheté qu'une fois. Délai médian de réachat : 29 jours | C4, C5 |
| F5 | At Risk : 15,5 % des clients, 30,5 % du CA, 96 % à achat unique (13 892 clients) | RFM |
| F6 | Potential Loyalists : 36 263 clients à achat unique récent (38,7 % du CA) | RFM |
| F7 | Frais de port médians : 73,1 % de la valeur pour les commandes les moins chères, 6,4 % pour les plus chères | EDA |
| F8 | Catégories : baby +268,6 %, watches_gifts +242,0 %, health_beauty +210,3 %. cool_stuff +10,4 %, bed_bath_table +109,2 % | P5 |
| F9 | 24 novembre 2017 : 1 147 commandes, environ 4,7 fois la moyenne quotidienne du mois | V2 |
| F10 | SP, RJ et MG : 63,4 % du CA. SP passe de 36,1 % à 40,4 % du CA | G1, G3 |
| F11 | Aucun coût dans les données : pas de marge | dataset |

## 2. Interprétations

| # | Interprétation | S'appuie sur |
|---|---|---|
| I1 | La croissance de 2018 est portée par l'acquisition, pas par le panier ni par le réachat | F1, F2 |
| I2 | Le plateau du CA suit la stagnation de l'acquisition | F3 |
| I3 | La valeur d'un client se joue dans sa première commande | F4 |
| I4 | Un tiers du CA vient de clients à forte dépense initiale dont la fidélité n'est pas observée | F5 |
| I5 | Les frais de port sont un frein plausible sur les petites commandes (hypothèse) | F7 |
| I6 | Le mix du CA se déplace vers certaines catégories | F8 |
| I7 | La dépendance à São Paulo augmente | F10 |

## 3. Recommandations

### R1. Tester une action de réachat sur les clients récents
- **Pourquoi** : 36 263 clients à achat unique ont acheté il y a moins de 180 jours (F6), et seuls 3 % des clients rachètent (F4).
- **Action** : message post-achat envoyé à un échantillon, avec un groupe témoin. Fenêtre de test calée sur le délai médian observé (29 jours), observée sur environ 90 jours.
- **Indicateur** : taux de réachat sous 90 jours, groupe testé contre groupe témoin.
- **Limite** : aucun canal CRM ni historique de contacts dans les données. L'effet attendu est inconnu.

### R2. Tester une réactivation ciblée des clients de forte valeur inactifs
- **Pourquoi** : le segment At Risk pèse 30,5 % du CA avec 277,75 BRL par client (F5).
- **Action** : contacter un échantillon des 13 892 clients à achat unique supérieur à 109,90 BRL et inactifs depuis plus de 270 jours, avec un groupe témoin.
- **Indicateur** : réactivations supplémentaires par rapport au témoin, rapportées au coût de l'action. Le panier moyen de ce segment (261,02 BRL) donne l'ordre de grandeur du gain par réactivation.
- **Limite** : le taux de réachat de base est de 3 % (F4) : s'attendre à un effet modeste. Ces clients n'ont jamais montré de fidélité.

### R3. Diagnostiquer le ralentissement de l'acquisition
- **Pourquoi** : les nouveaux clients mensuels reculent d'environ 14 % entre janvier et juin 2018 (F3), alors que la croissance repose sur eux (F2).
- **Action** : collecter le canal d'acquisition et les dépenses marketing par mois, puis rapprocher ces données des nouveaux clients mensuels.
- **Indicateur** : nouveaux clients par canal et par mois, coût d'acquisition.
- **Limite** : ces données n'existent pas dans le dataset, donc aucune cause n'est établie à ce stade.

### R4. Tester des mesures sur les frais de port des petites commandes
- **Pourquoi** : pour les 10 % de commandes les moins chères, les frais médians valent 73,1 % de la valeur (F7).
- **Action** : tester un seuil de livraison gratuite ou une incitation à regrouper les achats, sur une partie du trafic.
- **Indicateur** : taux de conversion, panier moyen et nombre de petites commandes, groupe testé contre groupe témoin.
- **Limite** : le coût logistique supporté par l'entreprise est inconnu (seuls les frais facturés sont observés). Aucune donnée d'abandon de panier : l'effet sur la conversion est une hypothèse.

### R5. Piloter l'assortiment par dynamique de catégorie
- **Pourquoi** : certaines catégories accélèrent (baby, watches_gifts, health_beauty, housewares, telephony), d'autres croissent moins que la moyenne (cool_stuff +10,4 %, bed_bath_table +109,2 %) (F8).
- **Action** : examiner l'offre, les prix et la disponibilité de cool_stuff et bed_bath_table. Suivre trimestriellement le classement des catégories.
- **Indicateur** : croissance annuelle comparable par catégorie et variation de rang.
- **Limite** : le CA n'est pas une marge (F11). Ne pas pousser une catégorie sans connaître sa rentabilité.

### R6. Préparer les pics événementiels
- **Pourquoi** : le 24 novembre 2017 a concentré 1 147 commandes en un jour (F9).
- **Action** : dimensionner la capacité de traitement et le support sur la base du pic observé, avant les prochains événements.
- **Indicateur** : commandes par jour pendant le pic, délais de traitement et de livraison.
- **Limite** : les délais de livraison et la satisfaction pendant le pic n'ont pas été analysés dans ce projet. À étudier avant de dimensionner. Un seul événement observé.

## 4. Données à collecter pour aller plus loin

| Donnée manquante | Ce qu'elle permettrait |
|---|---|
| Coûts produits et logistiques | Calculer la marge, arbitrer R4 et R5 |
| Canal d'acquisition et dépenses marketing | Expliquer le ralentissement (R3) et calculer un coût d'acquisition |
| Historique des promotions | Établir (ou non) le lien entre le pic de novembre 2017 et une promotion |
| Localisation des vendeurs rapprochée de celle des clients | Analyser le lien entre distance et frais de port |

## 5. Ce que l'analyse ne permet pas de recommander

- **Une action fondée sur la marge** : aucun coût dans les données.
- **Une baisse ou une hausse de prix** : aucune donnée d'élasticité.
- **Un chiffrage de gain** : les tests proposés servent précisément à le mesurer.
