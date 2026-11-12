@tool
extends SceneTree

func _init():
	print("--- Running CityCarZombieArena Runtime Test ---")
	var scene = load("res://scenes/environments/CityCarZombieArena.tscn")
	if not scene:
		print("FAILED: Cannot load CityCarZombieArena.tscn")
		quit(1)
		return
	
	var arena = scene.instantiate()
	get_root().add_child(arena)
	
	# Wait for ready
	print("Arena node inside tree: ", arena.is_inside_tree())
	print("Checking DirectionalLight3D runtime values:")
	var dl = arena.get_node("DirectionalLight3D") as DirectionalLight3D
	print("  Energy: ", dl.light_energy)
	print("  Color: ", dl.light_color)
	print("  Rotation: ", dl.rotation_degrees)
	print("  Shadow Mode: ", dl.directional_shadow_mode)
	print("  Shadow Blend Splits: ", dl.directional_shadow_blend_splits)
	print("  Shadow Max Distance: ", dl.directional_shadow_max_distance)

	print("Checking WorldEnvironment runtime values:")
	var we = arena.get_node("WorldEnvironment") as WorldEnvironment
	var env = we.environment
	print("  Tonemap: ", env.tonemap_mode)
	print("  Exposure: ", env.tonemap_exposure)
	print("  Glow Enabled: ", env.glow_enabled)
	print("  Glow Bloom: ", env.glow_bloom)
	print("  Glow Blend Mode: ", env.glow_blend_mode)
	print("  Fog Color: ", env.fog_light_color)
	print("  Ambient Color: ", env.ambient_light_color)

	print("Checking FoliageAndProps MultiMeshes:")
	var fap = arena.get_node("AdvancedTerrain/FoliageAndProps")
	for child in fap.get_children():
		if child is MultiMeshInstance3D:
			print("  ", child.name, " -> Instances: ", child.multimesh.instance_count, " | Cast Shadow: ", child.cast_shadow)

	print("--- Runtime Test Completed Successfully ---")
	arena.queue_free()
	quit(0)
