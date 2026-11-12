extends SceneTree

# ==============================================================================
# EMPIRICAL ADVERSARIAL STRESS TEST SUITE: REQUIREMENT R2 & REQUIREMENT R3
# ==============================================================================
# Target Codebase: /home/am/targetkill
# Focus:
#   R2: Epic Boss Climax (Wave 3 Boss, Screen Shake 0.42, Siren Alert, 520px HP Bar, Scale >= 2.0x)
#   R3: Addictive Arcade Combat Loop (Rapid Weapon Switching, Key 4 Pestilence Handgun,
#       Decapitation & Gore Leaks, Explosive Barrel 350 dmg / 7.5m Chain Reactions)
# ==============================================================================

var test_count: int = 0
var pass_count: int = 0
var fail_count: int = 0
var failure_details: Array = []

func _init():
	call_deferred("_run_adversarial_suite")

func record(id: String, condition: bool, description: String, fail_detail: String = ""):
	test_count += 1
	if condition:
		pass_count += 1
		print("  [PASS] [%s] %s" % [id, description])
	else:
		fail_count += 1
		failure_details.append({"id": id, "desc": description, "fail": fail_detail})
		printerr("  [FAIL] [%s] %s => DEFECT: %s" % [id, description, fail_detail])

func _run_adversarial_suite():
	for i in range(5):
		await process_frame

	print("\n======================================================================")
	print("   EMPIRICAL ADVERSARIAL CHALLENGER SUITE: R2 & R3 STRESS TESTING     ")
	print("   Target: Godot 4.x Headless Mode                                    ")
	print("======================================================================\n")

	print(">>> [SUITE 1] RAPID WEAPON SWITCHING & ARSENAL RELIABILITY STRESS TEST (R3)")
	await _test_rapid_weapon_switching()

	print("\n>>> [SUITE 2] DECAPITATION & GORE STRESS TEST (R3)")
	await _test_decapitation_and_gore()

	print("\n>>> [SUITE 3] EXPLOSIVE BARREL CHAIN REACTION & RADIUS STRESS TEST (R3)")
	await _test_explosive_barrel_chains()

	print("\n>>> [SUITE 4] EPIC BOSS CLIMAX & SHOWDOWN MECHANICS STRESS TEST (R2)")
	await _test_boss_climax()

	_print_summary_and_exit()

