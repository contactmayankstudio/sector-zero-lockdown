@tool
extends SceneTree

func _init():
	var test_weapons = [
		"scifi_battle_rifle",
		"vaccinator_energy",
		"axon_cannon",
		"car_smg",
		"prowl_blaster",
		"arcade_gun",
		"retro_ray_gun"
	]
	
	for wname in test_weapons:
		var path = "res://scenes/weapons/models/%s.scn" % wname
		var scn = load(path)
		if not scn:
			continue
		var inst = scn.instantiate()
		root.add_child(inst)
		await process_frame
		
		# Traverse all MeshInstance3D nodes and check their AABB
		print("\n--- Model: %s ---" % wname)
		var stack = [inst]
		while stack.size() > 0:
			var n = stack.pop_back()
			if n is MeshInstance3D:
				var m = n.mesh
				if m:
					var aabb = m.get_aabb()
					print("  Node '%s' AABB: pos=%s, size=%s" % [n.name, str(aabb.position), str(aabb.size)])
			for c in n.get_children():
				stack.append(c)
		inst.queue_free()
	quit(0)
