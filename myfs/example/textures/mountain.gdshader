shader_type spatial;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D DIRT;
uniform sampler2D ROCK_NORMAL: hint_normal;
uniform vec3 BEACH_COLOR: source_color = vec3(1.0, 1.0, 0.0);
uniform vec3 GRASS_COLOR: source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 ROCK_COLOR: source_color = vec3(0.5, 0.5, 0.5);
uniform vec3 SNOW_COLOR: source_color = vec3(1.0, 1.0, 1.0);

// Function to blend the normal map with the original normal
vec3 blend_normal_map(sampler2D p_normal_map, vec2 p_uv, mat3 p_normal_matrix, vec3 p_original_normal, float p_strength) {
    // Sample the normal map
    vec3 normal_from_map = texture(p_normal_map, p_uv).xyz * 2.0 - 1.0;
    
    // Transform the normal from the normal map to view space
    vec3 view_normal_from_map = normalize(p_normal_matrix * normal_from_map);
    
    // Blend the original normal with the normal from the map
    return normalize(mix(p_original_normal, view_normal_from_map, p_strength));
}

uniform float height_base = 50.0;
uniform float height_scale = 600.0;
uniform float height_noise_scale = 6000.0;
uniform float texture_scale = 100.0;
uniform float transition_smoothness : hint_range(0.01, 0.5) = 0.1;

vec3 smooth_color_transition(vec3 color1, vec3 color2, float t, float smoothness) {
    float scaled_t = smoothstep(0.0, 1.0, (t - 0.5 * smoothness) / (1.0 - smoothness));
    return mix(color1, color2, scaled_t);
}

float range_lerp(float value, float istart, float istop, float ostart, float ostop) { 
         return ostart + (ostop - ostart) * ((value - istart) / (istop - istart)); 
 }

void fragment() {
    // Get the world position of the fragment
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Normalize the height to a 0-1 range
    float normalized_height = clamp((world_pos.y + height_base) / height_scale, 0.0, 1.0);
	float noise_amt = range_lerp(normalized_height, 0.0, 1.0, 0.1, 1);
    float noised_height = normalized_height + texture(NOISE_PATTERN, world_pos.xz / height_noise_scale).x * noise_amt - noise_amt / 2.0;
	
    // Define our four colors
    vec3 color1 = BEACH_COLOR;  // Yellow
    vec3 color2 = GRASS_COLOR;  // Green
    vec3 color3 = ROCK_COLOR;  // Gray
    vec3 color4 = SNOW_COLOR;  // White
    
    // Define transition points
    float transition1 = 0.2; // End of beach
    float transition2 = 0.7; // End of grass
    float transition3 = 0.9; // End of rock
    
    // Calculate smooth transitions
    vec3 final_color;
	float dirt_amt = 0.0;
	float rock_amt = 0.0;
    if (noised_height < transition1) {
		dirt_amt = 0.5;
		float t = noised_height / transition1;
        final_color = smooth_color_transition(color1, color2, t, transition_smoothness);
    } else if (noised_height < transition2) {
		float t = (noised_height - transition1) / (transition2 - transition1);
        dirt_amt = mix(0.5, 0, t);
		final_color = smooth_color_transition(color2, color3, t, transition_smoothness);
		rock_amt = mix(0.0, 1.0, t);
    } else if (noised_height < transition3) {
		float t = (noised_height - transition2) / (transition3 - transition2);
        final_color = smooth_color_transition(color3, color4, t, transition_smoothness);
		rock_amt = mix(1.0, 0.0, t);
    } else {
        final_color = color4;
    }
	final_color = mix(final_color, texture(DIRT, world_pos.xz / texture_scale).rgb, dirt_amt);
    // final_color = mix(final_color, vec3(1.0, 0.0, 0.0), rock_amt);
	
    mat3 normal_matrix = mat3(INV_VIEW_MATRIX) * mat3(MODEL_MATRIX);
	NORMAL = blend_normal_map(ROCK_NORMAL, world_pos.xz / texture_scale, normal_matrix, NORMAL, rock_amt);
	
    // Set the albedo color
    ALBEDO = final_color;
}
