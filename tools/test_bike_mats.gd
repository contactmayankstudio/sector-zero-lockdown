@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	_tune_bike_materials(inst)
	print("Tune bike materials completed successfully!")
	inst.free()
	quit(0)

func _tune_bike_materials(root_node: Node3D):
	var chrome_mat = StandardMaterial3D.new()
	chrome_mat.resource_name = "ChromeExhaust"
	chrome_mat.albedo_color = Color(0.92, 0.94, 0.96)
	chrome_mat.metallic = 0.98
	chrome_mat.roughness = 0.10

	var stack = [root_node]
	while stack.size() > 0:
		var curr = stack.pop_back()
		if curr is MeshInstance3D and curr.mesh:
			for i in range(curr.mesh.get_surface_count()):
				var mat = curr.get_surface_override_material(i)
				if not mat:
					mat = curr.mesh.surface_get_material(i)
				if mat is StandardMaterial3D:
					var m_dup = mat.duplicate()
					var m_name = mat.resource_name
					var node_name = curr.name.to_lower()
					
					if node_name.contains("crome") or node_name.contains("exhaust"):
						curr.set_surface_override_material(i, chrome_mat)
						print("Applied chrome to: ", curr.name)
					elif m_name == "Material.001":
						# Metallic superbike paint & fairings
						m_dup.metallic = 0.85
						m_dup.roughness = 0.22
						m_dup.clearcoat_enabled = true
						m_dup.clearcoat = 1.0
						m_dup.clearcoat_roughness = 0.1
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.003":
						# Mechanical details & alloy rims
						m_dup.metallic = 0.70
						m_dup.roughness = 0.30
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.004" or node_name.contains("glass"):
						# Smoked aerodynamic visor
						m_dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						m_dup.albedo_color = Color(0.1, 0.15, 0.22, 0.4)
						m_dup.metallic = 0.3
						m_dup.roughness = 0.05
						m_dup.cull_mode = BaseMaterial3D.CULL_DISABLED
						curr.set_surface_override_material(i, m_dup)
					elif m_name == "Material.005" or node_name.contains("tyre") or node_name.contains("tire"):
						# Matte rubber tires
						m_dup.albedo_color = Color(0.10, 0.10, 0.10, 1.0)
						m_dup.metallic = 0.0
						m_dup.roughness = 0.90
						curr.set_surface_override_material(i, m_dup)
					else:
						curr.set_surface_override_material(i, m_dup)
		for c in curr.get_children():
			stack.push_back(c)
