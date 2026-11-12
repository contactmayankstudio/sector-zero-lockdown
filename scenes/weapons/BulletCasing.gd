extends Node3D
class_name BulletCasing

@onready var mesh_rifle = $MeshRifle
@onready var mesh_shotgun = $MeshShotgun
@onready var mesh_pistol = $MeshPistol
@onready var audio_drop = $AudioDrop

var linear_velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var lifetime: float = 0.0
var max_lifetime: float = 1.3
var floor_y: float = 0.0
var current_casing_type: String = "rifle"
var has_bounced: bool = false
var bounce_count: int = 0
var max_bounces: int = 2

var sfx_drops = [
	preload("res://audio/weapons/sfx_casing_drop1.wav"),
	preload("res://audio/weapons/sfx_casing_drop2.wav"),
	preload("res://audio/weapons/sfx_casing_drop3.wav")
]

func _ready():
	set_process(false)
	hide()

func activate(type: String, start_pos: Vector3, gun_basis: Basis, custom_floor_y: float = 0.0):
	if not mesh_rifle:
		mesh_rifle = get_node_or_null("MeshRifle")
	if not mesh_shotgun:
		mesh_shotgun = get_node_or_null("MeshShotgun")
	if not mesh_pistol:
		mesh_pistol = get_node_or_null("MeshPistol")
	if not audio_drop:
		audio_drop = get_node_or_null("AudioDrop")

	if is_inside_tree():
		global_position = start_pos
	else:
		position = start_pos
	floor_y = custom_floor_y
	has_bounced = false
	bounce_count = 0
	current_casing_type = type
	lifetime = 0.0
	
	if mesh_rifle: mesh_rifle.visible = (type == "rifle")
	if mesh_shotgun: mesh_shotgun.visible = (type == "shotgun")
	if mesh_pistol: mesh_pistol.visible = (type == "pistol")
	
	# Authentic ejection impulse relative to weapon
	var eject_right = gun_basis.x * randf_range(2.2, 3.4)
	var eject_up = gun_basis.y * randf_range(1.2, 2.2)
	var eject_back = gun_basis.z * randf_range(0.3, 0.9)
	
	linear_velocity = eject_right + eject_up + eject_back
	angular_velocity = Vector3(
		randf_range(-18.0, 18.0),
		randf_range(-12.0, 12.0),
		randf_range(-22.0, 22.0)
	)
	
	show()
	set_process(true)

func _process(delta: float):
	lifetime += delta
	if lifetime >= max_lifetime:
		deactivate()
		return
		
	# Apply ballistic gravity
	linear_velocity.y -= 9.8 * delta
	
	# Translation
	global_position += linear_velocity * delta
	
	# Tumbling rotation
	rotate_x(angular_velocity.x * delta)
	rotate_y(angular_velocity.y * delta)
	rotate_z(angular_velocity.z * delta)
	
	# Ground multi-bounce detection
	if global_position.y <= floor_y + 0.04 and bounce_count < max_bounces and linear_velocity.y < 0.0:
		bounce_count += 1
		has_bounced = true
		global_position.y = floor_y + 0.04
		
		var base_pitch = 1.0
		match current_casing_type:
			"shotgun":
				base_pitch = randf_range(0.86, 0.94)
			"pistol":
				base_pitch = randf_range(1.12, 1.22)
			_:
				base_pitch = randf_range(0.97, 1.05)
				
		if bounce_count == 1:
			linear_velocity.y = abs(linear_velocity.y) * 0.38
			linear_velocity.x *= 0.45
			linear_velocity.z *= 0.45
			angular_velocity *= 0.35
			
			if audio_drop and sfx_drops.size() > 0:
				audio_drop.stream = sfx_drops[randi() % sfx_drops.size()]
				audio_drop.pitch_scale = base_pitch
				audio_drop.volume_db = 4.0
				audio_drop.play()
		elif bounce_count == 2:
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			
			if audio_drop and sfx_drops.size() > 0:
				audio_drop.stream = sfx_drops[randi() % sfx_drops.size()]
				audio_drop.pitch_scale = base_pitch * randf_range(1.15, 1.28)
				audio_drop.volume_db = -1.5
				audio_drop.play()

func deactivate():
	set_process(false)
	hide()
