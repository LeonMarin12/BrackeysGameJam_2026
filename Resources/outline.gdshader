shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0); // Blanco por defecto
uniform float line_thickness : hint_range(0, 10) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 0.0;
	
	// Comprobar los 8 píxeles vecinos para un outline más suave
	outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	
	// Limitar el valor
	outline = min(outline, 1.0);
	
	vec4 color = texture(TEXTURE, UV);
	
	// Si el píxel actual es transparente pero hay píxeles opacos cerca, dibujar el outline
	vec4 final_color = color;
	if (color.a < 0.1 && outline > 0.0) {
		final_color = line_color;
	}
	
	COLOR = final_color;
}