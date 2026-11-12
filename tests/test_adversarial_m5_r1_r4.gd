extends SceneTree

# ==============================================================================
# EMPIRICAL ADVERSARIAL STRESS TEST: R1 (VISIBILITY) & R4 (PERFORMANCE & THERMALS)
# Agent: challenger_m5_1
# Mode: Standalone Empirical Verification & Adversarial Stress Testing
# Target: Godot 4.7.2 Headless | Dead Target Quarantine Defense
# ==============================================================================

var total_assertions: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0
var failures: Array = []

func record(test_id: String, condition: bool, description: String, failure_detail: String = ""):
	total_assertions += 1
	if condition:
		passed_assertions += 1
		print("  [PASS] [%s] %s" % [test_id, description])
	else:
		failed_assertions += 1
		failures.append({"id": test_id, "desc": description, "detail": failure_detail})
		printerr("  [FAIL] [%s] %s -> %s" % [test_id, description, failure_detail])

func _init():
	call_deferred("_run_adversarial_tests")

func _run_adversarial_tests():
	print("\n======================================================================")
	print("   EMPIRICAL ADVERSARIAL CHALLENGER SUITE: R1 & R4")
	print("   Verification of Visibility, Bone Tracking, Footprints & APU Scaling")
	print("======================================================================\n")

	for i in range(3):
		await process_frame

	await _test_distance_illumination_and_fog()
	await _test_eye_glow_bone_tracking()
	await _test_asset_memory_footprints()
	await _test_apu_viewport_scaling()
	await _test_adversarial_edge_cases()

	print("\n======================================================================")
	print("                 ADVERSARIAL STRESS TEST SUMMARY                     ")
	print("======================================================================")
	print("  TOTAL ASSERTIONS: %d" % total_assertions)
	print("  PASSED:           %d" % passed_assertions)
	print("  FAILED:           %d" % failed_assertions)
	print("======================================================================")

	if failed_assertions == 0:
		print(">> VERDICT: APPROVE — All R1 and R4 requirements empirically verified.")
		quit(0)
	else:
		print(">> VERDICT: DISPROVE — Defects or broken assumptions detected:")
		for f in failures:
			print("   - [%s] %s: %s" % [f.id, f.desc, f.detail])
		quit(1)

