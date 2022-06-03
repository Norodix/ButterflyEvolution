shader_type canvas_item;
uniform sampler2D colorCurve : hint_aniso; //This should be a gradient that maps black->white to the colors of the butterfly

void fragment(){
	float val = texture(TEXTURE, UV).r;
	val = sqrt(val);
	COLOR.rgb = texture(colorCurve, vec2(val, 0.0)).rgb;
	COLOR.a = texture(TEXTURE, UV).a;
	
}