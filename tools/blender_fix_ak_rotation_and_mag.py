import bpy
import math

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

# Remove body and hoodie meshes
for name in ["Object_57", "Object_59"]:
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.data.objects.remove(obj, do_unlink=True)

for name in ["Ch08_Body", "Ch08_Hoodie"]:
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.data.objects.remove(obj, do_unlink=True)

arm = bpy.data.objects.get("Object_5")
if arm and arm.type == 'ARMATURE':
    bpy.context.view_layer.objects.active = arm
    
    # Remove character bones
    bpy.ops.object.mode_set(mode='EDIT')
    edit_bones = arm.data.edit_bones
    gun_bone_names = {"_rootJoint", "Bone_043", "carg_044", "recam_045", "seg_046", "gatillo_047"}
    bones_to_remove = [b for b in edit_bones if b.name not in gun_bone_names]
    for b in bones_to_remove:
        edit_bones.remove(b)
    bpy.ops.object.mode_set(mode='OBJECT')

# In Object_63 (Magazine mesh), remove the floating reload mag vertices (carg2)
mag_obj = bpy.data.objects.get("Object_63")
if mag_obj and mag_obj.type == 'MESH':
    # Find vertex group for carg2_048 if it exists
    vg = mag_obj.vertex_groups.get("carg2_048")
    if vg:
        # In edit mode, select vertices belonging to carg2_048 and delete them
        bpy.context.view_layer.objects.active = mag_obj
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.select_all(action='DESELECT')
        mag_obj.vertex_groups.active_index = vg.index
        bpy.ops.object.vertex_group_select()
        bpy.ops.mesh.delete(type='VERT')
        bpy.ops.object.mode_set(mode='OBJECT')
        print("Removed carg2 floating magazine vertices!")

# Rotate the whole model so barrel points forward (-Y in Blender -> -Z in gltf)
# In Blender, glTF export maps +Y -> +Y, +Z -> -Z, so -Y becomes -Z forward in Godot
# Currently barrel was along +Z in Blender. Rotating -90 deg on X puts +Z to -Y
root_node = bpy.data.objects.get("Sketchfab_model")
if root_node:
    root_node.rotation_euler.x = math.radians(-90)
    root_node.location = (0.0, 0.0, 0.0)

out_path = "/home/am/targetkill/assets/3d/weapons/downloaded/ak74u_perfect.glb"
bpy.ops.export_scene.gltf(
    filepath=out_path,
    export_format='GLB',
    export_animations=True,
    export_apply=False
)
print(f"Exported perfect AK-74u to {out_path}")
