@tool
extends SceneTree

func test_scene(scene_path: String):
	print("\n--- Testing scene: ", scene_path.get_file(), " ---")
	var scn = load(scene_path) as PackedScene
	if not scn:
		print("FAILED to load scene: ", scene_path)
		return false
	var inst = scn.instantiate()
	if not inst:
		print("FAILED to instantiate scene: ", scene_path)
		return false
		
	var player = inst.find_child("Player", true, false)
	var spawner = inst.find_child("ZombieSpawner", true, false)
	var impact = inst.find_child("ImpactPool", true, false)
	var result_ui = inst.find_child("ResultUI", true, false)
	var atmo = inst.find_child("AtmosphereEnhancer", true, false)
	var nav = inst.find_child("NavigationRegion3D", true, false)
	
	print("Player: ", "OK" if player else "MISSING")
	print("ZombieSpawner: ", "OK" if spawner else "MISSING")
	print("ImpactPool: ", "OK" if impact else "MISSING")
	print("ResultUI: ", "OK" if result_ui else "MISSING")
	print("AtmosphereEnhancer: ", "OK" if atmo else "MISSING")
	print("NavigationRegion3D: ", "OK" if nav else "MISSING")
	
	if spawner and spawner.get("spawn_points"):
		var pts = spawner.get("spawn_points") as Array
		print("Spawn points count: ", pts.size())
		
	var ok = player and spawner and impact and result_ui and atmo and nav
	inst.free()
	return ok

func _init():
	var scenes = [
		"res://scenes/environments/MetroSubwayTunnel.tscn",
		"res://scenes/environments/HorrorLabCorridor.tscn",
		"res://scenes/environments/SurvivorTavern.tscn",
		"res://scenes/environments/SupermarketInfection.tscn",
		"res://scenes/environments/CastleFortress.tscn",
		"res://scenes/environments/AbandonedAlley.tscn"
	]
	
	var all_ok = true
	for p in scenes:
		if not test_scene(p):
			all_ok = false
			
	print("\n=== ALL NEW ENVIRONMENTS STATUS: ", "PASSED" if all_ok else "FAILED", " ===")
	quit(0 if all_ok else 1)
