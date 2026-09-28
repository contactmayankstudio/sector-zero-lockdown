class_name EnemyBase
extends CharacterBody3D

const EnemyHealthBar3D = preload("res://scripts/Combat/EnemyHealthBar3D.gd")

enum AIState {
	IDLE,
	WANDER,
	NOTICE_PLAYER,
	CHASE,
	ATTACK,
	STAGGER,
	SEARCH,
	LOST_PLAYER,
	DEAD
}

@export var move_speed: float = 2.2
@export var attack_range: float = 1.7
@export var attack_damage: float = 12.0
@export var reward_on_kill: int = 10
@export var archetype: String = "normal"
@export var attack_interval: float = 1.2
@export var sight_range: float = 35.0
@export var fly_height: float = 0.0

var ai_state: AIState = AIState.CHASE
var player: Node3D = null
var is_dead: bool = false
var path_update_timer: float = 0.0
var path_update_interval: float = 0.35
var attack_timer: float = 1.0
var stagger_timer: float = 0.0
var search_timer: float = 0.0
var last_known_player_pos: Vector3 = Vector3.ZERO
var has_los_to_player: bool = false
var stuck_time: float = 0.0
var prev_pos: Vector3 = Vector3.ZERO
var wall_avoid_timer: float = 0.0
var wall_avoid_dir: Vector3 = Vector3.ZERO

var model_instance: Node3D = null
var active_anim_player: AnimationPlayer = null

# Core node references (dynamically resolved to allow custom scene hierarchies)
var nav_agent: NavigationAgent3D = null
var _nav_ready: bool = false
var anim_player: AnimationPlayer = null
var health_component: Node = null
var mesh_instance: MeshInstance3D = null
var collision_shape: CollisionShape3D = null
var sfx_growl: AudioStreamPlayer3D = null
var sfx_attack: AudioStreamPlayer3D = null
var sfx_death: AudioStreamPlayer3D = null
var sfx_timer: Timer = null
var sfx_headshot: AudioStreamPlayer3D = null
var skeleton: Skeleton3D = null
var health_bar_3d: EnemyHealthBar3D = null

var archetype_data = {
	"normal": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 50.0,
		"speed": 1.55,
		"damage": 6.0,
		"scale": Vector3(1, 1, 1),
		"reward": 10,
		"attack_range": 1.5,
		"attack_interval": 1.5
	},
	"realistic": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 60.0,
		"speed": 1.65,
		"damage": 7.0,
		"scale": Vector3(1.05, 1.05, 1.05),
		"reward": 15,
		"attack_range": 1.5,
		"attack_interval": 1.55
	},
	"fast": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_fast.tres",
		"hp": 35.0,
		"speed": 2.1,
		"damage": 6.0,
		"scale": Vector3(0.95, 0.95, 0.95),
		"reward": 10,
		"attack_range": 1.5,
		"attack_interval": 1.45
	},
	"heavy": {
		"mesh": "res://scenes/zombies/models/RealButcherBoss.scn",
		"material": "res://resources/materials/mat_zombie_heavy.tres",
		"hp": 220.0,
		"speed": 1.0,
		"damage": 15.0,
		"scale": Vector3(1.05, 1.05, 1.05),
		"reward": 20,
		"attack_range": 1.8,
		"attack_interval": 2.0
	},
	"special": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 50.0,
		"speed": 1.6,
		"damage": 8.0,
		"scale": Vector3(0.95, 0.95, 0.95),
		"reward": 12,
		"attack_range": 1.8,
		"attack_interval": 2.0
	},
	"spitter": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 50.0,
		"speed": 1.45,
		"damage": 8.0,
		"scale": Vector3(0.95, 0.95, 0.95),
		"reward": 12,
		"attack_range": 5.5,
		"attack_interval": 2.6
	},
	"dog": {
		"mesh": "res://scenes/zombies/models/RealInfectedHound.scn",
		"material": "res://resources/materials/mat_zombie_fast.tres",
		"hp": 60.0,
		"speed": 2.8,
		"damage": 12.0,
		"scale": Vector3(1.15, 1.15, 1.15),
		"reward": 18,
		"attack_range": 2.4,
		"attack_interval": 1.7
	},
	"boss": {
		"mesh": "res://scenes/zombies/models/RealTitanBrute.scn",
		"material": "res://resources/materials/mat_zombie_boss.tres",
		"hp": 750.0,
		"speed": 1.1,
		"damage": 25.0,
		"scale": Vector3(2.0, 2.0, 2.0),
		"reward": 150,
		"attack_range": 2.7,
		"attack_interval": 2.2
	},
	"rat": {
		"mesh": "res://scenes/zombies/models/RealVelociraptor.scn",
		"material": "res://resources/materials/mat_zombie_fast.tres",
		"hp": 15.0,
		"speed": 2.6,
		"damage": 3.0,
		"scale": Vector3(0.35, 0.35, 0.35),
		"reward": 5,
		"attack_range": 1.2,
		"attack_interval": 0.8
	},
	"rats": {
		"mesh": "res://scenes/zombies/models/RealVelociraptor.scn",
		"material": "res://resources/materials/mat_zombie_fast.tres",
		"hp": 15.0,
		"speed": 2.6,
		"damage": 3.0,
		"scale": Vector3(0.35, 0.35, 0.35),
		"reward": 5,
		"attack_range": 1.2,
		"attack_interval": 0.8
	},
	"bat": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 12.0,
		"speed": 2.6,
		"damage": 4.0,
		"scale": Vector3(0.4, 0.4, 0.4),
		"reward": 5,
		"attack_range": 1.5,
		"attack_interval": 1.0,
		"fly_height": 0.0
	},
	"bats": {
		"mesh": "res://scenes/zombies/models/zombie_scary.scn",
		"material": "res://resources/materials/mat_zombie_normal.tres",
		"hp": 12.0,
		"speed": 2.6,
		"damage": 4.0,
		"scale": Vector3(0.4, 0.4, 0.4),
		"reward": 5,
		"attack_range": 1.5,
		"attack_interval": 1.0,
		"fly_height": 0.0
	}
}

