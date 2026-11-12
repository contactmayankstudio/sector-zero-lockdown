import re

# Clean ArmoryUI.gd
with open("scripts/UI/ArmoryUI.gd", "r") as f:
    content = f.read()

hack_armory = """	for mi in meshes_found:
		if mi.mesh:
			for i in range(mi.mesh.get_surface_count()):
				var mat = mi.mesh.surface_get_material(i)
				if mat and mat is StandardMaterial3D:
					var new_mat = mat.duplicate()
					var mat_name = new_mat.resource_name.to_lower()
					if "wood" in mat_name:
						new_mat.metallic = 0.1
						new_mat.roughness = 0.4
					elif "rubber" in mat_name or "polymer" in mat_name:
						new_mat.metallic = 0.2
						new_mat.roughness = 0.6
					else:
						new_mat.metallic = 0.85
						new_mat.roughness = 0.25
					mi.set_surface_override_material(i, new_mat)"""

content = content.replace(hack_armory, "")

with open("scripts/UI/ArmoryUI.gd", "w") as f:
    f.write(content)

# Clean Player.gd
with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

hack_player = """				var wm = model_res
				w.get_node("MeshInstance3D").mesh = wm
				w.get_node("MeshInstance3D").material_override = null
				for i in range(wm.get_surface_count()):
					var mat = wm.surface_get_material(i)
					if mat and mat is StandardMaterial3D:
						var new_mat = mat.duplicate()
						var mat_name = new_mat.resource_name.to_lower()
						if "wood" in mat_name:
							new_mat.metallic = 0.1
							new_mat.roughness = 0.4
						elif "rubber" in mat_name or "polymer" in mat_name:
							new_mat.metallic = 0.2
							new_mat.roughness = 0.6
						else:
							new_mat.metallic = 0.85
							new_mat.roughness = 0.25
						w.get_node("MeshInstance3D").set_surface_override_material(i, new_mat)"""

correct_player = """				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = null"""

content = content.replace(hack_player, correct_player)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
