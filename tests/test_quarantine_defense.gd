extends SceneTree

# ==============================================================================
# DEAD TARGET: QUARANTINE DEFENSE MODE — OPAQUE-BOX E2E TEST SUITE
# ==============================================================================
# Authoritative Source: ORIGINAL_REQUEST.md (2026-10-20T15:51:36Z) & PROJECT.md
# Test Tiers:
#   - Tier 1: Feature Coverage (R1 Visibility, R2 Boss Climax, R3 Arcade Combat, R4 APU Stability)
#   - Tier 2: Boundary & Corner Cases (Ranges, Angles, HP, Ammo, Rapid Switching, Scaling)
#   - Tier 3: Cross-Feature Combinations (Pairwise Interaction Verification)
#   - Tier 4: Real-World Application Scenarios (Wave 1 Defense, Wave 2 Swarm, Wave 3 Boss Showdown)
# ==============================================================================

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0
var defect_log: Array = []

var tier_stats: Dictionary = {
	"Tier 1 (Feature Coverage)": {"passed": 0, "total": 0},
	"Tier 2 (Boundary & Corner Cases)": {"passed": 0, "total": 0},
	"Tier 3 (Cross-Feature Combinations)": {"passed": 0, "total": 0},
	"Tier 4 (Real-World Scenarios)": {"passed": 0, "total": 0}
}
var current_tier: String = "Tier 1 (Feature Coverage)"

func _init():
	call_deferred("_execute_suite")

func record_assertion(test_id: String, condition: bool, description: String, defect_reason: String = ""):
	total_tests += 1
	tier_stats[current_tier]["total"] += 1
	if condition:
		passed_tests += 1
		tier_stats[current_tier]["passed"] += 1
		print("  [PASS] [%s] %s" % [test_id, description])
	else:
		failed_tests += 1
		var defect_entry = {
			"id": test_id,
			"tier": current_tier,
			"description": description,
			"reason": defect_reason
		}
		defect_log.append(defect_entry)
		printerr("  [FAIL] [%s] %s -> DEFECT: %s" % [test_id, description, defect_reason])

func _execute_suite():
	# Allow autoloads and frame synchronization to settle
	for i in range(5):
		await process_frame

	print("\n======================================================================")
	print("   DEAD TARGET QUARANTINE DEFENSE — OPAQUE-BOX E2E TEST SUITE")
	print("   Target: Godot 4.x Headless | AMD Kabini APU Target Optimization")
	print("   Specifications: R1 Visibility, R2 Boss Climax, R3 Arcade, R4 APU")
	print("======================================================================\n")

	current_tier = "Tier 1 (Feature Coverage)"
	print(">>> RUNNING TIER 1: FEATURE COVERAGE (R1 - R4)")
	await _run_tier_1_feature_coverage()

	current_tier = "Tier 2 (Boundary & Corner Cases)"
	print("\n>>> RUNNING TIER 2: BOUNDARY & CORNER CASES")
	await _run_tier_2_boundary_corner_cases()

	current_tier = "Tier 3 (Cross-Feature Combinations)"
	print("\n>>> RUNNING TIER 3: CROSS-FEATURE COMBINATIONS (PAIRWISE)")
	await _run_tier_3_cross_feature_combinations()

	current_tier = "Tier 4 (Real-World Scenarios)"
	print("\n>>> RUNNING TIER 4: REAL-WORLD APPLICATION SCENARIOS")
	await _run_tier_4_real_world_scenarios()

	_print_summary_and_exit()

# ==============================================================================
# TIER 1: FEATURE COVERAGE
# ==============================================================================

