@tool
extends SceneTree

func _init():
	print("=== RUNNING GAMEPLAY QA VERIFICATION ===")
	var scene_res = load("res://scenes/environments/AirportTerminal.tscn")
	if not scene_res:
		print("ERROR: Failed loading AirportTerminal.tscn")
		quit(1)
		return
		
	var game_scene = scene_res.instantiate()
	root.add_child(game_scene)
	
	# Give scene time to initialize
	for i in range(10):
		await process_frame
		
	var player = game_scene.find_child("Player", true, false)
	var spawner = game_scene.find_child("ZombieSpawner", true, false)
	
	print("Player found: ", player != null)
	print("Spawner found: ", spawner != null)
	
	if player:
		print("Player max_health: ", player.max_health, " current_health: ", player.current_health)
		print("Player is_stationary: ", player.is_stationary)
		
	# Wait for zombies to spawn and advance
	var zombie_detected = false
	for frame in range(90): # ~1.5 - 3.0 seconds
		await process_frame
		var zombies = root.find_children("*", "CharacterBody3D", true, false)
		for z in zombies:
			if z != player and z.is_in_group("zombies"):
				zombie_detected = true
				var skel: Skeleton3D = z.find_child("*Skeleton3D*", true, false)
				if skel and frame % 30 == 0:
					var b_head = skel.find_bone("mixamorig_Head_06")
					var b_hips = skel.find_bone("mixamorig_Hips_01")
					var b_toe = skel.find_bone("mixamorig_LeftToeBase_060")
					var gh = (skel.global_transform * skel.get_bone_global_pose(b_head)).origin
					var ghip = (skel.global_transform * skel.get_bone_global_pose(b_hips)).origin
					var gt = (skel.global_transform * skel.get_bone_global_pose(b_toe)).origin
					print("Frame %d | Zombie '%s' pos: %s | Head Y: %.2fm | Hips Y: %.2fm | Toe Y: %.2fm" % [
						frame, z.name, str(z.global_position), gh.y, ghip.y, gt.y
					])
					print("  Distance to player: %.2fm | Facing dir check (Toe Z vs Hips Z): %.3f" % [
						z.global_position.distance_to(player.global_position if player else Vector3.ZERO),
						gt.z - ghip.z
					])
					
	print("Zombie detected in gameplay: ", zombie_detected)
	
	# Capture a screenshot from the player's camera
	var vp = root.get_viewport()
	if vp:
		for i in range(3):
			await process_frame
		var img = vp.get_texture().get_image()
		if img and not img.is_empty():
			DirAccess.make_dir_recursive_absolute("screenshots")
			img.save_png("screenshots/gameplay_qa_fixed.png")
			print("Saved screenshot: screenshots/gameplay_qa_fixed.png")
			
	game_scene.queue_free()
	print("=== GAMEPLAY QA VERIFICATION COMPLETE ===")
	quit(0)
