extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	print("--- INSPECTING WEAPON CONFIG ORIENTATIONS ---")
	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			print("[MISSING] ", wid, " -> ", model_path)
			continue
			
		var res = load(model_path)
		if not (res is PackedScene):
			print("[NOT SCENE] ", wid)
			continue
			
		var inst = res.instantiate()
		var n3d = Node3D.new()
		n3d.add_child(inst)
		
		if cfg.has("basis"):
			inst.transform.basis = cfg.basis
		elif cfg.has("rot"):
			inst.rotation_degrees = cfg.rot
		if cfg.has("scale"):
			inst.scale = cfg.scale
		if cfg.has("offset"):
			inst.position = cfg.offset
			
		# Compute combined AABB of all meshes in model
		var aabb = AABB()
		var first = true
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			if m.mesh:
				var m_aabb = m.transform * m.mesh.get_aabb()
				if first:
					aabb = m_aabb
					first = false
				else:
					aabb = aabb.merge(m_aabb)
					
		print("ID: %-18s | Size: (X:%.2f, Y:%.2f, Z:%.2f) | Rot: %s" % [
			wid, aabb.size.x, aabb.size.y, aabb.size.z,
			str(cfg.get("rot", cfg.get("basis", "none")))
		])
		n3d.free()
	p.free()
	quit(0)
