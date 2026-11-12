extends SceneTree

func _init():
	var scn = load("res://scenes/weapons/models/m4a1.tscn")
	var inst = scn.instantiate()
	inst.rotation_degrees = Vector3(90, 0, -90)
	var muzzle = inst.find_child("MuzzleSocket", true, false)
	var m_pos = inst.to_global(muzzle.position) if muzzle else Vector3.ZERO
	print("M4A1 rotated (90, 0, -90) Muzzle Global Pos: ", m_pos)
	print("M4A1 local muzzle pos: ", muzzle.position)
	print("inst.transform.basis: ", inst.transform.basis)
	print("inst.transform.basis * muzzle.position: ", inst.transform.basis * muzzle.position)
	inst.free()
	quit()
