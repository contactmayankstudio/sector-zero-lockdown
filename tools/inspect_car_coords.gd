@tool
extends SceneTree

func _init():
	var s = load("res://scenes/environments/props/PoliceCarProp.scn")
	if s:
		var inst = s.instantiate()
		var aabb = AABB()
		var first = true
		for c in inst.find_children("*", "MeshInstance3D"):
			if c is MeshInstance3D and c.mesh:
				var m_aabb = c.get_transformed_aabb() if c.has_method("get_transformed_aabb") else c.mesh.get_aabb()
				if first:
					aabb = m_aabb
					first = false
				else:
					aabb = aabb.merge(m_aabb)
		print("PoliceCar AABB: size=", aabb.size, " center=", aabb.get_center())
		inst.free()
	quit(0)
