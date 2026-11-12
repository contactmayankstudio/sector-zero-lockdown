@tool
extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	p.free()

	print("--- RENDERING WEAPON PREVIEWS TO VERIFY ALIGNMENT ---")
	
	# Create off-screen rendering subviewport
	var vp = SubViewport.new()
	vp.size = Vector2i(512, 512)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = true
	
	var world = World3D.new()
	vp.world_3d = world
	
	var cam = Camera3D.new()
	cam.position = Vector3(0.0, 0.0, 0.0) # Camera at eye position looking down -Z
	cam.current = true
	vp.add_child(cam)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, 45, 0)
	vp.add_child(light)

	root.add_child(vp)

	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			continue
		var res = load(model_path)
		if not (res is PackedScene):
			continue

		var holder = Node3D.new()
		# Position weapon in right hand forward view: X: 0.18, Y: -0.16, Z: -0.42
		holder.position = Vector3(0.16, -0.16, -0.42)
		vp.add_child(holder)

		var inst = res.instantiate()
		if cfg.has("basis"):
			inst.transform.basis = cfg.basis
		elif cfg.has("rot"):
			inst.rotation_degrees = cfg.rot
		if cfg.has("scale"):
			inst.scale = cfg.scale
		if cfg.has("offset"):
			inst.position = cfg.offset
		holder.add_child(inst)

		# Wait frames
		for frame in range(3):
			await RenderingServer.frame_post_draw

		var img = vp.get_texture().get_image()
		if img:
			var save_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/weapon_preview_%s.png" % wid
			img.save_png(save_path)
			print("Saved preview: ", save_path)

		holder.queue_free()

	print("DONE ALL WEAPON PREVIEWS!")
	quit(0)