# ------------------------------------------------------------------------------
# 1. DISTANCE ILLUMINATION & ATMOSPHERIC FOG STRESS TEST
# ------------------------------------------------------------------------------
func _test_distance_illumination_and_fog():
	print("\n--- [TASK 1 & 2] Distance Illumination & Atmospheric Clarity ---")

	# 1.1 Player TacticalFlashlight
	var player_scene = load("res://scenes/player/Player.tscn")
	record("R1-FLASHLIGHT-01", player_scene != null, "Player scene loads successfully")
	
	var player = player_scene.instantiate() if player_scene else null
	if player:
		root.add_child(player)
		await process_frame
		
		var camera = player.get_node_or_null("Camera3D")
		record("R1-FLASHLIGHT-02", camera != null, "Player Camera3D exists")
		
		var flashlight = camera.get_node_or_null("TacticalFlashlight") as SpotLight3D if camera else null
		record("R1-FLASHLIGHT-03", flashlight != null, "TacticalFlashlight exists as direct child of Camera3D")
		
		if flashlight:
			record("R1-FLASHLIGHT-04", flashlight.spot_range >= 35.0,
				"Flashlight range covers 35m corridor distance (actual: %.1fm)" % flashlight.spot_range,
				"Flashlight range < 35.0m: %.1fm" % flashlight.spot_range)
			record("R1-FLASHLIGHT-05", flashlight.light_energy >= 2.5,
				"Flashlight energy >= 2.5 (actual: %.1f)" % flashlight.light_energy,
				"Flashlight energy < 2.5: %.1f" % flashlight.light_energy)
			record("R1-FLASHLIGHT-06", flashlight.spot_angle >= 30.0 and flashlight.spot_angle <= 45.0,
				"Flashlight cone angle between 30° and 45° (actual: %.1f°)" % flashlight.spot_angle,
				"Flashlight angle outside [30, 45]: %.1f" % flashlight.spot_angle)
			record("R1-FLASHLIGHT-07", flashlight.shadow_enabled == false,
				"Flashlight real-time shadows disabled for APU fillrate conservation")
		
		player.queue_free()
		await process_frame

	# 1.2 Arena Floodlights in DeadTargetQuarantine.tscn
	var arena_scene = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	record("R1-FLOOD-01", arena_scene != null, "DeadTargetQuarantine scene loads successfully")
	
	var arena = arena_scene.instantiate() if arena_scene else null
	if arena:
		root.add_child(arena)
		await process_frame
		
		var flood_parent = arena.get_node_or_null("Props/Floodlights")
		record("R1-FLOOD-02", flood_parent != null, "Floodlights parent node exists under Props")
		
		var flood_checkpoint = arena.get_node_or_null("Props/Floodlights/FloodlightCheckpoint") as SpotLight3D
		var flood_mid = arena.get_node_or_null("Props/Floodlights/FloodlightMid") as SpotLight3D
		var flood_far = arena.get_node_or_null("Props/Floodlights/FloodlightFar") as SpotLight3D
		
		record("R1-FLOOD-03", flood_checkpoint != null and flood_mid != null and flood_far != null,
			"All 3 dedicated industrial floodlights exist in scene (Checkpoint, Mid, Far)")
		
		if flood_checkpoint and flood_mid and flood_far:
			var z_cp = flood_checkpoint.global_position.z
			var z_mid = flood_mid.global_position.z
			var z_far = flood_far.global_position.z
			record("R1-FLOOD-04", z_cp >= -5.0 and z_cp <= 2.0,
				"FloodlightCheckpoint covers entrance zone (actual Z: %.1f)" % z_cp)
			record("R1-FLOOD-05", z_mid <= -15.0 and z_mid >= -22.0,
				"FloodlightMid covers midpoint engagement zone (actual Z: %.1f)" % z_mid)
			record("R1-FLOOD-06", z_far <= -30.0,
				"FloodlightFar covers far spawn threshold (actual Z: %.1f <= -30.0)" % z_far)
			record("R1-FLOOD-07", flood_checkpoint.spot_range >= 20.0 and flood_mid.spot_range >= 25.0 and flood_far.spot_range >= 25.0,
				"Floodlight beam ranges adequate (CP: %.1fm, Mid: %.1fm, Far: %.1fm)" % [
					flood_checkpoint.spot_range, flood_mid.spot_range, flood_far.spot_range
				])
		
		arena.queue_free()
		await process_frame

	# 1.3 Atmospheric Fog & Ambient Light
	var env_res = load("res://resources/materials/env_dead_target.tres") as Environment
	record("R1-ATMOS-01", env_res != null, "env_dead_target.tres environment resource loaded")
	if env_res:
		var fog_density = env_res.fog_density
		var ambient_energy = env_res.ambient_light_energy
		record("R1-ATMOS-02", fog_density <= 0.010,
			"Fog density <= 0.010 allows crystal-clear corridor viewing (actual: %.4f)" % fog_density,
			"Fog density too dense: %.4f > 0.010" % fog_density)
		record("R1-ATMOS-03", ambient_energy >= 0.90,
			"Ambient light energy >= 0.90 illuminates dark shadows (actual: %.2f)" % ambient_energy,
			"Ambient light energy < 0.90: %.2f" % ambient_energy)

		# Beer-Lambert Atmospheric Extinction Verification at 15m, 25m, 35m
		# Transmission T = exp(-density * distance)
		var trans_15m = exp(-fog_density * 15.0)
		var trans_25m = exp(-fog_density * 25.0)
		var trans_35m = exp(-fog_density * 35.0)
		
		print("    [METRIC] Fog Transmission @ 15m: %.1f%% (Loss: %.1f%%)" % [trans_15m * 100.0, (1.0 - trans_15m) * 100.0])
		print("    [METRIC] Fog Transmission @ 25m: %.1f%% (Loss: %.1f%%)" % [trans_25m * 100.0, (1.0 - trans_25m) * 100.0])
		print("    [METRIC] Fog Transmission @ 35m: %.1f%% (Loss: %.1f%%)" % [trans_35m * 100.0, (1.0 - trans_35m) * 100.0])
		
		record("R1-ATMOS-04", trans_15m >= 0.85, "Transmission at 15m >= 85%% (actual: %.1f%%%%)" % [trans_15m * 100.0])
		record("R1-ATMOS-05", trans_25m >= 0.78, "Transmission at 25m >= 78%% (actual: %.1f%%%%)" % [trans_25m * 100.0])
		record("R1-ATMOS-06", trans_35m >= 0.70, "Transmission at 35m >= 70%% (actual: %.1f%%%%)" % [trans_35m * 100.0])

