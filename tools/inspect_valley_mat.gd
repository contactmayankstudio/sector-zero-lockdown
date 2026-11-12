@tool
extends SceneTree

func _init():
	var s = load("res://scenes/environments/CityCarZombieArena.tscn")
	var inst = s.instantiate()
	var vm = inst.get_node_or_null("AdvancedTerrain/ValleyFloor") as MeshInstance3D
	if vm:
		print("ValleyFloor mesh: ", vm.mesh)
		var mat = vm.get_surface_override_material(0)
		print("Surface override material 0: ", mat)
		if not mat and vm.mesh:
			mat = vm.mesh.surface_get_material(0)
			print("Mesh surface material 0: ", mat)
		if mat is StandardMaterial3D:
			print("Albedo color: ", mat.albedo_color)
			print("Albedo texture: ", mat.albedo_texture)
			print("Normal texture: ", mat.normal_texture)
			print("Roughness texture: ", mat.roughness_texture)
			print("UV1 scale: ", mat.uv1_scale)
	inst.free()
	quit()
