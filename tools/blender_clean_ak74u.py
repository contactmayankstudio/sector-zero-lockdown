import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

# Delete character body meshes
for name in ["Object_57", "Object_59"]:
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.data.objects.remove(obj, do_unlink=True)

# Delete character empty nodes if any
for name in ["Ch08_Body", "Ch08_Hoodie"]:
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.data.objects.remove(obj, do_unlink=True)

# Delete character bones from armature
arm = bpy.data.objects.get("Object_5")
if arm and arm.type == 'ARMATURE':
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='EDIT')
    edit_bones = arm.data.edit_bones
    
    gun_bone_names = {"_rootJoint", "Bone_043", "carg_044", "recam_045", "seg_046", "gatillo_047", "carg2_048"}
    bones_to_remove = [b for b in edit_bones if b.name not in gun_bone_names]
    for b in bones_to_remove:
        edit_bones.remove(b)
        
    bpy.ops.object.mode_set(mode='OBJECT')

print("Remaining objects:")
for obj in bpy.data.objects:
    print(f"- {obj.name} ({obj.type})")

out_path = "/home/am/targetkill/assets/3d/weapons/downloaded/ak74u_clean.glb"
bpy.ops.export_scene.gltf(
    filepath=out_path,
    export_format='GLB',
    export_animations=True,
    export_apply=False
)
print(f"Successfully exported clean AK-74u to {out_path}")
