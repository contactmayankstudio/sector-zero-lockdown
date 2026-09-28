extends RigidBody3D

const BlastVFX = preload("res://scripts/Objects/BlastVFX.gd")

@export var fuse_seconds: float = 2.0
@export var damage: float = 300.0
@export var radius: float = 6.5
@export_range(0.0, 1.0) var blast_cash_multiplier: float = 0.5

var timer: float = 0.0
var is_exploded: bool = false

@onready var grenade_mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
@onready var grenade_collision: CollisionShape3D = get_node_or_null("CollisionShape3D")
@onready var explosion_audio: AudioStreamPlayer3D = get_node_or_null("SfxExplosion")

func _ready():
	timer = fuse_seconds
	mass = 1.0
	gravity_scale = 2.0
	linear_damp = 0.1
	angular_damp = 0.8

func _process(delta):
	if is_exploded:
		return
	timer -= delta
	if timer <= 0.0:
		explode()

func explode():
	if is_exploded:
		return
	is_exploded = true
	set_process(false)
	freeze = true
	collision_layer = 0
	collision_mask = 0
	if grenade_collision:
		grenade_collision.set_deferred("disabled", true)
	if grenade_mesh:
		grenade_mesh.visible = false

	var blast_position := global_position
	if explosion_audio:
		explosion_audio.play()
	var world := get_tree().current_scene as Node3D if get_tree() else null
	if not world:
		world = get_parent() as Node3D
	if world:
		BlastVFX.spawn(world, blast_position, radius, Color(1.0, 0.48, 0.14, 0.96))

	_apply_blast_damage(blast_position)
	_shake_player(blast_position)

	var cleanup_delay := 1.4
	if explosion_audio and explosion_audio.stream:
		cleanup_delay = maxf(cleanup_delay, explosion_audio.stream.get_length())
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(cleanup_delay).timeout
	queue_free()

func _apply_blast_damage(blast_position: Vector3):
	if not is_inside_tree() or not get_tree():
		return
	var zombies: Array[Node] = []
	for group_name in ["zombies", "zombie"]:
		for zombie in get_tree().get_nodes_in_group(group_name):
			if is_instance_valid(zombie) and not zombies.has(zombie):
				zombies.append(zombie)

	for zombie in zombies:
		if not is_instance_valid(zombie) or zombie.get("is_dead") == true or not zombie.has_method("take_damage"):
			continue
		var offset: Vector3 = zombie.global_position - blast_position
		var distance: float = offset.length()
		if distance > radius:
			continue
		var falloff := maxf(0.15, 1.0 - distance / radius)
		var blast_direction: Vector3 = offset.normalized()
		blast_direction.y += 0.4
		zombie.take_damage(damage * falloff, false, blast_direction, blast_cash_multiplier)

func _shake_player(blast_position: Vector3):
	if not is_inside_tree() or not get_tree():
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player or not player.has_method("apply_shake"):
		return
	var distance: float = player.global_position.distance_to(blast_position)
	if distance < radius * 2.5:
		player.apply_shake(lerpf(0.42, 0.06, clampf(distance / (radius * 2.5), 0.0, 1.0)))
