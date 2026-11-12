extends SceneTree

func _init():
	call_deferred("_run_test")

func _run_test():
	print("=== TESTING REAL PHYSICS COLLISION ON MOUNTAINS ===")
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("ERROR: Could not load scene")
		quit(1)
		return

	var arena = scn.instantiate()
	get_root().add_child(arena)

	# Wait 2 frames for scene and physics server to sync
	for i in range(2):
		await process_frame

	var world_3d = get_root().get_world_3d()
	if not world_3d:
		print("ERROR: No world_3d on root")
		quit(1)
		return

	var space_state = world_3d.direct_space_state

	# Test raycasts downwards from y = 100 to y = -50 at various mountain locations
	var test_points = [
		Vector3(0.0, 100.0, 0.0),       # Highway center
		Vector3(-15.0, 100.0, 0.0),     # West sidewalk / shoulder
		Vector3(-45.0, 100.0, -100.0),  # West mountain base
		Vector3(-75.0, 100.0, -100.0),  # West mountain slope
		Vector3(-110.0, 100.0, -100.0), # West mountain ridge
		Vector3(-150.0, 100.0, -100.0), # West mountain far
		Vector3(45.0, 100.0, -100.0),   # East mountain base
		Vector3(75.0, 100.0, -100.0),   # East mountain slope
		Vector3(110.0, 100.0, -100.0),  # East mountain ridge
	]

	var all_hit = true
	for pt in test_points:
		var ray_query = PhysicsRayQueryParameters3D.create(pt, pt + Vector3(0, -150, 0))
		ray_query.collide_with_areas = false
		ray_query.collide_with_bodies = true
		var result = space_state.intersect_ray(ray_query)
		if result.is_empty():
			print("❌ NO COLLISION at (x=%.1f, z=%.1f)! Ray fell straight through to -50m!" % [pt.x, pt.z])
			all_hit = false
		else:
			print("✓ Ray hit at (x=%.1f, z=%.1f): Hit pos = (%.2f, %.2f, %.2f), Collider = %s (%s)" % [
				pt.x, pt.z, result.position.x, result.position.y, result.position.z, result.collider.name, result.collider.get_class()
			])

	if all_hit:
		print("\n🎉 ALL TEST POINTS HIT SOLID COLLISION GROUND! 100% SUCCESS!")
	else:
		print("\n⚠️ SOME TEST POINTS MISSED! GAP IN COLLISION FOUND!")

	arena.queue_free()
	quit(0 if all_hit else 1)
