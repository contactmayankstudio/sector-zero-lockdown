with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

old_block = """		# Set 3D model on weapon
		if w.has_node("MeshInstance3D") and ResourceLoader.exists(cfg.model):
			var model_res = load(cfg.model)
			if model_res is PackedScene:
				var wm = _extract_mesh_from_scene(model_res)
				if wm:
					w.get_node("MeshInstance3D").mesh = wm
					w.get_node("MeshInstance3D").material_override = null
			elif model_res is Mesh:
				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = null"""

new_block = """		# Set 3D model on weapon
		if ResourceLoader.exists(cfg.model):
			var model_res = load(cfg.model)
			if model_res is PackedScene:
				if w.has_node("MeshInstance3D"):
					w.get_node("MeshInstance3D").visible = false
				var model_inst = model_res.instantiate()
				model_inst.name = "CustomModel"
				# Position and orientation in first-person hands
				model_inst.position = Vector3(0, 0, 0)
				w.add_child(model_inst)
			elif model_res is Mesh and w.has_node("MeshInstance3D"):
				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = null"""

content = content.replace(old_block, new_block)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
print("Patched Player.gd model instantiation!")
