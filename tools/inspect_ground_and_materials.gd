extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scn:
		print("Failed to load scene")
		quit(1)
		return
	var arena = scn.instantiate()
	get_root().add_child(arena)
	
	print("\n--- NODES UNDER AdvancedTerrain ---")
	var adv = arena.get_node_or_null("AdvancedTerrain")
	if adv:
		for c in adv.get_children():
			print("Child: ", c.name, " Class: ", c.get_class(), " pos=", c.position if c is Node3D else "")
			if c is MeshInstance3D:
				var m = c.get_surface_override_material(0)
				if not m and c.mesh:
					m = c.mesh.surface_get_material(0)
				if m is StandardMaterial3D:
					print("   -> Material: ", m.resource_name, " albedo_color=", m.albedo_color, " tex=", m.albedo_texture != null, " uv1_scale=", m.uv1_scale)
				elif m is ShaderMaterial:
					print("   -> ShaderMaterial")
				else:
					print("   -> Unknown/null material: ", m)
	
	print("\n--- NODES UNDER RealisticTerrain ---")
	var rt = arena.get_node_or_null("RealisticTerrain")
	if rt:
		for c in rt.get_children():
			print("Child: ", c.name, " Class: ", c.get_class(), " pos=", c.position if c is Node3D else "")
			if c is MeshInstance3D:
				var m = c.get_surface_override_material(0)
				if not m and c.mesh:
					m = c.mesh.surface_get_material(0)
				if m is StandardMaterial3D:
					print("   -> Material: ", m.resource_name, " albedo_color=", m.albedo_color, " tex=", m.albedo_texture != null, " uv1_scale=", m.uv1_scale)
	
	arena.queue_free()
	quit(0)