func _init():
	add_to_group("zombies")
	add_to_group("zombie")

func _ready():
	add_to_group("zombies")
	add_to_group("zombie")
	_resolve_nodes()
	if health_component:
		if not health_component.died.is_connected(_on_died):
			health_component.died.connect(_on_died)
		if not health_component.health_changed.is_connected(_on_health_changed):
			health_component.health_changed.connect(_on_health_changed)
	if get_tree():
		player = get_tree().get_first_node_in_group("player")
	attack_timer = 1.2
	if sfx_timer:
		sfx_timer.start(randf_range(3.0, 6.0))
	_apply_archetype()
	_setup_eye_glow()
	if fly_height <= 0.0 and global_position.y > 0.4:
		global_position.y = 0.05
	# Auto-assign parent_entity to all HitZones so headshot system works
	_bind_hit_zones()
	_wait_for_nav()

func _wait_for_nav():
	_nav_ready = false
	if get_tree():
		await get_tree().physics_frame
		await get_tree().physics_frame
	_nav_ready = true

func _bind_hit_zones():
	var hit_zones = find_children("*HitZone*", "Area3D", true, false)
	for hz in hit_zones:
		if hz.has_method("take_hit"):
			hz.parent_entity = self

static var _shared_eye_mat: StandardMaterial3D = null
static var _shared_eye_mesh: SphereMesh = null

func _setup_eye_glow():
	if get_node_or_null("EyeGlow"): return
	var eyes = Node3D.new()
	eyes.name = "EyeGlow"
	add_child(eyes)
	
	var head_y = 1.68
	var eye_dist = 0.065
	var eye_z = -0.16
	if archetype == "dog":
		head_y = 0.82
		eye_dist = 0.08
		eye_z = -0.55
	elif archetype == "heavy":
		head_y = 1.95
		eye_dist = 0.08
		eye_z = -0.18
	elif archetype == "boss":
		head_y = 2.45
		eye_dist = 0.12
		eye_z = -0.25
	elif archetype in ["rat", "rats"]:
		head_y = 0.15
		eye_dist = 0.03
	elif archetype in ["bat", "bats"]:
		head_y = 0.05
		
	if not _shared_eye_mat:
		_shared_eye_mat = StandardMaterial3D.new()
		_shared_eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_shared_eye_mat.albedo_color = Color(1.0, 0.12, 0.06, 1.0)
		_shared_eye_mat.no_depth_test = false
		
	if not _shared_eye_mesh:
		_shared_eye_mesh = SphereMesh.new()
		_shared_eye_mesh.radius = 0.016
		_shared_eye_mesh.height = 0.032
		
	var left_eye = MeshInstance3D.new()
	left_eye.mesh = _shared_eye_mesh
	left_eye.material_override = _shared_eye_mat
	left_eye.position = Vector3(-eye_dist, head_y, eye_z)
	eyes.add_child(left_eye)
	
	var right_eye = MeshInstance3D.new()
	right_eye.mesh = _shared_eye_mesh
	right_eye.material_override = _shared_eye_mat
	right_eye.position = Vector3(eye_dist, head_y, eye_z)
	eyes.add_child(right_eye)
	
	# Sinister red point light illuminating face subtly
	var eye_light = OmniLight3D.new()
	eye_light.light_color = Color(1.0, 0.28, 0.12)
	eye_light.light_energy = 0.35
	eye_light.omni_range = 1.6
	eye_light.position = Vector3(0, head_y, eye_z - 0.08)
	eyes.add_child(eye_light)
	
	# Body fill illumination so torso, limbs, skin, and clothes are clearly visible
	var body_fill = OmniLight3D.new()
	body_fill.name = "BodyFill"
	body_fill.light_color = Color(0.92, 0.95, 1.0)
	body_fill.light_energy = 0.65
	body_fill.omni_range = 3.2
	body_fill.position = Vector3(0, head_y * 0.55, 0.25)
	eyes.add_child(body_fill)

