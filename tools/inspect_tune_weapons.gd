extends SceneTree

func _init():
	var p_scene = load("res://scenes/player/Player.tscn")
	var p = p_scene.instantiate()
	
	# Let's inspect raw dimensions of these 4 weapons
	var test_weapons = ["prowler_smg", "ray_gun_cod", "car_smg", "vaccinator_energy", "negev_ng7"]
	for cfg in p.weapon_configs:
		if cfg.id in test_weapons:
			print("\nWEAPON: ", cfg.id)
			print("  Current offset: ", cfg.offset)
			print("  Current rot: ", cfg.get("rot", "none"))
			print("  Current scale: ", cfg.scale)
			var res = load(cfg.model)
			if res is PackedScene:
				var inst = res.instantiate()
				var meshes = inst.find_children("*", "MeshInstance3D", true, false)
				var min_v = Vector3(999, 999, 999)
				var max_v = Vector3(-999, -999, -999)
				for m in meshes:
					if m.mesh:
						var aabb = m.transform * m.mesh.get_aabb()
						min_v.x = min(min_v.x, aabb.position.x)
						min_v.y = min(min_v.y, aabb.position.y)
						min_v.z = min(min_v.z, aabb.position.z)
						max_v.x = max(max_v.x, aabb.end.x)
						max_v.y = max(max_v.y, aabb.end.y)
						max_v.z = max(max_v.z, aabb.end.z)
				print("  Raw bounds: min=", min_v, " max=", max_v, " size=", (max_v - min_v))
				print("  Scaled size: ", (max_v - min_v) * cfg.scale)
				inst.free()
				
	p.free()
	quit(0)