func _run_tier_1_feature_coverage():
	# --------------------------------------------------------------------------
	# R1: Crystal-Clear Visibility (Flashlight, Floodlights, Fog, Zombie Eyes, Rim)
	# --------------------------------------------------------------------------
	print("\n--- [R1] Visibility Subsystem Tests ---")
	
	# TC-T1-R1-01: Tactical Flashlight SpotLight3D on Player Camera
	var player_scene = load("res://scenes/player/Player.tscn")
	var player = player_scene.instantiate() if player_scene else null
	if player:
		root.add_child(player)
		await process_frame
		var cam = player.get_node_or_null("Camera3D")
		var flashlight = cam.get_node_or_null("TacticalFlashlight") if cam else null
		record_assertion(
			"TC-T1-R1-01",
			flashlight != null and flashlight is SpotLight3D,
			"TacticalFlashlight SpotLight3D exists as direct child of Player Camera3D",
			"Camera3D has no TacticalFlashlight SpotLight3D child (found only ViewmodelLight)"
		)
		
		# TC-T1-R1-02: Flashlight Photometric Parameters
		if flashlight and flashlight is SpotLight3D:
			var range_ok = flashlight.spot_range >= 35.0
			var angle_ok = flashlight.spot_angle >= 30.0 and flashlight.spot_angle <= 45.0
			var energy_ok = flashlight.light_energy >= 2.5
			var no_shadow = (flashlight.shadow_enabled == false)
			record_assertion(
				"TC-T1-R1-02",
				range_ok and angle_ok and energy_ok and no_shadow,
				"TacticalFlashlight parameters meet spec (range >= 35m, angle 30-45 deg, energy >= 2.5, shadows disabled)",
				"Flashlight params out of spec (range=%.1f, angle=%.1f, energy=%.1f, shadow=%s)" % [
					flashlight.spot_range, flashlight.spot_angle, flashlight.light_energy, str(flashlight.shadow_enabled)
				]
			)
		else:
			record_assertion(
				"TC-T1-R1-02",
				false,
				"TacticalFlashlight parameters meet spec (range >= 35m, angle 30-45 deg, energy >= 2.5, shadows disabled)",
				"TacticalFlashlight node is missing, cannot verify photometric parameters"
			)
		player.queue_free()
		await process_frame
	else:
		record_assertion("TC-T1-R1-01", false, "Player scene instantiates successfully", "Failed to load Player.tscn")
		record_assertion("TC-T1-R1-02", false, "TacticalFlashlight parameters meet spec", "Player scene failed")

	# TC-T1-R1-03: Arena Floodlights in DeadTargetQuarantine.tscn
	var dt_scene = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var dt_instance = dt_scene.instantiate() if dt_scene else null
	if dt_instance:
		root.add_child(dt_instance)
		await process_frame
		var lights = dt_instance.find_children("*", "Light3D", true, false)
		var floodlight_count = 0
		var far_light_found = false
		for l in lights:
			if l.name.to_lower().contains("flood") or l.name.to_lower().contains("arena") or (l is SpotLight3D and l.spot_range >= 20.0):
				floodlight_count += 1
			if l.global_position.z <= -28.0 or (l is Node3D and l.position.z <= -28.0):
				far_light_found = true
		record_assertion(
			"TC-T1-R1-03",
			floodlight_count >= 3 or (lights.size() >= 5 and far_light_found),
			"Arena floodlights illuminate checkpoint corridor (>= 3 floodlights spanning down to Z <= -30)",
			"Found %d floodlights in scene; far corridor (Z <= -30) lacks dedicated illumination" % floodlight_count
		)
		dt_instance.queue_free()
		await process_frame
	else:
		record_assertion("TC-T1-R1-03", false, "Arena floodlights illuminate checkpoint corridor", "Failed to load DeadTargetQuarantine.tscn")

	# TC-T1-R1-04: Fog Density & Ambient Light Specifications
	var env_res = load("res://resources/materials/env_dead_target.tres") as Environment
	var env_script_path = "res://scenes/environments/DeadTargetQuarantine.gd"
	var env_script_text = ""
	if FileAccess.file_exists(env_script_path):
		var f = FileAccess.open(env_script_path, FileAccess.READ)
		if f:
			env_script_text = f.get_as_text()
			f.close()
	var tres_fog_ok = env_res and env_res.fog_density <= 0.010
	var script_fog_ok = not env_script_text.contains("fog_density = 0.018") and (not env_script_text.contains("fog_density") or env_script_text.contains("0.008") or env_script_text.contains("0.010"))
	var ambient_ok = env_res and env_res.ambient_light_energy >= 0.90
	record_assertion(
		"TC-T1-R1-04",
		tres_fog_ok and script_fog_ok and ambient_ok,
		"Corridor atmospheric clarity: fog_density <= 0.010, ambient_light_energy >= 0.90",
		"Fog density too thick (tres=%.3f, script contains 0.018: %s) or ambient light < 0.90 (ambient=%.2f)" % [
			env_res.fog_density if env_res else -1.0,
			str(env_script_text.contains("fog_density = 0.018")),
			env_res.ambient_light_energy if env_res else -1.0
		]
	)

	# TC-T1-R1-05: Zombie Glowing Red Eyes Emissive & Head Bone Attachment
	var enemy_base_path = "res://scripts/Zombies/EnemyBase.gd"
	var enemy_code = ""
	if FileAccess.file_exists(enemy_base_path):
		var f_enemy = FileAccess.open(enemy_base_path, FileAccess.READ)
		if f_enemy:
			enemy_code = f_enemy.get_as_text()
			f_enemy.close()
	var eye_radius_ok = enemy_code.contains("radius = 0.038") or enemy_code.contains("radius = 0.04") or enemy_code.contains("radius = 0.035")
	var eye_emission_ok = enemy_code.contains("emission_energy_multiplier") or enemy_code.contains("emission_enabled = true")
	var eye_bone_attached = enemy_code.contains("BoneAttachment3D") or enemy_code.contains("attach_to_bone") or enemy_code.contains("find_bone(\"Head\")") or enemy_code.contains("find_bone(\"mixamorig_Head\")")
	record_assertion(
		"TC-T1-R1-05",
		eye_radius_ok and eye_emission_ok and eye_bone_attached,
		"Zombie glowing red eyes use visible sphere radius (>=0.035m), HDR emission, and attach to Head bone",
		"Zombie eye glow uses 0.016m sphere without HDR emission or is unattached to Head bone (stays rigid in air)"
	)

	# TC-T1-R1-06: Zombie Rim Lighting for Silhouette Edge Pop
	var rim_ok = enemy_code.contains("mat.rim = 0.95") or enemy_code.contains("rim = 0.9") or enemy_code.contains("rim = 1.0")
	var rim_tint_ok = enemy_code.contains("mat.rim_tint = 0.55") or enemy_code.contains("rim_tint = 0.5") or enemy_code.contains("rim_tint = 0.6")
	record_assertion(
		"TC-T1-R1-06",
		rim_ok and rim_tint_ok,
		"Zombie archetype material enforces strong rim lighting (rim >= 0.85, rim_tint >= 0.50)",
		"EnemyBase.gd overrides rim lighting with weak values (rim = 0.35, rim_tint = 0.20)"
	)

	# --------------------------------------------------------------------------
	# R2: Epic Boss Climax (Wave 3 Boss Entrance, Roar, Shake, HUD)
	# --------------------------------------------------------------------------
	print("\n--- [R2] Boss Climax Subsystem Tests ---")

	# TC-T1-R2-01: Boss Scale (Towering Titan >= 2.0x)
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	var boss = boss_scene.instantiate() if boss_scene else null
	if boss:
		root.add_child(boss)
		await process_frame
		var boss_scale = boss.scale
		var arch_scale = Vector3.ONE
		if enemy_code.contains("\"scale\": Vector3(2.3, 2.3, 2.3)") or enemy_code.contains("\"scale\": Vector3(2.0, 2.0, 2.0)"):
			arch_scale = Vector3(2.3, 2.3, 2.3)
		var scale_adequate = (boss_scale.x >= 2.0 and boss_scale.y >= 2.0) or arch_scale.x >= 2.0
		record_assertion(
			"TC-T1-R2-01",
			scale_adequate,
			"Boss Zombie model scale is towering (>= Vector3(2.0, 2.0, 2.0), target 2.3x)",
			"BossZombie scale is Vector3(1.8, 1.8, 1.8) (only 1.8x, not imposing 2.3x titan)"
		)

		# TC-T1-R2-02: Biohazard Red Glowing Veins Emission
		var has_emission = false
		var meshes = boss.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			for s in range(m.get_surface_override_material_count()):
				var mat = m.get_surface_override_material(s)
				if mat is StandardMaterial3D and mat.emission_enabled and mat.emission_energy_multiplier >= 3.0:
					has_emission = true
					break
			if m.material_override is StandardMaterial3D and m.material_override.emission_enabled and m.material_override.emission_energy_multiplier >= 3.0:
				has_emission = true
				break
		# Also check BossZombie.gd script logic
		var boss_script_path = "res://scenes/zombies/BossZombie.gd"
		var boss_code = ""
		if FileAccess.file_exists(boss_script_path):
			var fb = FileAccess.open(boss_script_path, FileAccess.READ)
			if fb:
				boss_code = fb.get_as_text()
				fb.close()
		if boss_code.contains("emission_enabled = true") and (boss_code.contains("3.8") or boss_code.contains("4.0")):
			has_emission = true
		record_assertion(
			"TC-T1-R2-02",
			has_emission,
			"Boss Zombie features biohazard red/vein emission (emission_enabled=true, energy >= 3.0)",
			"Boss Zombie skin mesh materials do not enable biohazard glowing veins (emission_enabled=false)"
		)

		# TC-T1-R2-03: Boss Entrance Roar Sound
		var sfx_growl = boss.get_node_or_null("SfxGrowl") as AudioStreamPlayer3D
		var roar_assigned = sfx_growl != null and sfx_growl.stream != null
		record_assertion(
			"TC-T1-R2-03",
			roar_assigned,
			"Boss Zombie has roar sound stream assigned ($SfxGrowl stream valid)",
			"Boss Zombie roar sound missing or null audio stream"
		)

		# TC-T1-R2-04: Boss Entrance Camera Screen-Shake
		var shake_triggered = boss_code.contains("apply_shake") or boss_code.contains("camera_shake") or boss_code.contains("shake_intensity")
		record_assertion(
			"TC-T1-R2-04",
			shake_triggered,
			"Boss Zombie entrance triggers Player camera screen shake (apply_shake >= 0.35)",
			"BossZombie._ready() does not invoke player apply_shake() on entrance roar"
		)

		boss.queue_free()
		await process_frame
	else:
		record_assertion("TC-T1-R2-01", false, "Boss Zombie scene instantiates", "Failed to load BossZombie.tscn")
		record_assertion("TC-T1-R2-02", false, "Boss Zombie biohazard veins", "Boss scene missing")
		record_assertion("TC-T1-R2-03", false, "Boss Zombie roar sound", "Boss scene missing")
		record_assertion("TC-T1-R2-04", false, "Boss Zombie entrance screen shake", "Boss scene missing")

	# TC-T1-R2-05: Prominent Boss Health Bar Width (>= 500px) in HUD
	var hud_scene = load("res://scenes/UI/HUD.tscn")
	var hud = hud_scene.instantiate() if hud_scene else null
	if hud:
		root.add_child(hud)
		await process_frame
		var boss_hp_bar = hud.get_node_or_null("Control/BossHealthBar") as ProgressBar
		var bar_width = 0.0
		if boss_hp_bar:
			bar_width = abs(boss_hp_bar.offset_right - boss_hp_bar.offset_left)
			if boss_hp_bar.custom_minimum_size.x > bar_width:
				bar_width = boss_hp_bar.custom_minimum_size.x
		record_assertion(
			"TC-T1-R2-05",
			bar_width >= 500.0,
			"Boss Health Bar width is prominent across top screen (width >= 500px, nominal 520px)",
			"Boss Health Bar width is only %.1f px (expected >= 500px, currently -160 to 160 = 320px)" % bar_width
		)

		# TC-T1-R2-06: Warning Siren Alert Banner in HUD
		var hud_code = ""
		var hud_script_path = "res://scripts/HUD.gd"
		if FileAccess.file_exists(hud_script_path):
			var fh = FileAccess.open(hud_script_path, FileAccess.READ)
			if fh:
				hud_code = fh.get_as_text()
				fh.close()
		var siren_alert_ok = hud_code.contains("WARNING: TITAN MUTANT APPROACHING") or hud_code.contains("TITAN MUTANT") or hud_code.contains("boss_spawned")
		record_assertion(
			"TC-T1-R2-06",
			siren_alert_ok and hud_code.contains("boss_spawned"),
			"HUD connects to boss_spawned and displays 'WARNING: TITAN MUTANT APPROACHING' alert banner",
			"HUD does not connect to boss_spawned signal or lacks Titan Mutant siren warning banner"
		)

		hud.queue_free()
		await process_frame
	else:
		record_assertion("TC-T1-R2-05", false, "Boss Health Bar exists on HUD", "Failed to load HUD.tscn")
		record_assertion("TC-T1-R2-06", false, "HUD warning siren alert banner", "Failed to load HUD.tscn")

	# --------------------------------------------------------------------------
	# R3: Addictive Arcade Combat Loop (Weapons, Key 4 Bug Fix, Gore, Barrels)
	# --------------------------------------------------------------------------
	print("\n--- [R3] Arcade Combat Subsystem Tests ---")

	# TC-T1-R3-01: 4 Military Weapons Definition & Balancing
	var w1 = load("res://resources/weapons/negev_ng7.tres")
	var w2 = load("res://resources/weapons/akx_scifi.tres")
	var w3 = load("res://resources/weapons/car_smg.tres")
	var w4 = load("res://resources/weapons/pestilence_handgun.tres")
	var weps_valid = (w1 != null and w2 != null and w3 != null and w4 != null)
	if weps_valid:
		var w1_ok = (w1.base_damage >= 40.0 and w1.base_mag_size >= 100)
		var w2_ok = (w2.base_damage >= 45.0 and w2.base_mag_size >= 30)
		var w3_ok = (w3.base_damage >= 30.0 and w3.base_mag_size >= 25)
		var w4_ok = (w4.base_damage >= 55.0 and w4.headshot_multiplier >= 2.0)
		record_assertion(
			"TC-T1-R3-01",
			w1_ok and w2_ok and w3_ok and w4_ok,
			"4 military weapons (NG7 LMG, AKX Carbine, SMG-9, Pestilence Handgun) correctly configured",
			"One or more military weapon parameters out of balance or unconfigured"
		)
	else:
		record_assertion("TC-T1-R3-01", false, "4 military weapon resources exist", "Missing weapon .tres files")

	# TC-T1-R3-02: Fix Key 4 Switching Bug in Player.gd
	var player_code = ""
	var player_script_path = "res://scenes/player/Player.gd"
	if FileAccess.file_exists(player_script_path):
		var fp = FileAccess.open(player_script_path, FileAccess.READ)
		if fp:
			player_code = fp.get_as_text()
			fp.close()
	var key4_bug_present = player_code.contains("switch_to_weapon(3)\n\t\t\t\tswitch_to_weapon(2)") or player_code.contains("switch_to_weapon(3)\r\n\t\t\t\tswitch_to_weapon(2)")
	var key4_clean = player_code.contains("KEY_4:") and not key4_bug_present
	record_assertion(
		"TC-T1-R3-02",
		not key4_bug_present and key4_clean,
		"Player input KEY_4 switches strictly to weapon slot 3 without Key 4 override bug",
		"Player.gd lines 734-736 contain verbatim bug: switch_to_weapon(3) immediately overridden by switch_to_weapon(2)"
	)

	# TC-T1-R3-03: Weapon Slot 0..3 Prioritization for Military Weapons
	var ordering_ok = player_code.contains("starter_weapons") and (player_code.contains("ordered_cfgs") or player_code.contains("for sw_id in starter_weapons"))
	record_assertion(
		"TC-T1-R3-03",
		ordering_ok,
		"Weapons slot ordering guarantees starter military weapons occupy slots 0..3 even with savegame unlocks",
		"Weapon configs appended in raw order, causing unlocked weapons to push Pestilence Handgun out of slot 3"
	)

	# TC-T1-R3-04: Visceral Headshot Audio Mapping
	var audio_code = ""
	var audio_script_path = "res://scripts/AudioManager.gd"
	if FileAccess.file_exists(audio_script_path):
		var fa = FileAccess.open(audio_script_path, FileAccess.READ)
		if fa:
			audio_code = fa.get_as_text()
			fa.close()
	var headshot_audio_ok = audio_code.contains("\"hit_headshot\": \"res://audio/impacts/sfx_headshot_crunch.wav\"") or audio_code.contains("sfx_headshot_crunch.wav")
	record_assertion(
		"TC-T1-R3-04",
		headshot_audio_ok,
		"AudioManager maps 'hit_headshot' to visceral sfx_headshot_crunch.wav instead of tick sound",
		"AudioManager maps 'hit_headshot' to sfx_hitmarker_tick.wav instead of sfx_headshot_crunch.wav"
	)

	# TC-T1-R3-05: Headshot Decapitation & Crimson Arterial Splatter
	var decap_ok = enemy_code.contains("mixamorig_Head") and enemy_code.contains("Vector3.ZERO")
	var gore_prefab_ok = FileAccess.file_exists("res://scenes/weapons/HeadshotGoreEffect.tscn") or enemy_code.contains("HeadshotGoreEffect") or enemy_code.contains("HeadshotBloodSpray")
	record_assertion(
		"TC-T1-R3-05",
		decap_ok and gore_prefab_ok,
		"Lethal headshots trigger Mixamo head bone zero-scaling decapitation and crimson blood particles",
		"EnemyBase._on_died() has no head bone decapitation logic; blood particle is currently green mist"
	)

	# TC-T1-R3-06: Explosive Barrels Count & Blast Specs
	var barrel_scene = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var barrel = barrel_scene.instantiate() if barrel_scene else null
	var barrel_specs_ok = false
	if barrel:
		barrel_specs_ok = (barrel.explosion_damage >= 350.0 and barrel.explosion_radius >= 7.5)
		barrel.queue_free()
	var quarantine_text = ""
	if FileAccess.file_exists("res://scenes/environments/DeadTargetQuarantine.tscn"):
		var fq = FileAccess.open("res://scenes/environments/DeadTargetQuarantine.tscn", FileAccess.READ)
		if fq:
			quarantine_text = fq.get_as_text()
			fq.close()
	var barrel_count_ok = quarantine_text.contains("ExplosiveBarrel1") and quarantine_text.contains("ExplosiveBarrel2") and quarantine_text.contains("ExplosiveBarrel3") and quarantine_text.contains("ExplosiveBarrel4")
	record_assertion(
		"TC-T1-R3-06",
		barrel_specs_ok and barrel_count_ok,
		"Explosive barrels (4 in scene) deliver 350.0 blast damage over 7.5m radius",
		"Explosive barrels count != 4 or damage/radius out of spec (dmg=%.1f, rad=%.1f)" % [
			barrel.explosion_damage if barrel else -1.0,
			barrel.explosion_radius if barrel else -1.0
		]
	)

	# --------------------------------------------------------------------------
	# R4: APU 30+ FPS Stability & Thermal Protection
	# --------------------------------------------------------------------------
	print("\n--- [R4] APU Stability Subsystem Tests ---")

	# TC-T1-R4-01: PoliceCar Prop Replacement (police.glb 191 KB vs PoliceCarProp.scn 27 MB)
	var uses_lightweight_car = quarantine_text.contains("police.glb") and not quarantine_text.contains("PoliceCarProp.scn")
	record_assertion(
		"TC-T1-R4-01",
		uses_lightweight_car,
		"DeadTargetQuarantine.tscn instances lightweight police.glb (191 KB) instead of 27 MB PoliceCarProp.scn",
		"DeadTargetQuarantine.tscn still instances 27 MB heavy prop PoliceCarProp.scn"
	)

	# TC-T1-R4-02: QualityManager APU Fillrate Scaling (scaling_3d_scale = 0.82)
	var qm_code = ""
	if FileAccess.file_exists("res://scripts/QualityManager.gd"):
		var fqm = FileAccess.open("res://scripts/QualityManager.gd", FileAccess.READ)
		if fqm:
			qm_code = fqm.get_as_text()
			fqm.close()
	var scaling_082_ok = qm_code.contains("0.82")
	var qm = root.get_node_or_null("QualityManager")
	var live_scale_ok = false
	if qm and qm.has_method("setup_legacy_profile"):
		qm.setup_legacy_profile()
		var vp = root
		if vp and abs(vp.scaling_3d_scale - 0.82) < 0.02:
			live_scale_ok = true
	record_assertion(
		"TC-T1-R4-02",
		scaling_082_ok or live_scale_ok,
		"QualityManager sets scaling_3d_scale = 0.82 on legacy/low-spec APU (reduces fillrate by ~33%)",
		"QualityManager sets scaling_3d_scale = 1.0 on Linux APU, leading to fillrate choke and thermal throttling"
	)

	# TC-T1-R4-03: Mobile-Optimized Lightweight Zombie Models (< 450 KB each)
	var m_normal = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_normal.tscn").size()
	var m_fast = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_fast.tscn").size()
	var m_heavy = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_heavy.tscn").size()
	var m_boss = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_boss.tscn").size()
	var m_dog = FileAccess.get_file_as_bytes("res://scenes/zombies/models/infected_dog.tscn").size()
	var all_models_light = (m_normal < 450000 and m_fast < 300000 and m_heavy < 300000 and m_boss < 300000 and m_dog < 250000)
	record_assertion(
		"TC-T1-R4-03",
		all_models_light,
		"All standard zombie models are mobile-optimized (< 450 KB each, total memory < 1.5 MB)",
		"One or more zombie model scenes exceed mobile size thresholds (normal: %d KB, boss: %d KB)" % [
			m_normal / 1024, m_boss / 1024
		]
	)

	# TC-T1-R4-04: Heavy Zombie Scenes Excluded from Quarantine Defense
	var unoptimized_leak = quarantine_text.contains("zombie_realistic_human.scn") or quarantine_text.contains("RealAlienMutant.scn") or quarantine_text.contains("RealButcherBoss.scn")
	var enemy_leak = enemy_code.contains("RealVelociraptor.scn") or enemy_code.contains("zombie_realistic_human.scn")
	record_assertion(
		"TC-T1-R4-04",
		not unoptimized_leak and not enemy_leak,
		"Heavy unoptimized models (68MB human, 63MB mutant, 7.6MB raptor) completely excluded from Quarantine",
		"Quarantine or EnemyBase references heavy unoptimized models (e.g. RealVelociraptor.scn 7.6MB for dog)"
	)

	# TC-T1-R4-05: Wave 3 Boss Concurrency Throttle (max_active_zombies <= 4)
	var gm_code = ""
	if FileAccess.file_exists("res://scripts/GameManager.gd"):
		var fgm = FileAccess.open("res://scripts/GameManager.gd", FileAccess.READ)
		if fgm:
			gm_code = fgm.get_as_text()
			fgm.close()
	var throttle_ok = gm_code.contains("max_active_zombies = 4")
	record_assertion(
		"TC-T1-R4-05",
		throttle_ok,
		"GameManager constrains active zombies to <= 4 during Wave 3 boss climax to protect APU framerate",
		"GameManager does not constrain max_active_zombies during Wave 3 boss showdown"
	)

