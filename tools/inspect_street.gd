@tool
extends SceneTree

func _init():
	var g = load("res://assets/external/downloads/environments/low_poly_street_gameready_6.glb")
	if g:
		var inst = g.instantiate()
		print("Root children count: ", inst.get_child_count())
		for c in inst.get_children():
			print(" - ", c.name, " (", c.get_class(), ")")
	quit(0)
