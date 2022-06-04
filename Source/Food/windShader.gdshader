shader_type canvas_item;

uniform mat4 global_transform;

//wave 1 is the overall wind affecting all leaves at the same time
uniform float waveAmplitude : hint_range(0, 300, 1) = 50;
uniform float waveSpeed : hint_range(0, 1000, 1) = 1;
uniform float waveLength : hint_range(10, 2000, 5) = 100;

void vertex() {
	mat4 INV_WORLD_MATRIX = inverse(global_transform);
	vec2 worldPos = (global_transform * vec4(VERTEX.x, VERTEX.y, 0.0, 1.0)).xy;
	float offsetFactor = smoothstep(0.2, 1.0, 1.0-UV.y); //make the bottom not move
	float windPhase = (worldPos.x + TIME * waveSpeed) / waveLength;
	float worldWaveOffsetX = sin(windPhase) * waveAmplitude * offsetFactor;
	vec2 worldNewPos = vec2(worldPos.x + worldWaveOffsetX, worldPos.y);
	vec4 newTransform = INV_WORLD_MATRIX * vec4(worldNewPos, 0.0, 1.0);
    VERTEX.xy = newTransform.xy;
	//VERTEX.x += worldWaveOffsetX;

	// vec4 waveDirection = INV_WORLD_MATRIX * vec4(cos(waveDirectionAngleRad), 0.0, sin(waveDirectionAngleRad), 0.0);
	// VERTEX.xz += waveDirection.xz * waveAmp * waveAmplitude; //main wind gushes
	// VERTEX.xz += vec2(waveAmp2 * waveAmplitude2, 0.0); //smaller peturbations
}
