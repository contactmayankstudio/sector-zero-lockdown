@tool
extends SceneTree

func _init():
	print("Testing Godot 4.7.2 shader compilation test...")
	var shader = Shader.new()
	shader.code = """
shader_type spatial;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

void fragment() {
	vec4 sc = textureLod(screen_texture, SCREEN_UV, 0.0);
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	ALBEDO = sc.rgb * depth;
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	print("Shader set successfully without error!")
	quit(0)