func _load_audio(base_path: String, fallback_path: String = "") -> AudioStream:
	var clean_path = base_path.trim_suffix(".wav").trim_suffix(".tres")
	var tres_path = clean_path + ".tres"
	var wav_path = clean_path + ".wav"
	if ResourceLoader.exists(tres_path):
		var s = load(tres_path)
		if s: return s
	if ResourceLoader.exists(wav_path):
		var s = load(wav_path)
		if s: return s
	if ResourceLoader.exists(base_path):
		var s = load(base_path)
		if s: return s
	if fallback_path != "":
		var clean_fb = fallback_path.trim_suffix(".wav").trim_suffix(".tres")
		var f_tres = clean_fb + ".tres"
		var f_wav = clean_fb + ".wav"
		if ResourceLoader.exists(f_tres):
			var s = load(f_tres)
			if s: return s
		if ResourceLoader.exists(f_wav):
			var s = load(f_wav)
			if s: return s
		if ResourceLoader.exists(fallback_path):
			return load(fallback_path)
	return null

func _resolve_nodes():
	if not nav_agent: nav_agent = get_node_or_null("NavigationAgent3D")
	if not anim_player: anim_player = get_node_or_null("AnimationPlayer")
	if not health_component: health_component = get_node_or_null("HealthComponent")
	if not mesh_instance: mesh_instance = get_node_or_null("MeshInstance3D")
	if not collision_shape: collision_shape = get_node_or_null("CollisionShape3D")
	if not sfx_growl: sfx_growl = get_node_or_null("SfxGrowl")
	if not sfx_attack: sfx_attack = get_node_or_null("SfxAttack")
	if not sfx_death: sfx_death = get_node_or_null("SfxDeath")
	if not sfx_timer: sfx_timer = get_node_or_null("SfxTimer")
	if not sfx_headshot: sfx_headshot = get_node_or_null("SfxHeadshot")
	if not sfx_headshot:
		sfx_headshot = AudioStreamPlayer3D.new()
		sfx_headshot.name = "SfxHeadshot"
		sfx_headshot.max_distance = 25.0
		sfx_headshot.bus = "SFX"
		add_child(sfx_headshot)
	if not sfx_headshot.stream:
		sfx_headshot.stream = _load_audio("res://audio/ui/sfx_hitmarker_tick.wav")
	if not skeleton:
		skeleton = find_child("Skeleton3D", true, false)

static var _cached_models: Dictionary = {}
static var _cached_materials: Dictionary = {}

static func _get_archetype_material(base_mat: StandardMaterial3D, arch: String, outfit: int) -> StandardMaterial3D:
	var base_id = base_mat.resource_name if base_mat.resource_name != "" else str(base_mat.get_instance_id())
	var key = base_id + "_" + arch + "_" + str(outfit)
	if _cached_materials.has(key):
		return _cached_materials[key]
	var mat = base_mat.duplicate() as StandardMaterial3D
	match arch:
		"boss":
			mat.albedo_color = Color(0.92, 0.55, 0.55, 1.0)
		"fast":
			mat.albedo_color = Color(0.85, 0.95, 0.85, 1.0)
		"heavy":
			mat.albedo_color = Color(0.85, 0.80, 0.75, 1.0)
		"spitter", "special":
			mat.albedo_color = Color(0.45, 1.0, 0.5, 1.0)
		_:
			match outfit:
				0: mat.albedo_color = Color(0.98, 0.90, 0.85, 1.0)
				1: mat.albedo_color = Color(0.88, 0.92, 0.98, 1.0)
	mat.rim_enabled = true
	mat.rim = 0.85
	mat.rim_tint = 0.5
	mat.roughness = 0.65
	mat.metallic = 0.0
	_cached_materials[key] = mat
	return mat

