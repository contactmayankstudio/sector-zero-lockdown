@tool
extends SceneTree

func _init():
	var scene = load("res://assets/3d/environments/airport_terminal.glb")
	var inst = scene.instantiate()
	var meshes = inst.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		print("Mesh: ", m.name, " pos: ", m.position, " aabb: ", m.mesh.get_aabb() if m.mesh else "null")
	quit()
