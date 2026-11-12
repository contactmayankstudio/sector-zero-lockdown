@tool
extends SceneTree

func _init():
	var scn = load("res://scenes/environments/ZombieNightHighway.tscn") as PackedScene
	var root = scn.instantiate()
	print("--- INSPECTING SCENE NODES ---")
	for child in root.get_children():
		print("Child: ", child.name, " Type: ", child.get_class())
		if child is Node3D:
			print("   Pos: ", child.position)
	
	var ground = root.get_node("NavigationRegion3D/Ground")
	for g in ground.get_children():
		print(" Ground child: ", g.name, " Type: ", g.get_class())
		if g is MeshInstance3D and g.mesh:
			var aabb = g.mesh.get_aabb()
			print("   Mesh AABB: ", aabb, " Pos: ", g.position)
		elif g is CollisionShape3D and g.shape:
			print("   Col shape: ", g.shape.get_class(), " pos: ", g.position)

	root.free()
	quit(0)
