class_name RealisticZombie
extends "res://scripts/Zombies/EnemyBase.gd"

func _ready():
	archetype = "realistic"
	super._ready()
	_setup_animation_aliases()
	_setup_hitzones()

func _apply_archetype():
	var scary_model_path = "res://scenes/zombies/models/zombie_scary.scn"
	var mutant_model_path = "res://scenes/zombies/models/zombie_mutant.scn"
	var target_model = mutant_model_path if archetype in ["heavy", "boss", "mutant"] else scary_model_path
	
	if ResourceLoader.exists(target_model):
		var old = get_node_or_null("SkeletalModel")
		if old:
			old.name = "OldModel"
			old.queue_free()
		var m_res = load(target_model)
		model_instance = m_res.instantiate()
		model_instance.name = "SkeletalModel"
		add_child(model_instance)
	elif not model_instance:
		model_instance = get_node_or_null("SkeletalModel")
		
	if model_instance:
		var anims = model_instance.find_children("*", "AnimationPlayer", true, false)
		if not anims.is_empty():
			active_anim_player = anims[0]
			active_anim_player.speed_scale = randf_range(0.95, 1.05)
			
	if mesh_instance:
		mesh_instance.visible = false
		
	scale = Vector3.ONE
	move_speed = 0.95
	attack_range = 1.6
	attack_interval = 1.5
	attack_damage = 15.0
	reward_on_kill = 15
	if health_component:
		health_component.max_health = 60.0
		health_component.current_health = 60.0

func _setup_animation_aliases():
	if not active_anim_player:
		return
	var lib = active_anim_player.get_animation_library("")
	if not lib:
		return
	var alias_map = {
		"walk": ["Walk", "walk"],
		"idle": ["Idle", "idle", "HappyIdle"],
		"attack": ["Attack_mixamo_vitruvian", "Attack", "attack"],
		"death": ["Death_mixamo_vitruvian", "Death", "death"],
		"headshot_reaction": ["HitReaction_mixamo_vitruvian", "HitReaction", "headshot_reaction"],
		"stagger": ["HitReaction_mixamo_vitruvian", "stagger"]
	}
	for target_name in alias_map:
		if not lib.has_animation(target_name):
			for candidate in alias_map[target_name]:
				if lib.has_animation(candidate):
					lib.add_animation(target_name, lib.get_animation(candidate))
					break

func _setup_hitzones():
	for child in get_children():
		if child is HitZone:
			child.parent_entity = self

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
				
	if last_hit_was_headshot:
		_handle_headshot_decapitation()

	velocity = Vector3.ZERO
	if active_anim_player and (active_anim_player.has_animation("death") or active_anim_player.has_animation("Death")):
		_play_anim("death")
	else:
		var tween = create_tween()
		if tween:
			tween.tween_property(self, "rotation:x", -PI/2.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(self, "position:y", position.y - 0.4, 0.45)
	
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
			
	if get_tree():
		await get_tree().create_timer(2.2).timeout
	queue_free()

func _handle_headshot_decapitation():
	if not skeleton:
		skeleton = find_child("Skeleton3D", true, false)
	if skeleton:
		for b in range(skeleton.get_bone_count()):
			var bname = skeleton.get_bone_name(b).to_lower()
			if "head" in bname:
				skeleton.set_bone_pose_scale(b, Vector3.ZERO)
	
	var spray = CPUParticles3D.new()
	spray.name = "HeadshotBloodSpray"
	spray.amount = 24
	spray.lifetime = 1.0
	spray.one_shot = true
	spray.explosiveness = 0.9
	spray.direction = Vector3.UP
	spray.spread = 35.0
	spray.initial_velocity_min = 2.5
	spray.initial_velocity_max = 5.0
	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(spray)
		spray.global_position = global_position + Vector3(0, 1.58, 0)
		spray.emitting = true
		if get_tree():
			get_tree().create_timer(spray.lifetime + 0.5).timeout.connect(func():
				if is_instance_valid(spray):
					spray.queue_free()
			)
