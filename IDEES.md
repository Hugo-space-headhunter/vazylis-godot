# Idées pour plus tard

Les idées et améliorations hors de l'étape en cours sont notées ici, au lieu d'être codées tout de suite.

## Finition visuelle (à traiter plus tard, dans une passe dédiée)

Décision de Hugo (29/10/2026) : les défauts de design, d'animation et de position par rapport au corps ne bloquent pas les étapes. On les note ici et on les corrige tous ensemble plus tard.

Cette passe devra être sérieuse et prendre du temps : Hugo compte énormément sur le visuel du personnage et du butin pour l'effet « farm and loot », et, à terme, pour une course au personnage le plus stylé et le plus fort entre joueurs. Le rendu doit être réaliste, fluide et attrayant.

- Armes mal tenues : la prise de toutes les armes est à revoir (épée et hache à deux mains, arc, dagues, épée et bouclier), en main, au repos et dans le dos.
- Armes à deux mains (épée, hache) : tenues en permanence à deux mains. Au repos, traînées au sol comme une couette très lourde, les deux bras vers l'arrière sur le côté. Attaques lourdes, comme si l'arme pesait une tonne (esprit « guerrier à grande épée », sans rien copier d'un jeu existant).
- Arc : une vraie animation où une main tire la corde.
- Animations d'attaque propres à chaque type d'arme (voir aussi « Armes et statistiques » plus bas).
- Lecture de la rareté sur l'équipement porté : standard, argenté et doré se ressemblent encore beaucoup ; il faudra de vraies variantes de matières (métal poli, liserés dorés, runes bleues de l'épique, halo du mythique, aura du transcendant), et des pièces différentes selon la rareté.
- Peau sous les vêtements : elle recule de 3 cm sous chaque pièce portée (voir `scripts/world/corps_sous_vetements.gd`) ; idéalement, des personnages de base dont le corps est fait pour les tenues.
- Cape rigide : elle ne suit pas les jambes quand on court ; une vraie cape animée (os ou tissu simulé).
- Boucles d'oreilles : pas encore visibles (trop petites pour le prototype).
- Pistes techniques : IK des deux mains dans Godot (TwoBoneIK3D), animations dédiées (faites dans Blender, ou d'autres sources d'animations, à valider avec Hugo pour la licence), effets d'impact (secousse de caméra, ralenti de quelques images, poussière).

## Technique

- Netteté et performances sur iPhone : l'écran de l'iPhone affiche 3 pixels par point. Si les images par seconde baissent avec les vraies scènes, réduire la résolution de rendu 3D (réglage « Échelle 3D »).
- Zone de sécurité de l'iPhone (encoche, barre du bas) : adapter les marges de l'interface quand le bandeau et les boutons arriveront (étape 3).
- Raccourci pour lancer les tests automatiques depuis l'éditeur Godot (panneau GUT en bas de l'éditeur).

## Personnage

- Ajouter le héros créé par Hugo avec Tripo comme deuxième personnage du catalogue (`character.heros_tripo`), avec les animations Quaternius par reciblage (« retargeting ») de Godot. Il faudra l'exporter de Tripo en GLB avec un squelette. Tripo gratuit : usage perso uniquement.
- Coiffures : le pack Universal Base Characters contient des coiffures séparées (dossier « Hairstyles », attachées à l'os de la tête). À ajouter avec l'écran de création du personnage.
- Écran de création du personnage (homme ou femme, prénom) : remplacera le bouton provisoire Homme/Femme.
- Caméra : en portrait, le personnage paraît petit ; envisager une caméra un peu plus proche en portrait. Empêcher la caméra de passer derrière les obstacles.
- Bibliothèque d'animations : le jeu en garde 43 alors qu'il en utilise 6 ; ne garder que les utiles pour alléger le téléchargement.

## Combat

- Cochonnet de suie : pas de vrai cochon en CC0 chez Quaternius ; le modèle « Dog » teinté sert en attendant. Les yeux rouges demanderaient de retoucher la texture.
- Épée : légèrement trop en avant pendant la marche avec l'arme sortie ; à affiner dans `placements` du catalogue si besoin.
- Plusieurs monstres d'une même zone peuvent se chevaucher ; les écarter un peu les uns des autres.
- Les étiquettes « nom niv. X » de tous les monstres sont toujours visibles ; ne les montrer que pour les monstres proches si l'écran devient chargé.

## Armes et statistiques

- Arc et bouclier : modèles provisoires faits par code ; les remplacer par de vrais modèles (aucun arc ni bouclier seul en CC0 dans les packs actuels ; chercher chez KayKit Adventurers ou Quaternius).
- Hache : sa particularité (ignorer 15 % de la défense) n'a pas encore d'effet, car les monstres n'ont pas de défense.
- Poids du jeu : 19 Mo après la partie 4.1 (textures des tenues réduites à 512 px, textures des armes limitées à 512 px à l'import). À surveiller à chaque nouvel asset ; les textures sont exportées deux fois (PC et mobile), on pourrait n'exporter que le format mobile.
- Outils `tools/calculer_prise.gd` et `tools/calculer_prise_pose.gd` : ils calculent la prise en main d'une nouvelle arme (au repos ou à un moment d'une animation) ; à utiliser pour les armes créées par Hugo.
- Tir à l'arc : la main droite ne tire pas la corde (l'animation est un sort lancé d'une main) ; chercher une vraie animation de tir à l'arc.
- Dagues et épée et bouclier : une même animation d'attaque à l'épée ; chercher des animations propres aux dagues.
- Coup à deux mains : l'animation « TreeChopping » commence arme levée, ce qui fait un petit saut au début du coup ; une animation d'armement serait plus fluide.
- Main gauche sur le manche : pendant le coup à deux mains, la main gauche est proche du manche grâce à l'animation ; on pourrait la coller exactement au manche avec l'IK de Godot (TwoBoneIK3D).

## Butin et sac

- Butin de test : le bouton « Test : butin » fait tomber 6 objets d'un coup ; leurs noms se chevauchent (normal, en jeu ils tombent un par un).
- Vignettes : les objets fins (dagues, épée) paraissent petits dans leur case ; cadrer la vignette sur l'arme en diagonale.
- Agrandir le sac (au-delà de 40 cases) : à décider plus tard (question ouverte du game design).
- Trier le sac (par rareté, par type, par niveau).

## Équipement

- Mains : le game design prévoit une main principale et une main secondaire (dague, épée à une main ou bouclier). Pour le prototype, un seul emplacement « Arme » couvre les deux mains (paire de dagues, épée et écu, arme à deux mains). Séparer les deux mains quand il y aura des épées à une main et des boucliers seuls — à valider avec Hugo.
- Comparaison plus détaillée entre l'objet du sac et l'objet porté (statistique par statistique).

## Recyclage

- Filtre par matériau (« tout ce qui est en fer ») : quand les matériaux existeront (étape 7).
- Le recyclage rapporte seulement de l'or pour l'instant ; les matériaux arriveront avec la forge (étape 7).
- Message d'erreur sans gravité dans la console de Godot (« Parameter "material" is null ») quand on change plusieurs fois de suite une pièce de rareté argentée ou plus : à comprendre.
