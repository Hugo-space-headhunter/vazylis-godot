# Assets utilisés

Chaque asset du jeu est noté ici : nom, source, licence.

- Assets CC0 en priorité (Quaternius, KayKit).
- Modèles Tripo version gratuite : marqués « Tripo gratuit – usage perso uniquement ». Ils devront être régénérés avec un abonnement payant ou remplacés avant toute publication.
- Créations de Hugo : marquées « création de Hugo ».

## Modèles 3D

| Identifiant | Fichier | Source | Licence |
| --- | --- | --- | --- |
| `character.heros_homme` | `assets/models/character/heros_homme/` | Quaternius, Universal Base Characters (version gratuite), https://quaternius.com — textures réduites à 1024 px | CC0 |
| `character.heros_femme` | `assets/models/character/heros_femme/` | Quaternius, Universal Base Characters (version gratuite), https://quaternius.com — textures réduites à 1024 px | CC0 |
| `monster.cochonnet_suie` | `assets/models/monster/cochonnet_suie/` | Quaternius, Ultimate Monsters (« Dog »), https://quaternius.com — teinté et réduit dans le catalogue | CC0 |
| `monster.corbac` | `assets/models/monster/corbac/` | Quaternius, Ultimate Monsters (« Pigeon ») — teinté et réduit dans le catalogue | CC0 |
| `monster.pomelin` | `assets/models/monster/pomelin/` | Quaternius, Ultimate Monsters (« GreenBlob ») — teinté et réduit dans le catalogue | CC0 |
| `weapon.epee_depart` | `assets/models/weapon/epee_depart/` | Polyy, 3D Fantasy Weapons Pack, version « low » (« Knight's Longsword »), https://polyy.ai — accord de Hugo le 29/10/2026 | CC0, aucun crédit exigé |
| `weapon.dague` | `assets/models/weapon/dague/` | Polyy, 3D Fantasy Weapons Pack (low), « Rogue's Dagger », https://polyy.ai | CC0, aucun crédit exigé |
| `weapon.claymore` | `assets/models/weapon/claymore/` | Polyy, 3D Fantasy Weapons Pack (low), « Highland Claymore » | CC0, aucun crédit exigé |
| `weapon.hache` | `assets/models/weapon/hache/` | Polyy, 3D Fantasy Weapons Pack (low), « Twin Moon Battle Axe » | CC0, aucun crédit exigé |
| `weapon.bouclier` | `assets/models/weapon/bouclier/bouclier.glb` | Modèle provisoire généré par code (`tools/generer_armes_provisoires.gd`) | Original, propre au projet |
| `weapon.arc` | `assets/models/weapon/arc/arc.glb` | Modèle provisoire généré par code (`tools/generer_armes_provisoires.gd`) | Original, propre au projet |
| `projectile.fleche` | `assets/models/projectile/fleche/fleche.glb` | Modèle provisoire généré par code (`tools/generer_armes_provisoires.gd`) | Original, propre au projet |
| `armor.paysan_*_h`, `armor.paysan_*_f` (plastron, gants, bottes, ceinture) | `assets/models/armor/tenue_paysan/` | Quaternius, Modular Character Outfits - Fantasy (version gratuite), tenue « Peasant », https://quaternius.com — textures réduites à 512 px | CC0 |
| `armor.rodeur_*_h`, `armor.rodeur_*_f` (casque, plastron, épaulière, gants, bottes, ceinture) | `assets/models/armor/tenue_rodeur/` | Quaternius, Modular Character Outfits - Fantasy (version gratuite), tenue « Ranger » — textures réduites à 512 px | CC0 |
| `armor.cape_voyage` | `assets/models/armor/cape_voyage/cape_voyage.glb` | Modèle provisoire généré par code (`tools/generer_objets_provisoires.gd`) | Original, propre au projet |
| `jewel.amulette_lucioles`, `jewel.boucle_os` | `assets/models/jewel/` | Modèles provisoires générés par code (`tools/generer_objets_provisoires.gd`) | Original, propre au projet |
| `prop.cristal_test` | `assets/models/prop/cristal_test/cristal_test.glb` | Modèle provisoire généré par code (`tools/generer_cristal_test.gd`) | Original, propre au projet |
| `prop.exemple_manquant` | aucun (volontairement absent) | Modèle provisoire automatique (boîte rose) | Original, propre au projet |

## Animations

| Nom | Fichier | Source | Licence |
| --- | --- | --- | --- |
| Universal Animation Library (version gratuite, 43 animations) | `assets/models/animation/bibliotheque_ual1/bibliotheque_ual1.glb` | Quaternius, https://quaternius.com — même squelette que les personnages de base | CC0 |
| Universal Animation Library 2 (version gratuite, 43 animations, dont le coup à deux mains « TreeChopping ») | `assets/models/animation/bibliotheque_ual2/bibliotheque_ual2.glb` | Quaternius, https://quaternius.com — même squelette | CC0 |

## Décor du terrain de test

Rochers et piliers : formes simples de Godot (`scenes/monde/rocher.tscn`, `scenes/monde/pilier.tscn`), provisoires, propres au projet.

## Décors

| Nom | Dossier | Source | Licence |
| --- | --- | --- | --- |
| Rempart, piliers, bannières, torches, tonneaux, caisses, tables, coffre de Vazylis (16 modèles) | `assets/models/prop/kaykit_donjon/` (une seule texture partagée) | KayKit Dungeon Pack 1.1, Kay Lousberg (https://kaylousberg.itch.io/), copié depuis l'ancien projet | CC0 |
| Rochers et piliers des Prés | `scenes/monde/rocher.tscn`, `scenes/monde/pilier.tscn` | Formes simples faites dans Godot (provisoires) | Original, propre au projet |

## Images

| Nom | Fichier | Source | Licence |
| --- | --- | --- | --- |
| Icône provisoire de Vazylis (rempart doré) | `icon.svg`, `assets/icones/*.png` | Dessin original généré par code (`tools/generer_icones.gd`) | Original, propre au projet |
| Icône des statistiques (quatre losanges) | `assets/icones/ui/statistiques.svg` | Dessin original | Original, propre au projet |
| Icône du sac à dos | `assets/icones/ui/sac.svg` | Dessin original | Original, propre au projet |
| Vignettes des objets dans le sac | (fabriquées pendant le jeu) | Rendu automatique des modèles 3D (`scripts/ui/vignettes.gd`) | — |

## Outils (hors assets du jeu)

| Nom | Dossier | Source | Licence |
| --- | --- | --- | --- |
| GUT 9.7.1 (tests automatiques) | `addons/gut/` | https://github.com/bitwes/Gut | MIT (non inclus dans l'export du jeu) |
