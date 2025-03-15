shader_type canvas_item;

uniform bool effect_enabled = false;


void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
	vec4 original_color = texture(TEXTURE, UV); // Store the original color

    if (effect_enabled) {
        //tex_color.rgb *= vec3(1.0, 0.5, 0.5); // Example: Tint red
		//tex_color.rgb *= vec3(1.0, 1.0, 1.0); // Tint white
		float white_tint_factor = 0.5; // Adjust this value (0.0 to 1.0)
		tex_color.rgb = mix(tex_color.rgb, vec3(1.0, 0.5, 0.5), white_tint_factor);

		COLOR = tex_color;
    }
	else{
		COLOR = original_color;
	}

 
}
