extends SceneTree

func _init():
	var LM = load("res://scripts/Loading/LoadingManager.gd")
	var inst = LM.new()
	var bg_tex = null
	for child in inst.loading_ui_layer.get_children():
		if child is TextureRect:
			bg_tex = child
			break
	print("LoadingManager bg_tex found: ", bg_tex != null)
	if bg_tex:
		print("Texture: ", bg_tex.texture)
	inst.free()
	quit()
