extends Node
class_name HealthComponent

signal health_changed(current_health)
signal died

@export var max_health: float = 100.0
var current_health: float

var is_dead: bool = false

func _ready():
	current_health = max_health

func take_damage(amount: float):
	if is_dead:
		return
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		is_dead = true
		died.emit()
