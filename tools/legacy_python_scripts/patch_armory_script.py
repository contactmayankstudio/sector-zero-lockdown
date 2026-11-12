import re

with open("scripts/UI/ArmoryUI.gd", "r") as f:
    content = f.read()

# find _setup_active_mesh and add material override
injection = """
	var m1 = load("res://resources/materials/mat_weapon.tres")
	if m1:
		for mi in meshes_found:
			if mi.mesh:
				for i in range(mi.mesh.get_surface_count()):
					mi.set_surface_override_material(i, m1)
"""

content = re.sub(r'(for mi in meshes_found:\n\t\tif mi\.mesh:)', injection + r'\1', content)

with open("scripts/UI/ArmoryUI.gd", "w") as f:
    f.write(content)
