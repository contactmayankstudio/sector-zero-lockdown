extends SceneTree

func _init():
	var res = load("res://scenes/weapons/models/negev_ng7.scn")
	var inst = res.instantiate()
	
	# In negev_ng7, find where the barrel tip is and where the stock is in raw mesh local space!
	# Flash hider / muzzle tip vs buttstock
	var min_x_pt = Vector3(999, 999, 999)
	var max_x_pt = Vector3(-999, -999, -999)
	
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		if m.mesh:
			var a = m.transform * m.mesh.get_aabb()
			if a.position.x < min_x_pt.x:
				min_x_pt = a.position
			if a.end.x > max_x_pt.x:
				max_x_pt = a.end
				
	print("Negev Min X Point (Muzzle): ", min_x_pt)
	print("Negev Max X Point (Stock): ", max_x_pt)
	
	# The barrel/muzzle is at negative X (-0.355) and stock is at positive X (+0.35)
	# We want the barrel (-X) to point along -Z (camera forward)
	# And we want the top (+Y) to point along +Y (up)
	# And we want the left/right (+Z) to point along +X (right)
	#
	# If vector V is in weapon space:
	# Forward direction (Muzzle): V_muzzle = (-1, 0, 0)
	# Up direction (Sights): V_up = (0, 1, 0)
	# Right direction: V_right = (0, 0, 1)
	#
	# In Camera space, we want:
	# Muzzle to point along (0, 0, -1) [Forward]
	# Up to point along (0, 1, 0) [Up]
	# Right to point along (1, 0, 0) [Right]
	#
	# Therefore:
	# Transform * (-1, 0, 0) = (0, 0, -1)  => Transform * (1, 0, 0) = (0, 0, 1)
	# Transform * (0, 1, 0) = (0, 1, 0)
	# Transform * (0, 0, 1) = (1, 0, 0)
	#
	# Basis columns:
	# col 0 (X basis) = (0, 0, 1)
	# col 1 (Y basis) = (0, 1, 0)
	# col 2 (Z basis) = (-1, 0, 0)   (since col0 x col1 = (0, 0, 1) x (0, 1, 0) = (-1, 0, 0))
	#
	# This corresponds to a rotation!
	var target_basis = Basis(Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(-1, 0, 0))
	var euler_deg = target_basis.get_euler() * (180.0 / PI)
	print("Computed target Basis: ", target_basis)
	print("Euler degrees: ", euler_deg)
	
	inst.free()
	quit(0)
