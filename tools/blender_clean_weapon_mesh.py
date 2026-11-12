import bpy
import mathutils
import math

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="/home/am/targetkill/real/ak74u__free_animation..glb")

# Target gun meshes
gun_mesh_names = ["Object_61", "Object_62", "Object_63"]

# Delete carg2 floating mag vertices in Object_63 first
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
        print("Deleted carg2 vertices from mag!")

gun_objs = []
for name in gun_mesh_names:
    obj = bpy.data.objects.get(name)
    if obj:
        gun_objs.append(obj)
        # Apply world transform so vertices are in absolute world space
        bpy.context.view_layer.objects.active = obj
        # Remove armature modifier
        for mod in list(obj.modifiers):
            if mod.type == 'ARMATURE':
                obj.modifiers.remove(mod)
        # Clear parent keeping world transform
        mat = obj.matrix_world.copy()
        obj.parent = None
        obj.matrix_world = mat

# Now delete all non-gun objects
for obj in list(bpy.data.objects):
    if obj not in gun_objs:
        bpy.data.objects.remove(obj, do_unlink=True)

# Select all gun objects and join them into one unified model
bpy.ops.object.select_all(action='DESELECT')
for obj in gun_objs:
    obj.select_set(True)
bpy.context.view_layer.objects.active = gun_objs[0]
bpy.ops.object.join()
ak = bpy.context.active_object
ak.name = "AK74u"

# Apply all transforms to vertices
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Calculate bounds
bb = [ak.matrix_world @ mathutils.Vector(b) for b in ak.bound_box]
min_c = mathutils.Vector([min(v[i] for v in bb) for i in range(3)])
max_c = mathutils.Vector([max(v[i] for v in bb) for i in range(3)])
center = (min_c + max_c) * 0.5
dim = max_c - min_c
print(f"AK bounds: min={min_c}, max={max_c}, dim={dim}")

# In world space:
# Check dimensions: X, Y, Z
# The longest axis is the barrel!
print(f"Dimension X={dim.x:.3f}, Y={dim.y:.3f}, Z={dim.z:.3f}")

# Longest axis is Z (length ~ 0.65m), or Y, or X.
# We want:
# Barrel pointing along -Y (which exports to -Z in Godot forward).
# Top of gun along +Z (which exports to +Y in Godot up).
# Handle/grip around (0, 0, 0).

# Let's inspect orientation:
# In the original FBX/GLB:
# Mesh vertices: X: -0.32 to +0.07 (width ~ 0.39m or Y is 0.05 to 0.53, Z is 1.05 to 1.39)
# Let's align center of the gun to (0, 0, 0) first:
ak.location = -center
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

# Re-evaluate bounds after centering at origin:
bb = [ak.matrix_world @ mathutils.Vector(b) for b in ak.bound_box]
min_c = mathutils.Vector([min(v[i] for v in bb) for i in range(3)])
max_c = mathutils.Vector([max(v[i] for v in bb) for i in range(3)])
dim = max_c - min_c

# Find which axis is length:
axes = [('x', dim.x), ('y', dim.y), ('z', dim.z)]
axes.sort(key=lambda x: x[1], reverse=True)
longest_axis = axes[0][0]
print(f"Longest axis (barrel) is {longest_axis} with length {axes[0][1]:.3f}m")

# If longest axis is Z: rotate 90 deg around X so barrel points along -Y
if longest_axis == 'z':
    ak.rotation_euler = (math.radians(-90), 0, 0)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
elif longest_axis == 'x':
    ak.rotation_euler = (0, 0, math.radians(-90))
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

# Now check new dimensions:
bb = [ak.matrix_world @ mathutils.Vector(b) for b in ak.bound_box]
min_c = mathutils.Vector([min(v[i] for v in bb) for i in range(3)])
max_c = mathutils.Vector([max(v[i] for v in bb) for i in range(3)])
dim = max_c - min_c
print(f"Oriented bounds: min={min_c}, max={max_c}, dim={dim}")

out_path = "/home/am/targetkill/assets/3d/weapons/downloaded/ak74u_perfect.glb"
bpy.ops.export_scene.gltf(
    filepath=out_path,
    export_format='GLB',
    export_animations=False,
    export_apply=True
)
print("SUCCESS! Exported ak74u_perfect.glb clean static mesh!")
