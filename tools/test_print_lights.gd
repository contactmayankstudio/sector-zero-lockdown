extends SceneTree

func _init():
	var root = Node3D.new()
	get_root().add_child(root)
	var scn = load("res://scenes/environments/DeadTargetQuarantine.tscn")
	var level = scn.instantiate()
	root.add_child(level)
	
	var lights = level.find_children("*", "Light3D", true, false)
	print("--- TOTAL LIGHTS: ", lights.size(), " ---")
	for l in lights:
		var p_name = l.get_parent().name if l.get_parent() else "none"
		print("LIGHT: ", l.name, " (parent: ", p_name, ") class=", l.get_class(), " vis=", l.visible)
	quit(0)
