import re

with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

injection = """
		var m1 = load("res://resources/materials/mat_weapon.tres")
		if m1:
			var meshes = w_inst.find_children("*", "MeshInstance3D", true, false)
			if w_inst is MeshInstance3D: meshes.append(w_inst)
			for mi in meshes:
				if mi.mesh:
					for i in range(mi.mesh.get_surface_count()):
						mi.set_surface_override_material(i, m1)
"""

# Find where it instantiates the weapon in Player.gd
content = re.sub(r'(camera_pivot\.add_child\(w_inst\))', r'\1' + injection, content)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