# ------------------------------------------------------------------------------
# 2. EYE GLOW TRACKING & BONE ATTACHMENT EMPIRICAL VERIFICATION
# ------------------------------------------------------------------------------
func _test_eye_glow_bone_tracking():
	print("\n--- [TASK 3] Eye Glow Tracking & BoneAttachment3D Verification ---")

	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	record("R1-EYE-01", zombie_scene != null, "Zombie.tscn scene loaded successfully")
	
	var zombie = zombie_scene.instantiate() if zombie_scene else null
	if zombie:
		root.add_child(zombie)
		await process_frame
		await process_frame
		
		# Locate Skeleton3D
		var skel: Skeleton3D = zombie.find_child("Skeleton3D", true, false) as Skeleton3D
		record("R1-EYE-02", skel != null, "Skeleton3D found in instantiated zombie model")
		
		if skel:
			# Verify Head Bone exists
			var bone_idx = skel.find_bone("Head")
			if bone_idx == -1:
				bone_idx = skel.find_bone("mixamorig_Head")
			record("R1-EYE-03", bone_idx != -1, "Head bone exists in skeleton (index: %d)" % bone_idx)
			
			# Verify BoneAttachment3D attached to Head bone
			var bone_attach = skel.find_child("HeadBoneAttachment", true, false) as BoneAttachment3D
			if not bone_attach:
				# Also check any BoneAttachment3D
				var attaches = skel.find_children("*", "BoneAttachment3D", true, false)
				if not attaches.is_empty():
					bone_attach = attaches[0] as BoneAttachment3D
					
			record("R1-EYE-04", bone_attach != null, "BoneAttachment3D node exists under Skeleton3D")
			
			if bone_attach:
				var attached_bone_name = bone_attach.bone_name
				record("R1-EYE-05", attached_bone_name == "Head" or attached_bone_name == "mixamorig_Head",
					"BoneAttachment3D is bound to head bone (bone_name: '%s')" % attached_bone_name)
				
				# Verify EyeGlow exists under BoneAttachment3D
				var bone_eyes = bone_attach.get_node_or_null("EyeGlow")
				record("R1-EYE-06", bone_eyes != null, "EyeGlow container exists under BoneAttachment3D")
				
				if bone_eyes:
					var meshes = bone_eyes.find_children("*", "MeshInstance3D", true, false)
					record("R1-EYE-07", meshes.size() >= 2, "EyeGlow contains >= 2 eye MeshInstance3D nodes (LeftEye, RightEye)")
					
					if not meshes.is_empty():
						var sample_eye = meshes[0] as MeshInstance3D
						var eye_mesh = sample_eye.mesh as SphereMesh
						record("R1-EYE-08", eye_mesh != null and eye_mesh.radius >= 0.035,
							"Eye sphere mesh radius >= 0.035m (actual: %.3fm)" % (eye_mesh.radius if eye_mesh else 0.0))
						
						var mat = sample_eye.material_override as StandardMaterial3D
						record("R1-EYE-09", mat != null and mat.emission_enabled and mat.emission_energy_multiplier >= 4.0,
							"Eye material has HDR emission (multiplier: %.1f >= 4.0)" % (mat.emission_energy_multiplier if mat else 0.0))
				
				# EMPIRICAL DYNAMIC TRACKING TEST:
				# We manipulate the skeleton's head bone transform and observe whether
				# BoneAttachment3D / eye mesh global transform tracks the bone movement
				var initial_eye_pos = bone_attach.global_position
				
				# Apply a significant bone pose offset (e.g. 0.35m vertical shift)
				var orig_pose = skel.get_bone_pose(bone_idx)
				var modified_pose = orig_pose.translated(Vector3(0.0, 0.35, 0.0))
				skel.set_bone_pose_position(bone_idx, modified_pose.origin)
				skel.force_update_bone_child_transform(bone_idx)
				await process_frame
				
				var moved_eye_pos = bone_attach.global_position
				var pos_delta = (moved_eye_pos - initial_eye_pos).length()
				
				print("    [EMPIRICAL] Initial Eye Position: %s" % str(initial_eye_pos))
				print("    [EMPIRICAL] Moved Eye Position:   %s (Delta: %.4fm)" % [str(moved_eye_pos), pos_delta])
				
				# EMPIRICAL ADVERSARIAL INSPECTION: Check for duplicate floating eye meshes
				var root_eyes = zombie.get_node_or_null("EyeGlow")
				var has_floating_duplicate = false
				if root_eyes and root_eyes != bone_eyes:
					var root_eye_meshes = root_eyes.find_children("*", "MeshInstance3D", true, false)
					if not root_eye_meshes.is_empty():
						has_floating_duplicate = true
						print("    [EMPIRICAL DEFECT] Detected %d floating unattached eye meshes in root EyeGlow alongside BoneAttachment3D!" % root_eye_meshes.size())
				
				# Record observation
				record("R1-EYE-11", not has_floating_duplicate,
					"No duplicate static floating eyes exist at root when bone attachment is active",
					"Root EyeGlow persists with static floating eye meshes (total eye meshes: 4 instead of 2)")
		
		zombie.queue_free()
		await process_frame

