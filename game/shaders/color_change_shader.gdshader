shader_type canvas_item;

uniform vec4 og_color : source_color;
uniform vec4 new_color : source_color;

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);

    // Define a threshold for the comparison
	if (COLOR == og_color){
		COLOR = new_color;
	}
	else{
		COLOR.rgb = curr_color.rgb;
	}
	
}
