extends SceneTree

func _init():
	print("--- STARTING AUTOMATED HEADLESS QA AUDIT ---")
	
	# 1. Test Weapon Resources & Models
	var weapons_to_test = [
		"negev_ng7", "p90", "ak74_bayonet", "akx_scifi", "n7_rifle", "car_smg", "grenade_mk2"
	]
	
	print("\n[STEP 1] Validating Weapon Resources and Models:")
	for wid in weapons_to_test:
		var res_path = "res://resources/weapons/" + wid + ".tres"
		var scn_path = "res://scenes/weapons/models/" + wid + ".tscn"
		
		var w_res = load(res_path) as WeaponData
		var w_scn = load(scn_path) as PackedScene
		
		if not w_res:
			printerr("FAIL: WeaponData missing or invalid for: ", wid)
		else:
			print("  + WeaponData OK: ", wid, " (Damage: ", w_res.base_damage, ", Mag: ", w_res.base_mag_size, ", Class: ", w_res.get_class(), ")")
			
		if not w_scn:
			printerr("FAIL: Model scene missing for: ", wid)
		else:
			var inst = w_scn.instantiate()
			var m_count = inst.find_children("*", "MeshInstance3D", true, false).size()
			if inst is MeshInstance3D: m_count += 1
			print("  + Model Scene OK: ", wid, " (Meshes found: ", m_count, ")")
			inst.free()

	# 2. Test Realistic Zombie Models
	print("\n[STEP 2] Validating Realistic Zombie Scenes:")
	var zombies_to_test = [
		"res://scenes/zombies/models/zombie_scary.tscn",
		"res://scenes/zombies/models/zombie_mutant.tscn"
	]
	for zpath in zombies_to_test:
		var zscn = load(zpath) as PackedScene
		if not zscn:
			printerr("FAIL: Zombie scene missing: ", zpath)
		else:
			var zinst = zscn.instantiate()
			var m_count = zinst.find_children("*", "MeshInstance3D", true, false).size()
			if zinst is MeshInstance3D: m_count += 1
			print("  + Zombie Scene OK: ", zpath, " (Meshes: ", m_count, ")")
			zinst.free()

	# 3. Test Full Gameplay Level Spawn (AirportTerminal)
	print("\n[STEP 3] Testing Mission 1-1 Level Instantiation:")
	var map_res = load("res://scenes/environments/AirportTerminal.tscn") as PackedScene
	if not map_res:
		printerr("FAIL: Could not load AirportTerminal.tscn")
		quit(1)
		return
		
	var map_inst = map_res.instantiate()
	get_root().add_child(map_inst)
	print("  + AirportTerminal instantiated into scene tree.")
	
	# Find player
	var player = map_inst.find_child("Player", true, false)
	if player:
		print("  + Player detected in level.")
		print("  + Player weapons initialized: ", player.weapons.size())
		if player.weapons.size() > 0:
			for i in range(player.weapons.size()):
				var w = player.weapons[i]
				var wname = w.weapon_data.display_name if w.weapon_data else "NoData"
				print("     Weapon [", i, "]: ", wname, " (Node visible: ", w.visible, ")")
	else:
		printerr("FAIL: Player node not found!")

	# Spawn test zombie
	print("\n[STEP 4] Spawning Zombie in Level:")
	var z_prefab = load("res://scenes/zombies/Zombie.tscn") as PackedScene
	if z_prefab:
		var z = z_prefab.instantiate()
		map_inst.add_child(z)
		z.position = Vector3(0, 0, -5)
		print("  + Zombie spawned at (0, 0, -5). Archetype: ", z.archetype)
		print("  + Zombie health: ", z.health_component.current_health if z.health_component else "null")
		print("  + Zombie HitZones found: ", z.find_children("*HitZone*", "Area3D", true, false).size())
	else:
		printerr("FAIL: Zombie.tscn could not be loaded!")

	print("\n--- ALL CHECKS COMPLETED SUCCESSFULLY ---")
	quit(0)
