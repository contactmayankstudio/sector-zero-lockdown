extends SceneTree

var passed: int = 0
var failed: int = 0

func _init():
	print("\n==================================================")
	print("AUDITING ENDLESS SURVIVAL SCALING & BOSS CADENCE")
	print("==================================================")
	
	var gm_script = load("res://scripts/GameManager.gd")
	var gm = Node3D.new()
	gm.set_script(gm_script)
	root.add_child(gm)
	
	gm.is_endless_mode = true
	var enemy_script = load("res://scripts/Zombies/EnemyBase.gd")
	
	# Test scaling across waves 1 to 30
	var waves_to_test = [1, 5, 10, 20, 30]
	
	for w in waves_to_test:
		gm.current_wave = w
		
		# Expected calculations
		var exp_hp = 1.0 + (w - 1) * 0.08
		var exp_dmg = clamp(1.0 + (w - 1) * 0.06, 1.0, 3.0)
		var exp_spd = clamp(1.0 + (w - 1) * 0.015, 1.0, 1.45)
		
		# Zombie node with real EnemyBase and HealthComponent
		var mock_zombie = CharacterBody3D.new()
		mock_zombie.set_script(enemy_script)
		var mock_health = HealthComponent.new()
		mock_health.max_health = 50.0
		mock_health.current_health = 50.0
		mock_zombie.add_child(mock_health)
		mock_zombie.health_component = mock_health
		mock_zombie.attack_damage = 10.0
		mock_zombie.move_speed = 2.0
		
		gm._apply_endless_scaling(mock_zombie)
		
		var scaled_hp = mock_health.max_health
		var scaled_dmg = mock_zombie.attack_damage
		var scaled_spd = mock_zombie.move_speed
		
		_check("Wave %d HP scaling (exp: ~%.1f, got: %.1f)" % [w, 50.0 * exp_hp, scaled_hp], abs(scaled_hp - round(50.0 * exp_hp)) < 0.1)
		_check("Wave %d DMG scaling (exp: ~%.1f, got: %.1f)" % [w, 10.0 * exp_dmg, scaled_dmg], abs(scaled_dmg - round(10.0 * exp_dmg)) < 0.1)
		_check("Wave %d SPD scaling within cap (got: %.2f)" % [w, scaled_spd], scaled_spd <= 2.0 * 1.45 + 0.01)
		
		# Archetype check
		if w % 10 == 0:
			var arch = gm._pick_archetype()
			_check("Wave %d guarantees Apex Boss archetype" % w, arch == "boss")
		elif w % 5 == 0:
			var arch = gm._pick_archetype()
			_check("Wave %d guarantees Heavy / Mini-Boss archetype" % w, arch == "heavy")
			
		mock_zombie.free()
		
	gm.free()
	
	print("\n==================================================")
	print("ENDLESS SCALING AUDIT: %d PASSED, %d FAILED" % [passed, failed])
	print("==================================================")
	
	if failed > 0:
		quit(1)
	else:
		quit(0)

func _check(label: String, cond: bool):
	if cond:
		passed += 1
		print("[PASS] %s" % label)
	else:
		failed += 1
		printerr("[FAIL] %s" % label)
