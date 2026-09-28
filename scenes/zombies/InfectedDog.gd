class_name InfectedDog
extends "res://scripts/Zombies/EnemyBase.gd"

@onready var head_hit_zone = $HeadHitZone
@onready var body_hit_zone = $BodyHitZone

func _init():
	super._init()
	archetype = "dog"
	move_speed = 4.1
	attack_range = 3.2
	attack_damage = 20.0
	attack_interval = 1.2
	reward_on_kill = 35

func _ready():
	archetype = "dog"
	super._ready()
	_setup_dog_model()
	_setup_hit_zones()

func _setup_dog_model():
	if not model_instance:
		model_instance = find_child("SkeletalModel", true, false)
	if model_instance:
		model_instance.scale = Vector3(1.0, 1.0, 1.0)
		model_instance.rotation.y = 0.0
		var anims = model_instance.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			active_anim_player = anims[0]
			active_anim_player.speed_scale = randf_range(1.15, 1.35)
			_setup_animation_aliases()

func _setup_animation_aliases():
	if not active_anim_player:
		return
	var lib = active_anim_player.get_animation_library("")
	if not lib:
		return
	var alias_map = {
		"walk": ["run", "walk", "Fox|Fox_WalkFast_F"],
		"idle": ["idle", "Fox|Fox_Stand"],
		"attack": ["attack", "Fox|Fox_Howl"],
		"death": ["death"],
		"stagger": ["hit_react", "stagger"]
	}
	for target_name in alias_map:
		if not lib.has_animation(target_name):
			for candidate in alias_map[target_name]:
				if lib.has_animation(candidate):
					lib.add_animation(target_name, lib.get_animation(candidate))
					break

func _setup_hit_zones():
	for child in get_children():
		if child is HitZone:
			child.parent_entity = self

func take_damage(amount: float, is_headshot: bool = false, hit_dir: Vector3 = Vector3.ZERO, cash_multiplier: float = 1.0):
	if is_dead:
		return
	last_hit_was_headshot = is_headshot
	last_hit_cash_multiplier = clampf(cash_multiplier, 0.0, 1.0)
	if health_component:
		health_component.take_damage(amount)
	if is_dead:
		return
		
	# Dog specific hurt reactions
	if is_headshot:
		if active_anim_player and active_anim_player.has_animation("hit_head"):
			_play_anim("hit_head")
		elif active_anim_player and active_anim_player.has_animation("headshot_reaction"):
			_play_anim("headshot_reaction")
		elif active_anim_player and active_anim_player.has_animation("stagger"):
			_play_anim("stagger")
		ai_state = AIState.STAGGER
		stagger_timer = 0.35
	elif amount >= 20.0:
		if active_anim_player and active_anim_player.has_animation("hit_body"):
			_play_anim("hit_body")
		elif active_anim_player and active_anim_player.has_animation("stagger"):
			_play_anim("stagger")
		ai_state = AIState.STAGGER
		stagger_timer = 0.40

func _on_died():
	if is_dead: return
	is_dead = true
	ai_state = AIState.DEAD
	_remove_from_zombie_groups()
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	for child in get_children():
		if child is HitZone:
			for col in child.find_children("*", "CollisionShape3D", true, false):
				col.set_deferred("disabled", true)
				
	velocity = Vector3.ZERO
	_play_anim("death")
	
	if sfx_death:
		sfx_death.play()
		
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		event_bus.enemy_killed.emit(archetype, last_hit_was_headshot, global_position)
		
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.add_cash(int(round(reward_on_kill * last_hit_cash_multiplier)))
		
	var mission_mgr = get_node_or_null("/root/MissionManager")
	if mission_mgr:
		mission_mgr.on_zombie_killed()
		
	await get_tree().create_timer(2.5).timeout
	queue_free()
