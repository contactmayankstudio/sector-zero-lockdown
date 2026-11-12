extends SceneTree

func _init():
	print("--- CHECKING PREFAB COLLIDERS ---")
	for path in ["res://scenes/environments/models/RealCityBuildings8.scn", "res://scenes/environments/models/RealStreet6.scn"]:
		var s = load(path)
		if s:
			var inst = s.instantiate()
			print("Inspecting: ", path)
			_find_colliders(inst)
	quit(0)

func _find_colliders(n: Node):
	if n is CollisionShape3D or n is StaticBody3D or n is Area3D:
		print("  FOUND: ", n.name, " class: ", n.get_class(), " pos: ", n.position)
		if n is CollisionShape3D and n.shape:
			print("    Shape: ", n.shape.get_class())
	for c in n.get_children():
		_find_colliders(c)
