import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath='/home/am/targetkill/assets/3d/weapons/downloaded/ak74u_centered.glb')
import mathutils

for obj in bpy.data.objects:
    print(f"OBJ: {obj.name} | type: {obj.type} | loc: {obj.location} | parent: {obj.parent.name if obj.parent else None}")
    if obj.type == 'MESH':
        bb = [obj.matrix_world @ mathutils.Vector(b) for b in obj.bound_box]
        min_c = [min(v[i] for v in bb) for i in range(3)]
        max_c = [max(v[i] for v in bb) for i in range(3)]
        print(f"   BOUNDS: min={min_c}, max={max_c}")
