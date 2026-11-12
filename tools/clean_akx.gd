extends SceneTree

func _init():
	print("--- CLEANING AKX SCIFI DUPLICATE NODES ---")
	var akx_path = "res://scenes/weapons/models/akx_scifi.scn"
	var akx_scn = load(akx_path)
	var inst = akx_scn.instantiate()
	var to_remove = []
	for c in inst.find_children("*", "Node3D", true, false):
		if "_001" in c.name or "_002" in c.name:
			to_remove.append(c)
	print("Found duplicate nodes to remove in AKX: ", to_remove.size())
	for n in to_remove:
		if is_instance_valid(n) and n.get_parent():
			n.get_parent().remove_child(n)
			n.free()
			
	var packed = PackedScene.new()
	packed.pack(inst)
	var err = ResourceSaver.save(packed, akx_path, ResourceSaver.FLAG_COMPRESS)
	print("Saved cleaned akx_scifi.scn: ", err)
	inst.free()
	quit(0)
