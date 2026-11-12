@tool
extends SceneTree

func _init():
	print("[TEST] Loading ZombieNightHighway scene...")
	var scn = load("res://scenes/environments/ZombieNightHighway.tscn")
	if not scn:
		printerr("Failed to load ZombieNightHighway.tscn")
		quit(1)
		return
		
	var inst: Node3D = scn.instantiate()
	root.add_child(inst)
	
	# Wait for setup and frame rendering
	for i in range(20):
		await process_frame
		
	var car = inst.get_node_or_null("DrivableCar")
	var hud = inst.get_node_or_null("RoadkillHUD")
	print("Car present: ", car != null)
	print("Roadkill HUD present: ", hud != null)
	if car:
		print("Car pos: ", car.global_position, " occupied: ", car.get("is_occupied"))
	
	await process_frame
	var vp = root.get_viewport()
	var tex = vp.get_texture()
	if tex:
		var img = tex.get_image()
		if img and not img.is_empty():
			var out_path = "/home/am/.gemini/antigravity-cli/brain/08378c8c-9ce1-4412-b567-0c21abef9f63/zombie_highway_roadkill_verified.png"
			img.save_png(out_path)
			print("Saved screenshot to: ", out_path)
			
	inst.queue_free()
	quit(0)
