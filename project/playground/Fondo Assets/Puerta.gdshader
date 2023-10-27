// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix, skip_vertex_transform;

uniform float upper_limit: hint_range(0.0, 1.0, 0.01) = 0.2;

void vertex() {
	float width_unscaled = abs(VERTEX.x);
	float width_scaled = abs(MODEL_MATRIX * vec4(VERTEX, 0.0, 0.0)).x;
    VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	VERTEX.y += (width_scaled-width_unscaled) * 0.2;
}

void fragment() {
	if (SCREEN_UV.y < upper_limit) {
		discard;
	}
}