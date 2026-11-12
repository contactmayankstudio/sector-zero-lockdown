with open("scripts/Characters/Player.gd", "r") as f:
    content = f.read()

# Replace the elif block
old = """			elif model_res is Mesh:
				w.get_node("MeshInstance3D").mesh = model_res
"""
new = """			elif model_res is Mesh:
				w.get_node("MeshInstance3D").mesh = model_res
				w.get_node("MeshInstance3D").material_override = load("res://resources/materials/mat_weapon.tres")
"""
content = content.replace(old, new)

with open("scripts/Characters/Player.gd", "w") as f:
    f.write(content)
