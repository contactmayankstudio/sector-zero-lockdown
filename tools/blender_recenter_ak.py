import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

# Delete character body meshes
for name in ["Object_57", "Object_59"]:
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.data.objects.remove(obj, do_unlink=True)

# Delete carg2 floating mag
mag_obj = bpy.data.objects.get("Object_63")
if mag_obj and mag_obj.type == 'MESH':
    vg = mag_obj.vertex_groups.get("carg2_048")
    if vg:
        bpy.context.view_layer.objects.active = mag_obj
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.select_all(action='DESELECT')
        mag_obj.vertex_groups.active_index = vg.index
        bpy.ops.object.vertex_group_select()
        bpy.ops.mesh.delete(type='VERT')
        bpy.ops.object.mode_set(mode='OBJECT')
        print("Deleted carg2 vertices!")

arm = bpy.data.objects.get("Object_5")
if arm:
    bone = arm.data.bones.get("Bone_043")
    if bone:
        head = bone.head_local.copy()
        print(f"Bone_043 head: {head}")
        arm.location = (-head.x, -head.y, -head.z)
        bpy.context.view_layer.objects.active = arm
        bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

out_path = "/home/am/targetkill/assets/3d/weapons/downloaded/ak74u_centered.glb"
bpy.ops.export_scene.gltf(
    filepath=out_path,
    export_format='GLB',
    export_animations=True,
    export_apply=False
)
print("Successfully exported centered AK-74u!")
