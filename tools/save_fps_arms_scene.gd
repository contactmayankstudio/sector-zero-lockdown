extends SceneTree

func _init():
	var mat_camo = load("res://resources/materials/mat_player.tres")
	var mat_skin = load("res://resources/materials/mat_skin.tres")
	var glove_scn = load("res://assets/3d/weapons/downloaded/black_gloves.glb")
	
	var root_node = Node3D.new()
	root_node.name = "fps_arms"
	
	# 1. Right Hand (Holding weapon grip)
	var right_hand = Node3D.new()
	right_hand.name = "RightHand"
	var rh_b = Basis(
		Vector3(0.422618, -0.453154, 0.784886),
		Vector3(0.784886, 0.586824, -0.203173),
		Vector3(-0.453154, 0.594738, 0.663414)
	)
	right_hand.transform = Transform3D(rh_b, Vector3(0.04, -0.1, 0.02))
	root_node.add_child(right_hand)
	right_hand.owner = root_node
	
	var right_glove = glove_scn.instantiate()
	right_glove.name = "RightGlove"
	right_glove.scale = Vector3(-0.48, 0.48, 0.48)
	right_hand.add_child(right_glove)
	right_glove.owner = root_node
	
	# Right Wrist (Skin) - Placed directly along local -Y cuff
	var rw = MeshInstance3D.new()
	rw.name = "RightWrist"
	var rw_cyl = CylinderMesh.new()
	rw_cyl.top_radius = 0.042
	rw_cyl.bottom_radius = 0.045
	rw_cyl.height = 0.04
	rw_cyl.radial_segments = 16
	rw.mesh = rw_cyl
	rw.material_override = mat_skin
	rw.position = Vector3(0, -0.185, 0.008)
	right_hand.add_child(rw)
	rw.owner = root_node
	
	# Right Forearm Sleeve (SWAT Camo) - Extends along local -Y towards body
	var rs = MeshInstance3D.new()
	rs.name = "RightForearm"
	var rs_cyl = CylinderMesh.new()
	rs_cyl.top_radius = 0.046
	rs_cyl.bottom_radius = 0.068
	rs_cyl.height = 0.40
	rs_cyl.radial_segments = 16
	rs.mesh = rs_cyl
	rs.material_override = mat_camo
	rs.position = Vector3(0, -0.39, 0.008)
	right_hand.add_child(rs)
	rs.owner = root_node
	
	# 2. Left Hand (Holding/supporting weapon)
	var left_hand = Node3D.new()
	left_hand.name = "LeftHand"
	var lh_b = Basis(
		Vector3(0.321394, 0.766044, -0.55667),
		Vector3(-0.55667, 0.642788, 0.526848),
		Vector3(0.766044, 0, 0.642788)
	)
	left_hand.transform = Transform3D(lh_b, Vector3(0.015, -0.075, -0.18))
	root_node.add_child(left_hand)
	left_hand.owner = root_node
	
	var left_glove = glove_scn.instantiate()
	left_glove.name = "LeftGlove"
	left_glove.scale = Vector3(0.44, 0.44, 0.44)
	left_hand.add_child(left_glove)
	left_glove.owner = root_node
	
	# Left Wrist (Skin) - Placed directly along local -Y cuff
	var lw = MeshInstance3D.new()
	lw.name = "LeftWrist"
	var lw_cyl = CylinderMesh.new()
	lw_cyl.top_radius = 0.040
	lw_cyl.bottom_radius = 0.043
	lw_cyl.height = 0.04
	lw_cyl.radial_segments = 16
	lw.mesh = lw_cyl
	lw.material_override = mat_skin
	lw.position = Vector3(0, -0.175, 0.008)
	left_hand.add_child(lw)
	lw.owner = root_node
	
	# Left Forearm Sleeve (SWAT Camo) - Extends along local -Y towards body
	var ls = MeshInstance3D.new()
	ls.name = "LeftForearm"
	var ls_cyl = CylinderMesh.new()
	ls_cyl.top_radius = 0.044
	ls_cyl.bottom_radius = 0.065
	ls_cyl.height = 0.40
	ls_cyl.radial_segments = 16
	ls.mesh = ls_cyl
	ls.material_override = mat_camo
	ls.position = Vector3(0, -0.38, 0.008)
	left_hand.add_child(ls)
	ls.owner = root_node
	
	var ps = PackedScene.new()
	ps.pack(root_node)
	var err = ResourceSaver.save(ps, "res://scenes/weapons/models/fps_arms.tscn")
	print("Saved clean fps_arms.tscn! Result: ", err)
	quit(0)
