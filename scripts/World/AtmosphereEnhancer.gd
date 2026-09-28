extends Node3D
class_name AtmosphereEnhancer

@export var fan_rotation_speed: float = 4.0 # radians/sec (~240 rpm)
@export var strobe_pulse_speed: float = 3.5

@onready var dust_particles: CPUParticles3D = get_node_or_null("SunlightDust")
@onready var fan_blades = get_node_or_null("IndustrialFan/Blades")
@onready var alert_strobe = get_node_or_null("AlertStrobe/StrobeLight")

var time: float = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _setup_blood_pool_listener():
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("enemy_killed"):
		if not event_bus.enemy_killed.is_connected(_on_enemy_killed):
			event_bus.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(_archetype: String, _is_headshot: bool, death_pos: Vector3):
	spawn_ground_blood_decal(death_pos)

static var _shared_blood_mat: StandardMaterial3D = null
static var _shared_blood_mesh: PlaneMesh = null
var _active_decals: Array[Node] = []

func spawn_ground_blood_decal(pos: Vector3):
	_active_decals = _active_decals.filter(is_instance_valid)
	if _active_decals.size() >= 6:
		var oldest = _active_decals.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	if not _shared_blood_mesh:
		_shared_blood_mesh = PlaneMesh.new()
		_shared_blood_mesh.size = Vector2(1.5, 1.5)
		_shared_blood_mesh.orientation = PlaneMesh.FACE_Y

	if not _shared_blood_mat:
		_shared_blood_mat = StandardMaterial3D.new()
		_shared_blood_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_shared_blood_mat.albedo_texture = preload("res://textures/pbr/tex_blood_decal.png")
		_shared_blood_mat.albedo_color = Color(0.9, 0.9, 0.9, 0.85)
		_shared_blood_mat.roughness = 0.15
		_shared_blood_mat.metallic = 0.0

	var decal = MeshInstance3D.new()
	decal.mesh = _shared_blood_mesh
	decal.material_override = _shared_blood_mat
	
	add_child(decal)
	decal.global_position = Vector3(pos.x, 0.02, pos.z)
	decal.rotation.y = randf_range(0, TAU)
	_active_decals.append(decal)
	
	# Keep decal alive for 15s, then remove via node-bound tween
	var tw = decal.create_tween()
	tw.tween_interval(15.0)
	tw.tween_callback(decal.queue_free)

func _process(delta: float):
	time += delta
	# Rotate ceiling fans
	if fan_blades:
		fan_blades.rotate_y(fan_rotation_speed * delta)
		
	# Pulse emergency alert beacon
	if alert_strobe and alert_strobe is Light3D:
		var pulse = (sin(time * strobe_pulse_speed) * 0.5 + 0.5)
		alert_strobe.light_energy = 0.1 + pulse * 0.4
