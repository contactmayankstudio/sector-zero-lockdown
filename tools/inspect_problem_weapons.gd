@tool
extends SceneTree

# Inspect internal transforms of the 5 problematic weapons
var problematic = [
	"retro_ray_gun",
	"scifi_battle_rifle",
	"prowl_blaster",
	"vaccinator_energy",
	"axon_cannon"
]

func _init():
	print("=== INSPECTING PROBLEMATIC WEAPON SCENES ===")
	for wid in problematic:
		var path = "res://scenes/weapons/models/%s.scn" % wid
		var scn = load(path)
		var inst = scn.instantiate()
		print("\n--- %s ---" % wid)
		_print_transforms(inst, 0, Transform3D.IDENTITY)
		inst.free()
	quit(0)

func _print_transforms(node: Node, depth: int, parent_t: Transform3D):
	var indent = "  ".repeat(depth)
	var local_t = Transform3D.IDENTITY
	if node is Node3D:
		local_t = parent_t * node.transform
		var extra = ""
		if node is MeshInstance3D and node.mesh:
			var aabb = node.get_aabb()
			var global_aabb = node.transform * aabb
			extra = " [Mesh AABB: %s, LocalAABB: %s]" % [str(aabb), str(global_aabb)]
		print("%s- %s (%s) | Pos: %s | Rot: %s | Scale: %s%s" % [
			indent, node.name, node.get_class(), str(node.position), str(node.rotation_degrees), str(node.scale), extra
		])
	else:
		print("%s- %s (%s)" % [indent, node.name, node.get_class()])
		
	for c in node.get_children():
		_print_transforms(c, depth + 1, local_t)
