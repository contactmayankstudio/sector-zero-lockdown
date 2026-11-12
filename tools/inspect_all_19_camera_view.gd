@tool
extends SceneTree

# Inspect all 19 weapons in Player camera view
func _init():
	var player_scn = load("res://scenes/player/Player.tscn")
	var player = player_scn.instantiate()
	root.add_child(player)
	
	# Wait for Player to initialize weapons
	if not player.is_node_ready():
		await player.ready
	for f in range(5):
		await process_frame
		
	var cam: Camera3D = player.get_node("Camera3D")
	var wm: Node3D = cam.get_node("WeaponManager")
	
	print("\n========================================================")
	print("    INSPECTING ALL 19 WEAPONS IN FIRST-PERSON VIEW")
	print("========================================================")
	print("Camera Global Pos: ", cam.global_position)
	print("WeaponManager Pos relative to Cam: ", wm.position)
	
	var weapons_list = player.get("weapons")
	if not weapons_list:
		print("ERROR: weapons list is null or empty!")
		quit(1)
		return
		
	for idx in range(weapons_list.size()):
		var w = weapons_list[idx]
		var wid = w.weapon_data.weapon_id if w.weapon_data else "unknown"
		var wname = w.weapon_data.display_name if w.weapon_data else "unknown"
		
		# Find the 3D model under w
		var model = w.get_node_or_null("WeaponModel")
		if not model:
			model = w.get_node_or_null("CustomModel")
		if not model and w.has_node("MeshInstance3D"):
			model = w.get_node("MeshInstance3D")
			
		if not model:
			print("Weapon [%02d] %s: NO MODEL FOUND!" % [idx, wid])
			continue
			
		# Compute bounds relative to Camera3D
		var min_cam = Vector3(1e9, 1e9, 1e9)
		var max_cam = Vector3(-1e9, -1e9, -1e9)
		var vert_count = 0
		
		var stack = [model]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var mesh: Mesh = curr.mesh
				var gt: Transform3D = curr.global_transform
				# Transform to camera local space
				var cam_local = cam.global_transform.affine_inverse() * gt
				for s in range(mesh.get_surface_count()):
					var arr = mesh.surface_get_arrays(s)
					if arr.size() > Mesh.ARRAY_VERTEX:
						for v in arr[Mesh.ARRAY_VERTEX]:
							var cv = cam_local * v
							min_cam.x = min(min_cam.x, cv.x)
							min_cam.y = min(min_cam.y, cv.y)
							min_cam.z = min(min_cam.z, cv.z)
							max_cam.x = max(max_cam.x, cv.x)
							max_cam.y = max(max_cam.y, cv.y)
							max_cam.z = max(max_cam.z, cv.z)
							vert_count += 1
			for c in curr.get_children():
				stack.append(c)
				
		var size = max_cam - min_cam
		var center = (min_cam + max_cam) * 0.5
		print("\n[%02d] %s (%s):" % [idx, wid, wname])
		print("   Cam-Local Min: %s | Max: %s" % [str(min_cam), str(max_cam)])
		print("   Size in view:  X: %.3fm, Y: %.3fm, Z: %.3fm (Verts: %d)" % [size.x, size.y, size.z, vert_count])
		print("   Center in Cam: %s" % str(center))
		
		# Diagnostics:
		if size.x < 0.02 or size.y < 0.02 or size.z < 0.02:
			print("   >>> WARNING: TOO SMALL / INVISIBLE! <<<")
		elif size.x > 0.8 or size.y > 0.8 or size.z > 2.0:
			print("   >>> WARNING: TOO HUGE / BLOCKING SCREEN! <<<")
			
		if center.y > 0.1:
			print("   >>> WARNING: POSITIONED TOO HIGH (blocking center/top)! <<<")
		elif center.y < -0.6:
			print("   >>> WARNING: POSITIONED TOO LOW (off-screen below)! <<<")
			
		if center.x < 0.0:
			print("   >>> WARNING: POSITIONED ON LEFT SIDE (should be on right side: X > 0.1)! <<<")
		elif center.x > 0.5:
			print("   >>> WARNING: POSITIONED TOO FAR RIGHT (off-screen right)! <<<")
			
		if min_cam.z > -0.1:
			print("   >>> WARNING: BEHIND CAMERA NEAR PLANE! <<<")
			
	player.queue_free()
	quit(0)
