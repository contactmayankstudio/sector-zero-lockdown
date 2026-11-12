@tool
extends SceneTree

func _init():
	print("=== FIXING VACCINATOR MODEL ===")
	var vac_scn = load("res://scenes/weapons/models/vaccinator_energy.scn")
	var vac_inst = vac_scn.instantiate()
	
	# Find and remove duplicate skeleton_001
	var dup = vac_inst.find_child("c_medigun_defense_qc_skeleton_001", true, false)
	if dup:
		print("Removing duplicate skeleton_001...")
		dup.free()
		
	var skel = vac_inst.find_child("c_medigun_defense_qc_skeleton", true, false)
	if skel:
		print("Centering c_medigun_defense_qc_skeleton from %s to Vector3.ZERO..." % str(skel.position))
		skel.position = Vector3.ZERO
		
	var packed = PackedScene.new()
	_set_owner_recursive(vac_inst, vac_inst)
	packed.pack(vac_inst)
	ResourceSaver.save(packed, "res://scenes/weapons/models/vaccinator_energy.scn", ResourceSaver.FLAG_COMPRESS)
	print("Saved clean single-gun vaccinator_energy.scn!")
	vac_inst.free()
	quit(0)

func _set_owner_recursive(node: Node, new_owner: Node):
	if node != new_owner:
		node.owner = new_owner
	for child in node.get_children():
		_set_owner_recursive(child, new_owner)
