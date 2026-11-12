extends Node3D
class_name CasingPool

@export var pool_size: int = 24
var casing_scene = preload("res://scenes/weapons/BulletCasing.tscn")
var pool: Array = []
var next_idx: int = 0

func _ready():
	add_to_group("casing_pool")
	_init_pool()

func _init_pool():
	for i in range(pool_size):
		var c = casing_scene.instantiate()
		add_child(c)
		pool.append(c)

func spawn_casing(type: String, pos: Vector3, gun_basis: Basis, floor_y: float = 0.0):
	if pool.is_empty(): return
	var c = pool[next_idx]
	next_idx = (next_idx + 1) % pool_size
	c.activate(type, pos, gun_basis, floor_y)