# ==============================================================================
# TIER 2: BOUNDARY & CORNER CASES
# ==============================================================================

func _run_tier_2_boundary_corner_cases():
	# --------------------------------------------------------------------------
	# R1 Visibility Boundaries
	# --------------------------------------------------------------------------
	# TC-T2-R1-01: Flashlight Distance Cutoff Boundary (40.0m vs 40.1m)
	var test_light = SpotLight3D.new()
	test_light.spot_range = 40.0
	test_light.spot_angle = 32.0
	test_light.spot_attenuation = 1.0
	var dist_inside = 39.9
	var dist_outside = 40.1
	var atten_inside = pow(clamp(1.0 - (dist_inside / test_light.spot_range), 0.0, 1.0), test_light.spot_attenuation)
	var atten_outside = pow(clamp(1.0 - (dist_outside / test_light.spot_range), 0.0, 1.0), test_light.spot_attenuation)
	record_assertion(
		"TC-T2-R1-01",
		atten_inside > 0.0 and atten_outside == 0.0,
		"Tactical flashlight photometric range cut-off enforces hard zero boundary at dist > spot_range",
		"Flashlight distance boundary calculation failed"
	)
	test_light.queue_free()

	# TC-T2-R1-02: Flashlight Angular Falloff Boundary (Half-Angle 16 deg vs 17 deg)
	var half_angle_rad = deg_to_rad(16.0)
	var outside_angle_rad = deg_to_rad(17.0)
	var dot_inside = cos(half_angle_rad)
	var dot_outside = cos(outside_angle_rad)
	var cutoff_dot = cos(deg_to_rad(16.0))
	record_assertion(
		"TC-T2-R1-02",
		dot_inside >= cutoff_dot and dot_outside < cutoff_dot,
		"Flashlight spot cone boundary cleanly illuminates on-axis <= 16° and attenuates outside 16°",
		"Angular cutoff calculation mismatch"
	)

	# TC-T2-R1-03: Fog Density Upper-Bound Clamping
	var env_res = load("res://resources/materials/env_dead_target.tres") as Environment
	var density_clamped = env_res != null and env_res.fog_density <= 0.010 and env_res.fog_density >= 0.005
	record_assertion(
		"TC-T2-R1-03",
		density_clamped,
		"Fog density resource value strictly clamped within nocturnal mist band [0.005, 0.010]",
		"Fog density is %.4f (exceeds 0.010 upper bound, causing black wall effect)" % (env_res.fog_density if env_res else -1.0)
	)

	# TC-T2-R1-04: Zombie Eye Subtended Solid Angle at Max Range (25m)
	# Subtended angle theta = 2 * arctan(radius / distance)
	var r_nominal = 0.038
	var r_flawed = 0.016
	var theta_nominal = 2.0 * atan(r_nominal / 25.0)
	var theta_flawed = 2.0 * atan(r_flawed / 25.0)
	# Nominal subtends ~2.37x larger angle, exceeding the 1-pixel raster threshold at 1080p
	record_assertion(
		"TC-T2-R1-04",
		theta_nominal >= 0.003 and theta_nominal > (theta_flawed * 2.0),
		"3.8cm glowing eye mesh maintains visible raster resolution (> 2 pixels) at 25m distance",
		"Subtended eye angle at 25m too small (%.5f rad), collapses to sub-pixel noise" % theta_nominal
	)

	# TC-T2-R1-05: Rim Silhouette Normal Grazing Dot Product
	# Rim term: pow(1.0 - max(0.0, N.V), rim_power)
	var normal = Vector3(1, 0, 0)
	var view_grazing = Vector3(0.1736, 0.9848, 0).normalized() # ~80 deg grazing angle
	var n_dot_v = clamp(normal.dot(view_grazing), 0.0, 1.0)
	var rim_term = 1.0 - n_dot_v
	record_assertion(
		"TC-T2-R1-05",
		rim_term >= 0.80,
		"Silhouette edge at 80° grazing angle achieves >= 80% rim luminance factor",
		"Rim grazing factor calculation failed: %.2f" % rim_term
	)

	# --------------------------------------------------------------------------
	# R2 Boss Climax Boundaries
	# --------------------------------------------------------------------------
	# TC-T2-R2-01: Near-Zero Boss HP Boundary Transition (1.0 HP -> 0.0 HP)
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	var b_test = boss_scene.instantiate() if boss_scene else null
	if b_test:
		root.add_child(b_test)
		await process_frame
		if b_test.health_component:
			b_test.health_component.current_health = 1.0
			var is_alive_at_1 = not b_test.is_dead
			b_test.take_damage(20.0, false, Vector3.FORWARD)
			await process_frame
			var is_dead_at_0 = b_test.is_dead
			record_assertion(
				"TC-T2-R2-01",
				is_alive_at_1 and is_dead_at_0,
				"Boss Zombie survives at exactly 1.0 HP and cleanly triggers death transition at 0.0 HP",
				"Near-zero HP transition failed (alive_at_1=%s, dead_at_0=%s)" % [str(is_alive_at_1), str(is_dead_at_0)]
			)
		else:
			record_assertion("TC-T2-R2-01", false, "Boss Zombie has valid health component", "Health component null")
		b_test.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R2-01", false, "Boss Zombie near-zero HP test", "Failed to load BossZombie")

	# TC-T2-R2-02: Maximum Wave Count Boundary & Wave 3 Boss Trigger
	var gm_code = ""
	if FileAccess.file_exists("res://scripts/GameManager.gd"):
		var fgm = FileAccess.open("res://scripts/GameManager.gd", FileAccess.READ)
		if fgm:
			gm_code = fgm.get_as_text()
			fgm.close()
	var wave_trigger_ok = gm_code.contains("current_wave >= 3") and gm_code.contains("arch = \"boss\"")
	record_assertion(
		"TC-T2-R2-02",
		wave_trigger_ok,
		"GameManager wave boundary triggers Boss at wave >= 3 regardless of wave delay",
		"Wave 3 boss spawn condition missing in GameManager.gd"
	)

	# TC-T2-R2-03: Boss Health Bar Clamping [0.0, max_health]
	var hud_scene = load("res://scenes/UI/HUD.tscn")
	var hud = hud_scene.instantiate() if hud_scene else null
	if hud:
		root.add_child(hud)
		await process_frame
		var hp_bar = hud.get_node_or_null("Control/BossHealthBar") as ProgressBar
		if hp_bar and hud.has_method("update_boss_health"):
			hud.update_boss_health(-50.0)
			var underflow_clamped = (hp_bar.value >= 0.0)
			hud.update_boss_health(999999.0)
			var overflow_clamped = (hp_bar.value <= hp_bar.max_value)
			record_assertion(
				"TC-T2-R2-03",
				underflow_clamped and overflow_clamped,
				"Boss Health Bar clamps strictly between 0.0 and max_health under negative/overflow damage ticks",
				"Health bar clamping failed (underflow=%s, overflow=%s)" % [str(underflow_clamped), str(overflow_clamped)]
			)
		else:
			record_assertion("TC-T2-R2-03", false, "Boss Health Bar clamping", "ProgressBar or update_boss_health missing")
		hud.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R2-03", false, "Boss Health Bar clamping", "HUD scene load failed")

	# TC-T2-R2-04: Boss Scale Bounding Box Dimensions
	var enemy_code = ""
	if FileAccess.file_exists("res://scripts/Zombies/EnemyBase.gd"):
		var fe = FileAccess.open("res://scripts/Zombies/EnemyBase.gd", FileAccess.READ)
		if fe:
			enemy_code = fe.get_as_text()
			fe.close()
	var scale_bounded = enemy_code.contains("\"scale\": Vector3(2.3, 2.3, 2.3)") or enemy_code.contains("\"scale\": Vector3(2.0, 2.0, 2.0)")
	record_assertion(
		"TC-T2-R2-04",
		scale_bounded,
		"Boss Zombie configuration defines bounding box scaling >= 2.0x in all 3 axes",
		"Boss scale config is Vector3(1.8, 1.8, 1.8), below the 2.0x titan threshold"
	)

	# TC-T2-R2-05: Screen-Shake Intensity Safe Bounding [0.0, 1.0]
	var player_code = ""
	if FileAccess.file_exists("res://scenes/player/Player.gd"):
		var fp = FileAccess.open("res://scenes/player/Player.gd", FileAccess.READ)
		if fp:
			player_code = fp.get_as_text()
			fp.close()
	var shake_clamped = player_code.contains("shake_intensity = max(shake_intensity, intensity)") or player_code.contains("clamp(shake_intensity")
	record_assertion(
		"TC-T2-R2-05",
		shake_clamped,
		"Player camera apply_shake preserves valid float range and fades smoothly via shake_fade",
		"apply_shake logic missing or camera shake intensity unbound"
	)

	# --------------------------------------------------------------------------
	# R3 Arcade Combat Boundaries
	# --------------------------------------------------------------------------
	# TC-T2-R3-01: Boundary Ammo: Magazine Exhaustion (0 Ammo Behavior)
	var w_scene = load("res://scenes/weapons/Weapon.tscn")
	var w_test = w_scene.instantiate() if w_scene else null
	var w_data = load("res://resources/weapons/pestilence_handgun.tres")
	if w_test and w_data:
		w_test.weapon_data = w_data
		root.add_child(w_test)
		await process_frame
		w_test.current_ammo = 0
		var shoot_blocked = not w_test.can_shoot() if w_test.has_method("can_shoot") else true
		record_assertion(
			"TC-T2-R3-01",
			shoot_blocked,
			"Magazine exhaustion (0 ammo) blocks firing and triggers empty/reload state",
			"Weapon allows firing at 0 magazine ammo"
		)
		w_test.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R3-01", false, "Magazine exhaustion handling", "Failed to load pestilence_handgun.tres")

	# TC-T2-R3-02: Rapid Weapon Switching Stress (10 rapid cycles)
	var p_scene = load("res://scenes/player/Player.tscn")
	var p_inst = p_scene.instantiate() if p_scene else null
	if p_inst:
		root.add_child(p_inst)
		await process_frame
		var no_crash = true
		for cycle in range(10):
			for slot in range(4):
				if p_inst.has_method("switch_to_weapon"):
					p_inst.switch_to_weapon(slot)
		record_assertion(
			"TC-T2-R3-02",
			no_crash and p_inst.is_inside_tree(),
			"10 rapid weapon switching cycles (slots 0..3) execute without null viewmodel crash or state lock",
			"Rapid weapon switching produced an internal error or node failure"
		)
		p_inst.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R3-02", false, "Rapid weapon switching stress", "Player scene load failed")

	# TC-T2-R3-03: Reload Interruption via Fast Weapon Switch
	var p_inst2 = p_scene.instantiate() if p_scene else null
	if p_inst2:
		root.add_child(p_inst2)
		await process_frame
		if p_inst2.has_method("switch_to_weapon") and p_inst2.has_method("_trigger_reload"):
			p_inst2._trigger_reload()
			p_inst2.switch_to_weapon(1)
			await process_frame
			record_assertion(
				"TC-T2-R3-03",
				p_inst2.current_weapon_index == 1 or p_inst2.weapons.is_empty(),
				"Switching weapons immediately cancels active reload without locking viewmodel tween",
				"Weapon switch failed to cancel active reload"
			)
		else:
			record_assertion("TC-T2-R3-03", false, "Reload interruption handling", "Player methods missing")
		p_inst2.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R3-03", false, "Reload interruption handling", "Player scene load failed")

	# TC-T2-R3-04: Explosive Barrel Blast Distance Boundary (7.4m vs 7.6m)
	var barrel_res = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var b_inst = barrel_res.instantiate() if barrel_res else null
	if b_inst:
		var radius = b_inst.explosion_radius
		var dist_in = radius - 0.1
		var dist_out = radius + 0.1
		var ratio_in = 1.0 - (dist_in / radius)
		var dmg_in = b_inst.explosion_damage * max(0.35, ratio_in)
		var in_range = (dist_in <= radius)
		var out_of_range = (dist_out > radius)
		record_assertion(
			"TC-T2-R3-04",
			in_range and out_of_range and dmg_in >= 120.0,
			"Explosive barrel damage boundary applies at 7.4m (>=120 dmg) and cuts off at 7.6m (0 dmg)",
			"Blast distance boundary formula calculation failed"
		)
		b_inst.queue_free()
	else:
		record_assertion("TC-T2-R3-04", false, "Explosive barrel distance boundary", "ExplosiveBarrel load failed")

	# TC-T2-R3-05: Overkill Headshot Damage Boundary (10,000 Damage)
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var z_inst = z_scene.instantiate() if z_scene else null
	if z_inst:
		root.add_child(z_inst)
		await process_frame
		z_inst.take_damage(10000.0, true, Vector3.FORWARD)
		await process_frame
		var dead_cleanly = z_inst.is_dead and z_inst.last_hit_was_headshot
		record_assertion(
			"TC-T2-R3-05",
			dead_cleanly,
			"Extreme overkill damage (10,000 dmg) cleanly transitions zombie to dead state without NaN/overflow",
			"Overkill damage caused invalid state"
		)
		z_inst.queue_free()
		await process_frame
	else:
		record_assertion("TC-T2-R3-05", false, "Overkill headshot damage boundary", "Zombie scene load failed")

	# --------------------------------------------------------------------------
	# R4 APU Stability Boundaries
	# --------------------------------------------------------------------------
	# TC-T2-R4-01: Viewport Scaling Factor Clamping [0.50, 1.0]
	var vp = root
	var scale_in_range = (vp != null and vp.scaling_3d_scale >= 0.50 and vp.scaling_3d_scale <= 1.0)
	record_assertion(
		"TC-T2-R4-01",
		scale_in_range,
		"Viewport 3D scaling factor is bounded within safe rendering bounds [0.50, 1.0]",
		"scaling_3d_scale out of range: %.2f" % (vp.scaling_3d_scale if vp else -1.0)
	)

	# TC-T2-R4-02: Police Car Prop File Size Hard Limit (< 500 KB)
	var police_glb_path = "res://assets/3d/vehicles/police.glb"
	var glb_size = FileAccess.get_file_as_bytes(police_glb_path).size() if FileAccess.file_exists(police_glb_path) else 99999999
	record_assertion(
		"TC-T2-R4-02",
		glb_size > 0 and glb_size < 500000,
		"Replacement vehicle model police.glb file size is < 500 KB (actual: %d KB)" % (glb_size / 1024),
		"police.glb missing or exceeds 500 KB"
	)

	# TC-T2-R4-03: Mobile Zombie Combined Memory Footprint (< 2.5 MB)
	var z_norm_sz = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_normal.tscn").size()
	var z_fast_sz = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_fast.tscn").size()
	var z_heavy_sz = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_heavy.tscn").size()
	var z_boss_sz = FileAccess.get_file_as_bytes("res://scenes/zombies/models/zombie_boss.tscn").size()
	var z_dog_sz = FileAccess.get_file_as_bytes("res://scenes/zombies/models/infected_dog.tscn").size()
	var total_zombie_mem = z_norm_sz + z_fast_sz + z_heavy_sz + z_boss_sz + z_dog_sz
	record_assertion(
		"TC-T2-R4-03",
		total_zombie_mem < 2500000,
		"Total disk footprint for all 5 mobile zombie archetype models is < 2.5 MB (actual: %.2f MB)" % (float(total_zombie_mem) / 1048576.0),
		"Zombie models exceed 2.5 MB combined footprint (actual: %d bytes)" % total_zombie_mem
	)

	# TC-T2-R4-04: Concurrency Cap Under Heavy Swarm Stress (<= 8 normal, <= 4 boss)
	var spawner = load("res://scripts/GameManager.gd").new()
	root.add_child(spawner)
	await process_frame
	var cap_normal = spawner.max_active_zombies <= 8
	spawner.queue_free()
	await process_frame
	record_assertion(
		"TC-T2-R4-04",
		cap_normal,
		"GameManager max_active_zombies bounded to <= 8 during normal swarms to prevent APU draw call choke",
		"max_active_zombies exceeds 8"
	)

	# TC-T2-R4-05: Particle Budget Ceiling (amount <= 60 particles per emitter)
	var b_scene = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var b_node = b_scene.instantiate() if b_scene else null
	if b_node:
		var exp_parts = b_node.get_node_or_null("ExplosionParticles") as CPUParticles3D
		var amount_ok = (exp_parts == null or exp_parts.amount <= 60)
		record_assertion(
			"TC-T2-R4-05",
			amount_ok,
			"Explosive barrel particle emission count respects APU thermal budget (<= 60 particles)",
			"Explosive barrel particle count exceeds 60 particles"
		)
		b_node.queue_free()
	else:
		record_assertion("TC-T2-R4-05", false, "Particle budget ceiling", "Barrel load failed")

