# GTAOpenWorld.gd
# AGENT 10: MASTER OPEN WORLD INTEGRATION & GAMEPLAY COORDINATOR
# Integrates:
# 1. 3D Player with walking, running, crouching, jumping, and 3rd/1st person camera
# 2. Complete vehicle fleet: Sports Car, Superbike (Hayabusa 1300R), and Heavy Diesel Truck
# 3. Ambient traffic cars cruising along road lanes with collision avoidance
# 4. Animated pedestrian NPCs strolling along city sidewalks
# 5. Open-world dynamic missions with real-time GPS tracking and cash rewards
# 6. Dynamic Day/Night cycle, Rainstorm weather system, and glowing night streetlights
# 7. Interactive Map & Fast Travel modal [M] and In-Game Pause Menu [ESC]
# 8. Seamless 3x3 procedural chunk streaming optimized for low-end 4GB RAM APU
extends Node3D

@onready var chunk_manager = $ChunkManager
@onready var sky_controller = $SkyController
@onready var vehicle_spawner = $VehicleSpawner
@onready var npc_system = $NPCSystem
@onready var hud = $OpenWorldHUD

var player_node: Node3D = null
var player_car: Node3D = null
var player_bike: Node3D = null
var player_truck: Node3D = null
var ambience_audio: AudioStreamPlayer = null
var zombie_prefab: PackedScene = null
var active_zombies: Array[Node3D] = []

# Open-World Mission System
var current_mission_id: int = 1
var current_mission_kills: int = 0
var missions = [
	{
		"id": 1,
		"title": "Clear Downtown Horde",
		"target_kills": 5,
		"reward": 2500,
		"target_pos": Vector3(72.0, 1.2, 58.0)
	},
	{
		"id": 2,
		"title": "Highway Roadkill Blitz",
		"target_kills": 3,
		"reward": 4000,
		"target_pos": Vector3(140.0, 1.2, 64.0)
	},
	{
		"id": 3,
		"title": "Reach Mountain Overlook",
		"target_kills": 0,
		"reward": 5000,
		"target_pos": Vector3(64.0, 26.0, -65.0)
	}
]

func _ready():
	print("[GTA OPEN WORLD] Initializing Phase 2 AAA Open World Gameplay...")
	zombie_prefab = load("res://scenes/zombies/Zombie.tscn")
	_setup_chunk_manager()
	_setup_distant_horizon()
	_setup_player()
	_setup_vehicles()
	_setup_pedestrians()
	_setup_ambience()
	_setup_open_world_zombies()
	_update_mission_hud()
	print("[GTA OPEN WORLD] Phase 2 Systems Active: Player, 3 Vehicles, Traffic, NPCs, Weather, Missions!")

func _setup_chunk_manager():
	if not chunk_manager:
		return
	if chunk_manager.has_method("_update_chunks"):
		chunk_manager._update_chunks(Vector2i(0, 0))

func _setup_distant_horizon():
	var horizon_script = load("res://scripts/World/DistantHorizonMountains.gd")
	if horizon_script:
		var horizon_node = horizon_script.new()
		add_child(horizon_node)
		print("[GTA OPEN WORLD] Distant Horizon Mountains attached to world!")

func _setup_player():
	var player_prefab = load("res://scenes/player/Player.tscn")
	if not player_prefab:
		push_error("Failed to load Player.tscn")
		return
		
	player_node = player_prefab.instantiate()
	player_node.name = "Player"
	player_node.position = Vector3(72.0, 1.2, 58.0)
	if "is_stationary" in player_node:
		player_node.is_stationary = false
	if "move_limit" in player_node:
		player_node.move_limit = 0.0
	if "is_third_person" in player_node:
		player_node.is_third_person = true
	add_child(player_node)
	
	if chunk_manager:
		chunk_manager.target_node = player_node
	if hud:
		hud.player_ref = player_node

func _setup_vehicles():
	if not vehicle_spawner:
		return
		
	# 1. Sports Car (Parked along Right Lane heading South)
	if vehicle_spawner.has_method("spawn_player_car"):
		player_car = vehicle_spawner.spawn_player_car(Vector3(67.5, 0.4, 48.0), 0.0)
		
	# 2. Superbike (Hayabusa 1300R parked curbside)
	if vehicle_spawner.has_method("spawn_player_bike"):
		player_bike = vehicle_spawner.spawn_player_bike(Vector3(74.5, 0.4, 52.0), 0.0)
		
	# 3. Heavy Diesel Truck (Parked on Left Lane heading North)
	if vehicle_spawner.has_method("spawn_player_truck"):
		player_truck = vehicle_spawner.spawn_player_truck(Vector3(60.5, 0.5, 24.0), PI)
		
	# 4. Ambient Traffic Cars cruising along road lanes
	if vehicle_spawner.has_method("spawn_traffic_vehicle"):
		vehicle_spawner.spawn_traffic_vehicle(Vector3(60.5, 0.4, 110.0), Vector3.BACK, 13.0)
		vehicle_spawner.spawn_traffic_vehicle(Vector3(67.5, 0.4, -40.0), Vector3.FORWARD, 13.0)

func _setup_pedestrians():
	if not npc_system:
		return
		
	var sidewalk_points: Array[Vector3] = [
		Vector3(74.0, 0.25, 42.0),
		Vector3(74.0, 0.25, 78.0),
		Vector3(53.5, 0.25, 38.0),
		Vector3(53.5, 0.25, 72.0)
	]
	if npc_system.has_method("spawn_pedestrians_in_city"):
		npc_system.spawn_pedestrians_in_city(sidewalk_points, 4)

