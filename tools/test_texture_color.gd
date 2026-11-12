@tool
extends SceneTree

func _init():
	var tex = load("res://textures/pbr/grass/grass_diff_1k.jpg") as Texture2D
	print("Texture loaded: ", tex != null)
	if tex:
		var img = tex.get_image()
		print("Image: ", img != null)
		if img:
			print("Format: ", img.get_format(), " size: ", img.get_size())
			var pixel = img.get_pixel(100, 100)
			print("Sample pixel (100,100): ", pixel)
	
	var mat = load("res://resources/materials/mat_real_grass_pbr.tres") as StandardMaterial3D
	if mat:
		print("mat_real_grass_pbr albedo_color: ", mat.albedo_color)
		print("mat_real_grass_pbr albedo_texture: ", mat.albedo_texture)
		print("mat_real_grass_pbr uv1_scale: ", mat.uv1_scale)
	quit()
