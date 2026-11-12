@tool
extends SceneTree

func _init():
	print("Testing CURRENT_RENDERER in shader preprocessor...")
	var shader = Shader.new()
	shader.code = """
shader_type spatial;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 ndc;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	ALBEDO = vec3(linear_depth * 0.01);
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	print("Compiled preprocessor shader successfully!")
	quit(0)
