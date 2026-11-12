class_name AmmoPickup
extends Area3D

@export var pickup_type: String = "ammo" # "ammo", "health", "cash"
@export var amount: int = 45

var time: float = 0.0
var initial_y: float = 0.0
var is_collected: bool = false
var lifetime: float = 30.0

@onready var light: OmniLight3D = get_node_or_null("OmniLight3D")
var label: Label3D = null
var _player_ref: Node3D = null

func _ready():
	initial_y = global_position.y
	body_entered.connect(_on_body_entered)
	collision_layer = 4
	collision_mask = 1
	_setup_visuals()

func _setup_visuals():
	if not label:
		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.font_size = 18
		label.outline_size = 5
		label.position.y = 0.45
		add_child(label)
		
	match pickup_type:
		"health":
			if light: light.light_color = Color(1.0, 0.2, 0.25)
			label.text = "+%d HEALTH" % amount
			label.modulate = Color(1.0, 0.3, 0.35)
		"cash":
			if light: light.light_color = Color(1.0, 0.85, 0.15)
			label.text = "+$%d CASH" % amount
			label.modulate = Color(1.0, 0.88, 0.2)
		_:
			if light: light.light_color = Color(0.2, 1.0, 0.35)
			label.text = "+AMMO"
			label.modulate = Color(0.3, 1.0, 0.4)

func _process(delta: float):
	if is_collected: return
	time += delta
	rotation.y += delta * 2.2
	position.y = initial_y + sin(time * 3.5) * 0.10
	
	# Magnet effect: attract towards player when nearby
	if not is_instance_valid(_player_ref):
		_player_ref = get_tree().get_first_node_in_group("player") if get_tree() else null
	if is_instance_valid(_player_ref):
		var dist = global_position.distance_to(_player_ref.global_position)
		if dist < 2.5:
			global_position = global_position.move_toward(_player_ref.global_position + Vector3(0, 0.5, 0), 6.5 * delta)
			if dist < 0.9:
				collect(_player_ref)
				return

	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node):
	if is_collected: return
	if body.is_in_group("player"):
		collect(body)

func take_damage(_amount: float, _is_headshot: bool = false, _hit_dir: Vector3 = Vector3.ZERO):
	# Shooting a loot box collects it remotely!
	if not is_instance_valid(_player_ref):
		_player_ref = get_tree().get_first_node_in_group("player") if get_tree() else null
	if is_instance_valid(_player_ref):
		collect(_player_ref)

func collect(player: Node):
	if is_collected: return
	is_collected = true
	
	match pickup_type:
		"health":
			if "current_health" in player and "max_health" in player:
				player.current_health = min(player.max_health, player.current_health + amount)
				if "hud" in player and player.hud:
					player.hud.update_health(player.current_health, player.max_health)
		"cash":
			var save_mgr = get_node_or_null("/root/SaveManager")
			if save_mgr and save_mgr.has_method("add_cash"):
				save_mgr.add_cash(maxi(amount, 0))
				if "hud" in player and player.hud:
					player.hud.update_cash(save_mgr.data.cash)
		_:
			# Ammo
			if "weapons" in player and not player.weapons.is_empty():
				var w = player.weapons[player.current_weapon_index]
				if w and "current_ammo" in w and "max_ammo" in w:
					w.current_ammo = min(w.max_ammo, w.current_ammo + amount)
					w.ammo_changed.emit(w.current_ammo, w.max_ammo)
	
	# Audio feedback
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_ui_click()
		
	# Floating notification
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_hitmarker"):
		hud.show_hitmarker(false)
		
	queue_free()
