extends SceneTree

func _init():
	var p_scene = load("res://scenes/player/Player.tscn")
	var p = p_scene.instantiate()
	
	# Let's find index of each
	var configs = p.weapon_configs
	
	# 1. prowler_smg:
	# Raw AABB in world when rot=(1, 1.5, 0):
	# Let's see: where does it end up with offset Vector3(-0.04, -0.15, -0.05)?
	for cfg in configs:
		if cfg.id == "prowler_smg":
			# Let's find the mesh position when instantiated
			var res = load(cfg.model)
			var inst = res.instantiate()
			inst.rotation_degrees = cfg.rot
			inst.scale = cfg.scale
			var meshes = inst.find_children("*", "MeshInstance3D", true, false)
			var avg_pos = Vector3.ZERO
			for m in meshes:
				avg_pos += (inst.transform * m.transform).origin
			avg_pos /= float(meshes.size())
			print("prowler_smg scaled mesh center: ", avg_pos)
			# We want the mesh center to be roughly near (0, 0, -0.2) in weapon space
			# So cfg.offset should cancel avg_pos!
			print("Recommended prowler offset: ", -avg_pos + Vector3(0.0, -0.05, -0.2))
			inst.free()
			
		elif cfg.id == "ray_gun_cod":
			var res = load(cfg.model)
			var inst = res.instantiate()
			# Test with scale 0.04
			var test_scale = Vector3(0.04, 0.04, 0.04)
			inst.scale = test_scale
			inst.rotation_degrees = cfg.rot
			var meshes = inst.find_children("*", "MeshInstance3D", true, false)
			var min_v = Vector3(999, 999, 999)
			var max_v = Vector3(-999, -999, -999)
			for m in meshes:
				if m.mesh:
					var aabb = (inst.transform * m.transform) * m.mesh.get_aabb()
					min_v.x = min(min_v.x, aabb.position.x)
					min_v.y = min(min_v.y, aabb.position.y)
					min_v.z = min(min_v.z, aabb.position.z)
					max_v.x = max(max_v.x, aabb.end.x)
					max_v.y = max(max_v.y, aabb.end.y)
					max_v.z = max(max_v.z, aabb.end.z)
			var center = (min_v + max_v) * 0.5
			print("ray_gun_cod with scale 0.04 center: ", center, " size: ", (max_v - min_v))
			inst.free()

	p.free()
	quit(0)
