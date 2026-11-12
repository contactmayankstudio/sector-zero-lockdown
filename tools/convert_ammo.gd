
extends SceneTree

func _init():
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file("res://real/free_ammo_set_ver.2_ultra.glb", state)
	print("Ammo append err: ", err)
	if err == OK:
		var scene = doc.generate_scene(state)
		# Take one of the clean ammo box groups, e.g. Cube.001 or Shotgun ammo preview
		var box = scene.find_child("*Shotgun*", true, false)
		if not box:
			box = scene.find_child("*Cube*", true, false)
		var root_p = Node3D.new()
		root_p.name = "AmmoPickupMesh"
		if box:
			box.get_parent().remove_child(box)
			root_p.add_child(box)
			box.position = Vector3.ZERO
			box.owner = root_p
			for c in box.find_children("*", "Node3D", true, false):
				c.owner = root_p
		else:
			root_p.add_child(scene)
			scene.owner = root_p
			
		var packed = PackedScene.new()
		packed.pack(root_p)
		var s_err = ResourceSaver.save(packed, "res://scenes/pickups/AmmoPickupModel.scn", ResourceSaver.FLAG_COMPRESS)
		print("Saved AmmoPickupModel.scn err: ", s_err)
		root_p.free()
	quit(0)
