import struct
import json
import glob
import os

def parse_glb(path):
    with open(path, "rb") as f:
        data = f.read()
    
    # Header: magic (4), version (4), length (4)
    magic, version, length = struct.unpack("<4sII", data[:12])
    if magic != b"glTF":
        print(f"Not a valid GLB: {path}")
        return None
    
    # Chunk 0: JSON
    chunk_len, chunk_type = struct.unpack("<II", data[12:20])
    json_bytes = data[20:20+chunk_len]
    gltf = json.loads(json_bytes.decode("utf-8"))
    
    # Chunk 1: BIN
    bin_offset = 20 + chunk_len
    bin_len, bin_type = struct.unpack("<II", data[bin_offset:bin_offset+8])
    bin_data = data[bin_offset+8:bin_offset+8+bin_len]
    
    return gltf, bin_data

def analyze_facing(path):
    print(f"\n==========================================")
    print(f"FILE: {os.path.basename(path)}")
    res = parse_glb(path)
    if not res: return
    gltf, bin_data = res
    
    # Find all POSITION accessors
    meshes = gltf.get("meshes", [])
    accessors = gltf.get("accessors", [])
    buffer_views = gltf.get("bufferViews", [])
    
    all_verts = []
    for m in meshes:
        for prim in m.get("primitives", []):
            pos_idx = prim.get("attributes", {}).get("POSITION")
            if pos_idx is not None:
                acc = accessors[pos_idx]
                bv = buffer_views[acc["bufferView"]]
                offset = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
                count = acc["count"]
                # 3 floats per vertex (12 bytes)
                stride = bv.get("byteStride", 12)
                for i in range(count):
                    v_offset = offset + i * stride
                    x, y, z = struct.unpack_from("<fff", bin_data, v_offset)
                    all_verts.append((x, y, z))
    
    if not all_verts:
        print("No vertices found.")
        return
        
    print(f"Total vertices: {len(all_verts)}")
    min_y = min(v[1] for v in all_verts)
    max_y = max(v[1] for v in all_verts)
    height = max_y - min_y
    print(f"Y range: [{min_y:.3f}, {max_y:.3f}] (Height: {height:.3f})")
    
    # Feet slice: bottom 10%
    foot_y_max = min_y + height * 0.10
    feet = [v for v in all_verts if v[1] <= foot_y_max]
    
    # Head slice: top 10%
    head_y_min = max_y - height * 0.10
    head = [v for v in all_verts if v[1] >= head_y_min]
    
    # Mid-torso / chest slice: 55% to 75%
    torso_y_min = min_y + height * 0.55
    torso_y_max = min_y + height * 0.75
    torso = [v for v in all_verts if torso_y_min <= v[1] <= torso_y_max]
    
    if feet:
        min_fz = min(v[2] for v in feet)
        max_fz = max(v[2] for v in feet)
        avg_fz = sum(v[2] for v in feet) / len(feet)
        print(f"  FEET Z: min={min_fz:.3f}, max={max_fz:.3f}, avg={avg_fz:.3f}")
        dist_min = abs(avg_fz - min_fz)
        dist_max = abs(max_fz - avg_fz)
        print(f"    Feet center to -Z edge: {dist_min:.3f}, center to +Z edge: {dist_max:.3f}")
        if dist_max > dist_min * 1.2:
            print("    --> FEET (TOES) PROTRUDE TOWARDS +Z")
        elif dist_min > dist_max * 1.2:
            print("    --> FEET (TOES) PROTRUDE TOWARDS -Z")
            
    if head:
        min_hz = min(v[2] for v in head)
        max_hz = max(v[2] for v in head)
        avg_hz = sum(v[2] for v in head) / len(head)
        print(f"  HEAD Z: min={min_hz:.3f}, max={max_hz:.3f}, avg={avg_hz:.3f}")
        dist_min = abs(avg_hz - min_hz)
        dist_max = abs(max_hz - avg_hz)
        print(f"    Head center to -Z edge: {dist_min:.3f}, center to +Z edge: {dist_max:.3f}")
        if dist_max > dist_min * 1.15:
            print("    --> HEAD (NOSE/FACE) PROTRUDES TOWARDS +Z")
        elif dist_min > dist_max * 1.15:
            print("    --> HEAD (NOSE/FACE) PROTRUDES TOWARDS -Z")

    # Check bones if present
    nodes = gltf.get("nodes", [])
    for node in nodes:
        name = node.get("name", "").lower()
        if any(w in name for w in ["head", "jaw", "nose", "snout", "neck", "tail", "toe"]):
            trans = node.get("translation", [0, 0, 0])
            print(f"  Node/Bone '{node.get('name')}': translation={trans}")

for f in [
    "/home/am/Downloads/zombee/velociraptor.glb",
    "/home/am/Downloads/zombee/male_office_worker_zombie_character.glb",
    "/home/am/Downloads/zombee/male_zombie_character_around_6_feet_tall.glb",
    "/home/am/Downloads/zombee/zombie_biker.glb",
    "/home/am/Downloads/zombee/cronos_titan_-_greek_mythology.glb",
    "/home/am/Downloads/scary_zombie_pack.glb"
]:
    if os.path.exists(f):
        analyze_facing(f)
    else:
        print(f"File not found: {f}")
