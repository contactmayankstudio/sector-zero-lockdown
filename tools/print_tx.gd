extends SceneTree

func _init():
	var n = Node3D.new()
	n.rotation_degrees = Vector3(-90, 0, 0)
	n.position = Vector3(0.08, -0.08, -0.22)
	print("Transform: ", n.transform)
	n.free()
	quit(0)
