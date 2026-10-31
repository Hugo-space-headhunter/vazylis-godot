# Charte graphique de Vazylis

La référence visuelle du jeu, validée par Hugo le 30/10/2026 (chantier C de l'audit).
Tout nouvel asset doit la respecter ; un asset provisoire est marqué comme tel dans `ASSETS.md`.
Le document de game design reste la référence pour l'univers ; cette charte dit comment il doit **paraître**.

## 1. Style général

- **Low-poly stylisé, lisse et lisible**, dans la famille de Quaternius : des formes franches, peu de petits détails,
  une silhouette qu'on reconnaît de loin, même sur un écran de téléphone.
- **Des matières vraies plutôt que des aplats** : les sols, la pierre, le bois et l'écorce ont une vraie texture
  avec son relief (chantier B). Un modèle aux couleurs unies « façon Lego » doit recevoir une texture
  (réglage `texture_matiere` du catalogue) ou être remplacé.
- **Pas de réalisme photographique** : les textures restent douces et lisibles ; pas de détails plus fins qu'un pixel
  à 6 m de la caméra.
- **Les références** (Flyff, Warhammer, Metin2, Dofus, Levelup RPG) donnent des ambiances, jamais des formes à copier
  (voir la règle d'originalité du game design).

## 2. Proportions et silhouettes

- **Héros** : 1,8 m, proportions légèrement stylisées (mains et tête un peu plus grandes que nature à terme).
- **Monstres** : expressifs, une silhouette par rôle (rond et rebondissant, trapu et lent, fin et rapide…).
  Les petits monstres font 0,6 à 1,4 m.
- **Sous-boss** : 1,5 à 2,5 fois la taille d'un monstre de leur sous-zone, avec une aura au sol.
- **Décors** : à l'échelle réelle (porte 2,3 m, mur 3 m, arbre 5 à 8 m).
- **Tout repose au sol** : rien ne flotte, rien ne s'enfonce (sauf les buissons, enfoncés de 30 % pour que
  leur feuillage arrondi touche le sol).

## 3. Budgets pour le téléphone

| Élément | Triangles | Textures |
| --- | --- | --- |
| Héros (avec tenue) | 15 000 au plus | 1 024 px |
| Monstre | 1 000 à 6 000 | 512 px |
| Sous-boss | 15 000 au plus | 1 024 px |
| Arbre | 3 000 à 7 000 (masqué au-delà de 36 à 45 m) | 1 024 px, relief 512 px |
| Maison (fusionnée) | 5 000 au plus | 512 à 1 024 px |
| Petit décor | 2 000 au plus | partagée |
| Sol | — | 1 024 px, relief 512 px |

- Toutes les textures sont **compressées pour la carte graphique**, avec leurs versions réduites pour le lointain.
- Repères mesurés sur l'iPhone de Hugo : 60 images par seconde avec jusqu'à ~400 appels de dessin
  et ~240 000 triangles à l'écran (voir `docs/mesures-performances.md`).

## 4. Couleurs

Chaque zone a sa palette ; le monde s'assombrit et vire au pourpre en approchant de Trazake.

| Zone | Palette | Ambiance (scenes/zones/ambiances/) |
| --- | --- | --- |
| Vazylis | pierre claire, bois chaud, tuiles rouges, blanc et or des bannières | vallée claire |
| Prés de Vazylis | verts francs, ors chauds, terre beige | vallée claire : matin, soleil doré |
| Bois des Lucioles | verts profonds et bleutés, touches dorées des lucioles | sous-bois tamisé |
| Ruines du Guet | gris de pierre, ocre sec, verts éteints | ciel gris, brume froide |
| Lisière pourpre | bruns sombres, violets ternes | ciel et brume pourpres |

- **Le pourpre est réservé à la corruption de Trazake** (Lisière, monstres corrompus, sous-boss) : jamais sur un décor
  « sain » ni sur une rareté.
- **Le blanc lumineux est réservé à Vazylis et au rang transcendant.**
- Les couleurs de rareté (`config/raretes.cfg`) ne doivent pas se confondre avec celles d'une zone.

## 5. Lumière

- Un seul soleil, avec ombres jusqu'à 25 m ; une lumière ambiante plus froide qui éclaire les côtés à l'ombre.
- Un brouillard coloré par zone, plus épais en approchant de Trazake.
- Les gros décors (arbres, maisons, murs, buissons) projettent leur ombre ; les tout petits (fleurs, herbe, objets posés)
  n'en projettent pas.
- Pas de lumière dynamique en plus sans raison de gameplay (une lumière = du calcul en plus sur le téléphone).

## 6. Animations

- Chaque attaque a une **anticipation, un impact et un retour**. Les armes lourdes paraissent lourdes
  (épée et hache à deux mains tenues à deux mains, traînées en marchant, frappes lentes et massives).
- L'arc se bande vraiment (une main tire la corde).
- Chaque monstre a au minimum : repos, marche, course, attaque, coup reçu, mort.
- Les transitions entre animations sont fondues (pas de saut d'une pose à l'autre).

## 7. Effets visuels

- Lumineux et additifs, aux couleurs de la rareté ou de l'élément ; quelques dizaines de particules par effet au plus.
- Toujours un retour visible à l'impact (chiffre, éclat, secousse légère à venir).
- Les effets annoncent le danger (cercle rouge des attaques de zone) et la récompense (étincelles du butin, aura des champions).

## 8. Créations de Hugo et remplacement des assets

- Format glTF / GLB, 1 unité = 1 mètre, modèle tourné vers l'avant (+Z), origine aux pieds.
- Les personnages gardent le **même squelette** que les héros de base, pour partager animations et équipement.
- Pour remplacer un modèle, on ne change que sa ligne du catalogue (`assets/catalogue.cfg`) ; le jeu ne connaît
  que les identifiants.
- Licences : CC0 en priorité (Quaternius, KayKit, ambientCG) ; jamais d'asset payant ni à créditer sans l'accord de Hugo ;
  modèles Tripo gratuits pour le prototype seulement.

## 9. Inventaire des assets (31/10/2026)

**Conforme** : respecte la charte. **À retoucher** : on peut le rendre conforme sans le changer (teinte, texture, réglage).
**À remplacer** : un substitut ou un modèle provisoire, à remplacer par un modèle dédié (Tripo, création de Hugo, pack CC0).

| Famille | Assets | Verdict | Pourquoi |
| --- | --- | --- | --- |
| Héros | homme, femme (Quaternius) | Conforme | Bonne base ; le style des tenues reste à travailler (finition) |
| Tenues | paysan, rôdeur (Quaternius) | À retoucher | Correctes ; style par panoplie et mouvement des tissus à venir (finition) |
| Cape, collier, boucle d'oreille | générés par nos outils | À remplacer | Formes provisoires simples |
| Armes | épée, dague, claymore, hache (Polyy) | Conforme | Tenue en main à reprendre (finition des armes) |
| Bouclier, arc, flèche | générés par nos outils | À remplacer | Formes provisoires simples |
| Monstres des Prés et du Bois | Quaternius (Ultimate Monsters) | Conforme | Expressifs, dans le style |
| Gargouillon, Rat, Écuyer creux | Quaternius (substituts) | À remplacer | Ni gargouille, ni rat, ni armure vide |
| Pomelin noirci, Loup morbide, Villageois corrompu | Quaternius (teintés) | À retoucher | Épines, côtes visibles, tenue pourpre manquantes |
| Gardien, Krâg | personnage de base / orc (substituts) | À remplacer | Statue sans armure gothique ; Krâg sans sa lame-bras |
| Pomelin Royal, Gueule-Fleur | Quaternius (agrandis) | À retoucher | Couronne de feuilles et lianes manquantes |
| Forgeron | personnage de base | À retoucher | Sans tablier ni marteau |
| Maisons, chariot, barrière | Medieval Village Pack, fusionnés | Conforme | Texturés, dans le style |
| Murs, piliers, murets, dalles, éboulis | KayKit + pierre du pack village | Conforme | Aplats remplacés par de la vraie pierre (chantier B) |
| Tonneaux, caisses, fût, tables, tabourets, coffre | KayKit | À retoucher | Encore en aplats « jouet » ; leur donner du bois texturé |
| Bannières, torches | KayKit | À retoucher | Aplats ; tissu et métal à texturer |
| Arbres | bouleaux, arbres morts (Quaternius) | Conforme | Textures 1 024 px |
| Érables | Quaternius, feuillage rouge vif | À retoucher | Rouge saumon hors palette de la Vallée claire |
| Buissons, fleurs, herbe | Quaternius | Conforme | Buissons ancrés, herbe texturée (chantier B) |
| Sols | ambientCG | Conforme | Validés par Hugo (chantier B) |
| Enclume de la forge | formes simples | À remplacer | Provisoire |
| Cristal de Vazylis | généré par nos outils | À remplacer | Objet de test de l'étape 0 |
| Rochers | formes simples + texture de gravier | À retoucher | Sphères texturées ; de vrais rochers seraient mieux |
| Lucioles, brume, auras, cercles d'attaque | effets du jeu | Conforme | À embellir lors de la passe sur les effets |