# ==============================================================================
# SUITE 1: RAPID WEAPON SWITCHING (R3)
# ==============================================================================
func _test_rapid_weapon_switching():
	var player_scene = load("res://scenes/player/Player.tscn")
	var player = player_scene.instantiate() if player_scene else null
	if not player:
		record("ST-R3-WEP-01", false, "Player instantiation", "Failed to load Player.tscn")
		return

	root.add_child(player)
	await process_frame
	await process_frame

	# Verify starter weapons slots 0..3
	var expected_ids = ["negev_ng7", "akx_scifi", "car_smg", "pestilence_handgun"]
	var slots_ok = true
	var slot_detail = ""
	for i in range(4):
		if i >= player.weapons.size():
			slots_ok = false
			slot_detail = "Player has fewer than 4 weapons (%d)" % player.weapons.size()
			break
		var w = player.weapons[i]
		var wid = w.weapon_data.weapon_id if (w and w.weapon_data) else ""
		if wid != expected_ids[i]:
			slots_ok = false
			slot_detail = "Slot %d is %s (expected %s)" % [i, wid, expected_ids[i]]
			break

	record("ST-R3-WEP-01", slots_ok, "Starter weapons occupy slots 0..3 (NG7, AKX, SMG-9, Pestilence)", slot_detail)

	# Adversarial check: SaveManager unlocked_weapons desync test
	var save_mgr = root.get_node_or_null("SaveManager")
	if save_mgr and save_mgr.data:
		save_mgr.data.unlocked_weapons = [
			"rocket_launcher", "ray_gun_cod", "prowler_smg", "primordium_vandal",
			"grenade_mk2", "negev_ng7", "akx_scifi", "car_smg", "pestilence_handgun"
		]
		player._init_weapons()
		await process_frame

		var desync_detected = false
		for i in range(4):
			var w = player.weapons[i]
			var wid = w.weapon_data.weapon_id if (w and w.weapon_data) else ""
			if wid != expected_ids[i]:
				desync_detected = true
				break
		record(
			"ST-R3-WEP-02",
			not desync_detected,
			"Starter military weapons never desync from slots 0..3 even with arbitrary savegame unlocks",
			"Starter weapons shifted out of slots 0..3 when all weapons were unlocked"
		)

	# Rapid switching across Keys 1, 2, 3, 4 via InputEventKey
	var key_mappings = {
		KEY_1: 0,
		KEY_2: 1,
		KEY_3: 2,
		KEY_4: 3
	}
	var keys = [KEY_1, KEY_2, KEY_3, KEY_4]
	var rapid_success = true
	var key4_failures = 0
	var total_switches = 120

	for s in range(total_switches):
		var target_key = keys[s % keys.size()]
		var ev = InputEventKey.new()
		ev.keycode = target_key
		ev.pressed = true
		player._input(ev)
		
		var expected_slot = key_mappings[target_key]
		if player.current_weapon_index != expected_slot:
			rapid_success = false
			if target_key == KEY_4:
				key4_failures += 1

	record(
		"ST-R3-WEP-03",
		rapid_success and key4_failures == 0,
		"Rapid weapon switching across Keys 1-4 executes 120 rapid cycles without failure",
		"Weapon index mismatched or Key 4 failed %d times" % key4_failures
	)

	# Verify Key 4 specifically selects Pestilence Handgun with 100% reliability
	var pestilence_count = 0
	for trial in range(50):
		var ev4 = InputEventKey.new()
		ev4.keycode = KEY_4
		ev4.pressed = true
		player._input(ev4)
		var cur_w = player.get_current_weapon()
		var cur_id = cur_w.weapon_data.weapon_id if (cur_w and cur_w.weapon_data) else ""
		if player.current_weapon_index == 3 and cur_id == "pestilence_handgun":
			pestilence_count += 1
		# Randomly switch to another weapon
		player.switch_to_weapon(randi() % 3)

	record(
		"ST-R3-WEP-04",
		pestilence_count == 50,
		"Key 4 achieves 100% reliable selection (50/50 trials) of slot 3 Pestilence Handgun",
		"Key 4 only selected Pestilence Handgun %d / 50 times" % pestilence_count
	)

	# Switching during active firing
	player.start_fire()
	var fire_switch_ok = true
	for s in range(20):
		var slot = s % 4
		player.switch_to_weapon(slot)
		if player.current_weapon_index != slot:
			fire_switch_ok = false
			break
	player.stop_fire()
	record(
		"ST-R3-WEP-05",
		fire_switch_ok and is_instance_valid(player.fps_arms) and is_instance_valid(player.weapon_manager),
		"Weapon switching during continuous firing operates smoothly without viewmodel corruption",
		"Switching during fire resulted in invalid state"
	)

	# Switching during active reload & tween
	var cur_w = player.get_current_weapon()
	if cur_w:
		cur_w.current_ammo = 0
		player._trigger_reload()
		# Rapidly switch to weapon 3 during reload
		var ev4 = InputEventKey.new()
		ev4.keycode = KEY_4
		ev4.pressed = true
		player._input(ev4)
		await process_frame
		var w3 = player.get_current_weapon()
		var w3_id = w3.weapon_data.weapon_id if (w3 and w3.weapon_data) else ""
		record(
			"ST-R3-WEP-06",
			player.current_weapon_index == 3 and w3_id == "pestilence_handgun",
			"Active reload is immediately cancelled upon switching, transitioning cleanly to slot 3",
			"Reload switch failed (current_slot=%d, id=%s)" % [player.current_weapon_index, w3_id]
		)

	player.queue_free()
	await process_frame

