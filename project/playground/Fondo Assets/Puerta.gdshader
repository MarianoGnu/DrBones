// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix, skip_vertex_transform;

void vertex() {
	float width_unscaled = abs(VERTEX.x);
	float width_scaled = (MODEL_MATRIX * vec4(VERTEX, 0.0, 0.0)).x;
    VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	VERTEX.y += (width_scaled-width_unscaled) * 0.5;
	//VERTEX.y += width_scaled;
}