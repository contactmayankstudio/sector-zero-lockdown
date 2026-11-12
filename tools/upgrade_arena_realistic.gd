@tool
extends SceneTree
## Upgrades CityCarZombieArena: adds PBR grass+dirt terrain strips, replaces
## the low-poly police car body mesh with the realistic HD sedan visual.
## Keeps all existing anti-hang/performance protections intact.

func _init():
	print("--- [UPGRADE] Adding Realistic Terrain & HD Sedan Car ---")

	# ---------- 1. LOAD THE EXISTING ARENA SCENE ----------
	var arena_packed = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not arena_packed:
		printerr("[UPGRADE] Could not load CityCarZombieArena.tscn!")
		quit(1)
		return
	var arena = arena_packed.instantiate()

	# ---------- 2. ADD GRASS TERRAIN STRIPS (both sides of road) ----------
	var terrain_node = Node3D.new()
	terrain_node.name = "RealisticTerrain"
	arena.add_child(terrain_node)
	terrain_node.owner = arena

	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	var dirt_mat  = load("res://resources/materials/mat_dirt.tres")

	# Road is 50 wide centered at X=0, extends Z from +75 to -235 (center -80, length 320)
	# Add two strips per side: dirt shoulder (4m) + grass field (18m)
	# Left side:  X = -25 to -29 (dirt), -29 to -47 (grass)
	# Right side: X = +25 to +29 (dirt), +29 to +47 (grass)

	var strip_configs = [
		# Left dirt shoulder
		{"name": "DirtStripLeft",  "pos": Vector3(-27.0, -0.02, -80.0), "size": Vector2(4.0, 320.0), "mat": dirt_mat, "uv_scale": Vector3(1, 48, 1)},
		# Left grass field
		{"name": "GrassFieldLeft", "pos": Vector3(-38.0, -0.04, -80.0), "size": Vector2(18.0, 320.0), "mat": grass_mat, "uv_scale": Vector3(3, 48, 1)},
		# Right dirt shoulder
		{"name": "DirtStripRight", "pos": Vector3(27.0, -0.02, -80.0), "size": Vector2(4.0, 320.0), "mat": dirt_mat, "uv_scale": Vector3(1, 48, 1)},
		# Right grass field
		{"name": "GrassFieldRight","pos": Vector3(38.0, -0.04, -80.0), "size": Vector2(18.0, 320.0), "mat": grass_mat, "uv_scale": Vector3(3, 48, 1)},
	]

	for cfg in strip_configs:
		# Static body + collision
		var sb = StaticBody3D.new()
		sb.name = cfg.name
		terrain_node.add_child(sb)
		sb.owner = arena

		var col = CollisionShape3D.new()
		col.name = "Col"
		var box = BoxShape3D.new()
		box.size = Vector3(cfg.size.x, 0.1, cfg.size.y)
		col.shape = box
		col.position = cfg.pos + Vector3(0, -0.05, 0)
		sb.add_child(col)
		col.owner = arena

		# Mesh
		var mi = MeshInstance3D.new()
		mi.name = cfg.name + "Mesh"
		var plane = PlaneMesh.new()
		plane.size = cfg.size
		mi.mesh = plane
		mi.position = cfg.pos
		if cfg.mat:
			var dup_mat = cfg.mat.duplicate()
			dup_mat.uv1_scale = cfg.uv_scale
			mi.set_surface_override_material(0, dup_mat)
		sb.add_child(mi)
		mi.owner = arena
		print("[UPGRADE] Added terrain strip: ", cfg.name)

	# ---------- 3. SWAP CAR BODY WITH REALISTIC SEDAN MODEL ----------
	var car_node = arena.get_node_or_null("DrivableCar")
	if car_node:
		# Hide the old low-poly mesh wrapper (police car body)
		var old_mesh = car_node.get_node_or_null("CarMeshWrapper")
		if old_mesh:
			old_mesh.visible = false
			old_mesh.name = "CarMeshWrapper_OLD"
			print("[UPGRADE] Hidden old low-poly CarMeshWrapper")

		# Update collision box to match sedan dimensions (~2.18 x 1.6 x 4.2)
		var col_shape_node = car_node.get_node_or_null("CarMeshWrapper_OLD/CollisionShape")
		if not col_shape_node:
			# Try direct child collision shapes
			for child in car_node.get_children():
				if child is CollisionShape3D:
					col_shape_node = child
					break
		if col_shape_node and col_shape_node.shape is BoxShape3D:
			col_shape_node.shape.size = Vector3(2.0, 1.4, 4.1)
			col_shape_node.position = Vector3(0, 0.7, 0)
			# Reparent collision under car root if it was under old mesh wrapper
			if col_shape_node.get_parent() != car_node:
				var old_parent = col_shape_node.get_parent()
				old_parent.remove_child(col_shape_node)
				car_node.add_child(col_shape_node)
				col_shape_node.owner = arena
			print("[UPGRADE] Updated collision box for sedan")

		# Add new collision shape if none found
		if not col_shape_node:
			var new_col = CollisionShape3D.new()
			new_col.name = "SedanCollision"
			var new_box = BoxShape3D.new()
			new_box.size = Vector3(2.0, 1.4, 4.1)
			new_col.shape = new_box
			new_col.position = Vector3(0, 0.7, 0)
			car_node.add_child(new_col)
			new_col.owner = arena
			print("[UPGRADE] Created new collision shape for sedan")

		# Load and attach the realistic sedan visual
		var sedan_scn = load("res://assets/downloaded_cars/sedan_real.glb")
		if sedan_scn:
			var sedan_inst = sedan_scn.instantiate()
			sedan_inst.name = "SedanRealisticBody"
			# Rotate 180 deg so +Z faces forward (Godot convention)
			sedan_inst.rotation_degrees = Vector3(0, 180, 0)
			# Lower it so wheels sit at suspension rest height
			sedan_inst.position = Vector3(0, -0.33, 0)
			car_node.add_child(sedan_inst)
			sedan_inst.owner = arena
			_set_owner_recursive(sedan_inst, arena)

			# Hide the sedan's built-in wheel nodes (VehicleWheel3D will handle visuals)
			for wn in ["Wheel_LF", "Wheel_RF", "Wheel_LR", "Wheel_RR"]:
				var w = _find_node_by_name(sedan_inst, wn)
				if w:
					w.visible = false

			print("[UPGRADE] Attached realistic sedan body (180° rotated)")
		else:
			printerr("[UPGRADE] Could not load sedan_real.glb!")

		# Update VehicleWheel3D positions to match sedan proportions
		# Sedan wheels (after 180° rot): FL(-0.82, 0.33, -1.58), FR(0.81, 0.33, -1.58)
		#                                 BL(-0.82, 0.33, 1.34),  BR(0.81, 0.33, 1.34)
		var wheel_updates = {
			"WheelFL": Vector3(-0.82, 0.38, -1.58),
			"WheelFR": Vector3(0.82, 0.38, -1.58),
			"WheelBL": Vector3(-0.82, 0.38, 1.34),
			"WheelBR": Vector3(0.82, 0.38, 1.34),
		}
		for wname in wheel_updates:
			var wnode = car_node.get_node_or_null(wname)
			if wnode:
				wnode.position = wheel_updates[wname]
				wnode.wheel_radius = 0.34
				# Hide old wheel meshes
				var wmesh = wnode.get_node_or_null("WheelMesh")
				if wmesh:
					wmesh.visible = false
				print("[UPGRADE] Updated ", wname, " pos=", wheel_updates[wname])

		# Update headlight positions for sedan front
		var hl_l = car_node.get_node_or_null("HeadlightL")
		var hl_r = car_node.get_node_or_null("HeadlightR")
		if hl_l:
			hl_l.position = Vector3(-0.7, 0.55, -2.0)
		if hl_r:
			hl_r.position = Vector3(0.7, 0.55, -2.0)

		# Update chase camera for slightly taller sedan
		var cam = car_node.get_node_or_null("ChaseCamera")
		if cam:
			cam.position = Vector3(0, 2.6, 6.2)

	else:
		printerr("[UPGRADE] DrivableCar node not found in arena!")

	# ---------- 4. SAVE UPGRADED SCENE ----------
	var packed = PackedScene.new()
	var err = packed.pack(arena)
	if err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/environments/CityCarZombieArena.tscn")
		if save_err == OK:
			print("[SUCCESS] Upgraded CityCarZombieArena.tscn saved!")
		else:
			printerr("[ERROR] Failed to save: ", save_err)
	else:
		printerr("[ERROR] Failed to pack: ", err)

	arena.queue_free()
	quit(0)

func _set_owner_recursive(node: Node, new_owner: Node):
	for child in node.get_children():
		child.owner = new_owner
		_set_owner_recursive(child, new_owner)

func _find_node_by_name(node: Node, target: String) -> Node3D:
	if node.name == target and node is Node3D:
		return node
	for c in node.get_children():
		var res = _find_node_by_name(c, target)
		if res:
			return res
	return null