func _apply_archetype():
	var cfg = archetype_data.get(archetype, archetype_data["normal"])
	if cfg.has("attack_range"): attack_range = cfg.attack_range
	if cfg.has("attack_interval"): attack_interval = cfg.attack_interval
	if cfg.has("fly_height"): fly_height = cfg.fly_height
	
	var target_mesh = cfg.mesh
	if archetype in ["normal", "realistic"]:
		var humanoid_models = [
			"res://scenes/zombies/models/zombie_scary.scn",
			"res://scenes/zombies/models/RealZombieOffice.scn",
			"res://scenes/zombies/models/RealZombieBiker.scn",
			"res://scenes/zombies/models/RealZombie6ft.scn"
		]
		target_mesh = humanoid_models.pick_random()
	elif archetype == "fast":
		var fast_models = [
			"res://scenes/zombies/models/zombie_scary.scn",
			"res://scenes/zombies/models/RealZombieOffice.scn"
		]
		target_mesh = fast_models.pick_random()
	
	var res: Resource = null
	if target_mesh != "" and ResourceLoader.exists(target_mesh):
		res = _cached_models.get(target_mesh)
		if not res:
			res = load(target_mesh)
			if res:
				_cached_models[target_mesh] = res
	
	# Try authored 3D model scenes first, then the original 3D GLB imports.
	# Keep a model fallback so enemies never silently become the placeholder mesh.
	if not (res is PackedScene):
		var model_fallbacks = [
			"res://scenes/zombies/models/zombie_scary.scn",
			"res://assets/3d/zombies/zombie_scary.glb",
			"res://assets/3d/zombies/zombie_normal.glb"
		]
		for fallback_path in model_fallbacks:
			if not ResourceLoader.exists(fallback_path):
				continue
			var fallback_res = _cached_models.get(fallback_path)
			if not fallback_res:
				fallback_res = load(fallback_path)
				if fallback_res:
					_cached_models[fallback_path] = fallback_res
			if fallback_res is PackedScene:
				target_mesh = fallback_path
				res = fallback_res
				break

	if res and res is PackedScene:
		if mesh_instance:
			mesh_instance.visible = false
			
		var existing_wrapper = get_node_or_null("ModelWrapper")
		if existing_wrapper:
			existing_wrapper.name = "OldModelWrapper"
			existing_wrapper.queue_free()
			model_instance = null
		elif model_instance:
			model_instance.queue_free()
			model_instance = null
			
		var pre_existing_model = get_node_or_null("SkeletalModel")
		if pre_existing_model:
			pre_existing_model.name = "OldSkeletalModel"
			pre_existing_model.queue_free()

		var models_facing_plus_z = [
			"res://scenes/zombies/models/RealZombieOffice.scn",
			"res://scenes/zombies/models/RealZombie6ft.scn",
			"res://scenes/zombies/models/RealZombieBiker.scn",
			"res://scenes/zombies/models/RealTitanBrute.scn",
			"res://scenes/zombies/models/RealVelociraptor.scn",
			"res://scenes/zombies/models/zombie_realistic_human.scn"
		]
		var wrapper = Node3D.new()
		wrapper.name = "ModelWrapper"
		wrapper.rotation.y = PI if (target_mesh in models_facing_plus_z or archetype == "dog") else 0.0
		add_child(wrapper)
		
		model_instance = res.instantiate()
		model_instance.name = "SkeletalModel"
		wrapper.add_child(model_instance)
			
		var anims = model_instance.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			active_anim_player = anims[0]
		if active_anim_player:
			if archetype == "fast":
				active_anim_player.speed_scale = randf_range(1.15, 1.3)
			elif archetype == "heavy":
				active_anim_player.speed_scale = randf_range(0.8, 0.95)
			elif archetype == "boss":
				active_anim_player.speed_scale = randf_range(1.15, 1.3)
			else:
				active_anim_player.speed_scale = randf_range(0.95, 1.1)
			
		# Material appearance variation across all meshes (using cached shared materials)
		if archetype != "dog":
			var outfit_type = randi() % 3
			var all_meshes = model_instance.find_children("*", "MeshInstance3D", true, false)
			for mesh_node in all_meshes:
				if not mesh_node or not is_instance_valid(mesh_node) or not mesh_node.mesh:
					continue
				for s_idx in range(mesh_node.mesh.get_surface_count()):
					var base_mat = mesh_node.get_active_material(s_idx)
					if base_mat and base_mat is StandardMaterial3D:
						var arch_mat = _get_archetype_material(base_mat, archetype, outfit_type)
						mesh_node.set_surface_override_material(s_idx, arch_mat)
		else:
			var all_meshes = model_instance.find_children("*", "MeshInstance3D", true, false)
			for mesh_node in all_meshes:
				if not mesh_node or not is_instance_valid(mesh_node) or not mesh_node.mesh:
					continue
				for s_idx in range(mesh_node.mesh.get_surface_count()):
					var base_mat = mesh_node.get_active_material(s_idx)
					if base_mat and base_mat is StandardMaterial3D:
						var raptor_mat = base_mat.duplicate() as StandardMaterial3D
						raptor_mat.rim_enabled = true
						raptor_mat.rim = 1.0
						raptor_mat.rim_tint = 0.7
						raptor_mat.roughness = 0.55
						raptor_mat.albedo_color = Color(1.2, 1.15, 1.1, 1.0)
						mesh_node.set_surface_override_material(s_idx, raptor_mat)
	elif res is Mesh and mesh_instance:
		var mat_res = load(cfg.material) if cfg.material != "" and ResourceLoader.exists(cfg.material) else null
		mesh_instance.mesh = res
		mesh_instance.material_override = mat_res
		mesh_instance.visible = true
		mesh_instance.rotation.y = PI
	
	scale = cfg.scale * randf_range(0.96, 1.04)
	move_speed = cfg.speed
	attack_damage = cfg.damage
	reward_on_kill = cfg.reward
	if health_component:
		health_component.max_health = cfg.hp
		health_component.current_health = cfg.hp
		
	if archetype == "spitter":
		attack_range = 5.5
	elif archetype == "special":
		attack_range = 1.8
	elif archetype == "dog":
		attack_range = 2.4
		attack_interval = 1.7
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.radius = 0.65
			collision_shape.shape.height = 1.8
			collision_shape.position.y = 0.9
		if not _dog_bark:
			_dog_bark = load("res://audio/zombies/sfx_dog_bark.tres")
		if not _dog_attack:
			_dog_attack = load("res://audio/zombies/sfx_dog_attack.tres")
		if not _dog_death:
			_dog_death = load("res://audio/zombies/sfx_dog_death.tres")
		if not sfx_growl: sfx_growl = get_node_or_null("SfxGrowl")
		if not sfx_attack: sfx_attack = get_node_or_null("SfxAttack")
		if not sfx_death: sfx_death = get_node_or_null("SfxDeath")
		if sfx_growl and _dog_bark: sfx_growl.stream = _dog_bark
		if sfx_attack and _dog_attack: sfx_attack.stream = _dog_attack
		if sfx_death and _dog_death: sfx_death.stream = _dog_death
		
	if archetype == "boss" and is_inside_tree() and get_tree():
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_boss_health"):
			hud.show_boss_health("THE ALPHA MUTANT", cfg.hp)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus and event_bus.has_signal("boss_spawned"):
			event_bus.boss_spawned.emit("THE ALPHA MUTANT", cfg.hp)

	# Attach or update overhead 3D health bar
	if not health_bar_3d:
		health_bar_3d = EnemyHealthBar3D.new()
		health_bar_3d.name = "EnemyHealthBar3D"
		add_child(health_bar_3d)
	var bar_height = 2.2
	if archetype == "dog":
		bar_height = 1.85
	elif archetype == "heavy":
		bar_height = 2.85
	elif archetype == "boss":
		bar_height = 2.4
	health_bar_3d.setup(cfg.hp if cfg.has("hp") else 60.0, bar_height)

