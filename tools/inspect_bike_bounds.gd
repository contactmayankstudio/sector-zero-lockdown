extends SceneTree

func _init():
	var bike_scene = load("res://scenes/vehicles/DrivableBike.tscn")
	var bike = bike_scene.instantiate()
	var vis = bike.find_child("VisualWrapper", true, false)
	print("Bike VisualWrapper found: ", vis != null)
	# Check meshes under VisualWrapper
	var meshes = vis.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		print("Mesh: ", m.name, " transform: ", m.transform, " aabb: ", m.mesh.get_aabb() if m.mesh else null)
	bike.queue_free()
	quit(0)