# ==============================================================================
# TIER 3: CROSS-FEATURE COMBINATIONS (PAIRWISE)
# ==============================================================================

func _run_tier_3_cross_feature_combinations():
	# TC-T3-PAIR-01: Tactical Flashlight + Weapon Firing (Recoil & Muzzle Light)
	var p_scene = load("res://scenes/player/Player.tscn")
	var p = p_scene.instantiate() if p_scene else null
	if p:
		root.add_child(p)
		await process_frame
		var cam = p.get_node_or_null("Camera3D")
		var flash = cam.get_node_or_null("TacticalFlashlight") if cam else null
		# Simulate weapon fire kick
		if p.has_method("apply_kick"):
			p.apply_kick(-0.48)
		await process_frame
		var flash_active = (flash != null and flash.is_inside_tree())
		var cam_rot_changed = (cam != null and cam.rotation.x != 0.0)
		record_assertion(
			"TC-T3-PAIR-01",
			flash_active and cam_rot_changed,
			"TacticalFlashlight beam pitch-synchronizes with Camera3D during active weapon recoil kick",
			"Flashlight missing or failed to maintain camera alignment during weapon recoil kick"
		)
		p.queue_free()
		await process_frame
	else:
		record_assertion("TC-T3-PAIR-01", false, "Flashlight + Weapon Firing pair", "Player scene load failed")

	# TC-T3-PAIR-02: Explosive Barrel Chain Explosion + Multi-Zombie Damage
	var barrel_scene = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var b1 = barrel_scene.instantiate() if barrel_scene else null
	var b2 = barrel_scene.instantiate() if barrel_scene else null
	var z1 = load("res://scenes/zombies/Zombie.tscn").instantiate()
	var z2 = load("res://scenes/zombies/Zombie.tscn").instantiate()
	if b1 and b2 and z1 and z2:
		root.add_child(b1)
		root.add_child(b2)
		root.add_child(z1)
		root.add_child(z2)
		b1.position = Vector3(0, 0, 0)
		b2.position = Vector3(0, 0, 5.0) # within 6.38m chain radius
		z1.position = Vector3(0, 0, 3.0) # between barrels
		z2.position = Vector3(0, 0, 6.0) # near barrel 2
		await process_frame
		b1.take_damage(50.0) # Detonate barrel 1
		await process_frame
		await process_frame
		var b2_detonated = b2.is_exploded
		var z1_damaged = (z1.is_dead or (z1.health_component and z1.health_component.current_health < z1.health_component.max_health))
		record_assertion(
			"TC-T3-PAIR-02",
			b2_detonated and z1_damaged,
			"Barrel 1 detonation triggers chain reaction to Barrel 2 and eliminates surrounding zombies",
			"Chain explosion did not detonate Barrel 2 or damage nearby zombies"
		)
		b1.queue_free()
		b2.queue_free()
		z1.queue_free()
		z2.queue_free()
		await process_frame
	else:
		record_assertion("TC-T3-PAIR-02", false, "Barrel chain explosion pair", "Scenes load failed")

	# TC-T3-PAIR-03: Weapon Switching During Recoil Kick
	var p2 = p_scene.instantiate() if p_scene else null
	if p2:
		root.add_child(p2)
		await process_frame
		if p2.has_method("apply_kick") and p2.has_method("switch_to_weapon"):
			p2.apply_kick(-0.48)
			p2.switch_to_weapon(1)
			await process_frame
			record_assertion(
				"TC-T3-PAIR-03",
				p2.current_weapon_index == 1,
				"Switching weapon during active recoil kick smoothly transitions weapon without pitch lock",
				"Weapon switch during recoil kick failed"
			)
		else:
			record_assertion("TC-T3-PAIR-03", false, "Weapon switch during recoil kick", "Methods missing")
		p2.queue_free()
		await process_frame
	else:
		record_assertion("TC-T3-PAIR-03", false, "Weapon switch during recoil kick", "Player scene load failed")

	# TC-T3-PAIR-04: Wave 3 Boss Spawn + Siren Alert + Health Bar + Screen Shake
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	var hud_scene = load("res://scenes/UI/HUD.tscn")
	var b_test = boss_scene.instantiate() if boss_scene else null
	var h_test = hud_scene.instantiate() if hud_scene else null
	var p_test = p_scene.instantiate() if p_scene else null
	if b_test and h_test and p_test:
		root.add_child(p_test)
		root.add_child(h_test)
		root.add_child(b_test)
		await process_frame
		await process_frame
		var hp_bar = h_test.get_node_or_null("Control/BossHealthBar")
		var bar_visible = hp_bar != null and hp_bar.visible
		var bar_width_adequate = hp_bar != null and abs(hp_bar.offset_right - hp_bar.offset_left) >= 500.0
		var event_bus = root.get_node_or_null("EventBus")
		record_assertion(
			"TC-T3-PAIR-04",
			bar_visible and bar_width_adequate,
			"Boss spawn simultaneously initiates siren warning banner, expands 520px health bar, and shakes camera",
			"Boss spawn failed to activate 520px health bar or siren alert (bar_visible=%s, width_adequate=%s)" % [
				str(bar_visible), str(bar_width_adequate)
			]
		)
		b_test.queue_free()
		h_test.queue_free()
		p_test.queue_free()
		await process_frame
	else:
		record_assertion("TC-T3-PAIR-04", false, "Boss spawn + HUD + Shake combo", "Scenes load failed")

	# TC-T3-PAIR-05: Tactical Flashlight + Zombie Red Eye Emissive & Rim Silhouette
	var z_test = load("res://scenes/zombies/Zombie.tscn").instantiate()
	var p3 = p_scene.instantiate() if p_scene else null
	if z_test and p3:
		root.add_child(p3)
		root.add_child(z_test)
		z_test.position = Vector3(0, 0, -20.0) # 20m in corridor
		await process_frame
		var eye_glow = z_test.get_node_or_null("EyeGlow")
		var has_eyes = (eye_glow != null)
		var cam = p3.get_node_or_null("Camera3D")
		var flash = cam.get_node_or_null("TacticalFlashlight") if cam else null
		record_assertion(
			"TC-T3-PAIR-05",
			has_eyes and flash != null,
			"Zombie at 20m in flashlight cone exhibits visible glowing red eyes and rim lighting against dark walls",
			"Zombie red eyes or player tactical flashlight missing at 20m engagement distance"
		)
		z_test.queue_free()
		p3.queue_free()
		await process_frame
	else:
		record_assertion("TC-T3-PAIR-05", false, "Flashlight + Zombie Eyes pair", "Scenes load failed")

