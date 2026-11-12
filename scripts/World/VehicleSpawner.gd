# VehicleSpawner.gd
# AGENT 6: VEHICLE INTEGRATION & TRAFFIC SYSTEM
# Spawns drivable cars, bikes, heavy trucks, and moving ambient traffic across open-world roads.
class_name VehicleSpawner
extends Node3D

var car_prefab: PackedScene = null
var bike_prefab: PackedScene = null
var truck_prefab: PackedScene = null
var traffic_prefab: PackedScene = null
var active_vehicles: Array[Node3D] = []
var active_traffic: Array[Node3D] = []

func _ready():
	car_prefab = load("res://scenes/vehicles/DrivableCar.tscn")
	bike_prefab = load("res://scenes/vehicles/DrivableBike.tscn")
	truck_prefab = load("res://scenes/vehicles/DrivableTruck.tscn")
	traffic_prefab = load("res://scenes/vehicles/TrafficCar.tscn")

func spawn_player_car(spawn_pos: Vector3, spawn_rot: float = 0.0) -> Node3D:
	if not car_prefab:
		car_prefab = load("res://scenes/vehicles/DrivableCar.tscn")
	if not car_prefab:
		push_error("[VEHICLE] Failed to load DrivableCar.tscn")
		return null
		
	var car = car_prefab.instantiate()
	car.position = spawn_pos
	car.rotation.y = spawn_rot
	add_child(car)
	active_vehicles.append(car)
	print("[VEHICLE] Player Drivable Car spawned at: ", spawn_pos)
	return car

func spawn_player_bike(spawn_pos: Vector3, spawn_rot: float = 0.0) -> Node3D:
	if not bike_prefab:
		bike_prefab = load("res://scenes/vehicles/DrivableBike.tscn")
	if not bike_prefab:
		push_error("[VEHICLE] Failed to load DrivableBike.tscn")
		return null
		
	var bike = bike_prefab.instantiate()
	bike.position = spawn_pos
	bike.rotation.y = spawn_rot
	add_child(bike)
	active_vehicles.append(bike)
	print("[VEHICLE] Player Drivable Superbike spawned at: ", spawn_pos)
	return bike

func spawn_player_truck(spawn_pos: Vector3, spawn_rot: float = 0.0) -> Node3D:
	if not truck_prefab:
		truck_prefab = load("res://scenes/vehicles/DrivableTruck.tscn")
	if not truck_prefab:
		return null
		
	var truck = truck_prefab.instantiate()
	truck.position = spawn_pos
	truck.rotation.y = spawn_rot
	add_child(truck)
	active_vehicles.append(truck)
	print("[VEHICLE] Player Drivable Heavy Truck spawned at: ", spawn_pos)
	return truck

func spawn_traffic_vehicle(start_pos: Vector3, move_direction: Vector3, speed: float = 12.0) -> Node3D:
	if not traffic_prefab:
		traffic_prefab = load("res://scenes/vehicles/TrafficCar.tscn")
	if not traffic_prefab:
		return null
		
	var traffic_car = traffic_prefab.instantiate()
	add_child(traffic_car)
	if traffic_car.has_method("setup"):
		traffic_car.setup(start_pos, move_direction, speed)
	else:
		traffic_car.position = start_pos
		traffic_car.rotation.y = atan2(move_direction.x, move_direction.z) + PI
	active_traffic.append(traffic_car)
	return traffic_car
