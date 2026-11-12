import bpy
import sys

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/3d/weapons/negev_ng7/scene.gltf")
bpy.ops.export_scene.obj(filepath="models/weapons/negev_ng7.obj", use_materials=True)
