// Le sol des zones : de grandes taches (deux couleurs), un grain fin, et un chemin de terre
// sinueux (facultatif). Tout est calculé à partir de la position dans le monde : les zones
// voisines se raccordent sans couture, et le chemin continue d'une zone à l'autre.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec3 couleur_claire : source_color = vec3(0.5, 0.66, 0.3);
uniform vec3 couleur_sombre : source_color = vec3(0.36, 0.56, 0.27);
// Un bruit en niveaux de gris, qui se répète sans couture (scenes/monde/bruit_sol.tres).
uniform sampler2D bruit : repeat_enable, filter_linear_mipmap;
// Taille des taches et du grain : plus le nombre est petit, plus ils sont grands.
uniform float echelle_taches = 0.035;
uniform float echelle_grain = 0.7;
// Force du grain (0 = sol lisse).
uniform float force_grain = 0.24;

// Chemin de terre : largeur 0 = pas de chemin. Il suit l'axe x = chemin_x en ondulant,
// entre chemin_z_debut (au sud) et chemin_z_fin (au nord, plus négatif).
uniform vec3 couleur_chemin : source_color = vec3(0.5, 0.41, 0.29);
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
	float taches = texture(bruit, sol * echelle_taches).r;
	float grain = texture(bruit, sol * echelle_grain).r;
	vec3 couleur = mix(couleur_sombre, couleur_claire, smoothstep(0.3, 0.7, taches));
	couleur *= 1.0 - force_grain * 0.5 + force_grain * grain;
	if (chemin_largeur > 0.0) {
		float ondulation = (texture(bruit, vec2(position_monde.z * 0.013, 0.37)).r - 0.5) * 9.0;
		float ecart = abs(position_monde.x - chemin_x - ondulation);
		float bord = chemin_largeur * 0.5 + (grain - 0.5) * 0.9;
		float dans = 1.0 - smoothstep(bord - 0.5, bord + 0.25, ecart);
		dans *= smoothstep(chemin_z_fin - 1.0, chemin_z_fin + 1.0, position_monde.z);
		dans *= 1.0 - smoothstep(chemin_z_debut - 1.0, chemin_z_debut + 1.0, position_monde.z);
		couleur = mix(couleur, couleur_chemin * (0.85 + 0.3 * grain), dans);
	}
	ALBEDO = couleur;
	ROUGHNESS = 1.0;
}
