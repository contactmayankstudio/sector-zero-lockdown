@tool
extends SceneTree

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs

	print("=================================================================")
	print("ANALYZING ALL 14 WEAPONS FOR EXACT FORWARD (-Z) FACING ALIGNMENT")
	print("=================================================================")

	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			print("MISSING: ", wid, " at ", model_path)
			continue

		var res = load(model_path)
		if not (res is PackedScene):
			continue

		var inst = res.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		
		# Calculate raw unrotated model AABB
		var raw_aabb = AABB()
		var first = true
		for m in meshes:
			if m.mesh:
				var m_aabb = m.mesh.get_aabb()
				if first:
					raw_aabb = m_aabb
					first = false
				else:
					raw_aabb = raw_aabb.merge(m_aabb)

		# Current applied transform
		var cur_rot = cfg.get("rot", Vector3.ZERO)
		var cur_scale = cfg.get("scale", Vector3.ONE)
		var cur_offset = cfg.get("offset", Vector3.ZERO)

		print("\n--- WEAPON: %s ---" % wid)
		print("  Model: %s" % model_path)
		print("  Raw AABB Size: X:%.3f, Y:%.3f, Z:%.3f (Center: %s)" % [raw_aabb.size.x, raw_aabb.size.y, raw_aabb.size.z, str(raw_aabb.get_center())])
		print("  Current Config -> Rot: %s, Scale: %s, Offset: %s" % [str(cur_rot), str(cur_scale), str(cur_offset)])

		# Which raw axis is the barrel?
		var longest_axis = "X"
		var max_dim = raw_aabb.size.x
		if raw_aabb.size.y > max_dim:
			longest_axis = "Y"
			max_dim = raw_aabb.size.y
		if raw_aabb.size.z > max_dim:
			longest_axis = "Z"
			max_dim = raw_aabb.size.z
		print("  Barrel Longest Axis: %s (length: %.3f)" % [longest_axis, max_dim])

		inst.free()

	p.free()
	quit(0)
