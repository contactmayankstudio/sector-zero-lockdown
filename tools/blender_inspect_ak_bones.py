import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

arm = bpy.data.objects.get("Object_5")
if arm and arm.type == 'ARMATURE':
    print("=== ARMATURE BONES ===")
    for b in arm.data.bones:
        print(f"Bone: {b.name}, head: {b.head_local}, parent: {b.parent.name if b.parent else 'None'}")