# ==============================================================================
# SUITE 2: DECAPITATION & GORE STRESS TEST (R3)
# ==============================================================================
func _test_decapitation_and_gore():
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if not zombie_scene:
		record("ST-R3-GORE-01", false, "Load Zombie.tscn", "Zombie.tscn missing")
		return

	var zombie_count = 25
	var all_decapitated_zero_scale = true
	var all_headzones_hidden = true
	var all_eyeglows_hidden = true
	var gore_effects_spawned = 0

	for i in range(zombie_count):
		var z = zombie_scene.instantiate()
		root.add_child(z)
		z.position = Vector3(0, 0, -3.0)
		await process_frame

		# Lethal headshot
		z.take_damage(600.0, true, Vector3.FORWARD)
		await process_frame

		# Verify zombie is dead & headshot flag
		if not z.is_dead or not z.last_hit_was_headshot:
			all_decapitated_zero_scale = false

		# Verify skeleton head bone scale is strictly Vector3.ZERO
		var skel: Skeleton3D = z.skeleton if z.skeleton else (z.find_child("Skeleton3D", true, false) as Skeleton3D)
		if skel:
			var head_idx = skel.find_bone("mixamorig_Head")
			if head_idx == -1:
				head_idx = skel.find_bone("Head")
			if head_idx != -1:
				var bone_scale = skel.get_bone_pose_scale(head_idx)
				if bone_scale != Vector3.ZERO:
					all_decapitated_zero_scale = false

		# Verify HeadHitZone is hidden
		var hz = z.get_node_or_null("HeadHitZone")
		if hz and hz.visible:
			all_headzones_hidden = false

		# Verify EyeGlow is hidden
		var eg = z.find_child("EyeGlow", true, false)
		if eg and eg.visible:
			all_eyeglows_hidden = false

		# Check for spawned gore effect
		var gore_nodes = root.find_children("*", "CPUParticles3D", true, false)
		for gn in gore_nodes:
			if ("HeadshotGoreEffect" in gn.name or gn.name == "HeadshotGoreEffect") and is_instance_valid(gn):
				gore_effects_spawned += 1
				break

		z.queue_free()
		await process_frame

	record(
		"ST-R3-GORE-01",
		all_decapitated_zero_scale,
		"25 lethal headshots strictly scale mixamorig_Head bone to Vector3.ZERO across all zombies",
		"One or more zombies failed head bone zero-scaling decapitation"
	)

	record(
		"ST-R3-GORE-02",
		all_headzones_hidden and all_eyeglows_hidden,
		"HeadHitZone and EyeGlow nodes are 100% hidden upon decapitation across all 25 zombies",
		"HeadHitZone or EyeGlow remained visible post-decapitation"
	)

	record(
		"ST-R3-GORE-03",
		gore_effects_spawned >= 20,
		"HeadshotGoreEffect blood particle instances spawned on headshot kills (spawn count = %d / 25)" % gore_effects_spawned,
		"HeadshotGoreEffect particles failed to spawn reliably"
	)

	# Wait for particle timeout (0.85s lifetime + timer)
	await create_timer(1.2).timeout
	await process_frame

	# Check for memory leaks / lingering gore nodes
	var lingering_gore_nodes = root.find_children("*", "CPUParticles3D", true, false)
	var lingering_count = 0
	for n in lingering_gore_nodes:
		if ("HeadshotGoreEffect" in n.name or n.name == "HeadshotGoreEffect") and is_instance_valid(n) and not n.is_queued_for_deletion():
			lingering_count += 1

	record(
		"ST-R3-GORE-04",
		lingering_count == 0,
		"Zero memory leak: all HeadshotGoreEffect instances cleanly self-freed after emitter lifetime",
		"Memory leak: %d lingering HeadshotGoreEffect instances failed to free" % lingering_count
	)

