class_name PubgAirdrop
extends CharacterBody3D

## PUBG Supply Airdrop Crate with Parachute & Volumetric Red Smoke Flare
## Drops from sky, billows iconic PUBG red smoke flare, and supplies player with ammo, health, & cash.

signal looted

@export var fall_speed: float = 12.0 # m/s descending
@export var ground_y: float = 0.0
@export var loot_cash_reward: int = 3500

var is_landed: bool = false
var is_looted: bool = false
var nearby_player: Node3D = null

# Nodes
var crate_mesh: MeshInstance3D = null
var tarp_mesh: MeshInstance3D = null
var parachute_mesh: MeshInstance3D = null
var red_smoke_particles: CPUParticles3D = null
var smoke_light: OmniLight3D = null
var prompt_label: Label3D = null
var sfx_audio: AudioStreamPlayer3D = null

func _ready() -> void:
	add_to_group("airdrops")
	_build_airdrop_visuals()
	_setup_interaction_prompt()
	_setup_red_smoke()
	
	# Start high in sky
	if global_position.y < 35.0:
		global_position.y = 50.0

func _physics_process(delta: float) -> void:
	if not is_landed:
		# Descend smoothly like real parachute
		global_position.y -= fall_speed * delta
		
		# Gentle sway while falling
		rotation_degrees.z = sin(Time.get_ticks_msec() * 0.003) * 3.5
		
		if global_position.y <= ground_y + 0.70:
			global_position.y = ground_y + 0.70
			_on_crate_landed()
	else:
		_check_player_proximity()

func _build_airdrop_visuals() -> void:
	# 1. Red Steel Crate Base (1.4m x 1.4m x 1.2m)
	crate_mesh = MeshInstance3D.new()
	crate_mesh.name = "CrateBody"
	var box = BoxMesh.new()
	box.size = Vector3(1.4, 1.1, 1.4)
	
	var red_mat = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.85, 0.12, 0.12, 1.0) # Classic PUBG Red
	red_mat.metallic = 0.82
	red_mat.roughness = 0.35
	crate_mesh.mesh = box
	crate_mesh.material_override = red_mat
	add_child(crate_mesh)

	# 2. Blue Waterproof Tarp Cover on Top
	tarp_mesh = MeshInstance3D.new()
	tarp_mesh.name = "TarpCover"
	var tarp_box = BoxMesh.new()
	tarp_box.size = Vector3(1.46, 0.22, 1.46)
	
	var blue_mat = StandardMaterial3D.new()
	blue_mat.albedo_color = Color(0.12, 0.35, 0.85, 1.0) # Classic PUBG Blue Tarp
	blue_mat.roughness = 0.80
	tarp_mesh.mesh = tarp_box
	tarp_mesh.material_override = blue_mat
	tarp_mesh.position = Vector3(0.0, 0.52, 0.0)
	add_child(tarp_mesh)

	# 3. Parachute Canopy (Visible while falling)
	parachute_mesh = MeshInstance3D.new()
	parachute_mesh.name = "ParachuteCanopy"
	var canopy = CylinderMesh.new()
	canopy.top_radius = 2.8
	canopy.bottom_radius = 1.6
	canopy.height = 1.2
	
	var para_mat = StandardMaterial3D.new()
	para_mat.albedo_color = Color(0.92, 0.90, 0.85, 1.0)
	para_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	parachute_mesh.mesh = canopy
	parachute_mesh.material_override = para_mat
	parachute_mesh.position = Vector3(0.0, 4.2, 0.0)
	add_child(parachute_mesh)

	# 4. Audio Player
	sfx_audio = AudioStreamPlayer3D.new()
	sfx_audio.name = "AirdropAudio"
	sfx_audio.bus = "SFX"
	sfx_audio.max_distance = 60.0
	add_child(sfx_audio)

func _setup_red_smoke() -> void:
	red_smoke_particles = CPUParticles3D.new()
	red_smoke_particles.name = "RedSmokeFlare"
	red_smoke_particles.emitting = false
	red_smoke_particles.amount = 75
	red_smoke_particles.lifetime = 2.8
	red_smoke_particles.position = Vector3(0.0, 0.65, 0.0)
	red_smoke_particles.direction = Vector3(0.0, 1.0, 0.0)
	red_smoke_particles.spread = 16.0
	red_smoke_particles.initial_velocity_min = 4.5
	red_smoke_particles.initial_velocity_max = 8.5
	red_smoke_particles.gravity = Vector3(0.0, 0.8, 0.0)
	red_smoke_particles.scale_amount_min = 1.0
	red_smoke_particles.scale_amount_max = 3.5

	var smoke_mat = StandardMaterial3D.new()
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smoke_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	smoke_mat.albedo_color = Color(0.98, 0.15, 0.15, 0.45) # Iconic PUBG Red Flare

	var quad = QuadMesh.new()
	quad.size = Vector2(0.65, 0.65)
	quad.material = smoke_mat
	red_smoke_particles.mesh = quad
	add_child(red_smoke_particles)

	# Red glow light
	smoke_light = OmniLight3D.new()
	smoke_light.name = "RedSmokeLight"
	smoke_light.light_color = Color(1.0, 0.15, 0.15)
	smoke_light.light_energy = 3.0
	smoke_light.omni_range = 8.0
	smoke_light.position = Vector3(0.0, 0.9, 0.0)
	smoke_light.visible = false
	add_child(smoke_light)