func _play_anim(anim_name: String, custom_blend: float = -1.0):
	var ap = active_anim_player if active_anim_player else anim_player
	if not ap:
		return
	if ap.has_animation(anim_name):
		ap.play(anim_name, custom_blend)
		return
		
	var candidates: Array = []
	match anim_name:
		"walk", "run", "heavy_walk", "fast_walk":
			candidates = ["Walk", "walk", "fast_walk", "run", "heavy_walk", "Fox|Fox_WalkFast_F"]
		"attack", "heavy_attack", "attack_windup", "slam", "roar":
			candidates = ["Attack_mixamo_vitruvian", "Attack", "attack", "heavy_attack", "attack_windup", "slam", "roar"]
		"idle":
			candidates = ["Idle", "HappyIdle", "Sway", "idle", "Fox|Fox_Stand"]
		"death":
			candidates = ["Death_mixamo_vitruvian", "Death", "death", "stagger"]
		"stagger", "hit_react", "hit", "impact", "hit_front", "hit_body":
			candidates = ["HitReaction_mixamo_vitruvian", "hit_react", "stagger", "hit", "impact", "hit_front", "hit_body", "headshot_reaction"]
		_:
			candidates = [anim_name]
				
	for c in candidates:
		if ap.has_animation(c):
			ap.play(c, custom_blend)
			return
			
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.play(anim_name, custom_blend)

