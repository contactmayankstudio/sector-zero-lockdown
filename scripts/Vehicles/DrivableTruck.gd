# DrivableTruck.gd
# AGENT 6: HEAVY INDUSTRIAL DRIVABLE TRUCK
# High-torque heavy diesel truck with ramming mass, double axle suspension, and zombie plow capability.
class_name DrivableTruck
extends DrivableCar

func _ready():
	super._ready()
	# Heavy Truck Physics
	mass = 4200.0
	max_engine_force = 28000.0
	max_top_speed_kmh = 105.0
	nitro_top_speed_kmh = 125.0
	nitro_boost_force = 10000.0
	max_health = 1200.0
	current_health = 1200.0
	steer_speed = 4.2
	max_steer_angle = 0.42
	
	# Truck Prompt
	if prompt_label:
		prompt_label.text = "PRESS [F] TO DRIVE HEAVY DIESEL TRUCK"
	print("[TRUCK] Heavy Industrial Drivable Truck Ready (Mass: 4200kg, Armor: 1200 HP)")
