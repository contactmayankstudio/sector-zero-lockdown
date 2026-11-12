extends SceneTree

func _init():
	var env_scenes = [
		"res://scenes/environments/AirportTerminal.tscn",
		"res://scenes/environments/AirportServiceRoad.tscn",
		"res://scenes/environments/UrbanStreet.tscn",
		"res://scenes/environments/RailwayStation.tscn",
		"res://scenes/environments/AbandonedTrain.tscn",
		"res://scenes/environments/DarkIndustrial.tscn",
		"res://scenes/environments/FinalLockdown.tscn"
	]
	
	print("--- INSPECTING 7 ENVIRONMENT SCENES FOR GROUND & LIGHTING ---")
	
	for path in env_scenes:
		var ps = load(path)
		var inst = ps.instantiate()
		print("\n=== ", path.get_file(), " ===")
		
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var lights = inst.find_children("*", "Light3D", true, false)
		var envs = inst.find_children("*", "WorldEnvironment", true, false)
		
		print("  Total MeshInstances: ", meshes.size())
		print("  Total Lights: ", lights.size())
		print("  WorldEnvironment present: ", not envs.is_empty())
		
		var ground_nodes = []
		for m in meshes:
			var nname = m.name.to_lower()
			if "ground" in nname or "floor" in nname or "road" in nname or "terrain" in nname or "platform" in nname or "asphalt" in nname:
				ground_nodes.append(m)
				
		print("  Ground / Floor nodes found: ", ground_nodes.size())
		for g in ground_nodes:
			var mat = g.material_override
			var m_mesh = g.mesh
			print("    - Node: ", g.name, " mesh: ", m_mesh.get_class() if m_mesh else "none", " material: ", mat.resource_path if mat else "default")
			
		inst.free()
	quit(0)
