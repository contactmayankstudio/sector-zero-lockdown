extends SceneTree

func _init():
	var scenes = [
		"res://scenes/environments/models/RealCityBuildings8.scn",
		"res://scenes/environments/models/RealStreet6.scn",
		"res://scenes/environments/props/PoliceCarProp.scn",
		"res://scenes/vehicles/DrivableCar.tscn",
		"res://scenes/vehicles/DrivableBike.tscn"
	]
	for p in scenes:
		var scn = load(p)
		if scn:
			var inst = scn.instantiate()
			var mi_count = 0
			var vert_count = 0
			var stack = [inst]
			while stack.size() > 0:
				var c = stack.pop_back()
				if c is MeshInstance3D and c.mesh:
					mi_count += 1
					for s in range(c.mesh.get_surface_count()):
						vert_count += c.mesh.surface_get_array_len(s)
				for ch in c.get_children():
					stack.append(ch)
			print(p, " -> MeshInstances: ", mi_count, " Vertices: ", vert_count)
			inst.free()
	quit()
