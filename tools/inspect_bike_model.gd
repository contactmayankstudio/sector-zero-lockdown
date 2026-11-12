@tool
extends SceneTree

func _init():
	print("=== Inspecting Bike Models ===")
	var paths = [
		"res://assets/downloaded_bikes/hayabusa.glb",
		"res://assets/downloaded_bikes/zx10r.glb",
		"res://assets/downloaded_bikes/vehicle-motorcycle.glb"
	]
	for p in paths:
		print("\n--- Model: ", p, " ---")
		var scn = load(p)
		if not scn:
			printerr("Failed to load: ", p)
			continue
		var inst = scn.instantiate()
		_inspect_node(inst, 0)
		var total_aabb = _calc_bounds(inst)
		print("Overall Bounds: pos=", total_aabb.position, " size=", total_aabb.size)
		inst.queue_free()
	quit(0)

func _inspect_node(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	var info = "%s%s (%s)" % [indent, node.name, node.get_class()]
	if node is MeshInstance3D:
		var aabb = node.get_aabb()
		info += " [Mesh: %s, AABB: %s]" % [node.mesh.resource_name if node.mesh else "None", aabb]
		if node.mesh:
			for i in range(node.mesh.get_surface_count()):
				var mat = node.get_surface_override_material(i)
				if not mat:
					mat = node.mesh.surface_get_material(i)
				var mat_name = mat.resource_name if mat else "None"
				var mat_type = mat.get_class() if mat else ""
				info += "\n%s  -> Surface %d: %s (%s)" % [indent, i, mat_name, mat_type]
	print(info)
	for child in node.get_children():
		_inspect_node(child, depth + 1)

func _calc_bounds(node: Node3D) -> AABB:
	var total_aabb = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh:
			var curr_aabb = curr.transform * curr.get_aabb()
			if first:
				total_aabb = curr_aabb
				first = false
			else:
				total_aabb = total_aabb.merge(curr_aabb)
		for c in curr.get_children():
			if c is Node3D:
				stack.push_back(c)
	return total_aabb
