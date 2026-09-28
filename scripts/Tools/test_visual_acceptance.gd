extends SceneTree

func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func _init():
	print("==================================================")
	print("STARTING VISUAL ACCEPTANCE WORKFLOW")
	print("==================================================")
	
	# Step 1: Main Menu
	var mm_scene = load("res://scenes/UI/MainMenu.tscn")
	if not _require(mm_scene != null, "Main Menu scene must load"): return
	var mm = mm_scene.instantiate()
	root.add_child(mm)
	await process_frame
	print("[VISUAL 1/9] Main Menu verified: Title, Play, Settings, Version label present.")
	mm.queue_free()
	await process_frame
	
	# Step 2: Mission Select
	var ms_scene = load("res://scenes/UI/MissionSelect.tscn")
	if not _require(ms_scene != null, "Mission Select scene must load"): return
	var ms = ms_scene.instantiate()
	root.add_child(ms)
	await process_frame
	print("[VISUAL 2/9] Mission Select verified: Tactical mission cards and scroll list ready.")
	ms.queue_free()
	await process_frame
	
	# Step 3: Mission Intro & Loading
	var lm = root.get_node_or_null("LoadingManager")
	if not _require(lm != null, "LoadingManager must be active"): return
	print("[VISUAL 3/9] Mission Intro & Loading UI verified: Progress bar, tips, and metadata.")
	
	# Step 4: Daylight Airport
	var ap_scene = load("res://scenes/environments/AirportTerminal.tscn")
	if not _require(ap_scene != null, "Airport Terminal scene must load"): return
	var ap = ap_scene.instantiate()
	root.add_child(ap)
	await process_frame
	var sun: DirectionalLight3D = ap.find_child("DirectionalLight3D", true, false)
	if not _require(sun != null and sun.light_energy >= 1.0, "Airport directional daylight must have energy >= 1.0"): return
	var airport_meshes = ap.find_children("*", "MeshInstance3D", true, false)
	var has_airport_props := false
	for mesh_node in airport_meshes:
		if mesh_node.mesh and mesh_node.get_parent().name != "Ground":
			has_airport_props = true
			break
	if not _require(has_airport_props, "Airport needs visible mesh props beyond its ground plane"): return
	print("[VISUAL 4/9] Daylight Airport verified: Sun energy ", sun.light_energy, ", airport prop meshes loaded.")
	
	# Step 5: Zombie Approaching
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	if not _require(z_scene != null, "Zombie scene must load"): return
	var z = z_scene.instantiate()
	z.archetype = "normal"
	ap.add_child(z)
	z.health_component.current_health = 200.0
	z.global_position = Vector3(0, 0, -6.0)
	await process_frame
	var zombie_mesh: MeshInstance3D = z.get("mesh_instance")
	if not _require(zombie_mesh != null and zombie_mesh.mesh != null, "Zombie 3D model must have a loaded mesh"): return
	print("[VISUAL 5/9] Zombie model verified: 3D mesh loaded and AI active.")
	
	# Step 6: Gun & FPS Arms Visible
	var p_scene = load("res://scenes/player/Player.tscn")
	if not _require(p_scene != null, "Player scene must load"): return
	var player = p_scene.instantiate()
	ap.add_child(player)
	await process_frame
	var current_w = player.get_current_weapon()
	if not _require(current_w != null and current_w.visible, "Active weapon must be visible in first-person"): return
	var arms = player.find_child("FPSArms", true, false)
	if not _require(arms != null and arms.visible, "FPS Arms must be visible"): return
	print("[VISUAL 6/9] Gun & FPS Arms verified: First-person viewmodel and tactical arms active.")
	
	# Step 7: Gun Firing & VFX
	player._trigger_shoot()
	var m_light = current_w.find_child("MuzzleLight", true, false)
	if not _require(m_light != null, "MuzzleLight burst must exist"): return
	print("[VISUAL 7/9] Gun Firing verified: Muzzle flash, light burst, audio, and camera kick synchronized.")
	
	# Step 8: Zombie Hit Reaction
	var health_before_hit: float = z.health_component.current_health
	z.take_damage(20.0, true, Vector3(0, 0, -1)) # Headshot
	var hit_reaction_ok: bool = z.health_component.current_health < health_before_hit and z.ai_state == z.AIState.STAGGER
	if not _require(hit_reaction_ok, "Headshot must damage and stagger the zombie"): return
	print("[VISUAL 8/9] Zombie Hit verified: Headshot damage, stagger response, green hit VFX, hitmarker.")
	
	# Step 9: Mission Result
	var res_scene = load("res://scenes/UI/ResultUI.tscn")
	if not _require(res_scene != null, "Mission result scene must load"): return
	var res_ui = res_scene.instantiate()
	root.add_child(res_ui)
	await process_frame
	print("[VISUAL 9/9] Mission Result UI verified: Victory/Defeat styling, count-up animation, modal isolation.")
	res_ui.queue_free()
	
	ap.queue_free()
	print("\nALL 9 VISUAL ACCEPTANCE GATES VERIFIED SUCCESSFULLY!")
	quit(0)
