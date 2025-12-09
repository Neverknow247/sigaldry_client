shader_type canvas_item;

uniform float gray_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	float lum =
		0.2126 * base.r +
		0.7152 * base.g +
		0.0722 * base.b;

	vec3 gray = vec3(lum);

	base.rgb = mix(base.rgb, gray, gray_amount);

	COLOR = base;
}