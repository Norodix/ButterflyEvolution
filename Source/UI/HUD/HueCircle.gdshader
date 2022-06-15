shader_type canvas_item;

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment(){
	float r = (UV.x-0.5) * (UV.x-0.5) + (UV.y-0.5) * (UV.y-0.5);
	r *= 4.0; //compensate to -1 to 1
	float ring = smoothstep(0.52, 0.55, r) * (1.0-smoothstep(0.97, 1.0, r));
	//float ring = step(0.55, r) * (1.0 - step(1.0, r));
	COLOR.a = ring;
	float angle = atan(UV.y-0.5, UV.x-0.5) / 2.0 / 3.1415;
	//COLOR .rgb = atan(UV.y, UV.x);
	COLOR.rgb = hsv2rgb(vec3(fract(angle + 0.25), 1.0, 1.0));
	//COLOR.rgb = vec3(angle);
	//internal darker background
	COLOR.rgb *= smoothstep(0.52, 0.55, r);
	COLOR.a = clamp(0.0, 1.0, COLOR.a + float(r<0.55) * 0.5);
}
