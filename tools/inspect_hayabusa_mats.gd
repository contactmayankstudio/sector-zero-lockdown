@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	
	print("--- Hayabusa Structure ---")
	_dump(inst, 0)
	
	# Check orientation: where is front wheel vs back wheel?
	var wf = inst.find_child("Wheel_F", true, false)
	var wb = inst.find_child("Wheel_B", true, false)
	if wf:
		print("Wheel_F global pos: ", wf.global_position)
	if wb:
		print("Wheel_B global pos: ", wb.global_position)
		
	# Check materials in the scene
	var mats = {}
	_collect_materials(inst, mats)
	print("\n--- Materials in Hayabusa ---")
	for m_name in mats.keys():
		var m = mats[m_name]
		print("Material name: ", m_name)
		if m is StandardMaterial3D:
			print("  albedo_color: ", m.albedo_color)
			print("  albedo_texture: ", m.albedo_texture.resource_path if m.albedo_texture else "None")
			print("  metallic: ", m.metallic, " roughness: ", m.roughness)
			print("  metallic_texture: ", m.metallic_texture.resource_path if m.metallic_texture else "None")
			print("  roughness_texture: ", m.roughness_texture.resource_path if m.roughness_texture else "None")
			print("  normal_enabled: ", m.normal_enabled)
	
	inst.free()
	quit(0)

func _dump(node: Node, depth: int):
	if depth > 4: return
	var indent = "  ".repeat(depth)
	var pos = ""
	if node is Node3D:
		pos = " pos=%s rot=%s" % [node.position, node.rotation_degrees]
	print("%s%s (%s)%s" % [indent, node.name, node.get_class(), pos])
	for c in node.get_children():
		_dump(c, depth + 1)

func _collect_materials(node: Node, mats: Dictionary):
	if node is MeshInstance3D and node.mesh:
		for i in range(node.mesh.get_surface_count()):
			var m = node.get_surface_override_material(i)
			if not m:
				m = node.mesh.surface_get_material(i)
			if m and not mats.has(m.resource_name):
				mats[m.resource_name] = m
	for c in node.get_children():
		_collect_materials(c, mats)
