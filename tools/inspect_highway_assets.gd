@tool
extends SceneTree

func _init():
	var files = [
		"res://assets/roads_kit/glb/sign-highway-detailed.glb",
		"res://assets/roads_kit/glb/sign-highway-wide.glb",
		"res://assets/roads_kit/glb/road-straight-barrier.glb",
		"res://assets/roads_kit/glb/road-bridge.glb"
	]
	for p in files:
		if not ResourceLoader.exists(p):
			print("Missing: ", p)
			continue
		var s = load(p)
		var inst = s.instantiate()
		var meshes = inst.find_children("*", "MeshInstance3D", true, false)
		var tris = 0
		for m in meshes:
			if m.mesh:
				for i in range(m.mesh.get_surface_count()):
					tris += m.mesh.surface_get_array_len(i) / 3
		print(p.get_file(), " -> tris: ", tris, " | meshes: ", meshes.size())
		inst.free()
	quit()