func _on_health_changed(hp):
	if archetype == "boss":
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("update_boss_health"):
			hud.update_boss_health(hp)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus and event_bus.has_signal("boss_health_changed"):
			var max_hp = archetype_data["boss"]["hp"]
			event_bus.boss_health_changed.emit(hp, max_hp)

var last_hit_was_headshot: bool = false
var last_hit_cash_multiplier: float = 1.0

func take_damage(amount: float, is_headshot: bool = false, hit_dir: Vector3 = Vector3.ZERO, cash_multiplier: float = 1.0):
	if is_dead:
		return
	last_hit_was_headshot = is_headshot
	last_hit_cash_multiplier = clampf(cash_multiplier, 0.0, 1.0)
	if is_headshot:
		if not sfx_headshot:
			_resolve_nodes()
		if sfx_headshot:
			if not sfx_headshot.stream:
				sfx_headshot.stream = _load_audio("res://audio/ui/sfx_hitmarker_tick.wav")
			if sfx_headshot.stream and is_inside_tree():
				sfx_headshot.play()
	# Compute projected HP and trigger 3D overhead damage popup
	var cur_hp = health_component.current_health if health_component else 50.0
	var max_hp = health_component.max_health if health_component else 50.0
	var new_hp = max(0.0, cur_hp - amount)
	if health_bar_3d:
		health_bar_3d.on_damaged(new_hp, max_hp, amount, is_headshot)
		
	# Apply physical impact knockback
	if hit_dir != Vector3.ZERO:
		var knock_force = clamp(amount * 0.06, 0.4, 3.5)
		velocity += hit_dir.normalized() * knock_force

	if health_component:
		health_component.take_damage(amount)
	if is_dead:
		return
		
	# Hurt reactions
	if is_headshot:
		if active_anim_player and active_anim_player.has_animation("headshot_reaction"):
			_play_anim("headshot_reaction")
		elif active_anim_player and active_anim_player.has_animation("hit_head"):
			_play_anim("hit_head")
		elif active_anim_player and active_anim_player.has_animation("stagger"):
			_play_anim("stagger")
		if model_instance:
			model_instance.rotation.x = -deg_to_rad(32.0)
			model_instance.position.y += 0.05
		ai_state = AIState.STAGGER
		stagger_timer = 0.45
	elif amount > 25.0:
		if active_anim_player and active_anim_player.has_animation("stagger"):
			_play_anim("stagger")
		elif active_anim_player and active_anim_player.has_animation("hit_body"):
			_play_anim("hit_body")
		if model_instance:
			model_instance.rotation.y += deg_to_rad(randf_range(-22.0, 22.0))
		ai_state = AIState.STAGGER
		stagger_timer = 0.55
	elif hit_dir != Vector3.ZERO:
		var local_dir = global_transform.basis.inverse() * hit_dir
		if abs(local_dir.x) > abs(local_dir.z):
			if local_dir.x > 0 and (active_anim_player and active_anim_player.has_animation("hit_right")):
				_play_anim("hit_right")
			elif active_anim_player and active_anim_player.has_animation("hit_left"):
				_play_anim("hit_left")
			elif active_anim_player and active_anim_player.has_animation("hit_body"):
				_play_anim("hit_body")
			else:
				_play_anim("hit_front")
		elif local_dir.z > 0 and (active_anim_player and active_anim_player.has_animation("hit_back")):
			_play_anim("hit_back")
		elif active_anim_player and active_anim_player.has_animation("hit_body"):
			_play_anim("hit_body")
		else:
			_play_anim("hit_front")
	elif active_anim_player and active_anim_player.has_animation("hit_body"):
		_play_anim("hit_body")
	elif active_anim_player and active_anim_player.has_animation("hit_front"):
		_play_anim("hit_front")
	elif active_anim_player and active_anim_player.has_animation("hit"):
		_play_anim("hit")

func take_hit(damage: float, impact_vector: Vector3 = Vector3.ZERO) -> Dictionary:
	take_damage(damage, false, impact_vector)
	return {
		"final_damage": damage,
		"is_headshot": false,
		"zone": "body"
	}

func _check_line_of_sight() -> bool:
	if not player: return false
	var space = get_world_3d().direct_space_state
	var start = global_position + Vector3(0, 1.4, 0)
	var end = player.global_position + Vector3(0, 1.2, 0)
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]
	var res = space.intersect_ray(query)
	if res.is_empty():
		return true
	if res.collider == player or res.collider.is_in_group("player"):
		return true
	return false

