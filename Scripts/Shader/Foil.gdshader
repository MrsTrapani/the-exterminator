shader_type canvas_item;

uniform float foil_strength : hint_range(0.0, 1.0) = 0.35;
uniform float rainbow_scale : hint_range(0.1, 8.0) = 1.5;
uniform float shine_strength : hint_range(0.0, 2.0) = 0.45;
uniform float shine_width : hint_range(0.01, 0.4) = 0.12;
uniform float speed : hint_range(0.0, 1.0) = 0.15;

// Animate this manually for an interactive foil effect.
uniform float foil_offset : hint_range(-2.0, 2.0) = 0.0;

varying vec4 item_color;

vec3 rainbow(float hue) {
	return 0.5 + 0.5 * cos(
		6.283185 * (hue + vec3(0.0, 0.666667, 0.333333))
	);
}

void vertex() {
	item_color = COLOR;
}

void fragment() {
	vec4 card = texture(TEXTURE, UV) * item_color;

	float diagonal = UV.x + UV.y * 0.6;
	float motion = TIME * speed + foil_offset;

	vec3 foil = rainbow(diagonal * rainbow_scale + motion);

	vec3 color = mix(
		card.rgb,
		card.rgb * foil * 2.0,
		foil_strength
	);

	float sweep = fract(diagonal * 0.5 - motion);
	float distance_to_shine = abs(sweep - 0.5);
	float shine = 1.0 - smoothstep(
		0.0, shine_width, distance_to_shine
	);

	color += foil * shine * shine_strength;

	COLOR = vec4(color, card.a);
}