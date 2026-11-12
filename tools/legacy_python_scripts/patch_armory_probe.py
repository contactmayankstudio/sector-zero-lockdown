import re

with open("scenes/UI/ArmoryUI.tscn", "r") as f:
    content = f.read()

if "ReflectionProbe" not in content:
    probe = """
[node name="ReflectionProbe" type="ReflectionProbe" parent="3DView/SubViewport"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
extents = Vector3(5, 5, 5)
origin_offset = Vector3(0, -0.5, 0)
box_projection = true
enable_shadows = true
intensity = 1.5
"""
    content = content.replace('[node name="WeaponPreviewCam"', probe + '\n[node name="WeaponPreviewCam"')
    with open("scenes/UI/ArmoryUI.tscn", "w") as f:
        f.write(content)