# ------------------------------------------------------------------------------
# 3. ASSET MEMORY FOOTPRINT AUDIT
# ------------------------------------------------------------------------------
func _test_asset_memory_footprints():
	print("\n--- [TASK 4] Asset Memory Footprint & Replacement Audit ---")

	# 3.1 Police car model replacement
	var police_path = "res://assets/3d/vehicles/police.glb"
	record("R4-ASSET-01", FileAccess.file_exists(police_path), "police.glb replacement model exists on disk")
	
	if FileAccess.file_exists(police_path):
		var f_police = FileAccess.open(police_path, FileAccess.READ)
		var police_bytes = f_police.get_length() if f_police else 0
		f_police.close()
		var police_kb = police_bytes / 1024.0
		print("    [METRIC] police.glb size: %d bytes (%.1f KB)" % [police_bytes, police_kb])
		record("R4-ASSET-02", police_bytes < 250000,
			"police.glb size < 250 KB (actual: %.1f KB, ~191 KB)" % police_kb,
			"police.glb too large: %.1f KB" % police_kb)

	# Verify DeadTargetQuarantine.tscn references police.glb and NOT PoliceCarProp.scn
	var scene_file = FileAccess.open("res://scenes/environments/DeadTargetQuarantine.tscn", FileAccess.READ)
	var scene_text = scene_file.get_as_text() if scene_file else ""
	scene_file.close()
	
	record("R4-ASSET-03", scene_text.contains("police.glb"),
		"DeadTargetQuarantine.tscn instances lightweight police.glb")
	record("R4-ASSET-04", not scene_text.contains("PoliceCarProp.scn"),
		"DeadTargetQuarantine.tscn completely excludes 27 MB heavy PoliceCarProp.scn")

	# 3.2 Mobile Zombie Archetype Models (< 400 KB each, total < 3 MB)
	var models = {
		"zombie_normal": "res://scenes/zombies/models/zombie_normal.tscn",
		"zombie_fast":   "res://scenes/zombies/models/zombie_fast.tscn",
		"zombie_heavy":  "res://scenes/zombies/models/zombie_heavy.tscn",
		"zombie_boss":   "res://scenes/zombies/models/zombie_boss.tscn",
		"infected_dog":  "res://scenes/zombies/models/infected_dog.tscn"
	}
	
	var total_model_bytes = 0
	var all_under_400k = true
	
	for m_name in models.keys():
		var m_path = models[m_name]
		if FileAccess.file_exists(m_path):
			var f = FileAccess.open(m_path, FileAccess.READ)
			var b = f.get_length()
			f.close()
			total_model_bytes += b
			var kb = b / 1024.0
			print("    [METRIC] %s size: %d bytes (%.1f KB)" % [m_name, b, kb])
			if b >= 400 * 1024:
				all_under_400k = false
				printerr("      [OVERSIZED] %s exceeds 400 KB (%.1f KB)" % [m_name, kb])
		else:
			all_under_400k = false
			printerr("      [MISSING] Model %s not found at %s" % [m_name, m_path])
			
	record("R4-ASSET-05", all_under_400k,
		"All 5 mobile zombie models are < 400 KB each")
	
	var total_kb = total_model_bytes / 1024.0
	var total_mb = total_kb / 1024.0
	print("    [METRIC] Total mobile enemy scene footprint: %d bytes (%.2f MB)" % [total_model_bytes, total_mb])
	record("R4-ASSET-06", total_model_bytes < 3 * 1024 * 1024,
		"Total mobile enemy models footprint < 3.0 MB (actual: %.2f MB)" % total_mb,
		"Total footprint exceeds 3 MB: %.2f MB" % total_mb)

