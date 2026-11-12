extends SceneTree

func _init():
	print("--- Testing Downloaded Models in Godot ---")
	var weapons = [
		"res://assets/3d/weapons/downloaded/minigun_m134.glb",
		"res://assets/3d/weapons/downloaded/tavor_rifle.glb",
		"res://assets/3d/weapons/downloaded/flatline_rifle.glb",
		"res://assets/3d/weapons/downloaded/car_smg.glb",
		"res://assets/3d/weapons/downloaded/sniper_vantage.glb"
	]
	
	for w in weapons:
		var res = load(w)
		print("Loaded ", w, " -> ", res)
		if res is PackedScene:
			var inst = res.instantiate()
			print("  Instantiated successfully: ", inst.name)
			inst.queue_free()

	var envs = [
		"res://assets/external/downloads/environments/low_poly_street_gameready_6.glb",
		"res://assets/external/downloads/environments/street_city_buildings_8.glb",
		"res://assets/external/downloads/animals/fox_-_realistic_3d_model_demo_free.glb"
	]

	for e in envs:
		var res = load(e)
		print("Loaded ", e, " -> ", res)
		if res is PackedScene:
			var inst = res.instantiate()
			print("  Instantiated successfully: ", inst.name)
			inst.queue_free()

	print("--- Finished Testing ---")
	quit(0)
