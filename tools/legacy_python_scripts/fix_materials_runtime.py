import re

def patch_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # The block we injected previously in ArmoryUI.gd:
    old_armory = """	var m1 = load("res://resources/materials/mat_weapon.tres")
	if m1:
		for mi in meshes_found:
			if mi.mesh:
				for i in range(mi.mesh.get_surface_count()):
					mi.set_surface_override_material(i, m1)"""
    
    new_armory = """	for mi in meshes_found:
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
    
    if old_armory in content:
        content = content.replace(old_armory, new_armory)
    
    with open(filepath, "w") as f:
        f.write(content)

patch_file("scripts/UI/ArmoryUI.gd")

def patch_player(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    old_player = """				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = load("res://resources/materials/mat_weapon.tres")"""

    new_player = """				var wm = model_res
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
    
    if old_player in content:
        content = content.replace(old_player, new_player)
    
    with open(filepath, "w") as f:
        f.write(content)

patch_player("scripts/Characters/Player.gd")

