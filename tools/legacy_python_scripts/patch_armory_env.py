import re

with open("scenes/UI/ArmoryUI.tscn", "r") as f:
    content = f.read()

# Add glow, ssr, ssao to environment
new_env = """ambient_light_energy = 0.8
tonemap_mode = 2
tonemap_exposure = 1.15
ssr_enabled = true
ssr_max_steps = 64
ssao_enabled = true
ssao_radius = 1.5
ssao_intensity = 2.0
glow_enabled = true
glow_intensity = 1.5
glow_bloom = 0.2
glow_blend_mode = 0
"""
content = re.sub(r'ambient_light_energy = 0.8\ntonemap_mode = 2\ntonemap_exposure = 1.15', new_env, content)

# Add a dramatic rim light if not present
if "RimLight" not in content:
    rim_light = """
[node name="RimLight" type="DirectionalLight3D" parent="3DView/SubViewport"]
transform = Transform3D(-0.866025, 0.353553, -0.353553, 0, 0.707107, 0.707107, 0.5, 0.612372, -0.612372, -2, 2, -2)
light_color = Color(0.2, 0.6, 1.0, 1)
light_energy = 3.5
light_specular = 2.0
"""
    content = content.replace('[node name="KeyLight"', rim_light + '\n[node name="KeyLight"')

# Also boost KeyLight energy for more dramatic highlights
content = re.sub(r'light_energy = 2.0', 'light_energy = 4.0\nlight_specular = 1.5', content)

with open("scenes/UI/ArmoryUI.tscn", "w") as f:
    f.write(content)
print("Patched ArmoryUI lighting!")
