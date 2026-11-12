@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/environments/CityCarZombieArena.tscn")
	var inst = scn.instantiate()
	var car = inst.get_node_or_null("DrivableCar")
	if car:
		print("Car pos: ", car.position)
		for c in car.get_children():
			var vis = c.visible if c is Node3D else "N/A"
			print("  Car child: ", c.name, " (", c.get_class(), ") visible=", vis)
			if c.name == "SedanRealisticBody":
				print("    Sedan children count: ", c.get_child_count())
				for sc in c.get_children():
					print("      sedan sub: ", sc.name, " (", sc.get_class(), ") visible=", sc.visible if sc is Node3D else "N/A")
	quit()
