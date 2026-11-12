extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	print("--- RAW WEAPON MODEL INSPECTION ---")
	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			continue
		var res = load(model_path)
		if not (res is PackedScene):
			continue
		var inst = res.instantiate()
		
		# Find mesh without any transforms applied
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var raw_size = Vector3.ZERO
		for m in meshes:
			if m.mesh:
				var sz = m.mesh.get_aabb().size
				if sz.length() > raw_size.length():
					raw_size = sz
		print("ID: %-18s | Raw Mesh Max AABB: (X:%.2f, Y:%.2f, Z:%.2f)" % [
			wid, raw_size.x, raw_size.y, raw_size.z
		])
		inst.free()
	p.free()
	quit(0)