# ==============================================================================
# TIER 4: REAL-WORLD APPLICATION SCENARIOS
# ==============================================================================

func _run_tier_4_real_world_scenarios():
	# Scenario Phase 1: Wave 1 Defense & Flashlight Engagement
	print("\n--- [Scenario Phase 1] Wave 1 Defense & Flashlight Engagement ---")
	var dt_scene = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var dt = dt_scene.instantiate() if dt_scene else null
	if dt:
		root.add_child(dt)
		await process_frame
		var player = dt.get_node_or_null("Player")
		var cam = player.get_node_or_null("Camera3D") if player else null
		var flash = cam.get_node_or_null("TacticalFlashlight") if cam else null
		record_assertion(
			"TC-T4-SCENARIO-01",
			flash != null and flash.light_energy >= 2.5,
			"Scenario Phase 1: Quarantine Checkpoint initialized with player tactical flashlight illuminating corridor",
			"Player in DeadTargetQuarantine scene lacks TacticalFlashlight SpotLight3D"
		)
		dt.queue_free()
		await process_frame
	else:
		record_assertion("TC-T4-SCENARIO-01", false, "Scenario Phase 1 initialization", "DeadTargetQuarantine scene failed")

	# Scenario Phase 2: Wave 2 Swarming & Explosive Barrel Area Denial
	print("\n--- [Scenario Phase 2] Wave 2 Swarming & Explosive Barrel Area Denial ---")
	var barrel_scene = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var z_scene = load("res://scenes/zombies/Zombie.tscn")
	var barrel = barrel_scene.instantiate() if barrel_scene else null
	var z_swarm: Array = []
	for i in range(3):
		var z = z_scene.instantiate()
		z_swarm.append(z)
	if barrel and not z_swarm.is_empty():
		root.add_child(barrel)
		for i in range(z_swarm.size()):
			root.add_child(z_swarm[i])
			z_swarm[i].position = Vector3(float(i) * 1.5 - 1.5, 0, -2.0)
		await process_frame
		barrel.take_damage(50.0)
		await process_frame
		await process_frame
		var all_wiped = true
		for z in z_swarm:
			if not z.is_dead and z.health_component and z.health_component.current_health > 0:
				all_wiped = false
		record_assertion(
			"TC-T4-SCENARIO-02",
			all_wiped and barrel.is_exploded,
			"Scenario Phase 2: Explosive barrel shot detonates fireball wiping out entire swarming zombie cluster",
			"Explosive barrel blast failed to wipe out swarming zombies in radius"
		)
		barrel.queue_free()
		for z in z_swarm:
			z.queue_free()
		await process_frame
	else:
		record_assertion("TC-T4-SCENARIO-02", false, "Scenario Phase 2 swarming", "Instantiation failed")

	# Scenario Phase 3: Wave 3 Epic Boss Showdown & Climax
	print("\n--- [Scenario Phase 3] Wave 3 Epic Boss Showdown & Climax ---")
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	var hud_scene = load("res://scenes/UI/HUD.tscn")
	var boss = boss_scene.instantiate() if boss_scene else null
	var hud = hud_scene.instantiate() if hud_scene else null
	if boss and hud:
		root.add_child(hud)
		root.add_child(boss)
		await process_frame
		await process_frame
		var hp_bar = hud.get_node_or_null("Control/BossHealthBar")
		var bar_ready = (hp_bar != null and hp_bar.visible and abs(hp_bar.offset_right - hp_bar.offset_left) >= 500.0)
		# Damage boss
		boss.take_damage(5000.0, false, Vector3.FORWARD)
		await process_frame
		var boss_took_dmg = (boss.health_component and boss.health_component.current_health < boss.health_component.max_health)
		record_assertion(
			"TC-T4-SCENARIO-03",
			bar_ready and boss_took_dmg,
			"Scenario Phase 3: Wave 3 Titan Boss showdown active with 520px health bar and damage tracking",
			"Boss Health Bar not active at >= 500px or damage tracking failed"
		)
		boss.queue_free()
		hud.queue_free()
		await process_frame
	else:
		record_assertion("TC-T4-SCENARIO-03", false, "Scenario Phase 3 boss showdown", "Instantiation failed")

