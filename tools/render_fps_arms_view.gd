extends SceneTree

func _init():
	print("[START] Loading UrbanStreet scene for arms & weapon check...")
	var scene = load("res://scenes/environments/UrbanStreet.tscn")
	if not scene:
		print("Failed to load scene")
		quit(1)
		return

	var world = scene.instantiate()
	root.add_child(world)

	# Let world initialize and settle
	for i in range(20):
		await process_frame

	var player = world.find_child("Player", true, false)
	if player:
		print("Player found at ", player.global_position)
		var arms = player.get_node_or_null("Camera3D/FPSArms")
		if arms:
			print("FPSArms found! Visible: ", arms.visible)
			for child in arms.get_children():
				print("  Arm child: ", child.name, " visible: ", child.visible)
				for sub in child.get_children():
					print("    Subchild: ", sub.name, " visible: ", sub.visible)

	for i in range(15):
		await process_frame

	var vp = root.get_viewport()
	var tex = vp.get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			img.save_png("screenshots/fps_arms_view_check.png")
			print("[SUCCESS] Saved screenshots/fps_arms_view_check.png")

	quit(0)
