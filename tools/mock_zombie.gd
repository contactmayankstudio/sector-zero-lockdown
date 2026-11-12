@tool
extends Node3D

var health: float = 100.0
var damage_received: float = 0.0
var is_dead: bool = false

func take_damage(amount: float, is_headshot: bool = false, impulse: Vector3 = Vector3.ZERO):
	damage_received += amount
	health -= amount
	if health <= 0:
		is_dead = true
