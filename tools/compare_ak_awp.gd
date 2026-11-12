extends SceneTree

func _init():
	for wid in ["ak47", "awp"]:
		var scn = load("res://scenes/weapons/models/%s.tscn" % wid)
		var inst = scn.instantiate()
		print("=== WEAPON: %s ===" % wid)
		var mi = inst.find_children("*", "MeshInstance3D", true, false)[0]
		var aabb = mi.mesh.get_aabb()
		print("Mesh AABB: ", aabb)
		print("Mesh AABB size: ", aabb.size)
		var muz = inst.find_child("MuzzleSocket", true, false)
		print("MuzzleSocket pos: ", muz.position)
		
		# Test rotation Vector3(90, -90, 0)
		inst.rotation_degrees = Vector3(90, -90, 0)
		var muz_dir = inst.transform.basis * muz.position
		print("Muz transformed: ", muz_dir)
		inst.free()
	quit()
