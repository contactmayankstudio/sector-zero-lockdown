extends SceneTree

func _init():
	print("--- AUDITING ALL 84 CAMPAIGN MISSIONS & ENVIRONMENTS ---")
	var dir = DirAccess.open("res://resources/missions/campaign")
	if not dir:
		print("Failed to open campaign dir!")
		quit(1)
		
	var files = []
	dir.list_dir_begin()
	var f = dir.get_next()
	while f != "":
		if f.ends_with(".tres"):
			files.append(f)
		f = dir.get_next()
	dir.list_dir_end()
	files.sort()
	
	print("Total mission resource files found: ", files.size())
	
	var env_counts = {}
	var broken_missions = []
	
	for fname in files:
		var path = "res://resources/missions/campaign/" + fname
		var res = load(path)
		if not res:
			broken_missions.append(fname + " (Failed to load resource)")
			continue
			
		var env_scene = res.scene_path if "scene_path" in res else ""
		if env_scene == "" or env_scene == null:
			broken_missions.append(fname + " (No scene_path specified)")
			continue
			
		if not ResourceLoader.exists(env_scene):
			broken_missions.append(fname + " (Environment scene does not exist: " + str(env_scene) + ")")
			continue
			
		env_counts[env_scene] = env_counts.get(env_scene, 0) + 1
		
	print("\n--- ENVIRONMENT SCENE USAGE ACROSS ALL 84 MISSIONS ---")
	for env_path in env_counts:
		print("  ", env_path, " -> used in ", env_counts[env_path], " missions")
		
	if broken_missions.is_empty():
		print("\nSUCCESS: ALL 84 MISSIONS HAVE VALID AND EXISTING ENVIRONMENT SCENES!")
	else:
		print("\nBROKEN MISSIONS FOUND: ", broken_missions.size())
		for b in broken_missions:
			print("  ", b)
			
	quit(0)
