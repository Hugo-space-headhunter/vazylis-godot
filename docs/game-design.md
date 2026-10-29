# Vazylis : Le Dernier Rempart — Game Design

Version du 26 octobre 2026 · Hugo Couasnon

## Vision et accroche

Un RPG mobile 3D de farm infini : on tue des monstres et des boss pour looter un équipement toujours meilleur, et cet équipement permet d'aller toujours plus loin. Pas de quêtes : la seule boucle est tuer → looter → s'améliorer → avancer.

- **Inspiration de départ** : Levelup RPG (farm infini, jouable à une main), avec un univers, un butin et des mécaniques propres.
- **Accroche** : un monde qui s'assombrit à mesure qu'on progresse, parce qu'on avance dans les terres déjà conquises par le tyran Trazake. La progression se voit autant qu'elle se ressent.
- **Objectif** : d'abord un prototype que Hugo joue au quotidien, améliore et enrichit en continu. Une fois satisfait : publication sur l'App Store, puis réflexion sur le multijoueur.
- **Nom** : Vazylis : Le Dernier Rempart (« Vazylis » est un nom inventé, sans occurrence trouvée en ligne ni sur l'App Store au 26 octobre 2026).

## Histoire du monde

Vazylis est le dernier rempart du royaume de Lenanta face aux armées de Trazake, un roi autoproclamé qui veut dominer tout le royaume.

- **Vazylis** : à l'origine un village calme, où les Vazyliens vivent de partage et d'une vie tranquille. C'est le village de départ et le centre du monde.
- **Trazake** : tyran à l'apparence de mutant inhumain, inspiré de l'esthétique sombre de science-fiction gothique, sans copier aucun design existant. Il est le boss le plus difficile du jeu.
- **Le joueur** : un Vazylien, homme ou femme, qui prend les armes pour devenir assez fort avant l'arrivée de Trazake.
- **La corruption** : plus on s'éloigne de Vazylis, plus on entre dans les terres déjà conquises par Trazake, donc plus le monde est sombre.
- **Le retour de Trazake** : il ne meurt jamais vraiment et revient plus fort à chaque assaut, ce qui justifie son donjon hebdomadaire.

**Pitch** : *Vazylis est le dernier rempart. Trazake approche. Chaque Vazylien doit tout donner pour devenir assez fort avant son arrivée. Prenons les armes !*

## Univers et direction artistique

Le style est une 3D low-poly stylisée, construite à partir de packs de modèles libres de droits (Quaternius, KayKit). Trois inspirations forment l'atmosphère générale du jeu et se mélangent partout, dès la première zone, sans reprendre de noms, personnages ou designs existants :

- **Flyff** : couleurs saturées, formes rondes et lisibles, monstres expressifs, un monde vivant.
- **Dark fantasy** : ruines, brume, morts-vivants, une menace diffuse, même dans les zones lumineuses.
- **Space Marine (Warhammer 40K)** : architecture gothique colossale, armures massives, crânes, étendards, reliques d'une technologie ancienne. Certains boss portent une vraie touche de science-fiction (armes à énergie).

Le mélange est permanent, seul le dosage évolue. Dans les premières zones, la couleur domine et le gothique apparaît en ruines, statues et vestiges. Plus on progresse, plus l'ombre et la corruption prennent le dessus.

### Règle d'originalité

Les trois univers sont des inspirations d'ambiance, jamais des sources à recopier. Cette règle s'applique à tout le contenu du jeu, et à tous les prompts donnés à Claude Code.

- **On reprend** : des ambiances, des palettes, des proportions (armures massives, monstres ronds), des motifs génériques du genre (crânes, étendards, gothique, brume).
- **On ne reprend jamais** : noms, factions, personnages, monstres signature, symboles ou emblèmes reconnaissables, designs d'armures ou d'armes identifiables, logos, textes.
- **Le test** : un joueur doit pouvoir dire « ça rappelle telle ambiance », mais jamais « c'est tel élément de tel jeu ».
- **L'identité propre** : le jeu crée ses propres noms, son propre bestiaire et ses propres emblèmes.

## Les 5 zones du monde ouvert

Le monde est une carte ouverte faite de 5 zones collées, parcourues à pied sans écran de chargement. On part de Vazylis, et chaque zone s'éloigne un peu plus vers les terres de Trazake. Chaque zone est un univers avec ses propres monstres et sous-boss, plus un donjon permanent.

| Zone | Niveaux | Ambiance | Monstres |
| --- | --- | --- | --- |
| 1. La Vallée claire | 1 à 40 | Prairies lumineuses et champignons géants, parsemés de ruines gothiques et de statues de chevaliers | Petites créatures mignonnes mais agressives |
| 2. La Forêt des Murmures | 41 à 80 | Bois sombres aux arbres immenses, autels ornés de crânes, lanternes | Centaures, elfes, hippogriffes, chauves-souris |
| 3. Les Marais du Deuil | 81 à 120 | Brume, ruines englouties d'une ancienne cathédrale | Morts-vivants, hydres |
| 4. Les Terres de Cendre | 121 à 160 | Volcans, forteresses noires hérissées d'étendards | Orcs, armée de Trazake |
| 5. La Cathédrale Brisée | 161 à 200 | Gothique colossal, reliques technologiques, ciel corrompu | Chevaliers noirs, élites mutantes |

### Sous-zones : la progression constante

Chaque zone couvre 40 niveaux et se découpe en **4 sous-zones de 10 niveaux**, enchaînées comme dans Flyff : en avançant dans la zone, les monstres montent progressivement en niveau. Le joueur a toujours, juste devant lui, des monstres un peu plus forts.

| Élément | Par sous-zone | Par zone |
| --- | --- | --- |
| Monstres différents | 3 (un par tranche d'environ 3 niveaux) | 12 |
| Sous-boss | 1, présent directement dans la sous-zone | 4 |
| Donjon permanent | — | 1, avec un boss final |

Ce découpage donne 60 monstres et 20 sous-boss pour les 5 zones.

### Au-delà du niveau 200

Le niveau est infini, mais le contenu ne peut pas l'être. Deux leviers : de nouvelles zones ajoutées au fil du temps, et le **donjon mythique de la Tour**, dont les étages peuvent monter en niveau sans fin pour offrir un défi permanent.

## Personnage et statistiques

Il n'y a pas de classe : tous les joueurs partent du même personnage standard, homme ou femme au choix à la création, et le style de jeu dépend de l'arme équipée.

| Statistique | Effet |
| --- | --- |
| Force | Dégâts |
| Agilité | Vitesse d'attaque et chance de coup critique |
| Vitalité | Points de vie et résistance |
| Intelligence | Points de mana (inutilisés dans le prototype, prévus pour la magie) |

Aux 4 statistiques de base s'ajoutent celles de l'équipement, ainsi que des bonus en pourcentage portés par les items : vitesse d'attaque, chance de coup critique, dégâts critiques, etc.

### Points de statistiques

- **4 points par niveau**, à répartir librement dans la fenêtre des statistiques (boutons + et −).
- **Une fois validés, les points sont définitifs.** Seul un **parchemin de réinitialisation**, très cher en or, permet de tout redistribuer.

### Affinités entre statistiques et armes

Toutes les statistiques servent, mais chaque arme en privilégie certaines. La Vitalité reste utile partout : tout miser sur l'attaque rend le personnage incapable d'encaisser.

| Arme | Style | Statistiques privilégiées |
| --- | --- | --- |
| Paire de dagues (une arme dans chaque main) | Rapide, coups moins forts | Agilité, puis Force |
| Arc | Mobile, tape vite à distance | Agilité, puis Force |
| Épée à deux mains | Lente, gros dégâts | Force, puis Vitalité |
| Hache à deux mains | Lente, gros dégâts | Force, puis Vitalité |
| Épée et bouclier | Équilibrée, résistante | Force et Vitalité |

### Effet précis de chaque point de statistique (valeurs de départ)

| Statistique | Effet par point | Plafond |
| --- | --- | --- |
| Force | +2 dégâts sur chaque coup | — |
| Agilité | +0,4 % de vitesse d'attaque et +0,1 % de chance de critique | Vitesse ×2,5 ; critique 60 % |
| Vitalité | +12 points de vie et +0,5 de défense | — |
| Intelligence | +5 points de mana (puissance des sorts plus tard) | — |

Chaque arme a une **statistique d'affinité** qui augmente ses dégâts de 0,3 % par point : l'Agilité pour les dagues et l'arc, la Force pour les armes à deux mains, la Vitalité pour l'épée et bouclier. La Force sert donc à tout le monde, mais chaque build a sa statistique fétiche.

| Arme | Vitesse de base | Dégâts de l'arme | Affinité | Particularité |
| --- | --- | --- | --- | --- |
| Paire de dagues | 1,6 coup/s | Faibles | Agilité | +10 % de chance de critique |
| Arc | 1,3 coup/s | Moyens | Agilité | Frappe à distance |
| Épée à deux mains | 0,8 coup/s | Élevés | Force | Dégâts critiques ×2 au lieu de ×1,5 |
| Hache à deux mains | 0,75 coup/s | Très élevés | Force | Ignore 15 % de la défense adverse |
| Épée et bouclier | 1,1 coup/s | Moyens | Vitalité | 10 % de chance de bloquer un coup, défense augmentée |

**Valeurs décidées à l'étape 3** (réglables dans le fichier de configuration) :

- **Dégâts de l'arme selon son type** : la formule des dégâts de l'arme est multipliée par ×0,65 pour les dagues (faibles), ×0,8 pour l'arc (moyens), ×1,35 pour l'épée à deux mains (élevés), ×1,45 pour la hache (très élevés) et ×0,9 pour l'épée et bouclier (moyens, un peu moins forte car plus résistante). Sans points de statistiques, toutes les armes ont ainsi une force proche : la différence vient des statistiques et des particularités.
- **Bloquer un coup** (épée et bouclier) : le coup est entièrement annulé. **Défense augmentée** : le bouclier apporte 2 de défense par niveau.
- **Mana** = 5 × Intelligence, sans base (la magie viendra plus tard).
- **Points de statistiques** : 0 au niveau 1, puis 4 à chaque niveau gagné ; les points non dépensés se gardent.
- **Calibrage des monstres** : il est fait sur un joueur « moyen », qui met 1 point dans chaque statistique à chaque niveau et porte une épée et bouclier standard de son niveau. Un build réfléchi tue donc plus vite que ce joueur moyen.
- **Nom du personnage** : « Vazylien » ou « Vazylienne » en attendant l'écran de création.

## Formules de combat (valeurs de départ)

Toutes les valeurs sont dans le fichier de configuration et se règlent en jouant.

- **Dégâts d'un coup** = (dégâts de l'arme + 2 × Force) × (1 + 0,3 % × statistique d'affinité) × (1 + bonus % des items et panoplies).
- **Dégâts de l'arme** = (10 + 3 × niveau de l'item) × multiplicateur de rareté, plus le bonus d'amélioration.
- **Coup critique** : chance = 5 % + 0,1 % × Agilité + bonus des items (plafond 60 %) ; dégâts ×1,5 (×2 à deux mains), plus les bonus de dégâts critiques.
- **Vitesse d'attaque** = vitesse de base de l'arme × (1 + 0,4 % × Agilité + bonus des items), plafonnée à ×2,5.
- **Points de vie** = 100 + 15 × niveau + 12 × Vitalité + bonus des items.
- **Défense** = armure des items + 0,5 × Vitalité.
- **Réduction des dégâts subis** = défense ÷ (défense + 50 × niveau de l'attaquant), plafonnée à 75 %.

### Calibrage des monstres

À niveau égal, avec un équipement adapté :

| Ennemi | Temps pour le tuer | Temps pour qu'il tue le joueur sans soin |
| --- | --- | --- |
| Monstre | Environ 10 secondes | Environ 60 secondes |
| Monstre champion | Environ 50 secondes | Environ 30 secondes |
| Sous-boss | Environ 1 minute | Environ 20 secondes |
| Boss de donjon de zone | Environ 3 minutes | Environ 15 secondes : il faut un meilleur équipement et plusieurs essais |

Un monstre plus haut que le joueur de plus de 5 niveaux frappe 5 % plus fort par niveau d'écart.

**Comment le calibrage se traduit en chiffres (décidé à l'étape 2, précisé à l'étape 3)** : la vie d'un monstre vaut les dégâts par seconde d'un joueur « moyen » de son niveau (voir les valeurs de l'étape 3) multipliés par le temps visé pour le tuer (10 secondes). Ses dégâts par seconde sont réglés pour qu'il tue ce joueur moyen, défense comprise, dans le temps visé (60 secondes). Les monstres passifs frappent 2 fois moins fort. Ces valeurs sont dans le fichier de configuration.

## Combat et modes de jeu

Le combat est en attaque automatique, comme dans Levelup RPG : au contact d'un monstre, le personnage frappe seul. Les compétences actives avec temps de recharge et la magie viendront après le prototype.

- **Mode déplacement** (bouton « pied ») : armes rangées, on se déplace sans engager les monstres.
- **Mode combat** (bouton « arme ») : armes sorties, le personnage attaque automatiquement les monstres qu'il approche ou sur lesquels il passe.
- **Mode AFK** (bouton à part, activé ou désactivé) : différent du mode combat, le personnage cible lui-même les monstres de la zone et les enchaîne sans intervention.
- **Soin** : mode de récupération des points de vie à préciser (potions, temps de recharge).

## Interface et commandes

Le jeu se joue à une main, en vertical comme en horizontal. L'écran reste le plus dégagé possible pour voir la carte.

### Ce qu'on voit à l'écran

- **En haut à gauche** : un petit bandeau compact avec le nom du personnage, son niveau, et les barres de vie, de mana et d'XP.
- **En bas à droite** : deux gros boutons, « arme » (mode combat) et « pied » (mode déplacement), et à côté un bouton AFK plus petit.
- **Mini-boutons** qui ouvrent des mini-menus en jeu :
  - **Sac à dos** : inventaire (voir ci-dessous) ;
  - **Statistiques** (icône des 4 éléments) : répartition des points avec + et − ;
  - **Familier** : le gérer, le nourrir, le faire évoluer ;
  - **Tour** : accès au donjon mythique ;
  - **Tour magique** : n'apparaît que le week-end, pour le donjon de Trazake ;
  - **Carte** et **Réglages**.

### Le menu Sac à dos

Un seul écran réunit tout ce qui touche à l'équipement :

- le personnage affiché avec son équipement porté ;
- l'inventaire en cases, façon sac à dos (esprit Flyff ou Dofus) ;
- le glisser-déposer d'un item sur le personnage pour le remplacer ;
- l'amélioration des items avec les ressources (+1 à +10) ;
- le recyclage, manuel ou programmé par filtres.

### Commandes

- **Joystick flottant** : il apparaît là où le pouce touche l'écran.
- **Caméra** : elle suit automatiquement le personnage. Elle peut aussi se tourner avec un deuxième doigt, en option.

## Retours visuels

Les effets apparaissent et disparaissent très vite, comme des notifications, sans jamais gêner le jeu.

- **Dégâts** : le chiffre de chaque coup s'affiche sur le monstre.
- **Butin** : pas de ramassage. À la mort du monstre, l'item apparaît brièvement dans la couleur de sa rareté, puis file dans l'inventaire.
- **Montée de niveau** : mention « Level Up », cercle lumineux au sol sous le personnage, et une aura d'énergie autour de lui pendant 1 seconde.
- **Équipement visible** : chaque arme et pièce d'armure portée se voit sur le personnage. C'est l'une des sources de satisfaction principales du jeu : vaincre un boss et se promener avec son épée.
- **Son et musique** : plus tard.

## Progression et expérience

Le niveau du personnage est infini. La difficulté monte progressivement : chaque niveau doit rester atteignable sans des jours de farm, et les donjons doivent être le moyen d'accélérer.

- **XP gagnée** = XP de base du monstre × coefficient d'écart de niveau :
  - monstre plus fort : environ +5 % par niveau d'écart, plafonné vers +50 % ;
  - même niveau : XP normale ;
  - monstre plus faible : environ −10 % par niveau d'écart, avec un minimum symbolique de 5 % de l'XP normale.
- **Exemple** : un monstre niveau 30 rapporte un peu plus que la normale à un personnage niveau 28, et presque rien à un personnage niveau 50.

### Rythme cible et courbe d'XP

Référence : environ 3 heures de jeu par soirée. Objectif : niveau 200 en environ 4 semaines, avec une montée rapide au début puis de plus en plus longue. Le temps cible pour passer un niveau L, en minutes :

```
t(L) = 0,5 + 0,084 × L^1,2
```

Soit environ 35 secondes au niveau 1 (4 monstres), 3,5 minutes au niveau 20, 22 minutes au niveau 100 et 49 minutes au niveau 200. Le temps fixe de 0,5 minute (2 minutes à l'origine) a été réduit le 29 octobre 2026 pour accélérer surtout les premiers niveaux.

| Repère | Niveau | Temps de jeu cumulé (environ) | Soirées de 3 h |
| --- | --- | --- | --- |
| Fin de la zone 1 | 40 | 2 h 30 | 1 |
| Fin de la zone 2 | 80 | 10 h 30 | 3 à 4 |
| Fin de la zone 3 | 120 | 25 h | 8 à 9 |
| Fin de la zone 4 | 160 | 47 h | 15 à 16 |
| Fin de la zone 5 | 200 | 75 h | 25 (environ 4 semaines) |

- **XP de base d'un monstre de niveau L** = 10 × L (10 XP au niveau 1, 100 XP au niveau 10).
- **XP requise pour un niveau** = temps cible × monstres tués par minute (environ 6, soit un toutes les 10 secondes) × XP de base d'un monstre de ce niveau.
- **Donjons** : ils rapportent plus d'XP par minute que le farm en zone, pour récompenser le risque.
- **Au-delà de 200** : la même formule continue, sans plafond.

## Équipement

Tout l'équipement se loote dans le monde, sauf les armes inédites vendues contre de l'or. Un même item (par exemple « Épée longue ») peut tomber dix fois avec des statistiques différentes, ce qui pousse à farmer pour obtenir le meilleur exemplaire.

### Emplacements

- **Armes** : main principale et main secondaire. La main secondaire accepte une dague, une épée à une main ou un bouclier. Une arme à deux mains occupe les deux.
- **Armure** : casque (toutes les coiffes), plastron, gants, bottes, ceinture, cape.
- **Bijoux** : un collier, deux boucles d'oreilles.
- **Slots spéciaux** : familier, étendard, accessoire de taille (voir plus bas).

### Armes du prototype

Paire de dagues, épée à deux mains, hache à deux mains, arc, épée et bouclier. Le type d'arme définit le style de jeu (vitesse, portée, dégâts).

### Raretés

| Rang | Multiplicateur de puissance | Bonus en % (proposition) | Où le trouver |
| --- | --- | --- | --- |
| Standard | ×1 | 0 | Monstres, sous-boss, boss de zone |
| Argenté | ×1,2 | 1 | Monstres, sous-boss, boss de zone |
| Doré | ×1,45 | 2 | Monstres, sous-boss, boss de zone |
| Épique | ×1,75 | 3 | Sous-boss, boss des donjons de zone |
| Mythique | ×2,1 | 4 | Boss final des donjons de zone, donjon mythique de la Tour |
| Transcendant | ×2,5 | 5 | Donjon mythique de la Tour, donjon de Trazake |

### Niveau et puissance d'un item

Le niveau d'un item suit celui du monstre ou du donjon qui le donne, sans limite. Sa puissance vaut **niveau × multiplicateur de rareté**, plus le bonus d'amélioration (+1 à +10). Un transcendant niveau 50 (puissance 125) surpasse donc un standard niveau 80 (80), puis se fait dépasser par un épique niveau 110 (192). Les multiplicateurs seront ajustés en jouant.

### Apparence des items

Tout l'équipement porté est visible sur le personnage, homme ou femme.

- **Prototype** : un modèle 3D par famille d'items (par exemple « Épée longue », « Hache runique »), décliné par rareté avec une couleur et un éclat propres. Un doré brille, un transcendant porte une aura.
- **À terme** : plusieurs designs par type d'arme, avec des esthétiques variées.

## Esthétique de l'équipement

Le style est héroïque, façon World of Warcraft : épaules, capes et armes affirmées, mais proportionnées. Ce qu'on loote est exactement ce qu'on voit sur le personnage, avec le reste de son équipement.

### Lecture de la rareté

| Rang | Rendu |
| --- | --- |
| Standard | Matériaux bruts, gris et brun, sans effet |
| Argenté | Métal poli, reflets argent |
| Doré | Liserés et garde dorés, léger éclat |
| Épique | Métal bleu sombre, runes bleues lumineuses |
| Mythique | Rouge profond et or, halo discret |
| Transcendant | Blanc lumineux et or pâle, aura autour de l'arme et du personnage |

Le violet est volontairement exclu des raretés : le pourpre est la couleur de la corruption de Trazake. Le transcendant, blanc et lumineux, incarne la lumière de Vazylis.

### Style selon la zone d'origine

Un item ressemble à la zone qui l'a lâché : on sait d'où vient un équipement en le regardant.

| Zone | Style des items |
| --- | --- |
| 1. La Vallée claire | Rustique vazylien : bois, fer, cuir |
| 2. La Forêt des Murmures | Sylvestre : bois sculpté, motifs elfiques |
| 3. Les Marais du Deuil | Funéraire : os, fer noir |
| 4. Les Terres de Cendre | Massif et brûlant : forge orque, braises incrustées |
| 5. La Cathédrale Brisée | Gothique noble : ornements, reliques technologiques |

La silhouette grandit avec le niveau : tenue modeste au début, épaulières imposantes, capes amples et armes plus grandes en fin de jeu. Pour le prototype : 5 types d'armes × 5 zones = 25 familles d'armes, chacune déclinée dans les 6 raretés.

### Cosmétiques et armes inédites

- **Cosmétiques** (achetés en or) : visibles en plus de l'équipement, ils donnent des statistiques supplémentaires.
- **Armes inédites** (boutique, très chères) : un look unique et reconnaissable, avec un effet spécial qu'aucune arme lootée ne possède.
- **Vision lointaine** : rendre certains cosmétiques payants en euros, avec des bonus exclusifs. Point à réfléchir avant une publication : les bonus payants sont souvent mal perçus par les joueurs (« pay-to-win »).

## Panoplies et bonus

Chaque sous-boss et chaque boss de donjon a sa panoplie. Porter plusieurs pièces d'une même panoplie débloque des bonus par paliers, et la panoplie complète ajoute un effet spécial unique. On peut mélanger plusieurs panoplies incomplètes pour cumuler leurs premiers paliers, comme dans Dofus : c'est là que se construisent les builds. Les pièces d'une panoplie partagent un même style visuel. Certains items n'appartiennent à aucune panoplie.

| Source | Nombre de pièces | Paliers de bonus |
| --- | --- | --- |
| Sous-boss | 3 ou 4 pièces | 2 pièces, puis panoplie complète |
| Boss de donjon de zone | 6 pièces (raretés jusqu'à mythique) | 2, 4 et 6 pièces |
| Boss de la Tour, Trazake | 6 pièces | 2, 4 et 6 pièces, effets les plus puissants |

- **Trois orientations par zone** : chaque zone propose des panoplies pour l'Agilité (dagues, arc), la Force (armes à deux mains) et la Vitalité (épée et bouclier).
- **Types de bonus** : statistiques fixes au premier palier, bonus en % au palier suivant, effet spécial à la panoplie complète.
- **Puissance** : les bonus suivent le niveau de la panoplie (celui de son sous-boss ou de son donjon), quelle que soit la rareté des pièces.

### Exemple : les panoplies de la zone 1

| Panoplie | Source | Pièces | Orientation | Bonus |
| --- | --- | --- | --- | --- |
| Couronne du Verger | Pomelin Royal | Coiffe, ceinture, bottes | Vitalité (débutant) | 2 pièces : +15 Vitalité · 3 pièces : +5 % de points de vie et **Regain** (régénère 1 % de vie par seconde hors combat) |
| Épines de la Gueule-Fleur | Gueule-Fleur | Gants, bottes, cape, boucle d'oreille | Agilité | 2 pièces : +15 Agilité · 4 pièces : +6 % de vitesse d'attaque et **Épines** (renvoie 10 % des dégâts reçus) |
| Rempart du Guet | Gardien sans visage | Casque, plastron, gants, ceinture | Vitalité et défense | 2 pièces : +20 Vitalité · 4 pièces : +8 % de défense et **Bastion** (15 % de chance de bloquer entièrement un coup) |
| Lame de Krâg | Krâg le Mutilé | Casque, plastron, cape, collier | Force | 2 pièces : +15 Force · 4 pièces : +8 % de dégâts et **Rage** (+20 % de dégâts sous 50 % de vie) |
| Armure de Morvhal | Donjon : Crypte du Guet | Casque, plastron, gants, bottes, ceinture, cape | Force et Vitalité | 2 pièces : +25 Force · 4 pièces : +10 % de dégâts critiques · 6 pièces : **Serment brisé** (chaque coup a 5 % de chance de déclencher une onde qui frappe les ennemis proches) |

Les panoplies des zones 2 à 5 suivront le même modèle, avec des valeurs plus élevées.

## Ressources, amélioration et recyclage

Les monstres lâchent des items et des ressources. Les ressources servent à améliorer les items de +1 à +10.

### Les 4 familles de matériaux

Chaque famille a des paliers qui suivent le niveau des zones (par exemple fer, puis bronze, puis bauxite).

| Famille | Exemples | Sert à améliorer | Où la trouver |
| --- | --- | --- | --- |
| Minerais | Fer, bronze, bauxite | Armes en métal, armures lourdes | Monstres |
| Bois | Chêne, frêne | Arcs, manches d'armes | Monstres |
| Peaux | Cuir | Armures légères : gants, bottes, ceinture, cape | Monstres |
| Pierres précieuses | Rubis | Paliers élevés, items mythiques et transcendants | Boss de donjon (pas les sous-boss) |

### Taux de réussite de l'amélioration (proposition)

Un échec fait perdre les matériaux utilisés, jamais le niveau d'amélioration.

| Palier | Réussite | Difficulté |
| --- | --- | --- |
| +1 et +2 | 100 % | Garantie |
| +3 | 90 % | Facile |
| +4 | 80 % | Facile |
| +5 | 70 % | Facile |
| +6 | 45 % | Difficile |
| +7 | 35 % | Difficile |
| +8 | 20 % | Très difficile |
| +9 | 12 % | Très difficile |
| +10 | 6 % | Très difficile |

### Recyclage

Les items inutiles se recyclent en matériaux et en or. Un **recyclage automatique** réglable par filtres (par exemple « tout ce qui est en fer », « tout ce qui est sous le rang doré ») évite que le mode AFK remplisse l'inventaire.

## Familier, étendard et accessoire de taille

Ces trois slots apportent des statistiques complémentaires. Ils ne se lootent pas sur les monstres standards. Le familier fait partie du prototype, avec son propre bouton pour le gérer et le nourrir. L'étendard et l'accessoire de taille ont leur slot dès le prototype, mais restent vides au départ.

- **Familier** : il donne des bonus de statistiques et évolue grâce à des ressources dédiées, lâchées par les sous-boss avec un bon taux de drop. C'est le seul moyen de le faire évoluer. Son apparence change trois fois : jeune, senior, mature.
- **Étendard** : bonus de statistiques, dans l'esprit des étendards de Warhammer. Mode d'obtention à définir.
- **Accessoire de taille** : objet porté à la ceinture (chaîne de crânes, montre à gousset…) qui donne des statistiques. Mode d'obtention à définir.

## Monstres, sous-boss et boss

Chaque zone compte 12 monstres et 4 sous-boss, répartis dans ses sous-zones. Les sous-boss sont présents directement dans la zone, comme dans Flyff. Les vrais boss sont au bout des donjons.

- **Inspirations** : un mélange des bestiaires de Flyff, World of Warcraft, Warhammer et Metin2. On s'inspire, on ne copie pas (voir la règle d'originalité).
- **Variantes** : un même modèle 3D se décline en plusieurs monstres (couleur, taille, accessoires), ce qui permet un grand bestiaire avec des packs gratuits.

| Type | Où | Réapparition | Ce qu'il lâche |
| --- | --- | --- | --- |
| Monstre | Sous-zones | Rapide, environ 8 secondes (à régler) | Items, minerais, bois, peaux |
| Sous-boss | Sous-zones, en monde ouvert | Environ 5 minutes | Items jusqu'à épique, ressources de familier |
| Boss de donjon de zone | Fin du donjon de chaque zone | À chaque passage du donjon | Items jusqu'à mythique, pierres précieuses |
| Boss de la Tour | Donjon mythique | À chaque passage | Items jusqu'à transcendant, pierres précieuses |
| Trazake | Donjon du week-end | Une fois par semaine | Le meilleur butin du jeu |

## Tables de loot (proposition de départ)

Le butin repose sur trois étages : les monstres assurent un flux constant avec une chance de « jackpot » à chaque mort, les sous-boss sont des rendez-vous réguliers, les donjons sont les grands objectifs. Chaque ligne est un **tirage indépendant** : un monstre peut ne rien lâcher, ou plusieurs items d'un coup.

| Source | Standard | Argenté | Doré | Épique | Mythique | Transcendant | Ressources |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Monstre | 8 % | 3 % | 0,5 % | 0,05 % | — | — | 35 % (1 à 3 unités) |
| Monstre champion (1 sur 200) | — | 100 % | 100 % | 3 % | — | — | 100 % |
| Sous-boss | — | 100 % | 30 % | 5 % | — | — | 100 %, plus 60 % de ressources de familier |
| Boss de donjon de zone | — | — | 50 % | 25 % | 100 % (un item) | — | 100 %, avec pierres précieuses |
| Boss de la Tour | — | — | — | 50 % | 100 % | 3 % | 100 %, avec pierres précieuses |
| Trazake | — | — | — | — | 100 % | 100 % | 100 %, avec pierres précieuses |

### Mécaniques de motivation

- **Qualité de l'item** : chaque statistique est tirée entre 70 % et 100 % de son maximum (selon la rareté et le niveau). L'item affiche sa qualité ; un item à 100 % porte un éclat spécial.
- **Garantie anti-malchance** : sans doré depuis 250 monstres, le suivant est garanti doré ; sans épique depuis 2 000 monstres, le suivant est garanti épique ; un sous-boss lâche un épique au plus tard à sa 12e victoire sans épique. Le compteur repart à zéro à chaque obtention.
- **Monstres champions** : un monstre sur 200 apparaît en version champion (plus gros, aura, 5 fois plus de vie et d'XP).
- **Panoplies ciblées** : chaque sous-boss et chaque boss de donjon a sa propre liste d'items et de pièces de panoplie, pour donner des cibles de farm précises.
- **Niveau du butin** : un item a le niveau du monstre qui le lâche, ce qui pousse à farmer la bonne sous-zone.
- **Mode AFK** : mêmes taux qu'en jeu actif.

### Ce que ça donne sur une soirée de 3 heures (environ)

Avec 6 monstres tués par minute et une quinzaine de sous-boss : environ 85 standards, 50 argentés, 15 dorés et 1 à 2 épiques, sans compter les donjons. Ces valeurs se règlent dans le fichier de configuration pendant le prototype.

## Bestiaire

Chaque zone suit l'avancée vers les terres de Trazake : créatures sauvages d'abord, puis morts-vivants, puis son armée, puis sa garde rapprochée. Tous les noms et designs sont originaux.

| Zone | Types de monstres principaux | Logique |
| --- | --- | --- |
| 1. La Vallée claire (1–40) | Passifs gothiques, gobelin, plante géante, loup morbide, humain corrompu | Du paisible au premier contact avec les troupes de Trazake |
| 2. La Forêt des Murmures (41–80) | Centaure, elfe maléfique, hippogriffe, chauve-souris à trois têtes | Créatures sauvages gagnées par Trazake |
| 3. Les Marais du Deuil (81–120) | Goule, squelette archer, hydre, nécromancien, kraken (boss) | Le royaume des morts et de l'eau |
| 4. Les Terres de Cendre (121–160) | Orc commandant de guerre et ses troupes, humains corrompus d'élite | L'armée de Trazake en marche |
| 5. La Cathédrale Brisée (161–200) | Chevaliers noirs, nécromanciens supérieurs, élites mutantes | Le cœur gothique du pouvoir de Trazake |

- **Monstres passifs** : ils n'attaquent pas tant qu'on ne les frappe pas. Ils peuplent le début de la zone 1.
- **Variantes** : chaque type se décline en plusieurs monstres (par exemple gobelin chapardeur, gobelin chaman, gobelin chef).

### Zone 1 — La Vallée claire (niveaux 1 à 40)

Des prés mignons-macabres autour de Vazylis, les ruines d'une forteresse gothique, puis la lisière pourpre où la corruption commence.

| Sous-zone | Monstre | Apparence | Comportement |
| --- | --- | --- | --- |
| Les Prés de Vazylis (1–10) | Cochonnet de suie | Cochon de lait noir, yeux rouges, queue en tire-bouchon | Passif, riposte faiblement |
| | Corbac | Corbeau trapu aux plumes en lambeaux | Passif, sautille, pique si attaqué |
| | Pomelin | Petite boule-fruit sombre aux joues rondes | Rebondit vers le joueur et charge |
| | **Sous-boss : Pomelin Royal** | Pomelin géant couronné de feuilles noires | Invoque des Pomelins |
| Le Bois des Lucioles (11–20) | Gobelin chapardeur | Petit gobelin en haillons, sac sur le dos | Rapide, frappe puis recule |
| | Ronce-gueule | Jeune plante carnivore aux lianes épineuses | Immobile, fouette à portée |
| | Gobelin chaman | Gobelin couvert d'os et de plumes | Lance des boules vertes à distance |
| | **Sous-boss : Gueule-Fleur** | Plante géante carnivore, corolle pourpre | Ancrée au sol, attaque en zone avec ses lianes |
| Les Ruines du Guet (21–30) | Gargouillon | Petite gargouille de pierre, ailes trop courtes | Très résistant, frappe lentement |
| | Rat des cryptes | Rat massif aux yeux rouges | Attaque en groupe |
| | Écuyer creux | Armure vide animée, épée rouillée | Pare parfois les coups |
| | **Sous-boss : le Gardien sans visage** | Statue de chevalier gothique qui s'éveille, grand bouclier | Bloque de face, frappe en zone |
| La Lisière pourpre (31–40) | Pomelin noirci | Le Pomelin, devenu noir, épines et yeux violets | Agressif, charge en meute |
| | Loup morbide | Loup décharné, côtes visibles, pelage fumant | Rapide, encercle le joueur |
| | Villageois corrompu | Humain d'un hameau voisin, veines pourpres, outils en guise d'armes | Premier humain passé à Trazake |
| | **Sous-boss : Krâg le Mutilé** | Chef éclaireur mutant, un bras remplacé par une lame | Enrage sous la moitié de sa vie |

**Donjon — La Crypte du Guet (niveau 40)** : accès par un tourbillon dans les Ruines du Guet. Boss final : **Morvhal, le Chevalier déchu**, ancien protecteur de Vazylis corrompu par Trazake, grande armure gothique fissurée et lueur violette. Il lâche les premiers mythiques du jeu.

### Zone 2 — La Forêt des Murmures (niveaux 41 à 80)

Une forêt immense aux arbres colossaux, où les créatures sauvages sont tombées une à une sous l'influence de Trazake.

| Sous-zone | Monstre | Apparence | Comportement |
| --- | --- | --- | --- |
| L'Orée sombre (41–50) | Chiroptère tricéphale | Petite chauve-souris à trois têtes | Attaque en piqué, puis remonte |
| | Gobelin des fourrés | Gobelin camouflé de feuilles, arc court | Tire à distance, se cache |
| | Mousse-rôdeur | Créature de mousse et d'écorce, yeux luisants | Lent, très résistant |
| | **Sous-boss : Chef Mâchefer** | Gobelin chef monté sur un sanglier cuirassé | Charge, puis appelle des gobelins |
| La Clairière des Centaures (51–60) | Centaure éclaireur | Centaure léger, arc long, peintures de guerre | Garde ses distances et tire |
| | Centaure lancier | Centaure massif, lance et bouclier | Charge à travers le terrain |
| | Cerf spectral | Cerf aux bois de branches mortes, lueur bleutée | Rapide, coups de bois en zone |
| | **Sous-boss : Varnhorn, Seigneur des sabots** | Centaure colossal, peintures pourpres de Trazake | Alterne charges et volées de flèches |
| Les Nids des Hauteurs (61–70) | Hippogriffon | Jeune hippogriffe au plumage gris | Agile, attaque du bec |
| | Hippogriffe sauvage | Hippogriffe adulte, serres immenses | Plonge depuis le ciel |
| | Chiroptère tricéphale adulte | Grande chauve-souris à trois têtes | Cri qui étourdit brièvement |
| | **Sous-boss : Sélénoir** | Hippogriffe au plumage noir, yeux violets | Rafales de vent, plongeons répétés |
| Le Bosquet des Elfes noirs (71–80) | Elfe maléfique archère | Elfe pâle, armure de feuilles noires | Tirs précis à longue portée |
| | Elfe maléfique lame-double | Elfe vêtue de cuir, une dague dans chaque main | Très rapide, frappe en rafale |
| | Elfe maléfique tisseuse | Elfe en robe, bâton de ronces | Soigne les autres elfes |
| | **Sous-boss : Ysmira, Dame des Ronces** | Sorcière elfe couronnée d'épines | Fait jaillir des ronces du sol |

**Donjon — Le Cœur Pourri (niveau 80)** : accès par un tourbillon au pied du plus vieil arbre de la forêt. Boss final : **Vieil-Écorce**, arbre gigantesque corrompu, ultime évolution de la plante géante.

### Zone 3 — Les Marais du Deuil (niveaux 81 à 120)

Brume, eaux noires et ruines englouties : le royaume des morts relevés par les nécromanciens de Trazake.

| Sous-zone | Monstre | Apparence | Comportement |
| --- | --- | --- | --- |
| Les Tourbières (81–90) | Goule rampante | Goule maigre à quatre pattes, mâchoire démesurée | Rapide, attaque en meute |
| | Crapaud pustuleux | Énorme crapaud couvert de pustules | Crache un poison qui ronge la vie |
| | Feu follet | Petite flamme verdâtre flottante | Fonce sur le joueur et explose |
| | **Sous-boss : Gorgemort** | Goule obèse, chaînes brisées aux poignets | Dévore les goules proches pour se soigner |
| Le Cimetière noyé (91–100) | Squelette archer | Squelette en armure rouillée, arc d'os | Tire à distance, recule |
| | Squelette fantassin | Squelette au bouclier fendu | Avance en ligne, pare les coups |
| | Goule affamée | Goule en haillons de fossoyeur | Frappe vite, s'acharne |
| | **Sous-boss : Maître Ossvald, nécromancien** | Robe noire, crâne en guise de lanterne | Relève les squelettes tombés autour de lui |
| La Rivière morte (101–110) | Hydrillon | Jeune hydre à deux têtes | Mord avec les deux têtes |
| | Anguille-lame | Anguille aux nageoires tranchantes | Surgit de l'eau, frappe, replonge |
| | Noyé | Humain corrompu gonflé d'eau, algues sur le corps | Lent, frappes lourdes |
| | **Sous-boss : Hydrevase** | Hydre ancienne à cinq têtes | Chaque tête attaque séparément |
| L'Abbaye engloutie (111–120) | Squelette archer d'élite | Squelette en armure gothique, arc noir | Tirs perçants |
| | Moine-goule | Goule en robe de moine, chapelet d'os | Maudit le joueur (ralentissement) |
| | Spectre de cloche | Silhouette translucide portant une cloche | Sonne : étourdit brièvement |
| | **Sous-boss : Le Sonneur** | Spectre géant enchaîné à une cloche de bronze | Ondes sonores en zone |

**Donjon — Le Lac des Profondeurs (niveau 120)** : accès par un tourbillon au centre d'un lac noir. Boss final : **Ulgoth, le Kraken**, tentacules surgissant de toutes parts autour d'une plateforme de ruines.

### Zone 4 — Les Terres de Cendre (niveaux 121 à 160)

Plaines calcinées, volcans et forges : ici marche l'armée de Trazake. Les premières touches de science-fiction apparaissent dans ses machines.

| Sous-zone | Monstre | Apparence | Comportement |
| --- | --- | --- | --- |
| Les Champs calcinés (121–130) | Orc pillard | Orc trapu, hachette et peaux | Frappe vite, en groupe |
| | Chien de cendre | Loup morbide aux braises incrustées dans le dos | Morsures qui brûlent |
| | Captif corrompu | Humain enchaîné, collier de métal pourpre | Désespéré, frappe sans relâche |
| | **Sous-boss : Porte-Bannière Grul** | Orc géant portant l'étendard de Trazake | Renforce les orcs autour de lui |
| Le Camp de guerre (131–140) | Orc berserker | Orc torse nu, deux haches | Enrage quand il est blessé |
| | Orc archer | Orc à l'arc lourd, flèches enflammées | Tire depuis les palissades |
| | Gobelin artificier | Gobelin chargé de bombes artisanales | Lance des explosifs |
| | **Sous-boss : Gorvak Brise-Rempart, commandant de guerre** | Orc colossal en armure de guerre, énorme marteau | Frappes au sol qui projettent le joueur |
| Les Forges de Trazake (141–150) | Golem de scories | Golem de métal fondu, fissures incandescentes | Lent, très résistant |
| | Forgeron corrompu | Humain musculeux, marteau rougeoyant | Frappes lourdes |
| | Diablotin de braise | Petit démon de feu | Rapide, laisse des flammes au sol |
| | **Sous-boss : Maître-Forge Vulk** | Mutant au bras-marteau mécanique, tubes lumineux | Marteau à énergie, ondes de choc |
| Le Bastion noir (151–160) | Soldat mutant | Mutant en armure de plaques noires | Discipliné, attaque en formation |
| | Chiroptère de feu | Chauve-souris à trois têtes enflammée | Piqués enflammés |
| | Orc d'élite | Orc en armure noire aux crânes gravés | Bloque, puis contre-attaque |
| | **Sous-boss : Capitaine Drass** | Mutant en armure lourde, canon à énergie sur l'épaule | Tirs à distance chargés |

**Donjon — La Fournaise (niveau 160)** : accès par un tourbillon dans la gueule d'un volcan. Boss final : **le Colosse de Fonte**, machine de guerre ancienne pilotée par un mutant.

### Zone 5 — La Cathédrale Brisée (niveaux 161 à 200)

Une cathédrale-forteresse colossale, place forte de Trazake : gothique massif, reliques technologiques et ciel corrompu.

| Sous-zone | Monstre | Apparence | Comportement |
| --- | --- | --- | --- |
| Le Parvis (161–170) | Chevalier noir | Armure gothique noire, épée longue | Équilibré, pare et riposte |
| | Gargouille ancienne | Le Gargouillon devenu adulte, ailes immenses | Fond du ciel, très résistante |
| | Pénitent corrompu | Humain encapuchonné, chaînes et flagellum | Se blesse pour frapper plus fort |
| | **Sous-boss : le Héraut noir** | Chevalier noir géant portant la bannière de Trazake | Renforce les chevaliers proches |
| La Nef (171–180) | Chevalier noir lancier | Armure noire, lance à pointe lumineuse | Charge en ligne droite |
| | Statue animée | Statue de saint aux yeux pourpres | Immobile jusqu'à ce qu'on approche |
| | Acolyte nécromant | Humain en robe, livre d'os | Relève les morts, à abattre en priorité |
| | **Sous-boss : Archidiacre Vel'Moor** | Nécromancien supérieur, crosse surmontée d'un crâne | Invoque des vagues de squelettes |
| Le Cloître (181–190) | Lame d'ombre | Elfe maléfique d'élite, masque noir | Disparaît puis frappe dans le dos |
| | Spectre de chevalier | Chevalier translucide | Traverse les obstacles |
| | Goule cuirassée | Goule enfermée dans une armure rivetée | Lente, frappes très lourdes |
| | **Sous-boss : Sœur Morne** | Inquisitrice humaine corrompue, épée flamboyante | Alterne frappes et malédictions |
| Le Chœur (191–200) | Garde mutant de Trazake | Mutant en armure lourde, technologie ancienne | Bouclier d'énergie frontal |
| | Chevalier noir d'élite | Armure noire ornée d'or terni | Combos rapides |
| | Abomination | Fusion de plusieurs corps corrompus | Imprévisible, frappe en zone |
| | **Sous-boss : le Bourreau de Trazake** | Colosse masqué, hache à deux mains gigantesque | Exécute : dégâts énormes sous 30 % de vie |

**Donjon — Le Reliquaire (niveau 200)** : accès par un tourbillon au centre du chœur. Boss final : **l'Archonte déchu**, ancien saint de Lenanta corrompu par Trazake, armure gothique incrustée de reliques technologiques.

**Trazake** et les monstres exclusifs de la Tour mythique seront définis séparément.

### Familles de modèles 3D et faisabilité en version gratuite

Le bestiaire repose sur une dizaine de familles de modèles, chacune déclinée en variantes (couleur, taille, accessoires, armes).

| Famille | Monstres concernés | Faisabilité en gratuit (estimation) |
| --- | --- | --- |
| Humanoïdes | Gobelins, humains corrompus, mutants, elfes, orcs, nécromanciens, chevaliers noirs, pénitents | Facile : une même base animée, habillée différemment |
| Morts-vivants | Squelettes, goules, écuyer creux, spectres | Facile : très courants dans les packs gratuits |
| Petites créatures | Cochonnet, corbac, Pomelin, rat, crapaud, feu follet, diablotin | Facile : formes simples |
| Quadrupèdes | Loup morbide, chien de cendre, cerf spectral, sanglier | Facile à moyen |
| Plantes | Ronce-gueule, Gueule-Fleur, mousse-rôdeur, Vieil-Écorce | Moyen |
| Pierre et métal | Gargouillon, gargouille, Gardien, statue, golem | Moyen |
| Volants | Chiroptères, hippogriffes | Moyen à difficile |
| Créatures rares | Centaures, hydres, Kraken, abomination, Colosse de Fonte | Difficile : versions simplifiées ou modèles provisoires, prioritaires pour le budget payant |

La zone 1 utilise presque uniquement des familles faciles : elle peut être construite entièrement en gratuit, et servir de vitrine avant d'investir.

## Donjons

Il existe trois sortes de donjons. Leur accès est libre, sans limite d'entrées : la seule barrière est la difficulté.

| Donjon | Accès | Contenu | Butin phare |
| --- | --- | --- | --- |
| Donjon de zone (un par zone, permanent) | Portail dans la zone : le personnage tombe dans un tourbillon qui le téléporte à l'intérieur | Monstres et sous-boss de la zone, puis un boss final | Mythique sur le boss final |
| Donjon mythique | Bouton « Tour » du menu | Monstres, sous-boss et boss exclusifs, introuvables dans les zones | Mythique et transcendant |
| Donjon de Trazake | Bouton « Tour magique », affiché uniquement le week-end (à partir du samedi minuit) | Tous les sous-boss et boss du jeu, puis Trazake | Le meilleur butin du jeu |

- **Paliers** : chaque donjon a un niveau et plusieurs niveaux de difficulté. Ses items ont le niveau du donjon. Un donjon de zone est conçu pour demander plusieurs essais et un meilleur équipement.
- **Structure** : des étages ou salles successifs, jusqu'au boss final.
- **Trazake** : le boss le plus dur du jeu. Le battre demande un équipement optimisé et un niveau élevé.
- **Mort en donjon** : retour à la première salle, sans perte de progression du personnage.

## Économie et mort

L'or s'obtient surtout par le recyclage. Comme presque tout se loote, il sert d'abord à acheter :

- des **cosmétiques**, visibles en plus de l'équipement et qui donnent des statistiques supplémentaires ;
- des **armes inédites**, très chères, qui sont le seul équipement qu'on ne peut pas looter, au look unique et avec un effet spécial ;
- le **parchemin de réinitialisation** des points de statistiques, très cher.

Quand le personnage meurt, il revient au point de départ (Vazylis), sans perdre son niveau ni son équipement. En donjon, il revient à la première salle.

## Cadre technique

Le jeu est développé avec le moteur **Godot 4**, en GDScript, sur le PC Windows de Hugo. Claude Code écrit le code et les scènes ; Hugo utilise l'éditeur Godot pour voir et ajuster.

1. **Développement et tests quotidiens** : sur le PC, directement dans l'éditeur Godot.
2. **Tests sur iPhone sans Mac** : export web installable sur l'écran d'accueil (Safari → Partager → Sur l'écran d'accueil), hébergé gratuitement sur GitHub Pages.
3. **Vraie app iOS** : export natif depuis un Mac de la maison, avec Xcode, puis installation via TestFlight (compte développeur Apple, 99 $/an).
4. **Publication** sur l'App Store, si le jeu le mérite.

**Rendu** : le projet démarre avec le rendu « Compatibility » de Godot, le seul disponible en version web, qui fonctionne aussi en natif et convient au style low-poly. Le passage au rendu « Mobile », plus riche, pourra se faire pour la version native, avec quelques ajustements d'éclairage.

**Langage** : GDScript, le langage de Godot. Le C# est écarté, car son export iOS est expérimental et il n'est pas exportable en web avec Godot 4.

Principes à respecter dès le départ :

- la logique du jeu (stats, XP, butin, économie) est séparée de l'affichage, pour pouvoir faire évoluer l'un sans casser l'autre ;
- toutes les valeurs d'équilibrage (taux, multiplicateurs, temps de réapparition) sont regroupées dans des fichiers de configuration faciles à modifier ;
- le monde est découpé en zones pour pouvoir, plus tard, ne charger que la zone courante et ses voisines ;
- l'architecture laisse la porte ouverte au multijoueur, sans le construire dans le prototype.

### Assets remplaçables

Hugo remplacera progressivement les modèles provisoires par ses propres créations ou par d'autres assets CC0, sans réécrire le gameplay.

- **Identifiants logiques** : le gameplay ne manipule que des identifiants (par exemple `monster.pomelin`), jamais de fichier 3D.
- **Catalogue d'assets** : un seul fichier associe chaque identifiant à son modèle et à ses réglages (échelle, orientation, animations, points d'attache). Remplacer un modèle, c'est changer une ligne du catalogue.
- **Animations standardisées** : idle, walk, run, attack, hit, die, avec une correspondance par modèle.
- **Points d'attache nommés** pour l'équipement : main droite, main gauche, dos, tête…
- **Repli automatique** : un modèle manquant est remplacé par un modèle provisoire, sans faire planter le jeu.
- **Spécification des créations de Hugo** : format glTF/GLB (Blender), 1 unité = 1 mètre, tourné vers l'avant, origine aux pieds, budget de polygones mobile, et le même squelette que les personnages de base pour partager animations et équipement.

### Sauvegarde et serveur

- **Sauvegarde en ligne** dès le prototype, pour ne jamais perdre sa progression. Un service gratuit à petite échelle suffit (type Supabase).
- **Heure du serveur** : l'ouverture du donjon de Trazake le week-end se base sur l'heure du serveur, pas celle du téléphone, pour éviter la triche.
- **Pas de gains hors ligne** : le personnage ne progresse que quand le jeu est ouvert.

### Graphismes et budget

- **Règle du prototype** : 100 % gratuit, assets CC0 en priorité. Les modèles générés avec la version gratuite de Tripo sont acceptés pour le prototype personnel uniquement : ils sont signalés dans ASSETS.md et devront être régénérés avec un abonnement payant ou remplacés avant toute publication.
- **Personnages, équipement et décors** : Quaternius (https://quaternius.itch.io/, CC0). Personnages de base, tenues fantasy modulaires pour l'équipement visible, bibliothèque d'animations, kits de décors médiévaux et monstres animés.
- **Bestiaire en complément** : KayKit (https://kaylousberg.itch.io/kaykit-adventurers, CC0), en attendant les packs payants.
- **Plus tard, si le rendu plaît** : budget de 200 à 500 € (voire plus en cas de publication). Pistes : Synty POLYGON Modular Fantasy Hero pour les personnages et l'équipement, Synty Fantasy Rivals pour les monstres. Ces packs visent Unity et Unreal et demandent une conversion pour le web.

## Périmètre du prototype

Le prototype doit prouver une seule chose : la boucle « je tue, je loote, je deviens plus fort, je vais plus loin » est addictive.

**Inclus**

- la création du personnage (homme ou femme) et ses 4 statistiques, avec 4 points par niveau ;
- les 5 types d'armes, tous les emplacements d'équipement classiques et l'équipement visible sur le personnage ;
- les 6 raretés, les statistiques tirées au hasard et le niveau des items ;
- les 4 familles de matériaux, l'amélioration +1 à +10, le recyclage manuel et programmé ;
- Vazylis et le monde ouvert de 5 zones collées, avec sous-zones, monstres et sous-boss ;
- les 5 donjons de zone et le donjon mythique de la Tour ;
- le familier et son évolution ;
- les modes déplacement, combat et AFK, l'interface et les retours visuels ;
- la mort avec retour au point de départ ;
- la sauvegarde en ligne.

**Plus tard**

- la magie, le mana et les compétences ;
- l'étendard et l'accessoire de taille (slots présents mais vides) ;
- le donjon de Trazake du week-end ;
- la boutique d'armes inédites, les cosmétiques et le parchemin de réinitialisation ;
- plusieurs designs par type d'arme ;
- le son et la musique ;
- les zones au-delà du niveau 200 et le chargement par régions ;
- le multijoueur.

## Plan de développement du prototype

Le prototype se construit en 12 étapes. Chacune se termine par une version jouable sur l'iPhone, testée avant de passer à la suivante. Les étapes 0 à 8 livrent une zone 1 complète : c'est le premier vrai jalon, où le jeu devient jouable au quotidien.

### Phase 1 — Les fondations

0. **Mise en place**
   - Projet Godot 4 (GDScript) sur le PC Windows, catalogue d'assets, export web installable sur l'écran d'accueil de l'iPhone, hébergement gratuit en HTTPS sur GitHub Pages, dépôt GitHub.
   - Fichier de configuration central pour toutes les valeurs d'équilibrage.
   - *Réussi si* : l'icône Vazylis est sur l'iPhone et ouvre une scène 3D en plein écran.
1. **Le personnage**
   - Personnage Quaternius animé (homme ou femme), joystick flottant, caméra qui suit, vertical et horizontal, un terrain de test.
   - *Réussi si* : on se promène de façon fluide, à une main.
2. **Le combat**
   - Trois monstres de la première sous-zone (passifs et agressifs), modes combat et déplacement, attaque automatique, chiffres de dégâts, mort et réapparition des monstres, XP, niveaux et effet « Level Up ».
   - *Réussi si* : tuer des monstres et monter de niveau est déjà agréable.
3. **Les statistiques et l'interface**
   - Bandeau en haut à gauche, fenêtre des statistiques (+ et −, 4 points par niveau, validation définitive), formules de combat, affinités des armes.
   - *Réussi si* : on sent la différence entre un build Force et un build Agilité.

### Phase 2 — La boucle de loot

4. **Le butin et l'inventaire**
   - Drops selon les tables de loot, 6 raretés, qualité des items, sac à dos en cases, glisser-déposer pour s'équiper, équipement visible sur le personnage, recyclage manuel et automatique.
   - *Réussi si* : on a envie de tuer « encore un monstre » pour voir ce qui tombe.
5. **La sauvegarde en ligne**
   - Compte joueur et sauvegarde automatique sur un service gratuit (type Supabase).
   - *Réussi si* : on ferme l'app, on la rouvre, tout est là.
6. **La zone 1 complète**
   - Vazylis, les 4 sous-zones, les 12 monstres, les 4 sous-boss, les monstres champions, le mode AFK, la mort avec retour à Vazylis, les ressources.
   - *Réussi si* : on peut farmer une soirée entière sans s'ennuyer.
7. **La forge et les panoplies**
   - Amélioration +1 à +10 avec les taux de réussite, matériaux, panoplies de la zone 1 et leurs bonus.
   - *Réussi si* : on a des objectifs précis (telle panoplie, tel +7).
8. **Le premier donjon et le familier**
   - La Crypte du Guet (tourbillon, étages, Morvhal, mythiques), le familier et son évolution.
   - *Réussi si* : on rate Morvhal, on s'équipe, on revient et on gagne.

**Jalon : la zone 1 est jouable au quotidien.** On joue plusieurs soirées, on ajuste les chiffres dans le fichier de configuration, et on corrige ce qui lasse avant d'aller plus loin.

### Phase 3 — Le monde complet

9. **Les zones 2 à 5**, une par une, chacune avec ses monstres, sous-boss, panoplies et son donjon.
10. **La Tour mythique**, avec ses monstres exclusifs et ses étages qui montent en niveau.
11. **La vraie app iOS** : export iOS natif depuis un Mac de la maison (Godot et Xcode), passage éventuel au rendu Mobile, compte développeur Apple, installation via TestFlight.

### Méthode de travail avec Claude Code

- **Une étape par session**, avec ce document comme référence permanente, déposé dans le projet Claude et dans `docs/game-design.md`.
- **Un fichier de règles dans le code** (CLAUDE.md) qui reprend l'essentiel : cadre technique, règle d'originalité, assets CC0 uniquement, valeurs dans le fichier de configuration.
- **Tester sur l'iPhone à chaque étape**, noter ce qui ne va pas, corriger avant de continuer.
- **Mettre à jour ce document** quand une décision change.

### Prérequis côté Hugo

| Étape | Ce qu'il faut | Coût |
| --- | --- | --- |
| 0 | Godot 4 et Claude Code sur le PC Windows, un compte GitHub, un hébergement gratuit (GitHub Pages) | Gratuit |
| 5 | Un compte sur un service de sauvegarde en ligne (type Supabase) | Gratuit à petite échelle |
| 11 | Compte développeur Apple, et un Mac de la maison avec Xcode | 99 $ par an |

## Questions ouvertes

- [x] Nom du jeu : Vazylis : Le Dernier Rempart (validé).
- [ ] Bestiaire : valider les 5 zones proposées, puis définir Trazake et les monstres exclusifs de la Tour.
- [ ] Le catalogue d'items : familles d'armes et d'armures, statistiques de base par type d'arme.
- [ ] Le nombre de bonus en % par rareté (0 à 5) est-il validé ?
- [ ] Le soin : potions, bouton avec temps de recharge, régénération ?
- [ ] La taille du sac à dos, et peut-on l'agrandir ?
- [ ] L'or tombe-t-il aussi sur les monstres, ou seulement via le recyclage ?
- [ ] Comment nourrir le familier, et ses bonus à chaque forme ?
- [ ] Comment obtenir l'étendard et l'accessoire de taille ?
- [ ] La Tour : nombre d'étages, niveaux, récompenses.
- [ ] Le donjon de Trazake : durée d'ouverture, récompenses.
- [ ] Une personnalisation du personnage au-delà de homme ou femme ?
- [x] Mac pour l'app iOS : disponible à la maison (réglé).
