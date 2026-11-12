extends SceneTree

func _init():
	print("--- TESTING WEAPON VIEWMODEL TRANSFORMS ---")
	
	# Dictionary of tuned weapon transforms: position, rotation (degrees), scale
	var weapon_configs = {
		"negev_ng7": {
			"model": "res://scenes/weapons/models/negev_ng7.scn",
			# Negev was modeled along X axis (barrel at -X or +X)
			"rot": Vector3(0, -90, 0),
			"scale": Vector3(1.0, 1.0, 1.0),
			"pos": Vector3(0.0, -0.05, 0.0)
		},
		"p90": {
			"model": "res://scenes/weapons/models/p90.scn",
			# P90 barrel at -X, rotate -90 deg around Y to point -Z
			"rot": Vector3(0, -90, 0),
			"scale": Vector3(0.85, 0.85, 0.85),
			"pos": Vector3(0.0, -0.02, 0.0)
		},
		"ak74_bayonet": {
			"model": "res://scenes/weapons/models/ak74_bayonet.scn",
			# AK-74 was modeled along Y/Z, let's verify
			"rot": Vector3(0, 0, 0),
			"scale": Vector3(1.0, 1.0, 1.0),
			"pos": Vector3(0.0, 0.0, 0.0)
		},
		"akx_scifi": {
			"model": "res://scenes/weapons/models/akx_scifi.scn",
			"rot": Vector3(0, 0, 0),
			"scale": Vector3(1.0, 1.0, 1.0),
			"pos": Vector3(0.0, 0.0, 0.0)
		},
		"n7_rifle": {
			"model": "res://scenes/weapons/models/n7_rifle.scn",
			# N7 rifle is 16m long, scale down 0.065 so it is ~0.8m long
			"rot": Vector3(0, 180, 0),
			"scale": Vector3(0.065, 0.065, 0.065),
			"pos": Vector3(0.0, 0.0, 0.2)
		},
		"car_smg": {
			"model": "res://scenes/weapons/models/car_smg.scn",
			# CAR SMG is 27m long, scale down 0.035
			"rot": Vector3(0, 180, 0),
			"scale": Vector3(0.035, 0.035, 0.035),
			"pos": Vector3(0.0, -0.1, 0.0)
		},
		"grenade_mk2": {
			"model": "res://scenes/weapons/models/grenade_mk2.scn",
			"rot": Vector3(0, 0, 0),
			"scale": Vector3(1.0, 1.0, 1.0),
			"pos": Vector3(0.0, 0.0, 0.0)
		}
	}

	for id in weapon_configs:
		var cfg = weapon_configs[id]
		var scn = load(cfg.model)
		if scn:
			var inst = scn.instantiate()
			inst.rotation_degrees = cfg.rot
			inst.scale = cfg.scale
			inst.position = cfg.pos
			print(id, " loaded successfully. Pos: ", inst.position, " Rot: ", inst.rotation_degrees, " Scale: ", inst.scale)
			inst.free()
	quit(0)
