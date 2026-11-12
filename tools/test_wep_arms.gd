
extends SceneTree
func _init():
	var root = Node3D.new()
	var cam = Camera3D.new()
	cam.fov = 72.0
	cam.position = Vector3(0, 1.65, 0)
	cam.current = true
	root.add_child(cam)
	
	var wep_mgr = Node3D.new()
	wep_mgr.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wep_mgr)
	
	# Load AK-74U
	var ak_res = load("res://scenes/weapons/models/ak74u.tscn")
	var ak = ak_res.instantiate()
	wep_mgr.add_child(ak)
	
	# Load realistic arms
	var arms_res = load("res://assets/3d/weapons/fps_arms_realistic.glb")
	var arms = arms_res.instantiate()
	arms.scale = Vector3(0.01, 0.01, 0.01)
	cam.add_child(arms)
	
	# Try some orientations
	print("AK transform:", ak.transform)
	print("Arms loaded successfully!")
	quit(0)
