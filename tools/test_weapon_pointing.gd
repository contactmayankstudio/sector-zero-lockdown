extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	# Create a test camera at player eye height
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.65, 0)
	root.add_child(cam)
	
	var wm = Node3D.new()
	wm.name = "WeaponManager"
	wm.position = Vector3(0.18, -0.18, -0.42)
	cam.add_child(wm)
	
	print("--- TESTING ALL WEAPON ORIENTATIONS ---")
	for cfg in cfgs:
		var wid = cfg.id
		if not ResourceLoader.exists(cfg.model):
			continue
		var res = load(cfg.model)
		if not (res is PackedScene):
			continue
		var inst = res.instantiate()
		wm.add_child(inst)
		
		if cfg.has("basis"):
			inst.transform.basis = cfg.basis
		elif cfg.has("rot"):
			inst.rotation_degrees = cfg.rot
		if cfg.has("scale"):
			inst.scale = cfg.scale
		if cfg.has("offset"):
			inst.position = cfg.offset
			
		# In weapon local coordinates, find the furthest vertices along X, Y, Z
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var min_pt = Vector3(999, 999, 999)
		var max_pt = Vector3(-999, -999, -999)
		for m in meshes:
			if m.mesh:
				var m_aabb = m.transform * m.mesh.get_aabb()
				min_pt.x = min(min_pt.x, m_aabb.position.x)
				min_pt.y = min(min_pt.y, m_aabb.position.y)
				min_pt.z = min(min_pt.z, m_aabb.position.z)
				max_pt.x = max(max_pt.x, m_aabb.end.x)
				max_pt.y = max(max_pt.y, m_aabb.end.y)
				max_pt.z = max(max_pt.z, m_aabb.end.z)
				
		var size = (max_pt - min_pt) * inst.scale
		print("ID: %-18s | Size: (X:%.2f, Y:%.2f, Z:%.2f) | Longest: %s" % [
			wid, size.x, size.y, size.z,
			"Z (Forward OK)" if size.z > size.x and size.z > size.y else ("X (SIDEWAYS!)" if size.x > size.z else "Y (UP/DOWN!)")
		])
		inst.queue_free()
		
	cam.queue_free()
	p.free()
	quit(0)