func _setup_open_world_zombies():
	if not zombie_prefab:
		return
		
	var spawn_coords = [
		Vector3(45.0, 0.25, 42.0),
		Vector3(88.0, 0.25, 42.0),
		Vector3(45.0, 0.25, 84.0),
		Vector3(88.0, 0.25, 84.0),
		Vector3(64.0, 0.25, 12.0)
	]
	for pt in spawn_coords:
		var z = zombie_prefab.instantiate()
		z.position = pt
		add_child(z)
		active_zombies.append(z)
		z.tree_exited.connect(func():
			_on_zombie_eliminated(false)
		)

func _on_zombie_eliminated(is_roadkill: bool):
	if not is_inside_tree(): return
	current_mission_kills += 1
	var sm = get_node_or_null("/root/SaveManager")
	var cash_gain = 350 if is_roadkill else 200
	if sm and sm.has_method("add_cash"):
		sm.add_cash(cash_gain)
		
	var mission = missions[current_mission_id - 1]
	if mission and mission["target_kills"] > 0:
		if current_mission_kills >= mission["target_kills"]:
			# Mission Accomplished!
			print("[MISSION] MISSION COMPLETE: ", mission["title"])
			if sm and sm.has_method("add_cash"):
				sm.add_cash(mission["reward"])
			current_mission_kills = 0
			current_mission_id = (current_mission_id % missions.size()) + 1
			
	_update_mission_hud()

func _on_zombie_roadkilled(_zombie_ref: Node3D, _speed_kmh: float):
	if not is_inside_tree(): return
	_on_zombie_eliminated(true)

func _update_mission_hud():
	if not is_inside_tree() or not hud: return
	var mission = missions[current_mission_id - 1]
	if not mission: return
	
	var cur_pos = player_node.global_position if (player_node and is_instance_valid(player_node)) else Vector3.ZERO
	var dist = cur_pos.distance_to(mission["target_pos"])
	var title = mission["title"]
	if mission["target_kills"] > 0:
		title += " [%d/%d]" % [current_mission_kills, mission["target_kills"]]
	hud.update_mission_gps(title, dist, mission["reward"])

func _setup_ambience():
	var amb_stream = load("res://audio/ambience/sfx_ambience_metro.wav")
	if amb_stream:
		ambience_audio = AudioStreamPlayer.new()
		ambience_audio.name = "CityAmbience"
		ambience_audio.stream = amb_stream
		ambience_audio.volume_db = -18.0
		ambience_audio.autoplay = true
		add_child(ambience_audio)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T:
				if sky_controller and sky_controller.has_method("cycle_time"):
					sky_controller.cycle_time()
			KEY_Y:
				if sky_controller and sky_controller.has_method("toggle_weather"):
					sky_controller.toggle_weather()
			KEY_V:
				if player_node and player_node.has_method("toggle_camera_perspective"):
					player_node.toggle_camera_perspective()
			KEY_M:
				if hud and hud.has_method("toggle_map"):
					hud.toggle_map()
			KEY_ESCAPE:
				if hud and hud.has_method("toggle_pause"):
					hud.toggle_pause()
			KEY_1:
				_teleport_player(Vector3(72.0, 1.2, 58.0), "Downtown Avenue Hub")
			KEY_2:
				_teleport_player(Vector3(140.0, 1.2, 64.0), "East Highway Commercial Strip")
			KEY_3:
				_teleport_player(Vector3(64.0, 26.0, -65.0), "North Mountain Overlook")
			KEY_4:
				_teleport_player(Vector3(-100.0, 6.0, 64.0), "West Countryside Farmlands")
			KEY_5:
				_teleport_player(Vector3(64.0, 1.2, 140.0), "South Gas Station & Shops")

func _teleport_player(pos: Vector3, loc_name: String):
	# Check if player is currently driving a vehicle
	var occupied_veh: Node3D = null
	for veh in [player_car, player_bike, player_truck]:
		if veh and is_instance_valid(veh) and veh.get("is_occupied"):
			occupied_veh = veh
			break
			
	if occupied_veh:
		occupied_veh.global_position = pos + Vector3(0, 0.5, 0)
		if "linear_velocity" in occupied_veh:
			occupied_veh.linear_velocity = Vector3.ZERO
		print("[TELEPORT] Teleported vehicle to: ", loc_name)
	elif player_node and is_instance_valid(player_node):
		player_node.global_position = pos
		if "velocity" in player_node:
			player_node.velocity = Vector3.ZERO
		print("[TELEPORT] Teleported player to: ", loc_name)
		
	# Trigger mission check if reached destination
	var mission = missions[current_mission_id - 1]
	if mission and mission["target_kills"] == 0:
		var cur_p = pos
		if cur_p.distance_to(mission["target_pos"]) < 35.0:
			var sm = get_node_or_null("/root/SaveManager")
			if sm and sm.has_method("add_cash"):
				sm.add_cash(mission["reward"])
			print("[MISSION] Overlook reached! Cash reward awarded: $", mission["reward"])
			current_mission_id = (current_mission_id % missions.size()) + 1
			
	_update_mission_hud()

func _process(_delta):
	if not chunk_manager:
		return
		
	# Stream chunks dynamically around player or currently active vehicle
	var target: Node3D = player_node
	for veh in [player_car, player_bike, player_truck]:
		if veh and is_instance_valid(veh) and veh.get("is_occupied"):
			target = veh
			break
			
	if target and is_instance_valid(target):
		chunk_manager.target_node = target
