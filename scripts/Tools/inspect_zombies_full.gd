@tool
extends SceneTree

func _init():
	var z1 = load("res://scenes/zombies/Zombie.tscn").instantiate()
	root.add_child(z1)
	print("--- Zombie.tscn ---")
	_inspect(z1, "")
	
	var z2 = load("res://assets/zombies/RealisticZombie.tscn").instantiate()
	root.add_child(z2)
	print("--- RealisticZombie.tscn ---")
	_inspect(z2, "")
	quit()

func _inspect(n: Node, indent: String):
	var vis = ""
	if n is Node3D:
		vis = " vis=" + str(n.visible) + " pos=" + str(n.position) + " scale=" + str(n.scale) + " rot=" + str(n.rotation_degrees)
	print(indent, n.name, " (", n.get_class(), ")", vis)
	for c in n.get_children():
		_inspect(c, indent + "  ")
