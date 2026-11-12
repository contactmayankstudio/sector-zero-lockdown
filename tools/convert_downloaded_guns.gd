@tool
extends SceneTree

func _init():
	print("Converting downloaded guns to .scn...")
	
	_convert_glb("/home/am/Downloads/gun/gold_primordium_vandal__valorant.glb", "res://scenes/weapons/models/primordium_vandal.scn")
	_convert_glb("/home/am/Downloads/gun/apex_legends_prowler_smg_liquid_cooled_reactive.glb", "res://scenes/weapons/models/prowler_smg.scn")
	_convert_glb("/home/am/Downloads/gun/ray_gun_-_call_of_duty.glb", "res://scenes/weapons/models/ray_gun_cod.scn")
	_convert_glb("/home/am/Downloads/gun/plasma_gun.glb", "res://scenes/weapons/models/plasma_gun.scn")
	_convert_glb("/home/am/Downloads/gun/rocket_launcher.glb", "res://scenes/weapons/models/rocket_launcher.scn")
	_convert_glb("/home/am/Downloads/gun/pestilence_retro_sci-fi_handgun.glb", "res://scenes/weapons/models/pestilence_handgun.scn")
	
	print("Finished converting downloaded guns!")
	quit(0)

func _convert_glb(src_path: String, dst_path: String):
	print("\nConverting: ", src_path.get_file(), " -> ", dst_path.get_file())
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(src_path, state)
	if err != OK:
		print("  ERR appending: ", err)
		return
	var scene = doc.generate_scene(state)
	if not scene:
		print("  ERR generating scene")
		return
		
	_set_owner_recursive(scene, scene)
	var packed = PackedScene.new()
	var pack_err = packed.pack(scene)
	if pack_err != OK:
		print("  ERR packing: ", pack_err)
		scene.free()
		return
		
	var save_err = ResourceSaver.save(packed, dst_path, ResourceSaver.FLAG_COMPRESS)
	print("  Saved: ", dst_path, " (code: ", save_err, ")")
	scene.free()

func _set_owner_recursive(node: Node, root: Node):
	for c in node.get_children():
		c.owner = root
		_set_owner_recursive(c, root)
