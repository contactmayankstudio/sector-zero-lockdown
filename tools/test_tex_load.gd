@tool
extends SceneTree

func _init():
	var tex = load("res://textures/pbr/asphalt/asphalt_02_diff_1k.jpg") as Texture2D
	if tex:
		print("Loaded tex: ", tex.get_size(), " format: ", tex.get_format() if tex.has_method("get_format") else "N/A")
	quit(0)
