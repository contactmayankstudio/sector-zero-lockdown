@tool
extends SceneTree

func _init():
	var models = {
		"scifi_battle_rifle": "res://scenes/weapons/models/scifi_battle_rifle.scn",
		"vaccinator_energy": "res://scenes/weapons/models/vaccinator_energy.scn",
		"axon_cannon": "res://scenes/weapons/models/axon_cannon.scn",
		"car_smg": "res://scenes/weapons/models/car_smg.scn",
		"prowl_blaster": "res://scenes/weapons/models/prowl_blaster.scn",
		"arcade_gun": "res://scenes/weapons/models/arcade_gun.scn",
		"retro_ray_gun": "res://scenes/weapons/models/retro_ray_gun.scn",
	}
	
	for name in models:
		var path = models[name]
		var scn = load(path)
		if not scn:
			print("Could not load ", path)
			continue
		var inst = scn.instantiate()
		root.add_child(inst)
		
		# Find mesh bounds in model local space (no parent rotation/scale)
		var min_b = Vector3(1e9, 1e9, 1e9)
		var max_b = Vector3(-1e9, -1e9, -1e9)
		var stack = [inst]
		while stack.size() > 0:
			var curr = stack.pop_back()
			if curr is MeshInstance3D and curr.mesh:
				var m = curr.mesh
				var t = curr.global_transform
				for s in range(m.get_surface_count()):
					var arr = m.surface_get_arrays(s)
					if arr.size() > Mesh.ARRAY_VERTEX:
						for v in arr[Mesh.ARRAY_VERTEX]:
							var tv = t * v
							min_b.x = min(min_b.x, tv.x)
							min_b.y = min(min_b.y, tv.y)
							min_b.z = min(min_b.z, tv.z)
							max_b.x = max(max_b.x, tv.x)
							max_b.y = max(max_b.y, tv.y)
							max_b.z = max(max_b.z, tv.z)
			for c in curr.get_children():
				stack.append(c)
		var size = max_b - min_b
		print("Model [%s]: Min=%s, Max=%s, Size=(X:%.3f, Y:%.3f, Z:%.3f)" % [name, str(min_b), str(max_b), size.x, size.y, size.z])
		inst.queue_free()
	quit(0)