func _physics_process(delta):
	if is_dead:
		return
	if global_position.y < -4.0:
		_on_died()
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player):
			return
		
	# Apply downward gravity to keep ground enemies firmly locked to the floor
	if fly_height <= 0.0:
		if not is_on_floor():
			velocity.y -= 19.6 * delta
		else:
			velocity.y = -0.5
		if global_position.y > 0.25:
			global_position.y = move_toward(global_position.y, 0.05, 12.0 * delta)
		
	var dist_to_player = global_position.distance_to(player.global_position)
	attack_timer -= delta
	
	# Stagger recovery
	if ai_state == AIState.STAGGER:
		stagger_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 6.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 6.0 * delta)
		move_and_slide()
		if model_instance:
			model_instance.rotation.x = lerp(model_instance.rotation.x, 0.0, 5.0 * delta)
			model_instance.rotation.y = lerp(model_instance.rotation.y, 0.0, 5.0 * delta)
			model_instance.position.y = lerp(model_instance.position.y, 0.0, 5.0 * delta)
		if stagger_timer <= 0:
			ai_state = AIState.CHASE
		return

	# AI State Machine - Zombies relentlessly advance and creep towards player
	if dist_to_player <= attack_range:
		ai_state = AIState.ATTACK
		_handle_attack(dist_to_player, delta)
	else:
		ai_state = AIState.CHASE
		_handle_chase(dist_to_player, delta)

func _handle_chase(dist_to_player: float, delta: float):
	if dist_to_player <= attack_range:
		ai_state = AIState.ATTACK
		velocity.x = 0.0
		velocity.z = 0.0
		return
		
	# Direct vector straight to player
	var to_player = player.global_position - global_position
	if fly_height <= 0.0:
		to_player.y = 0.0
	var dir = to_player.normalized()
	
	# Obstacle avoidance: slide along wall if colliding
	if is_on_wall():
		var wall_normal = get_wall_normal()
		var slide_dir = (dir - wall_normal * dir.dot(wall_normal)).normalized()
		if slide_dir.dot(dir) > 0.05:
			dir = slide_dir
		else:
			# Steer towards road corridor center (X = 0) to bypass barriers
			var to_center_x = -sign(global_position.x) if abs(global_position.x) > 0.2 else 0.0
			dir = (dir + Vector3(to_center_x * 0.6, 0.0, 0.0)).normalized()
			
	# Always face directly towards the player
	var face_target = player.global_position
	if fly_height <= 0.0:
		face_target.y = global_position.y
	_safe_look_at(face_target)
	
	# Unstuck Watchdog: ensure zombie never stays stuck behind barriers or pillars
	_stuck_watchdog_timer += delta
	if _stuck_watchdog_timer >= 1.6:
		_stuck_watchdog_timer = 0.0
		var progress = global_position.distance_to(_last_tracked_pos)
		_last_tracked_pos = global_position
		if progress < 0.35 and dist_to_player > attack_range * 1.2:
			var side_offset = Vector3(-dir.z, 0, dir.x) * (1.0 if randf() > 0.5 else -1.0)
			# Steer around the obstruction using normal movement; never teleport into melee range.
			dir = (dir + side_offset * 0.45).normalized()

	var horiz_vel = dir * move_speed
	velocity.x = horiz_vel.x
	velocity.z = horiz_vel.z
	move_and_slide()
	
	var walk_anim = "run" if (archetype in ["fast", "dog"]) else ("heavy_walk" if archetype == "heavy" else "walk")
	if active_anim_player and active_anim_player.current_animation != walk_anim:
		_play_anim(walk_anim)
		
	# Organic humanoid/quadruped gait oscillation (for non-RealisticZombie enemies)
	if model_instance and archetype != "dog" and archetype != "realistic" and not has_method("_setup_animation_aliases"):
		var wobble = sin(Time.get_ticks_msec() * 0.007) * 0.05
		var pitch_hitch = (sin(Time.get_ticks_msec() * 0.014) * 0.5 + 0.5) * 0.04
		model_instance.rotation.z = lerp(model_instance.rotation.z, wobble, 10.0 * delta)
		model_instance.rotation.x = lerp(model_instance.rotation.x, pitch_hitch, 10.0 * delta)

func _safe_look_at(target_pos: Vector3):
	var to_target = target_pos - global_position
	if fly_height <= 0.0:
		to_target.y = 0.0
		target_pos.y = global_position.y
	if to_target.length_squared() > 0.01:
		look_at(target_pos, Vector3.UP)

var _stuck_watchdog_timer: float = 0.0
var _last_tracked_pos: Vector3 = Vector3.ZERO

