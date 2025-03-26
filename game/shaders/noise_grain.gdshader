shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform bool animate = false;

void fragment() {
	// Sample the original screen texture
	vec4 original_color = texture(screen_texture, SCREEN_UV);

	float noise = 0.0;
	vec2 base;

	if (animate) {
		base = UV * TIME;
	} else {
		base = UV;
	}

	// Generate random noise
	noise = (fract(sin(dot(base, vec2(.01, -.02))) * 10000.) - 0.5) * 2.0;
	// Add noise to the original color
	original_color.rgb += noise * grain;

	// Clamp the final color to make sure it stays in the valid range
	COLOR = clamp(original_color, 0.0, 1.0);
}
