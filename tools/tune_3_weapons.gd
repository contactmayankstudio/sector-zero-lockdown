extends SceneTree

func _init():
	print("--- TUNING NEGEV, AKX, AND N7 ---")
	
	# Inspect Negev: where are the vertices located?
	var ng_scn = load("res://scenes/weapons/models/negev_ng7.scn")
	var ng = ng_scn.instantiate()
	var ng_min = Vector3(999, 999, 999); var ng_max = Vector3(-999, -999, -999)
	for m in ng.find_children("*", "MeshInstance3D", true, false):
		if not m.mesh: continue
		var aabb = m.transform * m.get_aabb()
		ng_min.x = min(ng_min.x, aabb.position.x); ng_min.y = min(ng_min.y, aabb.position.y); ng_min.z = min(ng_min.z, aabb.position.z)
		ng_max.x = max(ng_max.x, aabb.end.x); ng_max.y = max(ng_max.y, aabb.end.y); ng_max.z = max(ng_max.z, aabb.end.z)
	print("Negev in scn: min=", ng_min, " max=", ng_max, " center=", (ng_min + ng_max)*0.5, " size=", ng_max - ng_min)
	ng.free()

	# Inspect N7: where are the vertices located?
	var n7_scn = load("res://scenes/weapons/models/n7_rifle.scn")
	var n7 = n7_scn.instantiate()
	var n7_min = Vector3(999, 999, 999); var n7_max = Vector3(-999, -999, -999)
	for m in n7.find_children("*", "MeshInstance3D", true, false):
		if not m.mesh: continue
		var aabb = m.transform * m.get_aabb()
		n7_min.x = min(n7_min.x, aabb.position.x); n7_min.y = min(n7_min.y, aabb.position.y); n7_min.z = min(n7_min.z, aabb.position.z)
		n7_max.x = max(n7_max.x, aabb.end.x); n7_max.y = max(n7_max.y, aabb.end.y); n7_max.z = max(n7_max.z, aabb.end.z)
	print("N7 in scn: min=", n7_min, " max=", n7_max, " center=", (n7_min + n7_max)*0.5, " size=", n7_max - n7_min)
	n7.free()

	# Inspect AKX: test rotation to point forward
	# In weapon_refined_akx_scifi.png: rot was (-88.5, 180, 0) and barrel was pointing UP (+Y in camera)
	# To make it point forward (-Z in camera), we need to pitch forward by 90 degrees!
	# Current rot (-90, 180, 0) + 90 on X? or (0, 180, 0)? or (90, 0, 0)?
	var akx_scn = load("res://scenes/weapons/models/akx_scifi.scn")
	var akx = akx_scn.instantiate()
	for rx in [0, 90, -90]:
		for ry in [0, 90, 180, -90]:
			var b = Basis.from_euler(Vector3(deg_to_rad(rx), deg_to_rad(ry), 0))
			var fwd = b * Vector3(0, -1, 0)
			var up = b * Vector3(0, 0, 1)
			if fwd.z < -0.8 and up.y > 0.8:
				print("AKX forward candidate: rx=", rx, " ry=", ry, " fwd=", fwd, " up=", up)
	akx.free()
	
	quit(0)
