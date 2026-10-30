// Le sol des zones : une vraie texture (herbe, pavés, gravier…) avec son relief, nuancée par de
// grandes taches de couleur, et un chemin de terre sinueux (facultatif). Tout est calculé à partir
// de la position dans le monde : les zones voisines se raccordent sans couture, et le chemin
// continue d'une zone à l'autre. Les textures viennent d'ambientCG (CC0), voir ASSETS.md.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

// La texture du sol et son relief (une « normal map »).
uniform sampler2D texture_couleur : source_color, repeat_enable, filter_linear_mipmap;
uniform sampler2D texture_relief : hint_normal, repeat_enable, filter_linear_mipmap;
// Taille d'un motif de la texture, en mètres.
uniform float taille_motif = 3.0;
// Force du relief (0 = plat).
uniform float force_relief = 1.0;
// Nuances des grandes taches : la texture est multipliée par ces couleurs (blanc = inchangée).
uniform vec3 teinte_claire : source_color = vec3(1.0);
uniform vec3 teinte_sombre : source_color = vec3(0.8);
// Un bruit en niveaux de gris, qui se répète sans couture (scenes/monde/bruit_sol.tres).
uniform sampler2D bruit : repeat_enable, filter_linear_mipmap;
// Taille des taches : plus le nombre est petit, plus elles sont grandes.
uniform float echelle_taches = 0.035;

// Chemin de terre : largeur 0 = pas de chemin. Il suit l'axe x = chemin_x en ondulant,
// entre chemin_z_debut (au sud) et chemin_z_fin (au nord, plus négatif).
uniform sampler2D chemin_couleur : source_color, repeat_enable, filter_linear_mipmap;
uniform sampler2D chemin_relief : hint_normal, repeat_enable, filter_linear_mipmap;
uniform vec3 teinte_chemin : source_color = vec3(1.0);
uniform float chemin_x = 0.0;
uniform float chemin_largeur = 0.0;
uniform float chemin_z_debut = 0.0;
uniform float chemin_z_fin = 0.0;

varying vec3 position_monde;

void vertex() {
	position_monde = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 sol = position_monde.xz;
	vec2 uv = sol / taille_motif;
	float taches = texture(bruit, sol * echelle_taches).r;
	// Un deuxième passage de la texture, plus grand et tourné, mélangé selon les taches :
	// la répétition du motif ne se voit presque plus.
	vec2 uv_large = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.43;
	float melange = smoothstep(0.35, 0.65, texture(bruit, sol * echelle_taches * 1.7 + 0.31).r);
	vec3 couleur = mix(texture(texture_couleur, uv).rgb, texture(texture_couleur, uv_large).rgb, melange * 0.6);
	couleur *= mix(teinte_sombre, teinte_claire, smoothstep(0.3, 0.7, taches));
	vec3 relief = texture(texture_relief, uv).rgb;
	if (chemin_largeur > 0.0) {
		float grain = texture(bruit, sol * 0.7).r;
		float ondulation = (texture(bruit, vec2(position_monde.z * 0.013, 0.37)).r - 0.5) * 9.0;
		float ecart = abs(position_monde.x - chemin_x - ondulation);
		float bord = chemin_largeur * 0.5 + (grain - 0.5) * 0.9;
		float dans = 1.0 - smoothstep(bord - 0.5, bord + 0.25, ecart);
		dans *= smoothstep(chemin_z_fin - 1.0, chemin_z_fin + 1.0, position_monde.z);
		dans *= 1.0 - smoothstep(chemin_z_debut - 1.0, chemin_z_debut + 1.0, position_monde.z);
		vec2 uv_chemin = sol / 2.5;
		couleur = mix(couleur, texture(chemin_couleur, uv_chemin).rgb * teinte_chemin, dans);
		relief = mix(relief, texture(chemin_relief, uv_chemin).rgb, dans);
	}
	ALBEDO = couleur;
	NORMAL_MAP = relief;
	NORMAL_MAP_DEPTH = force_relief;
	ROUGHNESS = 1.0;
}
