@tool
extends SceneTree

func _init():
	print("=== TESTING PROCEDURAL 3D HEALTH BAR ===")
	var root = Node3D.new()
	get_root().add_child(root)
	
	var bar_node = Node3D.new()
	bar_node.name = "HealthBar3D"
	root.add_child(bar_node)
	
	# Create Sprite3D
	var sprite = Sprite3D.new()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.no_depth_test = true
	sprite.pixel_size = 0.008
	bar_node.add_child(sprite)
	
	# Create Image
	var w = 100
	var h = 12
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.08, 0.08, 0.1, 0.9)) # background
	# Border
	for x in range(w):
		img.set_pixel(x, 0, Color(0.2, 0.2, 0.25, 1.0))
		img.set_pixel(x, h - 1, Color(0.2, 0.2, 0.25, 1.0))
	for y in range(h):
		img.set_pixel(0, y, Color(0.2, 0.2, 0.25, 1.0))
		img.set_pixel(w - 1, y, Color(0.2, 0.2, 0.25, 1.0))
	# Fill health 70%
	var fill_w = int((w - 2) * 0.7)
	img.fill_rect(Rect2i(1, 1, fill_w, h - 2), Color(0.9, 0.15, 0.15, 1.0))
	
	var tex = ImageTexture.create_from_image(img)
	sprite.texture = tex
	print("Sprite3D created with texture: ", tex.get_size())
	
	# Create Label3D
	var lbl = Label3D.new()
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.text = "-35 HEADSHOT"
	lbl.font_size = 22
	lbl.modulate = Color(1.0, 0.85, 0.2)
	lbl.position.y = 0.18
	bar_node.add_child(lbl)
	print("Label3D created: ", lbl.text)
	
	root.free()
	print("SUCCESS: Procedural 3D Health Bar works cleanly!")
	quit(0)
