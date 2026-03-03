shader_type canvas_item;

uniform float glow_strength : hint_range(0.0, 10.0) = 2.5;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex * glow_strength;
}
