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

## Sur l'iPhone

À remplir avec les valeurs du panneau de mesure (Vazylis, Bois, Lisière).

| Date | Endroit | Images/s | Image (ms) | Mémoire vidéo | Monstres éveillés |
| --- | --- | --- | --- | --- | --- |
| | | | | | |
