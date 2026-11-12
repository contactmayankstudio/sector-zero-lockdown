@tool
extends SceneTree

func inspect_model(scn_path: String):
	print("\n================== ", scn_path.get_file(), " ==================")
	var scn = load(scn_path) as PackedScene
	if not scn:
		print("Failed to load: ", scn_path)
		return
	var inst = scn.instantiate() as Node3D
	
	var aabb = AABB()
	var first = true
	var stack = [inst]
	while stack.size() > 0:
		var n = stack.pop_back()
		if n is VisualInstance3D:
			var box = n.transform * n.get_aabb()
			var p = n.get_parent_node_3d()
			while p != inst and p != null:
				box = p.transform * box
				p = p.get_parent_node_3d()
			if first:
				aabb = box
				first = false
			else:
				aabb = aabb.merge(box)
		for c in n.get_children():
			stack.push_back(c)
			
	print("Bounds: Pos=", aabb.position, " Size=", aabb.size)
	print("Center: ", aabb.position + aabb.size * 0.5)
	
	# Also inspect top children
	for c in inst.get_children():
		print("  Child: ", c.name, " pos=", c.position, " rot=", c.rotation_degrees, " scale=", c.scale)
		for c2 in c.get_children():
			print("    Sub: ", c2.name, " pos=", c2.position, " rot=", c2.rotation_degrees, " scale=", c2.scale)
			break
	inst.free()

func _init():
	inspect_model("res://scenes/weapons/models/primordium_vandal.scn")
	inspect_model("res://scenes/weapons/models/prowler_smg.scn")
	inspect_model("res://scenes/weapons/models/ray_gun_cod.scn")
	inspect_model("res://scenes/weapons/models/plasma_gun.scn")
	inspect_model("res://scenes/weapons/models/rocket_launcher.scn")
	inspect_model("res://scenes/weapons/models/pestilence_handgun.scn")
	quit()
