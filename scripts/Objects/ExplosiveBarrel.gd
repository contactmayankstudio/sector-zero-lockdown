extends Area3D
class_name ExplosiveBarrel

const BlastVFX = preload("res://scripts/Objects/BlastVFX.gd")

@export var health: float = 25.0
@export var explosion_radius: float = 7.5
@export var explosion_damage: float = 350.0
@export_range(0.0, 1.0) var blast_cash_multiplier: float = 0.5

var is_exploded: bool = false

@onready var mesh_node = get_node_or_null("BarrelMesh")
@onready var col_shape = get_node_or_null("CollisionShape3D")
@onready var explosion_particles: CPUParticles3D = get_node_or_null("ExplosionParticles")
@onready var smoke_particles: CPUParticles3D = get_node_or_null("SmokeParticles")
@onready var blast_light: OmniLight3D = get_node_or_null("BlastLight")
@onready var sfx_explosion: AudioStreamPlayer3D = get_node_or_null("SfxExplosion")

func _ready():
	add_to_group("explosives")
	collision_layer = 2 # Bullet raycast layer
	collision_mask = 0

func take_damage(amount: float, _is_head: bool = false, _dir: Vector3 = Vector3.ZERO):
	if is_exploded:
		return
	health -= amount
	
	var imp_pool = get_tree().get_first_node_in_group("impact_pool") if (is_inside_tree() and get_tree()) else null
	if imp_pool:
		imp_pool.spawn_impact("concrete", global_position + Vector3(0, 0.5, 0), Vector3.UP)
		
	if health <= 0.0:
		explode()

func explode():
	if is_exploded:
		return
	is_exploded = true
	
	# Disable collision and hide barrel model
	if col_shape:
		col_shape.set_deferred("disabled", true)
	if mesh_node:
		mesh_node.visible = false
		
	# Play explosion audio
	if sfx_explosion:
		sfx_explosion.play()
		
	# Particle bursts
	if explosion_particles:
		explosion_particles.restart()
		explosion_particles.emitting = true
	if smoke_particles:
		smoke_particles.restart()
		smoke_particles.emitting = true

	var world := get_tree().current_scene as Node3D if get_tree() else null
	if not world:
		world = get_parent() as Node3D
	if world:
		BlastVFX.spawn(world, global_position, explosion_radius, Color(1.0, 0.48, 0.12, 0.96))
		
	# High-intensity blast flash
	if blast_light and is_inside_tree() and get_tree():
		blast_light.visible = true
		blast_light.light_energy = 9.0
		var tw = create_tween()
		if tw:
			tw.tween_property(blast_light, "light_energy", 0.0, 0.45)
		
	# Screen shake
	var player = get_tree().get_first_node_in_group("player") if (is_inside_tree() and get_tree()) else null
	if player and player.has_method("apply_shake"):
		var dist_to_player = global_position.distance_to(player.global_position)
		if dist_to_player < 24.0:
			var shake_amount = lerp(0.48, 0.04, dist_to_player / 24.0)
			player.apply_shake(shake_amount)
			
	# Damage all zombies in radius
	_apply_blast_damage()
	
	# Cleanup after particle lifetime
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(1.8).timeout
		queue_free()
	else:
		queue_free()

func _apply_blast_damage():
	if not is_inside_tree() or not get_tree():
		return
		
	var zombies: Array = []
	for z in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
	for z in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(z) and not zombies.has(z):
			zombies.append(z)
			
	for z in zombies:
		if not is_instance_valid(z) or z.is_dead:
			continue
		var dist = global_position.distance_to(z.global_position)
		if dist <= explosion_radius:
			var ratio = 1.0 - (dist / explosion_radius)
			var dmg = explosion_damage * max(0.35, ratio)
			var blast_dir = (z.global_position - global_position).normalized()
			blast_dir.y += 0.35 # Pop zombie upward
			z.take_damage(dmg, false, blast_dir, blast_cash_multiplier)
			
	# Chain explosion to nearby barrels
	for b in get_tree().get_nodes_in_group("explosives"):
		if is_instance_valid(b) and b != self and not b.is_exploded:
			var b_dist = global_position.distance_to(b.global_position)
			if b_dist <= explosion_radius * 0.85:
				b.take_damage(explosion_damage)