func _handle_attack(dist_to_player: float, _delta: float):
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()
	
	var look_target = player.global_position
	if fly_height <= 0.0:
		look_target.y = global_position.y
	_safe_look_at(look_target)
		
	if dist_to_player > attack_range * 1.3:
		ai_state = AIState.CHASE
		return
		
	if attack_timer <= 0:
		attack_timer = attack_interval
		var atk_anim = "heavy_attack" if (archetype in ["heavy", "boss"]) else "attack"
		_play_anim(atk_anim)
		if sfx_attack:
			sfx_attack.play()
		_perform_attack_strike()

func _handle_search(delta: float):
	search_timer -= delta
	var dist_to_last = global_position.distance_to(last_known_player_pos)
	if dist_to_last > 1.5:
		var dir = (last_known_player_pos - global_position).normalized()
		dir.y = 0.0
		velocity = dir * (move_speed * 0.75)
		_safe_look_at(last_known_player_pos)
		move_and_slide()
		_play_anim("walk")
	else:
		velocity = Vector3.ZERO
		move_and_slide()
		_play_anim("idle")
		if search_timer <= 0:
			ai_state = AIState.LOST_PLAYER

# Preloaded scenes/audio to avoid main-thread stalls during gameplay
static var _pickup_scene: PackedScene = preload("res://scenes/pickups/AmmoPickup.tscn")
static var _dog_bark: AudioStream = null
static var _dog_attack: AudioStream = null
static var _dog_death: AudioStream = null

var acid_prefab = preload("res://scenes/zombies/AcidSpit.tscn")

func _perform_attack_strike():
	await get_tree().create_timer(0.35).timeout
	if is_dead: return
	if archetype == "spitter" or archetype == "special":
		if acid_prefab and player:
			var spit = acid_prefab.instantiate()
			get_tree().current_scene.add_child(spit)
			spit.global_position = global_position + Vector3(0, 1.2, 0)
			var target_p = player.global_position + Vector3(0, 1.0, 0)
			var to_player = target_p - spit.global_position
			if to_player.length_squared() > 0.01:
				spit.direction = to_player.normalized()
			else:
				spit.direction = -global_transform.basis.z
	else:
		if player and global_position.distance_to(player.global_position) <= attack_range * 1.1:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage, global_position)

func _remove_from_zombie_groups():
	if is_in_group("zombies"):
		remove_from_group("zombies")
	if is_in_group("zombie"):
		remove_from_group("zombie")

func _on_died():
	if is_dead: return
	is_dead = true
	ai_state = AIState.DEAD
	if health_bar_3d:
		health_bar_3d.on_died()
	var eg = get_node_or_null("EyeGlow")
	if eg:
		eg.visible = false
	_remove_from_zombie_groups()
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	velocity = Vector3.ZERO
	
	_play_anim("death")
	if model_instance and archetype != "dog":
		var has_death_anim = false
		if active_anim_player:
			for d_name in ["Death_mixamo_vitruvian", "Death", "death"]:
				if active_anim_player.has_animation(d_name):
					has_death_anim = true
					break
		if not has_death_anim:
			var tw = create_tween()
			tw.tween_property(model_instance, "position:y", -0.4, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(model_instance, "rotation:x", deg_to_rad(75.0), 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if sfx_death and is_inside_tree():
		sfx_death.play()
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.enemy_killed.emit(archetype, last_hit_was_headshot, global_position)
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.add_cash(int(round(reward_on_kill * last_hit_cash_multiplier)))
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		if archetype == "boss":
			mission_mgr.on_boss_killed()
		else:
			mission_mgr.on_zombie_killed()
			
	# Spawn Loot Drops (Ammo, Health, Cash)
	if randf() < 0.18 or archetype == "boss":
		_spawn_loot_drop()
			
	if get_tree():
		await get_tree().create_timer(2.2).timeout
	queue_free()

func _spawn_loot_drop():
	if not is_inside_tree() or not get_tree(): return
	if _pickup_scene:
		var p = _pickup_scene.instantiate()
		var r = randf()
		if archetype == "boss":
			p.pickup_type = "cash"
			p.amount = 200
		elif r < 0.50:
			p.pickup_type = "ammo"
			p.amount = 35
		elif r < 0.90:
			p.pickup_type = "health"
			p.amount = 40
		else:
			p.pickup_type = "cash"
			p.amount = 25
		var target_parent = get_tree().current_scene if (get_tree() and get_tree().current_scene) else get_tree().root
		target_parent.add_child(p)
		p.global_position = global_position + Vector3(0, 0.3, 0)

func _on_sfx_timer_timeout():
	if not is_dead and sfx_growl and is_inside_tree():
		sfx_growl.play()
		if sfx_timer:
			sfx_timer.start(randf_range(4.0, 8.0))
