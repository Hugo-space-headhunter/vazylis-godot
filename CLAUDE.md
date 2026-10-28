# Vazylis : Le Dernier Rempart

## Contexte

- Jeu mobile RPG 3D de farm infini, projet personnel de Hugo. Hugo n'est pas développeur.
- La référence complète du jeu est `docs/game-design.md`. Lis-le avant chaque étape. Si une demande le contredit, signale-le avant d'agir.
- Le développement suit la section « Plan de développement du prototype » de ce document, une étape à la fois.

## Façon de travailler avec Hugo

- Réponds en français, avec des mots simples, sans jargon. Quand un concept technique est utile, explique-le avec une image ou un petit schéma.
- Au début d'une étape : résume ton plan en quelques lignes et attends l'accord de Hugo s'il y a un choix important.
- À la fin d'une étape : résume ce qui a été fait, explique pas à pas comment tester (sur le PC dans Godot, puis sur l'iPhone), et liste ce qui reste ou ce qui pose question.
- Si Hugo doit faire une action lui-même (installer un logiciel, cliquer dans l'éditeur Godot, créer un compte, télécharger un pack), guide-le pas à pas, un clic après l'autre.
- Fais des commits git réguliers avec des messages clairs en français, et pousse sur GitHub en fin d'étape.
- Reste dans le périmètre de l'étape en cours. Note les idées hors périmètre dans `IDEES.md` au lieu de les coder.

## Cadre technique

- **Moteur** : Godot 4 (dernière version stable), langage **GDScript** uniquement (pas de C#).
- **Poste de travail** : PC Windows. Les exports iOS natifs se feront plus tard sur un Mac de la maison, avec Xcode.
- **Rendu** : « Compatibility » (le seul disponible en export web). Ne pas utiliser de fonction réservée aux rendus Forward+ ou Mobile sans l'accord de Hugo.
- **Tests sur iPhone** : export web en mode un seul thread, avec l'option Progressive Web App activée (installable sur l'écran d'accueil, plein écran, portrait et paysage). Hébergement sur GitHub Pages, déployé automatiquement par GitHub Actions.
- **Performances mobiles** : low-poly, peu d'objets dessinés à la fois, ombres simples, 60 images/seconde visées (30 minimum).
- **Commandes tactiles** : tout se joue au doigt ; activer l'émulation du tactile à la souris pour tester sur le PC.
- **Fichiers lisibles** : scènes et ressources en format texte (`.tscn`, `.tres`). Quand une scène est plus simple à régler dans l'éditeur, explique à Hugo quoi faire.
- **Arborescence** :
  - `scripts/game/` : logique du jeu (statistiques, combat, XP, loot, économie) en classes GDScript indépendantes des nœuds et de l'affichage, testées automatiquement (addon de tests sous licence libre, par exemple GUT) ;
  - `scripts/world/` et `scenes/` : monde, personnages, monstres, affichage 3D ;
  - `scripts/ui/` et `scenes/ui/` : interface (bandeau, boutons, menus) ;
  - `config/` : toutes les valeurs d'équilibrage (taux, multiplicateurs, formules, temps de réapparition), commentées. Aucune valeur d'équilibrage en dur ailleurs.
- **Autoloads** (singletons) limités et nommés clairement : configuration, catalogue d'assets, sauvegarde.
- Le monde est découpé en zones, pour pouvoir plus tard ne charger que la zone courante et ses voisines.
- **Sauvegarde** : derrière une couche abstraite. D'abord locale, puis en ligne (Supabase) à l'étape 5.

## Assets remplaçables : règle d'architecture

Hugo remplacera progressivement les modèles provisoires par ses propres créations ou par d'autres assets. Remplacer un modèle ne doit jamais demander de toucher au gameplay.

- **Identifiants logiques** : le gameplay ne connaît jamais de fichier 3D. Il ne manipule que des identifiants (`monster.pomelin`, `weapon.epee_longue`, `armor.casque_guet`…).
- **Catalogue d'assets** (ressource ou fichier de données unique, chargé par un autoload) : il associe chaque identifiant à son fichier 3D et à ses réglages (échelle, rotation, décalage, noms d'animations, points d'attache). C'est le seul endroit à modifier pour remplacer un modèle.
- **Animations standardisées** : le jeu utilise des noms communs (`idle`, `walk`, `run`, `attack`, `hit`, `die`). Le catalogue fait la correspondance avec les vrais noms de chaque modèle.
- **Points d'attache** : armes et équipement s'accrochent à des points nommés (main droite, main gauche, dos, tête…), via des `BoneAttachment3D` définis dans le catalogue pour chaque personnage.
- **Repli automatique** : si un fichier manque ou ne se charge pas, le jeu affiche un modèle provisoire simple au lieu de planter, et le signale dans la console.
- **Rangement** : un dossier par asset, `assets/models/<catégorie>/<identifiant>/`.
- **Format** : glTF ou GLB (export standard de Blender et de Tripo).
- **Spécification des créations de Hugo** (à respecter et à lui expliquer quand il crée un modèle) : 1 unité = 1 mètre, personnage tourné vers l'avant, origine au niveau des pieds, budget de polygones mobile, et pour les personnages, le même squelette que les personnages de base afin de partager animations et équipement.
- **Test** : un test vérifie que chaque identifiant utilisé par le gameplay existe dans le catalogue.

## Assets : licences

- **Priorité aux assets CC0** : Quaternius (https://quaternius.itch.io/) et KayKit (https://kaylousberg.itch.io/). Jamais d'asset payant ni d'asset qui exige de créditer son auteur, sauf accord de Hugo.
- **Modèles Tripo** générés avec la version gratuite : acceptés pour le prototype personnel uniquement. Ils sont marqués « Tripo gratuit – usage perso uniquement » dans `ASSETS.md`, et devront être régénérés avec un abonnement payant ou remplacés avant toute publication.
- Chaque asset est noté dans `ASSETS.md` (nom, source, licence ; « création de Hugo » pour les siens).
- Si un téléchargement est impossible depuis ton environnement, demande à Hugo de télécharger le pack et de le déposer dans `assets/`, en le guidant pas à pas.
- Si aucun modèle ne convient, utilise un modèle provisoire simple et note-le dans `ASSETS.md`.

## Règle d'originalité

- Le jeu s'inspire d'ambiances (Flyff, World of Warcraft, Warhammer, Metin2, Dofus), sans jamais reprendre de noms, personnages, monstres signature, symboles, logos, designs identifiables ou textes.
- Tous les noms et designs du jeu sont originaux, comme définis dans `docs/game-design.md`.

## À ne jamais faire sans l'accord de Hugo

- Souscrire ou configurer un service payant.
- Supprimer des fichiers ou réécrire l'historique git.
- Changer une décision du document de game design.