# ==============================================================================
# SUITE 3: EXPLOSIVE BARREL CHAIN REACTION STRESS TEST (R3)
# ==============================================================================
func _test_explosive_barrel_chains():
	var barrel_scene = load("res://scenes/objects/ExplosiveBarrel.tscn")
	var zombie_scene = load("res://scenes/zombies/Zombie.tscn")
	if not barrel_scene or not zombie_scene:
		record("ST-R3-BARREL-01", false, "Load scenes", "ExplosiveBarrel or Zombie scene failed")
		return

	# Subtest 3.1: Spec verification
	var b_sample = barrel_scene.instantiate()
	var damage_ok = (b_sample.explosion_damage == 350.0)
	var radius_ok = (b_sample.explosion_radius == 7.5)
	record(
		"ST-R3-BARREL-01",
		damage_ok and radius_ok,
		"Explosive barrel delivers 350.0 blast damage across 7.5m radius",
		"Barrel specs mismatch (damage=%.1f, radius=%.1f)" % [b_sample.explosion_damage, b_sample.explosion_radius]
	)
	b_sample.queue_free()

	# Subtest 3.2: 4-Barrel Chain Reaction & Nearby Zombie Elimination
	# Barrel A at (0, 0, 0)
	# Barrel B at (0, 0, 5.0) -> dist 5.0m <= 6.375m (chain reaction target)
	# Barrel C at (0, 0, 10.0) -> dist 5.0m from B (secondary chain target)
	# Barrel D at (0, 0, 24.0) -> dist 14.0m from C (> 7.5m, should survive)
	var bA = barrel_scene.instantiate()
	var bB = barrel_scene.instantiate()
	var bC = barrel_scene.instantiate()
	var bD = barrel_scene.instantiate()
	root.add_child(bA)
	root.add_child(bB)
	root.add_child(bC)
	root.add_child(bD)
	bA.position = Vector3(0, 0, 0)
	bB.position = Vector3(0, 0, 5.0)
	bC.position = Vector3(0, 0, 10.0)
	bD.position = Vector3(0, 0, 24.0)

	# Place zombies:
	# z1 at (0, 0, 2.5) -> near A & B
	# z2 at (0, 0, 7.5) -> near B & C
	# z3 at (0, 0, 12.0) -> 2.0m from C
	# z4 at (0, 0, 35.0) -> far away, out of range
	var z1 = zombie_scene.instantiate()
	var z2 = zombie_scene.instantiate()
	var z3 = zombie_scene.instantiate()
	var z4 = zombie_scene.instantiate()
	root.add_child(z1)
	root.add_child(z2)
	root.add_child(z3)
	root.add_child(z4)
	z1.position = Vector3(0, 0, 2.5)
	z2.position = Vector3(0, 0, 7.5)
	z3.position = Vector3(0, 0, 12.0)
	z4.position = Vector3(0, 0, 35.0)

	await process_frame
	await process_frame

	# Shoot Barrel A with 50 damage (exceeds 25 HP)
	bA.take_damage(50.0)

	# Allow chain reaction frames to propagate through B and C
	for f in range(6):
		await process_frame

	var bA_exploded = bA.is_exploded
	var bB_exploded = bB.is_exploded
	var bC_exploded = bC.is_exploded
	var bD_survived = not bD.is_exploded

	record(
		"ST-R3-BARREL-02",
		bA_exploded and bB_exploded and bC_exploded and bD_survived,
		"3-barrel chain reaction (A -> B -> C) detonates sequentially; distant Barrel D survives",
		"Chain reaction failure: bA=%s, bB=%s, bC=%s, bD_survived=%s" % [
			str(bA_exploded), str(bB_exploded), str(bC_exploded), str(bD_survived)
		]
	)

	var z1_eliminated = z1.is_dead or (z1.health_component and z1.health_component.current_health <= 0)
	var z2_eliminated = z2.is_dead or (z2.health_component and z2.health_component.current_health <= 0)
	var z3_eliminated = z3.is_dead or (z3.health_component and z3.health_component.current_health <= 0)
	var z4_untouched = not z4.is_dead and (z4.health_component and z4.health_component.current_health == z4.health_component.max_health)

	record(
		"ST-R3-BARREL-03",
		z1_eliminated and z2_eliminated and z3_eliminated and z4_untouched,
		"Chain blasts eliminate all nearby zombies (Z1, Z2, Z3) while distant Zombie 4 takes 0 damage",
		"Zombie damage mismatch: z1=%s, z2=%s, z3=%s, z4_untouched=%s" % [
			str(z1_eliminated), str(z2_eliminated), str(z3_eliminated), str(z4_untouched)
		]
	)

	# Clean up instances safely
	if is_instance_valid(bD) and not bD.is_queued_for_deletion():
		bD.queue_free()
	if is_instance_valid(z4) and not z4.is_queued_for_deletion():
		z4.queue_free()
	await process_frame

