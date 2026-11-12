extends SceneTree

func _init():
	var scn = load("res://scenes/environments/GTAGroveStreetDirect.tscn")
	if not scn:
		print("Failed to load grove street")
		quit(1)
		return
	var inst = scn.instantiate()
	var min_y = 9999.0
	var max_y = -9999.0
	var mesh_count = 0
	
	for child in inst.get_children():
		if child is VisualInstance3D:
			mesh_count += 1
			var aabb = child.get_aabb()
			var pos = child.position
			var world_min_y = pos.y + aabb.position.y
			var world_max_y = pos.y + aabb.position.y + aabb.size.y
			if world_min_y < min_y: min_y = world_min_y
			if world_max_y > max_y: max_y = world_max_y
			if mesh_count <= 10:
				print(child.name, " pos=", pos, " AABB Y=[", world_min_y, ", ", world_max_y, "]")
	
	print("Total meshes:", mesh_count)
	print("Overall Min Y:", min_y, " Max Y:", max_y)
	quit(0)
