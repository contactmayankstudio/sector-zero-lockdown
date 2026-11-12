extends SceneTree

class DamageRecorder:
	extends Node3D
	var is_dead: bool = false
	var hit_count: int = 0
	var last_damage: float = 0.0
	var last_cash_multiplier: float = 1.0

	func take_damage(amount: float, _is_headshot: bool = false, _direction: Vector3 = Vector3.ZERO, cash_multiplier: float = 1.0):
		hit_count += 1
		last_damage = amount
		last_cash_multiplier = cash_multiplier

class ShakeRecorder:
	extends Node3D
	var shake_count: int = 0

	func apply_shake(_amount: float):
		shake_count += 1

func _init():
	call_deferred("_run")

func _check(condition: bool, label: String) -> bool:
	if condition:
		print("[PASS] ", label)
		return true
	else:
		push_error("[FAIL] " + label)
		quit(1)
		return false

func _run():
	var world := Node3D.new()
	world.name = "ExplosiveCombatTestWorld"
	root.add_child(world)
	current_scene = world

	var player := ShakeRecorder.new()
	player.add_to_group("player")
	world.add_child(player)
	var zombie := DamageRecorder.new()
	zombie.add_to_group("zombies")
	zombie.add_to_group("zombie")
	world.add_child(zombie)
	zombie.global_position = Vector3(2.0, 0.0, 0.0)

	var grenade_scene := load("res://scenes/weapons/Grenade.tscn") as PackedScene
	if not _check(grenade_scene != null, "Grenade scene loads"): return
	var grenade = grenade_scene.instantiate()
	grenade.fuse_seconds = 0.05
	world.add_child(grenade)
	grenade.global_position = Vector3.ZERO
	await create_timer(0.25).timeout
	var grenade_vfx := world.find_children("*", "Node3D", true, false).filter(func(node): return node.name.begins_with("BlastBurst"))
	if not _check(grenade.is_exploded and zombie.hit_count == 1 and is_equal_approx(zombie.last_cash_multiplier, 0.5), "Grenade explodes once, damages nearby zombies, and halves blast kill cash"): return
	if not _check(not grenade_vfx.is_empty() and player.shake_count > 0, "Grenade spawns blast VFX and shakes the nearby player"): return

	zombie.hit_count = 0
	var barrel_scene := load("res://scenes/objects/ExplosiveBarrel.tscn") as PackedScene
	if not _check(barrel_scene != null, "Explosive barrel scene loads"): return
	var barrel = barrel_scene.instantiate()
	world.add_child(barrel)
	barrel.global_position = Vector3.ZERO
	barrel.take_damage(1000.0)
	barrel.take_damage(1000.0)
	await create_timer(0.2).timeout
	var all_blast_vfx := world.find_children("*", "Node3D", true, false).filter(func(node): return node.name.begins_with("BlastBurst"))
	var particles_emitting: bool = barrel.explosion_particles != null and barrel.explosion_particles.emitting
	print("[INFO] Blast VFX nodes: ", all_blast_vfx.size(), ", camera shakes: ", player.shake_count)
	if not _check(barrel.is_exploded and zombie.hit_count == 1 and is_equal_approx(zombie.last_cash_multiplier, 0.5), "Barrel blast is idempotent and halves blast kill cash"): return
	if not _check(not all_blast_vfx.is_empty() and particles_emitting and player.shake_count > 1, "Barrel blast adds dramatic VFX and camera shake"): return

	await create_timer(2.0).timeout
	world.queue_free()
	await process_frame
	print("EXPLOSIVE COMBAT CHECKS PASSED")
	quit(0)