# ==============================================================================
# SUITE 4: EPIC BOSS CLIMAX (R2)
# ==============================================================================
func _test_boss_climax():
	var boss_scene = load("res://scenes/zombies/BossZombie.tscn")
	var hud_scene = load("res://scenes/UI/HUD.tscn")
	var player_scene = load("res://scenes/player/Player.tscn")

	if not boss_scene or not hud_scene or not player_scene:
		record("ST-R2-BOSS-01", false, "Load boss/hud/player scenes", "One or more scenes failed to load")
		return

	var player = player_scene.instantiate()
	var hud = hud_scene.instantiate()
	root.add_child(player)
	root.add_child(hud)
	player.position = Vector3(0, 0, 0)
	player.shake_intensity = 0.0

	await process_frame

	var boss = boss_scene.instantiate()
	root.add_child(boss)
	var shake_at_spawn = player.shake_intensity
	boss.position = Vector3(0, 0, -10.0)

	await process_frame
	await process_frame

	# Scale verification (Towering scale >= 2.0x, target 2.3x)
	var scale_ok = (boss.scale.x >= 2.0 and boss.scale.y >= 2.0 and boss.scale.z >= 2.0)
	record(
		"ST-R2-BOSS-01",
		scale_ok,
		"Boss Zombie exhibits towering scale >= Vector3(2.0, 2.0, 2.0) (actual: %s)" % str(boss.scale),
		"Boss scale is %s (< 2.0x)" % str(boss.scale)
	)

	# Biohazard red glowing veins & ChestLight
	var has_red_veins = false
	var meshes = boss.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		for s in range(m.get_surface_override_material_count()):
			var mat = m.get_surface_override_material(s)
			if mat is StandardMaterial3D and mat.emission_enabled and mat.emission_energy_multiplier >= 3.0:
				has_red_veins = true
				break
	var chest_light = boss.get_node_or_null("ChestLight") as OmniLight3D
	var chest_light_ok = chest_light != null and chest_light.light_energy >= 2.0
	record(
		"ST-R2-BOSS-02",
		has_red_veins and chest_light_ok,
		"Boss Zombie features biohazard red emission veins (multiplier >= 3.0) and ChestLight (energy >= 2.0)",
		"Boss veins emission or ChestLight missing"
	)

	# Camera screen-shake 0.42 trigger verification
	var shake_applied = (shake_at_spawn >= 0.40)
	record(
		"ST-R2-BOSS-03",
		shake_applied,
		"Boss entrance triggers player camera screen-shake (applied intensity = %.2f, target 0.42)" % shake_at_spawn,
		"player.apply_shake(0.42) not invoked on entrance (shake_at_spawn=%.2f)" % shake_at_spawn
	)

	# Siren warning alert banner on HUD
	var warning_banner = hud.find_child("BossWarningBanner", true, false)
	var banner_active = warning_banner != null and warning_banner.visible
	var banner_lbl = warning_banner.get_node_or_null("WarningLabel") as Label if warning_banner else null
	var banner_text_ok = banner_lbl != null and banner_lbl.text.contains("WARNING: TITAN MUTANT APPROACHING")
	record(
		"ST-R2-BOSS-04",
		banner_active and banner_text_ok,
		"HUD displays animated siren alert banner ('WARNING: TITAN MUTANT APPROACHING')",
		"Warning banner not visible or missing warning text"
	)

	# 520px Boss Health Bar prominence and health tracking
	var hp_bar = hud.get_node_or_null("Control/BossHealthBar") as ProgressBar
	var bar_visible = hp_bar != null and hp_bar.visible
	var bar_width = abs(hp_bar.offset_right - hp_bar.offset_left) if hp_bar else 0.0
	if hp_bar and hp_bar.custom_minimum_size.x > bar_width:
		bar_width = hp_bar.custom_minimum_size.x
	var width_520_ok = (bar_width >= 500.0)

	record(
		"ST-R2-BOSS-05",
		bar_visible and width_520_ok,
		"Boss Health Bar is prominent at top of HUD (width = %.1f px, nominal 520px)" % bar_width,
		"Boss Health Bar width is only %.1f px (< 500px)" % bar_width
	)

	# Real-time health damage tracking & Enrage state
	var initial_max_hp = boss.health_component.max_health if boss.health_component else 35000.0
	var hp_bar_synced_initial = (hp_bar != null and hp_bar.max_value == initial_max_hp and hp_bar.value == initial_max_hp)

	# Mutated Carapace body damage: 15% damage taken (85% reduction), capped at 350.0
	# Deal 1000.0 damage -> 150.0 actual damage applied
	boss.take_damage(1000.0, false, Vector3.FORWARD)
	await process_frame
	var hp_bar_synced_after_dmg = (hp_bar != null and abs(hp_bar.value - (initial_max_hp - 150.0)) < 1.0)

	# Heavy burst hit: 5000.0 damage -> capped at 350.0 max hit damage
	var hp_before_cap = boss.health_component.current_health
	boss.take_damage(5000.0, false, Vector3.FORWARD)
	await process_frame
	var hit_cap_respected = abs(boss.health_component.current_health - (hp_before_cap - 350.0)) < 1.0

	# Damage boss to <= 50% HP to trigger enrage mechanics
	var remaining_for_enrage = boss.health_component.current_health - (initial_max_hp * 0.48)
	boss.health_component.take_damage(remaining_for_enrage)
	for pf in range(5):
		await process_frame
	var enrage_triggered = boss.has_enraged and boss.move_speed >= 1.3 and boss.attack_interval <= 1.8
	var hp_bar_enrage_synced = (hp_bar != null and hp_bar.value <= (initial_max_hp * 0.50))

	# Lethal blow to Boss via health_component
	boss.health_component.take_damage(boss.health_component.current_health)
	await process_frame
	await process_frame
	var boss_eliminated = boss.is_dead and (hp_bar.value <= 0.0 or not hp_bar.visible)

	record(
		"ST-R2-BOSS-06",
		hp_bar_synced_initial and hp_bar_synced_after_dmg and hit_cap_respected and enrage_triggered and hp_bar_enrage_synced and boss_eliminated,
		"Boss Health Bar tracks damage in real-time; 350 cap & 50% HP enrage trigger; death cleanly handled",
		"Boss damage tracking / enrage failure (synced_init=%s, synced_dmg=%s, cap=%s, enraged=%s, dead=%s)" % [
			str(hp_bar_synced_initial), str(hp_bar_synced_after_dmg), str(hit_cap_respected), str(enrage_triggered), str(boss_eliminated)
		]
	)

	boss.queue_free()
	hud.queue_free()
	player.queue_free()
	await process_frame

# ==============================================================================
# SUMMARY & EXIT
# ==============================================================================
func _print_summary_and_exit():
	print("\n======================================================================")
	print("          EMPIRICAL ADVERSARIAL STRESS TEST SUITE SUMMARY             ")
	print("======================================================================")
	var pct = (float(pass_count) / float(test_count) * 100.0) if test_count > 0 else 0.0
	print("  TOTAL TESTS: %d" % test_count)
	print("  PASSED:      %d (%.1f%%)" % [pass_count, pct])
	print("  FAILED:      %d" % fail_count)
	print("======================================================================")

	if fail_count > 0:
		print("\n======================= FAILURES / DEFECTS ===========================")
		for f in failure_details:
			print("  * [%s] %s => %s" % [f["id"], f["desc"], f["fail"]])
		print("======================================================================")
		quit(1)
	else:
		print("   ALL EMPIRICAL ADVERSARIAL CHALLENGES PASSED SUCCESSFULLY!          ")
		print("   VERDICT: APPROVE (Requirements R2 & R3 verified rock-solid)        ")
		print("======================================================================")
		quit(0)
