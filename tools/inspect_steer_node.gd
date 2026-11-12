@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	var steer_node = inst.find_child("bone_wheel_F_steer", true, false)
	if steer_node:
		print("bone_wheel_F_steer found! pos=", steer_node.position, " rot=", steer_node.rotation_degrees)
	var wf = inst.find_child("Wheel_F", true, false)
	if wf:
		print("Wheel_F found! pos=", wf.position, " rot=", wf.rotation_degrees)
	inst.free()
	quit(0)
