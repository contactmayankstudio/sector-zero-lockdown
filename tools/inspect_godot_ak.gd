extends SceneTree

func _init():
	var s = load("res://scenes/weapons/models/AK74uClean.scn") as PackedScene
	if not s:
		print("Failed to load AK74uClean.scn")
		quit(1)
		return
	var inst = s.instantiate()
	print("Root: ", inst.name, " (", inst.get_class(), ")")
	_inspect(inst, 0)
	inst.free()
	quit(0)

func _inspect(node: Node, indent: int):
	var prefix = "  ".repeat(indent)
	var extra = ""
	if node is VisualInstance3D:
		var aabb = (node as VisualInstance3D).get_aabb()
		extra = " aabb: " + str(aabb)
	if node is Node3D:
		extra += " pos: " + str((node as Node3D).position) + " rot: " + str((node as Node3D).rotation_degrees)
	print(prefix, "- ", node.name, " (", node.get_class(), ")", extra)
	for c in node.get_children():
		_inspect(c, indent + 1)