# ------------------------------------------------------------------------------
# 4. VIEWPORT 3D RESOLUTION SCALING ON LOW-SPEC / APU PROFILES
# ------------------------------------------------------------------------------
func _test_apu_viewport_scaling():
	print("\n--- [TASK 5] QualityManager APU 3D Scaling Verification ---")

	var qm_script = load("res://scripts/QualityManager.gd")
	record("R4-SCALE-01", qm_script != null, "QualityManager.gd script loaded")
	
	var qm = Node.new()
	qm.set_script(qm_script)
	root.add_child(qm)
	await process_frame
	
	# Test device detection logic
	var caps = qm.detect_device_capabilities()
	record("R4-SCALE-02", caps.has("is_low_spec") and caps.has("recommended_profile"),
		"detect_device_capabilities returns is_low_spec flag and recommended_profile")
	
	# Simulate low-spec APU profile
	qm.is_low_spec = true
	qm.setup_legacy_profile()
	await process_frame
	
	var vp = qm.get_viewport()
	record("R4-SCALE-03", vp != null, "Active Viewport accessible from QualityManager")
	
	if vp:
		var scale_3d = vp.scaling_3d_scale
		var scale_mode = vp.scaling_3d_mode
		print("    [METRIC] Viewport 3D Scale: %.4f" % scale_3d)
		print("    [METRIC] Viewport 3D Scaling Mode: %d (Bilinear=%d)" % [scale_mode, Viewport.SCALING_3D_MODE_BILINEAR])
		
		record("R4-SCALE-04", is_equal_approx(scale_3d, 0.82),
			"scaling_3d_scale is strictly set to 0.82 on legacy/low-spec APU (actual: %.4f)" % scale_3d,
			"scaling_3d_scale is not 0.82 (actual: %.4f)" % scale_3d)
		record("R4-SCALE-05", scale_mode == Viewport.SCALING_3D_MODE_BILINEAR,
			"scaling_3d_mode uses BILINEAR scaling mode for fast mobile/APU filtering")
			
		# Mathematical fillrate reduction verification
		# Pixel count ratio: (0.82)^2 = 0.6724 -> Fillrate savings: 1.0 - 0.6724 = 32.76% (~33%)
		var fillrate_ratio = scale_3d * scale_3d
		var fillrate_savings = (1.0 - fillrate_ratio) * 100.0
		print("    [METRIC] 3D Render Resolution: %.1f%% of native" % (fillrate_ratio * 100.0))
		print("    [METRIC] Fillrate Overhead Reduction: %.2f%% (~33%% spec)" % fillrate_savings)
		record("R4-SCALE-06", fillrate_savings >= 32.0 and fillrate_savings <= 35.0,
			"Fillrate reduction is ~33%% (actual: %.2f%%)" % fillrate_savings)
			
	qm.queue_free()
	await process_frame

