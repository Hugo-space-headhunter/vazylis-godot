# Mesures de performances

Ce document garde la trace des mesures, pour comparer avant et après chaque optimisation.
Règle : une optimisation n'est « validée » que si elle a été mesurée, et sur l'iPhone quand c'est la cible.

## Comment mesurer

- **Dans le jeu** (PC ou iPhone) : toucher le compteur d'images par seconde en haut à gauche ouvre le détail :
  temps d'une image, des scripts et de la physique, appels de dessin, triangles, mémoire vidéo,
  monstres éveillés. Le retoucher le referme.
- **Sur le PC, automatiquement** : un petit script place le joueur à plusieurs endroits du monde
  et fait la moyenne sur 2 secondes (Godot 4.7.2, rendu Compatibility, fenêtre 938 × 787).

## Chantier A (30/10/2026) — mesuré sur le PC de Hugo

| Endroit | Appels de dessin | Triangles | Physique (avant → après) |
| --- | --- | --- | --- |
| Vazylis | 227 | 176 000 | 1,6 → 1,6 ms |
| Prés | 134 | 115 000 | 1,8 → 1,4 ms |
| Bois | 134 | 173 000 | 1,9 → 1,3 ms |
| Lisière | 138 | 205 000 | 2,1 → 1,8 ms |

- **Mémoire vidéo : 114 Mo → 47 Mo** (textures compressées pour la carte graphique, avec versions réduites pour le lointain).
- **Monstres éveillés** : 96 → 13 à 24 selon l'endroit (les autres dorment au-delà de 45 m).
- **Temps total d'une image sur le PC** : environ 9 à 10 ms, avec ou sans sommeil des monstres :
  sur ce PC, la différence n'est pas mesurable. Le gain est attendu sur l'iPhone, plus lent,
  et surtout avec les zones 2 à 5 (plus de 450 monstres) : **à mesurer sur l'iPhone**.
- **Version web** : 27 Mo → 49 Mo à télécharger la première fois (elle contient maintenant les textures
  compressées pour ordinateur et pour téléphone ; sans la version ordinateur, les textures
  s'affichent en noir dans un navigateur de PC). Ensuite, le jeu reste en cache sur l'iPhone.

## Chantier B (30/10/2026) — mesuré sur le PC, en portrait 720 × 1280

Ciel en dégradé, brouillard et lumière par zone, sol dessiné par un shader (taches, grain, chemin),
herbe semée par carreaux (MultiMesh, 16 triangles par touffe, masquée au-delà de 32 m) :

| Endroit | Appels de dessin | Triangles |
| --- | --- | --- |
| Vazylis | 394 | 219 000 |
| Prés | 287 | 169 000 |
| Bois | 243 | 218 000 |
| Ruines | 186 | 136 000 |
| Lisière | 133 | 159 000 |

Mémoire vidéo : 49 Mo. Version web : 49 Mo. **À mesurer sur l'iPhone.**

## Sur l'iPhone

iPhone de Hugo (écran 1170 × 2532, rendu à la pleine résolution 1170 × 2391), version web,
portrait, captures du 30/10/2026 après le chantier A :

| Endroit | Images/s | Image (ms) | Scripts (ms) | Appels de dessin | Triangles | Mémoire vidéo | Monstres éveillés |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Vazylis | 60 | 16,7 | 4 | 380 | 236 000 | 68 Mo | 12 / 96 |
| Prés (Pomelins) | 60 | 16,7 | 4 | 276 | 171 000 | 68 Mo | 17 / 96 |
| Bois des Lucioles | 60 | 16,7 | 7 | 250 | 190 000 | 68 Mo | 21 / 96 |
| Ruines du Guet (à l'entrée) | 58 | 17,2 | 53 (pointe passagère au changement de zone) | 197 | 175 000 | 68 Mo | 23 / 96 |
| Lisière pourpre | 59 | 16,9 | 5 | 81 | 61 000 | 68 Mo | 14 / 96 |

- **La cible des 60 images par seconde est atteinte partout** sur cet iPhone. L'écran est limité à 60 :
  16,7 ms par image est donc le plafond, et on ne connaît pas encore la marge restante.
- En portrait, la caméra voit plus loin vers le haut de l'écran : Vazylis dessine 380 appels (227 sur le PC en paysage).
  C'est l'endroit le plus chargé, à surveiller quand on ajoutera des décors (chantier B).
- Textures : affichage correct, rien de noir.
- À vérifier : la chauffe et la batterie sur une longue session (30 minutes de farm).
