# Segmentation RFM

**Périmètre** : 93 104 clients (`customer_unique_id`), commandes livrées, janvier 2017 - août 2018.
**Date de référence** : 1er septembre 2018.

## Méthode
- Récence : jours depuis la dernière commande, score 1 à 5 par seuils de percentiles (20/40/60/80 %). Seuils : 94, 179, 270, 383 jours.
- Fréquence : nombre de jours d'achat distincts, score 1 (1 jour), 2 (2 jours), 3 (3 jours et plus). Choix justifié par 784 clients dont toutes les commandes datent d'un même jour.
- Montant : CA cumulé hors frais de port, score 1 à 5 par seuils de percentiles. Seuils : 39,90 / 69,90 / 109,90 / 179,90 BRL.
- Seuils plutôt que `NTILE` : des clients ayant dépensé le même montant reçoivent toujours le même score.

## Règles de segments (ordre de priorité)
1. Champions : F >= 2, R >= 4, M >= 4
2. Loyal Customers : F >= 2, R >= 3
3. At Risk : R <= 2 et (F >= 2 ou M >= 4)
4. Potential Loyalists : F = 1, R >= 4
5. Lost Customers : F = 1, R <= 2, M <= 3
6. Occasional Customers : les autres clients

Les noms sont des étiquettes analytiques définies par ces règles, pas des catégories business établies.

## Résultats
| Segment | Clients | % clients | CA (BRL) | % CA | CA / client |
|---|---|---|---|---|---|
| Potential Loyalists | 36 263 | 38,9 % | 5 100 102 | 38,7 % | 140,64 |
| At Risk | 14 464 | 15,5 % | 4 017 320 | 30,5 % | 277,75 |
| Occasional Customers | 18 273 | 19,6 % | 2 399 119 | 18,2 % | 131,29 |
| Lost Customers | 22 671 | 24,4 % | 1 271 601 | 9,6 % | 56,09 |
| Champions | 833 | 0,9 % | 274 906 | 2,1 % | 330,02 |
| Loyal Customers | 600 | 0,6 % | 117 979 | 0,9 % | 196,63 |

## Limites
- 97 % des clients n'ont acheté qu'une fois : la fréquence ne distingue presque personne, et les segments « fidèles » sont très petits.
- 96 % du segment At Risk sont des clients à achat unique : le segment décrit des clients de forte valeur inactifs depuis plus de 270 jours, pas des clients dont on a observé la fidélité.
- Les clients récents n'ont pas eu autant de temps pour racheter que les autres : la comparaison entre segments est biaisée en faveur des segments récents.
- Les seuils sont des choix analytiques, modifier un seuil modifie les effectifs.
