shader_type canvas_item;

uniform vec2  shadow_offset : hint_range(-20, 20) = vec2(3.0, 4.0);
uniform vec4  shadow_color  : source_color        = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	vec4 sprite = texture(TEXTURE, UV);

	vec2 shadow_uv = UV - shadow_offset * TEXTURE_PIXEL_SIZE;
	float shadow_alpha = texture(TEXTURE, shadow_uv).a * shadow_color.a;

	vec4 shadow = vec4(shadow_color.rgb, shadow_alpha);

	// Draw shadow behind sprite
	COLOR = mix(shadow, sprite, sprite.a);
}
