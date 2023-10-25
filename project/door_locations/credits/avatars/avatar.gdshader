shader_type canvas_item;

uniform sampler2D selected_overlay;
uniform bool selected;

void fragment() {
	float len = length(vec2(.5) - UV);
	if (selected) {
		vec4 overlay_pixel = texture(selected_overlay, UV);
		COLOR.rgb = mix(COLOR, overlay_pixel, overlay_pixel.a).rgb;
	}
	if (len >= .48 && len <= .50) {
		len -= .48;
		len /= 0.02;
		COLOR.a = 1.0 - len;
	} else if (len > .5) {
		discard;
	}
}
