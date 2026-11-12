@tool
extends SceneTree

# We will test all 4 standard 90-degree rotations around X and Y:
# to find which rotation makes the barrel point towards Vector3(0, 0, -1) [FORWARD]
# and top/sight point towards Vector3(0, 1, 0) [UP]!

func _init():
	var p_script = load("res://scenes/player/Player.gd")
	var p = CharacterBody3D.new()
	p.set_script(p_script)
	var cfgs = p.weapon_configs
	p.free()

	print("=== DETERMINING EXACT ROTATION TO FACE FORWARD (-Z) ===")

	for cfg in cfgs:
		var wid = cfg.id
		var model_path = cfg.model
		if not ResourceLoader.exists(model_path):
			continue
		var res = load(model_path)
		if not (res is PackedScene):
			continue

		var inst = res.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)

		# Find the vertex that is furthest from the center (this is the barrel muzzle tip or stock)
		# Let's inspect the two extreme vertices along each axis
		var min_v = Vector3(9999, 9999, 9999)
		var max_v = Vector3(-9999, -9999, -9999)

		for m in meshes:
			if not m.mesh: continue
			var xform = m.transform
			for s in range(m.mesh.get_surface_count()):
				var arrs = m.mesh.surface_get_arrays(s)
				if arrs.size() > Mesh.ARRAY_VERTEX and arrs[Mesh.ARRAY_VERTEX] != null:
					var verts: PackedVector3Array = arrs[Mesh.ARRAY_VERTEX]
					for v in verts:
						var wv = xform * v
						min_v.x = minf(min_v.x, wv.x)
						max_v.x = maxf(max_v.x, wv.x)
						min_v.y = minf(min_v.y, wv.y)
						max_v.y = maxf(max_v.y, wv.y)
						min_v.z = minf(min_v.z, wv.z)
						max_v.z = maxf(max_v.z, wv.z)

		var center = (min_v + max_v) * 0.5
		var extents = (max_v - min_v)

		# The longest dimension is the barrel axis
		var barrel_axis = 0 # 0=X, 1=Y, 2=Z
		if extents.y > extents.x and extents.y > extents.z:
			barrel_axis = 1
		elif extents.z > extents.x and extents.z > extents.y:
			barrel_axis = 2

		# Also check which axis is height (second longest or stock/magazine height)
		var axis_names = ["X", "Y", "Z"]
		print("\nWeapon: %-18s | Extents: X=%.2f, Y=%.2f, Z=%.2f -> Barrel is along %s" % [
			wid, extents.x, extents.y, extents.z, axis_names[barrel_axis]
		])

		# Check existing MuzzleSocket or marker if present in scene
		var muzzle_socket = inst.find_child("*muzzle*", false, false)
		if not muzzle_socket:
			muzzle_socket = inst.find_child("*socket*", false, false)
		if muzzle_socket:
			print("  Found muzzle socket at: ", muzzle_socket.position)

		inst.free()

	quit(0)
