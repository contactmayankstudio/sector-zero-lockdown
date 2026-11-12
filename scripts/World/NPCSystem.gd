# NPCSystem.gd
# AGENT 7: REALISTIC PEDESTRIAN AI & CITY POPULATION
# Spawns real animated 3D human pedestrians on sidewalks with walk and idle cycles.
class_name NPCSystem
extends Node3D

var active_pedestrians: Array[Node3D] = []
static var soldier_prefab: PackedScene = null

func _ready():
	if soldier_prefab == null:
		soldier_prefab = load("res://scenes/characters/RealSoldier.scn")
		if not soldier_prefab:
			soldier_prefab = load("res://scenes/characters/RealSoldier.tscn")

func spawn_pedestrians_in_city(sidewalk_points: Array[Vector3], count: int = 6):
	for i in range(min(count, sidewalk_points.size())):
		var pt = sidewalk_points[i]
		var npc = _create_pedestrian(pt)
		if npc:
			add_child(npc)
			active_pedestrians.append(npc)

func _create_pedestrian(pos: Vector3) -> Node3D:
	var root = CharacterBody3D.new()
	root.position = pos
	root.collision_layer = 2
	root.collision_mask = 1
	
	# Instantiate 3D Animated Character
	var char_inst: Node3D = null
	if soldier_prefab:
		char_inst = soldier_prefab.instantiate()
		char_inst.name = "CharacterModel"
		char_inst.scale = Vector3(1.0, 1.0, 1.0)
		for mi in char_inst.find_children("*", "MeshInstance3D", true, false):
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(char_inst)
	else:
		# Fallback stylized mesh
		var bmesh = CapsuleMesh.new()
		bmesh.radius = 0.35
		bmesh.height = 1.75
		var minst = MeshInstance3D.new()
		minst.mesh = bmesh
		minst.position = Vector3(0.0, 0.88, 0.0)
		root.add_child(minst)
		
	# Collision Shape
	var col = CollisionShape3D.new()
	var cap_shape = CapsuleShape3D.new()
	cap_shape.radius = 0.35
	cap_shape.height = 1.8
	col.shape = cap_shape
	col.position = Vector3(0.0, 0.9, 0.0)
	root.add_child(col)
	
	# Attach pedestrian script with natural walking and idling
	var script = GDScript.new()
	script.source_code = """
extends CharacterBody3D

var walk_dir: Vector3 = Vector3.FORWARD
var walk_speed: float = 1.6
var turn_timer: float = 4.0
var anim_player: AnimationPlayer = null
var is_walking: bool = true

func _ready():
	anim_player = find_child("AnimationPlayer", true, false)
	walk_dir = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
	if anim_player and anim_player.has_animation("Walk"):
		anim_player.play("Walk")

func _physics_process(delta):
	turn_timer -= delta
	if turn_timer <= 0.0:
		turn_timer = randf_range(4.0, 9.0)
		if randf() < 0.25:
			# Pause and Idle
			is_walking = false
			velocity.x = 0.0
			velocity.z = 0.0
			if anim_player and anim_player.has_animation("Idle"):
				anim_player.play("Idle")
		else:
			is_walking = true
			walk_dir = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
			if anim_player and anim_player.has_animation("Walk"):
				anim_player.play("Walk")
				
	if is_walking:
		velocity.x = walk_dir.x * walk_speed
		velocity.z = walk_dir.z * walk_speed
		if walk_dir.length_squared() > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(walk_dir.x, walk_dir.z), delta * 5.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 3.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 3.0)
		
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
		
	move_and_slide()
"""
	script.reload()
	root.set_script(script)
	
	return root
