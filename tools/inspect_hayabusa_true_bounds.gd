@tool
extends SceneTree

func _init():
	var scn = load("res://assets/downloaded_bikes/hayabusa.glb")
	var inst = scn.instantiate()
	
	# Compute world transform of each node manually by accumulating transforms
	_accumulate_transforms(inst, Transform3D.IDENTITY)
	
	var min_pt = Vector3(1e9, 1e9, 1e9)
	var max_pt = Vector3(-1e9, -1e9, -1e9)
	
	var meshes = []
	_gather_meshes(inst, meshes)
	
	print("Found %d meshes." % meshes.size())
	for item in meshes:
		var mi: MeshInstance3D = item.node
		var xf: Transform3D = item.xf
		var m: Mesh = mi.mesh
		var aabb = xf * mi.get_aabb()
		min_pt = min_pt.min(aabb.position)
		max_pt = max_pt.max(aabb.end)
		print("Mesh: %s, World AABB: pos=%s, size=%s" % [mi.name, aabb.position, aabb.size])
		
	print("TOTAL BOUNDS: min=%s, max=%s, size=%s" % [min_pt, max_pt, max_pt - min_pt])
	
	# Find front and back positions
	var wf = _find_node_and_xf(inst, Transform3D.IDENTITY, "Wheel_F")
	var wb = _find_node_and_xf(inst, Transform3D.IDENTITY, "Wheel_B")
	if wf.node:
		print("Wheel_F origin: ", wf.xf.origin)
	if wb.node:
		print("Wheel_B origin: ", wb.xf.origin)
	var glasses = _find_node_and_xf(inst, Transform3D.IDENTITY, "glasses")
	if glasses.node:
		print("Glasses origin: ", glasses.xf.origin)

	inst.free()
	quit(0)

func _accumulate_transforms(node: Node, parent_xf: Transform3D):
	var curr_xf = parent_xf
	if node is Node3D:
		curr_xf = parent_xf * node.transform
		node.set_meta("calc_xf", curr_xf)
	for c in node.get_children():
		_accumulate_transforms(c, curr_xf)

func _gather_meshes(node: Node, list: Array):
	if node is MeshInstance3D and node.mesh:
		var xf = node.get_meta("calc_xf", Transform3D.IDENTITY)
		list.append({"node": node, "xf": xf})
	for c in node.get_children():
		_gather_meshes(c, list)

func _find_node_and_xf(node: Node, parent_xf: Transform3D, name_substr: String) -> Dictionary:
	var curr_xf = parent_xf
	if node is Node3D:
		curr_xf = parent_xf * node.transform
	if node.name.contains(name_substr):
		return {"node": node, "xf": curr_xf}
	for c in node.get_children():
		var res = _find_node_and_xf(c, curr_xf, name_substr)
		if res.node:
			return res
	return {"node": null, "xf": Transform3D.IDENTITY}
