shader_type canvas_item;

uniform sampler2D selected_overlay;
uniform bool selected;

void fragment() {
	float len = length(vec2(.5) - UV);
	if (selected) {
		vec4 overlay_pixel = texture(selected_overlay, UV);
		COLOR.rgb = mix(COLOR, overlay_pixel, overlay_pixel.a).rgb;
	}
	if (len > .5) {
		discard;
	}
}
