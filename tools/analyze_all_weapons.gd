extends SceneTree

func _init():
	print("=== ANALYZING ALL 14 WEAPONS GEOMETRY ===")
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	
	for cfg in cfgs:
		var wid = cfg.id
		var res = load(cfg.model)
		if not (res is PackedScene):
			print(wid, " -> NOT PACKED SCENE")
			continue
		var inst = res.instantiate()
		
		# Find all mesh instances
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var total_verts = 0
		var min_pt = Vector3(9999, 9999, 9999)
		var max_pt = Vector3(-9999, -9999, -9999)
		
		for m in meshes:
			if m.mesh:
				var aabb = m.transform * m.mesh.get_aabb()
				min_pt.x = min(min_pt.x, aabb.position.x)
				min_pt.y = min(min_pt.y, aabb.position.y)
				min_pt.z = min(min_pt.z, aabb.position.z)
				max_pt.x = max(max_pt.x, aabb.end.x)
				max_pt.y = max(max_pt.y, aabb.end.y)
				max_pt.z = max(max_pt.z, aabb.end.z)
				total_verts += m.mesh.get_faces().size()
		
		var sz = max_pt - min_pt
		var center = (min_pt + max_pt) * 0.5
		print("\nWeapon: ", wid)
		print("  Raw AABB: min=", min_pt, " max=", max_pt, " size=", sz)
		print("  Config rot: ", cfg.get("rot", "none"), " basis: ", cfg.get("basis", "none"), " scale: ", cfg.get("scale", "none"), " offset: ", cfg.get("offset", "none"))
		
		inst.free()
		
	p.free()
	quit(0)