func _setup_interaction_prompt() -> void:
	prompt_label = Label3D.new()
	prompt_label.name = "LootPrompt"
	prompt_label.text = "[E] / TAP: LOOT AIRDROP"
	prompt_label.font_size = 28
	prompt_label.modulate = Color(1.0, 0.90, 0.25, 1.0)
	prompt_label.outline_modulate = Color.BLACK
	prompt_label.outline_size = 6
	prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt_label.position = Vector3(0.0, 1.6, 0.0)
	prompt_label.visible = false
	add_child(prompt_label)

func _on_crate_landed() -> void:
	is_landed = true
	rotation_degrees = Vector3.ZERO
	
	# Discard parachute
	if parachute_mesh and is_instance_valid(parachute_mesh):
		parachute_mesh.visible = false
		
	# Ignite Iconic Red Smoke Flare!
	if red_smoke_particles:
		red_smoke_particles.emitting = true
	if smoke_light:
		smoke_light.visible = true
		
	# Play heavy metal impact sound
	if sfx_audio:
		var sound = load("res://audio/vehicles/impact_2.wav")
		if sound:
			sfx_audio.stream = sound
			sfx_audio.play()

	print("[PUBG AIRDROP] Supply Crate landed on highway! Red smoke flare active.")

func _check_player_proximity() -> void:
	if is_looted:
		return
		
	var tree = get_tree()
	if not tree:
		return
	var player = tree.get_first_node_in_group("player") as Node3D
	if not player or not is_instance_valid(player):
		return
		
	var dist = global_position.distance_to(player.global_position)
	var hud = tree.get_first_node_in_group("hud")
	if dist <= 3.8:
		prompt_label.visible = true
		if hud and hud.has_method("show_airdrop_prompt"):
			hud.show_airdrop_prompt(true)
		if Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E):
			loot_crate(player)
	else:
		prompt_label.visible = false
		if hud and hud.has_method("show_airdrop_prompt"):
			hud.show_airdrop_prompt(false)

func _unhandled_input(event: InputEvent) -> void:
	if is_looted or not is_landed:
		return
	if prompt_label and prompt_label.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_E:
				var player = get_tree().get_first_node_in_group("player") as Node3D
				if player:
					loot_crate(player)

func loot_crate(player: Node3D) -> void:
	if is_looted:
		return
	is_looted = true
	prompt_label.visible = false
	
	print("[PUBG AIRDROP] Player looted supply crate!")
	
	# 1. Victory audio
	if sfx_audio:
		var vic_sound = load("res://audio/ui/sfx_victory.wav")
		if vic_sound:
			sfx_audio.stream = vic_sound
			sfx_audio.play()
			
	# 2. Refill Player Health & Armor
	if player.has_method("heal"):
		player.heal(100.0)
	elif "current_health" in player and "max_health" in player:
		player.current_health = player.max_health
	if player.has_method("give_armor"):
		player.give_armor(200.0)
	elif "current_armor" in player and "max_armor" in player:
		player.max_armor = 200.0
		player.current_armor = 200.0
	if player.has_method("_update_hud"):
		player._update_hud()
			
	# 3. Refill all weapon ammo to MAX
	if "weapons" in player:
		for w in player.weapons:
			if "current_ammo" in w and "max_ammo" in w:
				w.current_ammo = w.max_ammo
				w.ammo_changed.emit(w.current_ammo, w.max_ammo)
				
	# 4. Award Cash Bonus via SaveManager
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("add_cash"):
		sm.add_cash(loot_cash_reward)
		
	# 5. Display PUBG Victory Banner & Killfeed on HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		if hud.has_method("show_airdrop_prompt"):
			hud.show_airdrop_prompt(false)
		if hud.has_method("show_center_notification"):
			hud.show_center_notification("★ PUBG LEVEL 3 AIRDROP LOOTED! FULL ARMOR & MAX AMMO ★", 4.0)
		if hud.has_method("add_killfeed_entry"):
			hud.add_killfeed_entry("COMBAT SOLDIER", "📦", "PUBG SUPPLY CRATE (+$3,500)", true)
		
	looted.emit()
	
	# Extinguish smoke after 12 seconds
	var tree = get_tree()
	if tree:
		var t = tree.create_timer(12.0)
		t.timeout.connect(func():
			if red_smoke_particles and is_instance_valid(red_smoke_particles):
				red_smoke_particles.emitting = false
			if smoke_light and is_instance_valid(smoke_light):
				smoke_light.visible = false
		)