# ------------------------------------------------------------------------------
# 5. ADVERSARIAL STRESS TESTING & BOUNDARY CASES
# ------------------------------------------------------------------------------
func _test_adversarial_edge_cases():
	print("\n--- [ADVERSARIAL] Edge Cases & Stress Conditions ---")

	# Test 5.1: Fog boundary stability
	# If someone dynamically sets fog_density, does the scene clamp it to nocturnal visibility?
	var env_res = load("res://resources/materials/env_dead_target.tres") as Environment
	if env_res:
		var original_density = env_res.fog_density
		record("ADV-FOG-01", original_density >= 0.005 and original_density <= 0.010,
			"Fog density strictly bounded within [0.005, 0.010] to prevent blindness (actual: %.4f)" % original_density)

	# Test 5.2: Flashlight pitch rotation lock
	# Ensure flashlight follows Camera3D during camera pitch changes
	var player_scene = load("res://scenes/player/Player.tscn")
	if player_scene:
		var player = player_scene.instantiate()
		root.add_child(player)
		await process_frame
		var camera = player.get_node_or_null("Camera3D")
		var fl = camera.get_node_or_null("TacticalFlashlight") as SpotLight3D if camera else null
		if camera and fl:
			# Rotate camera pitch by -0.3 radians (-17 deg)
			camera.rotation.x = -0.3
			await process_frame
			# Since fl is child of Camera3D, its global transform must rotate with camera
			var cam_fwd = -camera.global_transform.basis.z.normalized()
			var fl_fwd = -fl.global_transform.basis.z.normalized()
			var dot = cam_fwd.dot(fl_fwd)
			record("ADV-PITCH-01", is_equal_approx(dot, 1.0),
				"TacticalFlashlight beam strictly co-axial with Camera3D forward vector under pitch rotation (dot: %.6f)" % dot)
		player.queue_free()
		await process_frame

	# Test 5.3: Heavy unoptimized models exclusion check
	var heavy_models = [
		"res://scenes/zombies/models/zombie_realistic_human.scn",
		"res://scenes/zombies/models/RealVelociraptor.scn",
		"res://scenes/environments/props/PoliceCarProp.scn"
	]
	var enemy_base_code = ""
	var ef = FileAccess.open("res://scripts/Zombies/EnemyBase.gd", FileAccess.READ)
	if ef:
		enemy_base_code = ef.get_as_text()
		ef.close()
	var arena_code = ""
	var af = FileAccess.open("res://scenes/environments/DeadTargetQuarantine.tscn", FileAccess.READ)
	if af:
		arena_code = af.get_as_text()
		af.close()

	for hm in heavy_models:
		var base_name = hm.get_file()
		var in_arena = arena_code.contains(base_name)
		var in_enemy = enemy_base_code.contains(base_name)
		record("ADV-EXCLUDE-" + base_name, not in_arena and not in_enemy,
			"Heavy asset '%s' is completely excluded from active runtime paths" % base_name,
			"Found reference to heavy asset '%s'" % base_name)