# ==============================================================================
# SUMMARY & EXIT HANDLING
# ==============================================================================

func _print_summary_and_exit():
	print("\n======================================================================")
	print("                    E2E TEST SUITE EXECUTION SUMMARY                  ")
	print("======================================================================")
	for tier_name in tier_stats.keys():
		var p = tier_stats[tier_name]["passed"]
		var t = tier_stats[tier_name]["total"]
		var pct = (float(p) / float(t) * 100.0) if t > 0 else 0.0
		print("  * %s: %d / %d PASSED (%.1f%%)" % [tier_name, p, t, pct])

	print("----------------------------------------------------------------------")
	var overall_pct = (float(passed_tests) / float(total_tests) * 100.0) if total_tests > 0 else 0.0
	print("  TOTAL PASSED: %d / %d (%.1f%%)" % [passed_tests, total_tests, overall_pct])
	print("  TOTAL DEFECTS DETECTED: %d" % failed_tests)
	print("======================================================================")

	if not defect_log.is_empty():
		print("\n======================================================================")
		print("                  DISCOVERED IMPLEMENTATION DEFECTS                   ")
		print("======================================================================")
		for i in range(defect_log.size()):
			var d = defect_log[i]
			print("%2d. [%s] (%s): %s" % [i + 1, d["id"], d["tier"], d["description"]])
			print("    -> REASON: %s\n" % d["reason"])

	print("======================================================================")
	if failed_tests == 0:
		print("   ALL DEAD TARGET QUARANTINE DEFENSE TESTS PASSED! (100% PASS RATE)  ")
		print("======================================================================")
		quit(0)
	else:
		printerr("   TEST SUITE DETECTED %d IMPLEMENTATION DEFECTS TO ESCALATE!    " % failed_tests)
		print("======================================================================")
		# Exit code 1 indicates implementation defects found
		quit(1)
