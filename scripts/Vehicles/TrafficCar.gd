# TrafficCar.gd
# AGENT 6: HIGH-PERFORMANCE AMBIENT TRAFFIC CAR
# Lightweight CharacterBody3D vehicle for open-world road traffic.
# Uses low-poly sedan.glb (5 meshes) with shadow optimization for 30+ FPS on 4GB RAM APU.
class_name TrafficCar
extends CharacterBody3D

@export var speed: float = 12.5
@export var max_dist: float = 260.0

var move_dir: Vector3 = Vector3.FORWARD
var initial_pos: Vector3 = Vector3.ZERO
var travel_dist: float = 0.0

func _ready():
	initial_pos = global_position
	collision_layer = 2
	collision_mask = 7
	
	# Turn off shadow casting on wheels to reduce draw calls
	for child in find_children("*", "MeshInstance3D"):
		if "wheel" in child.name.to_lower():
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func setup(start_pos: Vector3, direction: Vector3, cruise_speed: float = 12.5):
	global_position = start_pos
	initial_pos = start_pos
	move_dir = direction.normalized()
	speed = cruise_speed
	rotation.y = atan2(move_dir.x, move_dir.z) + PI

func _physics_process(delta):
	# Raycast obstacle detection ahead (checks for player, other cars, zombies)
	var space = get_world_3d().direct_space_state if get_world_3d() else null
	var is_blocked = false
	if space:
		var ray_start = global_position + Vector3(0, 0.45, 0)
		var ray_end = ray_start + (move_dir * 9.5)
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.exclude = [self.get_rid()]
		var hit = space.intersect_ray(query)
		if hit:
			is_blocked = true
			
	if not is_blocked:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 2.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, speed * 2.0 * delta)
		
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
		
	move_and_slide()
	
	travel_dist = global_position.distance_to(initial_pos)
	if travel_dist > max_dist:
		global_position = initial_pos
		velocity = Vector3.ZERO
