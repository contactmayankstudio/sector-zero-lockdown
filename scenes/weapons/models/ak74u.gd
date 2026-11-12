extends Node3D

func _ready():
	var ap = find_child("AnimationPlayer", true, false)
	if ap and ap.has_animation("IDLE"):
		ap.play("IDLE")
