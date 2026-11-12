@tool
extends SceneTree

func _init():
	for path in [
		"res://scenes/environments/models/RealStreet6.scn",
		"res://scenes/environments/props/PoliceCarProp.scn",
		"res://scenes/player/Player.tscn"
	]:
		var scn = load(path) as PackedScene
		if not scn:
			print("Could not load: ", path)
			continue
		var inst = scn.instantiate()
		var count = 0
		var stack = [inst]
		while not stack.is_empty():
			var curr = stack.pop_back()
			if curr is MeshInstance3D:
				count += 1
			for c in curr.get_children():
				stack.append(c)
		print(path, " -> meshes: ", count)
		inst.free()
	quit()
