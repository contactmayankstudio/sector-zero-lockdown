@tool
extends SceneTree

func _init():
	var root_node = Node3D.new()
	root.add_child(root_node)
	
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	root_node.add_child(inst)
	
	var wf = inst.find_child("Wheel_F", true, false)
	var wb = inst.find_child("Wheel_B", true, false)
	if wf:
		print("Wheel_F global pos: ", wf.global_position)
	if wb:
		print("Wheel_B global pos: ", wb.global_position)
		
	var glass = inst.find_child("glasses", true, false)
	if glass:
		print("Glasses global pos: ", glass.global_position)
		
	var aabb = _calc_bounds(inst)
	print("Hayabusa bounds: min=", aabb.position, " max=", aabb.end, " size=", aabb.size)

	root_node.queue_free()
	quit(0)

func _calc_bounds(node: Node3D) -> AABB:
	var total_aabb = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh:
			var curr_aabb = curr.global_transform * curr.get_aabb()
			if first:
				total_aabb = curr_aabb
				first = false
			else:
				total_aabb = total_aabb.merge(curr_aabb)
		for c in curr.get_children():
			if c is Node3D:
				stack.push_back(c)
	return total_aabb
