extends SceneTree

func _init():
	for wid in ["m4a1", "usp45"]:
		var scn = load("res://scenes/weapons/models/%s.tscn" % wid)
		var inst = scn.instantiate()
		inst.rotation_degrees = Vector3(90, 0, -90)
		var t = inst.transform
		print("=== WEAPON: ", wid, " ===")
		print("Basis X: ", t.basis.x)
		print("Basis Y: ", t.basis.y)
		print("Basis Z: ", t.basis.z)
		inst.free()
	quit()
