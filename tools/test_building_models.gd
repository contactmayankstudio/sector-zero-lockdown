extends SceneTree

func _init():
	var models = [
		"res://scenes/environments/models/RealCityBuildings8.scn",
		"res://scenes/environments/models/RealStreet6.scn",
		"res://scenes/environments/models/RealApartment.scn",
		"res://scenes/environments/models/RealCityStreet7.scn",
		"res://scenes/environments/models/Supermarket.scn"
	]
	for mpath in models:
		var scn = load(mpath)
		if scn:
			var inst = scn.instantiate()
			print("=== ", mpath, " ===")
			print("  root: ", inst.name, " class: ", inst.get_class())
			var aabb = _calc_aabb(inst)
			print("  AABB size: ", aabb.size, " pos: ", aabb.position)
			inst.free()
	quit()

func _calc_aabb(node: Node3D) -> AABB:
	var total_aabb = AABB()
	var first = true
	var stack = [node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is VisualInstance3D:
			var cur_aabb = curr.get_aabb()
			if first:
				total_aabb = cur_aabb
				first = false
			else:
				total_aabb = total_aabb.merge(cur_aabb)
		for c in curr.get_children():
			if c is Node3D:
				stack.append(c)
	return total_aabb
