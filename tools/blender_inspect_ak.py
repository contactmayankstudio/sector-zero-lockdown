import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

print("=== BLENDER INSPECT OBJECTS ===")
for obj in bpy.data.objects:
    print(f"Object: {obj.name}, type: {obj.type}, parent: {obj.parent.name if obj.parent else 'None'}, loc: {obj.location}")

print("\n=== BLENDER ACTIONS / ANIMATIONS ===")
for act in bpy.data.actions:
    print(f"Action: {act.name}, frame_range: {act.frame_range}")
