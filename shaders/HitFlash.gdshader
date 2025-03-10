shader_type canvas_item;

uniform bool effect_enabled = false;


void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
	vec4 original_color = texture(TEXTURE, UV); // Store the original color

    if (effect_enabled) {
        tex_color.rgb *= vec3(1.0, 0.5, 0.5); // Example: Tint red
		COLOR = tex_color;
    }
	else{
		COLOR = original_color;
	}

 
}

