shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform bool shader_on = false;

void fragment(){
	//COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	if(shader_on){
		//float lum = (0.2126*COLOR.r + 0.7152*COLOR.g + 0.0722*COLOR.b);
		float lum = (0.2126*col.r + 0.7152*col.g + 0.0722*col.b);
		col.rgb = vec3(lum);
		//COLOR = vec4(lum, lum, lum, COLOR.a);
	//}else{
		//COLOR = vec4(0,0,0,0);
	}
	COLOR = col;
}