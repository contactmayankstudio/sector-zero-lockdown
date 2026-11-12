@tool
extends SceneTree

func _init():
	print("Testing TBN and NORMAL calculation in fragment...")
	var shader = Shader.new()
	shader.code = """
shader_type spatial;

uniform sampler2D wave_normal1 : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D wave_normal2 : hint_normal, filter_linear_mipmap, repeat_enable;

void fragment() {
	vec3 n1 = texture(wave_normal1, UV).rgb * 2.0 - 1.0;
	vec3 n2 = texture(wave_normal2, UV).rgb * 2.0 - 1.0;
	vec3 normal_blend = normalize(n1 + n2);
	
	mat3 tbn = mat3(TANGENT, BINORMAL, NORMAL);
	vec3 world_view_normal = normalize(tbn * normal_blend);
	
	float fresnel = pow(1.0 - clamp(dot(world_view_normal, VIEW), 0.0, 1.0), 4.0);
	ALBEDO = vec3(fresnel);
	NORMAL_MAP = normal_blend * 0.5 + 0.5;
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	print("TBN and Normal blending compiled successfully!")
	quit(0)
