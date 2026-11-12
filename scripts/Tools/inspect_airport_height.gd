@tool
extends SceneTree

func _init():
	var scene = load("res://scenes/environments/AirportTerminal.tscn")
	var inst = scene.instantiate()
	root.add_child(inst)
	
	var glb = inst.find_child("AirportTerminalGLB", true, false)
	if glb:
		var meshes = glb.find_children("*", "MeshInstance3D", true, false)
		for m in meshes:
			if "floor" in m.name.to_lower() or "ground" in m.name.to_lower():
				var aabb = m.global_transform * m.mesh.get_aabb()
				print("GLB Floor Mesh: ", m.name, " aabb: ", aabb)
	
	var nav = inst.find_child("NavigationRegion3D", true, false)
	if nav:
		var gr = nav.find_child("Ground", true, false)
		if gr:
			print("Nav Ground pos: ", gr.global_position)
	
	# Also inspect Player pos
	var p = inst.find_child("Player", true, false)
	if p:
		print("Player pos: ", p.global_position)
		
	quit()
