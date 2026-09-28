class_name ImpactPool
extends Node3D

var pools = {}
@export var impact_scenes: Dictionary = {}
@export var pool_size: int = 16

var audio_concrete = preload("res://audio/impacts/sfx_impact_concrete.wav")

const AUDIO_POOL_SIZE: int = 8
var _audio_pool: Array[AudioStreamPlayer3D] = []
var _audio_pool_idx: int = 0

func _ready():
	add_to_group("impact_pool")
	_init_pools()
	_init_audio_pool()

func _init_audio_pool():
	for i in range(AUDIO_POOL_SIZE):
		var p = AudioStreamPlayer3D.new()
		p.max_distance = 25.0
		p.bus = "SFX"
		add_child(p)
		_audio_pool.append(p)

func _init_pools():
	if impact_scenes.is_empty():
		impact_scenes = {
			"blood": preload("res://scenes/weapons/BloodEffect.tscn"),
			"concrete": preload("res://scenes/weapons/ImpactEffect.tscn")
		}
		
	for type in impact_scenes.keys():
		var pool = []
		for i in range(pool_size):
			var effect = impact_scenes[type].instantiate()
			effect.hide()
			add_child(effect)
			pool.append(effect)
		pools[type] = pool

func spawn_impact(type: String, pos: Vector3, normal: Vector3):
	_play_impact_audio(type, pos)
	
	if not pools.has(type):
		type = "concrete"
		if not pools.has(type):
			return
			
	for effect in pools[type]:
		if not effect.visible:
			effect.global_position = pos
			if normal.length() > 0.1:
				var up = Vector3.UP if abs(normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
				effect.look_at(pos + normal, up)
			effect.show()
			
			if effect.has_method("play_effect"):
				effect.play_effect()
			elif effect.has_method("restart"):
				effect.restart()
				
			_schedule_auto_hide(effect, 1.2)
			return

func _schedule_auto_hide(node: Node3D, delay: float):
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(node):
		node.hide()

func _play_impact_audio(type: String, pos: Vector3):
	if _audio_pool.is_empty(): return
	var p = _audio_pool[_audio_pool_idx]
	_audio_pool_idx = (_audio_pool_idx + 1) % AUDIO_POOL_SIZE
	p.stream = audio_concrete
	p.global_position = pos
	p.play()
