@tool
extends SceneTree

func _init():
	print("Starting conversion of new pro environments...")
	
	_convert_glb("/home/am/Downloads/envarment/old_metro_tunnel_free.glb", "res://scenes/environments/models/OldMetroTunnel.scn")
	_convert_glb("/home/am/Downloads/envarment/horror_corridor_vr_room_baked.glb", "res://scenes/environments/models/HorrorCorridor.scn")
	_convert_glb("/home/am/Downloads/envarment/old_bar.glb", "res://scenes/environments/models/OldBar.scn")
	_convert_glb("/home/am/Downloads/envarment/castle_of_loarre.glb", "res://scenes/environments/models/CastleLoarre.scn")
	_convert_glb("/home/am/Downloads/envarment/abandoned_alley/scene.gltf", "res://scenes/environments/models/AbandonedAlley.scn")
	_convert_glb("/home/am/Downloads/envarment/fixed_new_york_highway_interstate_95.glb", "res://scenes/environments/models/NYHighway.scn")
	
	print("All conversions finished!")
	quit(0)

func _convert_glb(src_path: String, dst_path: String):
	print("\nConverting: ", src_path.get_file(), " -> ", dst_path.get_file())
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(src_path, state)
	if err != OK:
		print("  ERROR appending GLTF: ", err)
		return
	var scene = doc.generate_scene(state)
	if not scene:
		print("  ERROR generating scene")
		return
	
	_set_owner_recursive(scene, scene)
	
	var packed = PackedScene.new()
	var pack_err = packed.pack(scene)
	if pack_err != OK:
		print("  ERROR packing scene: ", pack_err)
		scene.free()
		return
		
	var save_err = ResourceSaver.save(packed, dst_path, ResourceSaver.FLAG_COMPRESS)
	print("  Saved: ", dst_path, " (err code: ", save_err, ")")
	scene.free()

func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root
		_set_owner_recursive(child, root)
