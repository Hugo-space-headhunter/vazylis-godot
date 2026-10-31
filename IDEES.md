# Idées pour plus tard

Les idées et améliorations hors de l'étape en cours sont notées ici, au lieu d'être codées tout de suite.

## Finition visuelle (à traiter plus tard, dans une passe dédiée)

Décision de Hugo (29/10/2026) : les défauts de design, d'animation et de position par rapport au corps ne bloquent pas les étapes. On les note ici et on les corrige tous ensemble plus tard.

Cette passe devra être sérieuse et prendre du temps : Hugo compte énormément sur le visuel du personnage et du butin pour l'effet « farm and loot », et, à terme, pour une course au personnage le plus stylé et le plus fort entre joueurs. Le rendu doit être réaliste, fluide et attrayant.

- Armes mal tenues : la prise de toutes les armes est à revoir (épée et hache à deux mains, arc, dagues, épée et bouclier), en main, au repos et dans le dos.
- Armes à deux mains (épée, hache) : tenues en permanence à deux mains. Au repos, traînées au sol comme une couette très lourde, les deux bras vers l'arrière sur le côté. Attaques lourdes, comme si l'arme pesait une tonne (esprit « guerrier à grande épée », sans rien copier d'un jeu existant).
- Arc : une vraie animation où une main tire la corde.
- Tenue des armes à deux mains, à reprendre (Hugo, 31/10/2026) : le chantier C a essayé l'épée et la hache traînées à la hanche, tenues à deux mains par cinématique inverse ; sur l'iPhone, les mains restaient mal placées. Version actuelle (provisoire) : à la marche, l'arme traîne dans la main droite seule, la main gauche ne la rejoint que pour frapper. À reprendre avec une vraie animation « porter lourd » à deux mains ; le problème vient peut-être aussi du modèle 3D du personnage (proportions, squelette), à regarder en même temps. Outils existants : `tools/calculer_traine.gd`, `tools/calculer_prise_deux_mains.gd`, `scripts/world/prise_deux_mains.gd`.
- Architecture des bâtiments, à reprendre (Hugo, 31/10/2026) : maisons, rempart et ruines font encore « assemblage de blocs » ; leur donner une vraie architecture (formes, détails, proportions, intérieur), avec des modèles dédiés ou de meilleurs packs.
- Animations d'attaque propres à chaque type d'arme (voir aussi « Armes et statistiques » plus bas).
- Lecture de la rareté sur l'équipement porté : standard, argenté et doré se ressemblent encore beaucoup ; il faudra de vraies variantes de matières (métal poli, liserés dorés, runes bleues de l'épique, halo du mythique, aura du transcendant), et des pièces différentes selon la rareté.
- Peau sous les vêtements : elle recule de 3 cm sous chaque pièce portée (voir `scripts/world/corps_sous_vetements.gd`) ; idéalement, des personnages de base dont le corps est fait pour les tenues.
- Cape (31/10/2026) : la cape provisoire a maintenant trois colonnes d'os qui flottent comme des ressorts (`scripts/world/tissu.gd`), et l'amulette se balance (`scripts/world/pendule.gd`). Reste à faire : une vraie cape dessinée (tissu, bordure, fermoir), et vérifier qu'elle ne traverse pas l'épée et le bouclier rangés dans le dos.
- Pans des tuniques et des jupes : les tenues Quaternius (paysan, rôdeur) n'ont pas d'os pour leurs pans de tissu, elles ne peuvent donc pas flotter. Pour une tenue qui flotte (créations de Hugo ou nouveaux modèles) : garder le squelette des personnages de base et ajouter, dans Blender, des chaînes d'os en plus dans chaque pan (par exemple « pan_avant_0 » à « pan_avant_3 ») ; le jeu les fera flotter avec le réglage « tissu » du catalogue, comme la cape.
- Boucles d'oreilles : pas encore visibles (trop petites pour le prototype).
- Vêtements et armures (demande de Hugo, 29/10/2026) : retravailler tout le design et les textures des tenues, et la façon dont ils « vivent » selon les mouvements du personnage (marche, course, attaque) : tissus et capes qui flottent et suivent le mouvement, pièces qui bougent avec le corps, sans traverser la peau ni les autres pièces.
- Pistes techniques : IK des deux mains dans Godot (TwoBoneIK3D), os ou simulation de tissu pour les capes et les pans de vêtements (SpringBoneSimulator3D de Godot), animations dédiées (faites dans Blender, ou d'autres sources d'animations, à valider avec Hugo pour la licence), effets d'impact (secousse de caméra, ralenti de quelques images, poussière).
- Vazylis (étape 6.1) : le rempart et le village viennent du pack KayKit « donjon » en attendant le Medieval Village Pack (maisons, puits, marché) ; ajouter des arbres et des fleurs quand l'Ultimate Stylized Nature sera là.
- Pomelin Royal : pour l'instant un Pomelin plus gros et teinté ; lui faire sa couronne de feuilles noires (accessoire sur le point « tête »).
- Aura des champions et des sous-boss : anneau et étincelles simples, à embellir (halo, pulsation plus riche).
- Ressources dans le sac : un petit rond de couleur pour l'instant ; leur dessiner de vraies icônes.
- Bois des Lucioles (étape 6.2) : le pack Ultimate Stylized Nature n'est arrivé qu'en partie (Google Drive l'a coupé en plusieurs morceaux) ; il manque les pins, les « arbres normaux », les palmiers et les champignons. Les récupérer (autres morceaux du téléchargement) pour varier la forêt et ajouter les champignons géants de la Vallée claire.
- Maisons de Vazylis : fenêtres sans vitres ni volets, pas encore d'intérieur ; ajouter un puits et un marché couvert.
- Forge de Vazylis (étape 7) : enclume en formes simples et forgeron sans tablier ni marteau ; lui faire un vrai atelier (soufflet, braises, marteau) et une animation de frappe à chaque tentative.
- Gueule-Fleur : l'attaque de zone est un cercle rouge ; plus tard, de vraies lianes qui jaillissent du sol.
- Gobelin chaman : sa boule verte est une simple sphère lumineuse ; lui donner une traînée et une animation d'incantation.
- Ruines du Guet (étape 6.3) : des substituts faute de modèles CC0 exacts : le Gargouillon est un « Goleling » volant tout gris (pas une vraie gargouille), le Rat des cryptes est un chat gris-brun sans yeux rouges, l'Écuyer creux est un squelette sans épée (pas une armure vide). À remplacer par des modèles dédiés (Tripo ou créations de Hugo).
- Le Gardien sans visage : le personnage de base en pierre unie ; lui faire une vraie armure gothique, un heaume sans visage et un grand pavois.
- Décors des Ruines : pièces du pack KayKit « donjon » ; le pack Ultimate Modular Ruins (Quaternius, CC0) donnerait de vraies ruines gothiques (arches, escaliers, statues).
- Panoplies (étape 7) : les pièces reprennent les tenues de paysan et de rôdeur avec une teinte ; leur dessiner un vrai style par panoplie (feuillages du Verger, épines de la Gueule-Fleur, pierre gothique du Guet, cuir et lames de Krâg), et un effet visuel quand la panoplie est complète.
- Krâg le Mutilé (étape 6.4) : il garde la massue à pointes du modèle d'orc ; lui fixer une vraie lame à la place de l'avant-bras droit (essai fait sur l'os « LowerArm.R » : la lame restait cachée dans le bras, à reprendre avec la passe sur la tenue des armes).
- Lisière pourpre : Pomelin noirci sans épines ni yeux violets, Loup morbide sans côtes visibles ni pelage fumant, Villageois corrompu sans vêtements de paysan ni veines pourpres ; à embellir (modèles dédiés, ou tenue de paysan teintée sur le villageois).
- Performances : les monstres faits avec le personnage de base (Gardien, Villageois) sont lourds (environ 14 000 triangles chacun) ; si l'iPhone ralentit dans la Lisière, leur retirer l'ombre ou utiliser un modèle plus léger.

## Technique

- Relief (chantier B, 30/10/2026) : le sol de jeu reste plat (des bosses obligeraient à reposer décors et monstres) ; ajouter plus tard des collines en bordure de zone et des variations de hauteur décoratives, si le rendu le demande.
- Android (décidé le 30/10/2026 : plus tard) : on se concentre sur iOS. Le jeu ne dépend pas de la plateforme ; le jour venu, exporter l'app Android depuis le PC (Android SDK et Java gratuits) et la mesurer sur un vrai téléphone Android.
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
- Message d'erreur sans gravité dans la console de Godot (« Parameter "material" is null ») quand on change plusieurs fois de suite une pièce de rareté argentée ou plus : à comprendre.

## Sauvegarde

- PC et iPhone ont chacun leur sauvegarde (un compte anonyme par appareil). Pour jouer la même partie sur les deux : un vrai compte (e-mail) relié au compte anonyme — à décider plus tard.
- Supprimer l'icône Vazylis de l'iPhone fait perdre le compte anonyme, donc la partie : un vrai compte réglerait aussi ce point avant une publication.
- Comptes de test : la vérification de l'étape 5 (29/10/2026) a créé un compte anonyme de test et sa ligne dans la table « saves » de Supabase (depuis la version web lancée sur le PC). Hugo peut les supprimer dans Supabase (Authentication → Users, et Table Editor → saves) s'il le souhaite.
- La position du personnage et sa vie ne sont pas sauvegardées : on repart du point de départ, vie pleine (comme après une mort).
