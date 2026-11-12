import struct
import json
import os

def parse_glb(path):
    with open(path, "rb") as f:
        data = f.read()
    magic, version, length = struct.unpack("<4sII", data[:12])
    if magic != b"glTF": return None
    chunk_len, chunk_type = struct.unpack("<II", data[12:20])
    gltf = json.loads(data[20:20+chunk_len].decode("utf-8"))
    bin_offset = 20 + chunk_len
    bin_len, bin_type = struct.unpack("<II", data[bin_offset:bin_offset+8])
    bin_data = data[bin_offset+8:bin_offset+8+bin_len]
    return gltf, bin_data

def get_mesh_data(gltf, bin_data):
    meshes = gltf.get("meshes", [])
    accessors = gltf.get("accessors", [])
    buffer_views = gltf.get("bufferViews", [])
    
    verts = []
    normals = []
    
    for m in meshes:
        for prim in m.get("primitives", []):
            pos_idx = prim.get("attributes", {}).get("POSITION")
            norm_idx = prim.get("attributes", {}).get("NORMAL")
            if pos_idx is not None:
                acc = accessors[pos_idx]
                bv = buffer_views[acc["bufferView"]]
                offset = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
                stride = bv.get("byteStride", 12)
                for i in range(acc["count"]):
                    x, y, z = struct.unpack_from("<fff", bin_data, offset + i * stride)
                    verts.append((x, y, z))
            if norm_idx is not None:
                acc = accessors[norm_idx]
                bv = buffer_views[acc["bufferView"]]
                offset = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
                stride = bv.get("byteStride", 12)
                for i in range(acc["count"]):
                    nx, ny, nz = struct.unpack_from("<fff", bin_data, offset + i * stride)
                    normals.append((nx, ny, nz))
    return verts, normals

files = [
    ("velociraptor", "/home/am/Downloads/zombee/velociraptor.glb"),
    ("office", "/home/am/Downloads/zombee/male_office_worker_zombie_character.glb"),
    ("6ft", "/home/am/Downloads/zombee/male_zombie_character_around_6_feet_tall.glb"),
    ("biker", "/home/am/Downloads/zombee/zombie_biker.glb"),
    ("titan", "/home/am/Downloads/zombee/cronos_titan_-_greek_mythology.glb")
]

for name, path in files:
    print(f"\n==========================================")
    print(f"ANALYZING: {name}")
    gltf, bin_data = parse_glb(path)
    verts, normals = get_mesh_data(gltf, bin_data)
    
    # Analyze normals of the whole character
    # Front-facing character should have chest/face normals pointing in forward direction!
    # Back-facing surface normals point in backward direction.
    # But wait! For any closed mesh, sum of normals is ~0.
    # What about the nose?
    # Let's check the head slice:
    min_y = min(v[1] for v in verts)
    max_y = max(v[1] for v in verts)
    height = max_y - min_y
    
    # Head: top 15%
    head_y_min = max_y - height * 0.15
    head_verts_norms = [(v, n) for v, n in zip(verts, normals) if v[1] >= head_y_min]
    
    # In the head, find the extreme Z points:
    min_z_v, min_z_n = min(head_verts_norms, key=lambda pair: pair[0][2])
    max_z_v, max_z_n = max(head_verts_norms, key=lambda pair: pair[0][2])
    
    print(f"  Head Min Z vert: {min_z_v}, normal: {min_z_n}")
    print(f"  Head Max Z vert: {max_z_v}, normal: {max_z_n}")
    
    # Check normals on +Z side vs -Z side of head
    mid_z = (min_z_v[2] + max_z_v[2]) / 2.0
    plus_z_norms = [n for v, n in head_verts_norms if v[2] > mid_z]
    minus_z_norms = [n for v, n in head_verts_norms if v[2] < mid_z]
    
    avg_nz_plus = sum(n[2] for n in plus_z_norms) / len(plus_z_norms) if plus_z_norms else 0
    avg_nz_minus = sum(n[2] for n in minus_z_norms) / len(minus_z_norms) if minus_z_norms else 0
    
    print(f"  Head +Z side avg Normal Z: {avg_nz_plus:.3f}")
    print(f"  Head -Z side avg Normal Z: {avg_nz_minus:.3f}")
    
    # Now check FEET (bottom 8%)
    foot_y_max = min_y + height * 0.08
    foot_verts = [v for v in verts if v[1] <= foot_y_max]
    if foot_verts:
        min_fz = min(v[2] for v in foot_verts)
        max_fz = max(v[2] for v in foot_verts)
        # Average foot Z
        avg_fz = sum(v[2] for v in foot_verts) / len(foot_verts)
        # In human anatomy, ankle/leg meets foot near the back (heel).
        # Ankle is roughly at 1/3 of foot length from heel, and 2/3 from toes.
        # So the distance from leg center to toes is twice the distance to heel!
        leg_y_min = min_y + height * 0.12
        leg_y_max = min_y + height * 0.20
        leg_verts = [v for v in verts if leg_y_min <= v[1] <= leg_y_max]
        if leg_verts:
            avg_lz = sum(v[2] for v in leg_verts) / len(leg_verts)
            print(f"  Lower leg avg Z: {avg_lz:.3f}")
            print(f"  Foot min Z: {min_fz:.3f}, max Z: {max_fz:.3f}")
            dist_to_min = abs(avg_lz - min_fz)
            dist_to_max = abs(max_fz - avg_lz)
            print(f"  Distance from leg to foot min Z (-Z): {dist_to_min:.3f}")
            print(f"  Distance from leg to foot max Z (+Z): {dist_to_max:.3f}")
            if dist_to_max > dist_to_min * 1.3:
                print(f"  ===> TOES EXTEND TOWARDS +Z! Character faces +Z!")
            elif dist_to_min > dist_to_max * 1.3:
                print(f"  ===> TOES EXTEND TOWARDS -Z! Character faces -Z!")
            else:
                print(f"  Inconclusive from feet.")
