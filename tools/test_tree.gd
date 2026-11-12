@tool
extends SceneTree

func _init():
	var tree = Node3D.new()
	tree.name = "TestTree"
	
	# Trunk
	var trunk = MeshInstance3D.new()
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.38
	trunk_mesh.height = 3.5
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0, 1.75, 0)
	tree.add_child(trunk)
	
	# Foliage layers
	var grass_mat = load("res://resources/materials/mat_real_grass_pbr.tres")
	for i in range(3):
		var foliage = MeshInstance3D.new()
		var cone = CylinderMesh.new()
		cone.top_radius = 0.05
		cone.bottom_radius = 2.4 - (i * 0.45)
		cone.height = 2.6
		foliage.mesh = cone
		foliage.position = Vector3(0, 3.2 + (i * 1.5), 0)
		foliage.material_override = grass_mat
		tree.add_child(foliage)
		
	print("Procedural tree created successfully with ", tree.get_child_count(), " parts!")
	quit(0)
