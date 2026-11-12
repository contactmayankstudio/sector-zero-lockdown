import re

with open("resources/materials/mat_weapon.tres", "r") as f:
    content = f.read()

# Make it look like high-quality dark gunmetal
content = re.sub(r'metallic = [^\n]+', 'metallic = 1.0\nmetallic_specular = 0.8', content)
content = re.sub(r'roughness = [^\n]+', 'roughness = 0.25\nalbedo_color = Color(0.65, 0.65, 0.7, 1.0)\nclearcoat_enabled = true\nclearcoat_roughness = 0.15\nanisotropy_enabled = true\nanisotropy = 0.5', content)

with open("resources/materials/mat_weapon.tres", "w") as f:
    f.write(content)
print("Updated mat_weapon.tres")
