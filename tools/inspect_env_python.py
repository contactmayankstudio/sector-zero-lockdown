import struct
import json
import os

envs = {
    "supermarket": "/home/am/Downloads/envarment/super_market_for_free.glb",
    "metro": "/home/am/Downloads/envarment/old_metro_tunnel_free.glb",
    "highway": "/home/am/Downloads/envarment/fixed_new_york_highway_interstate_95.glb",
    "horror_corridor": "/home/am/Downloads/envarment/horror_corridor_vr_room_baked.glb",
    "old_bar": "/home/am/Downloads/envarment/old_bar.glb",
    "city_pack": "/home/am/Downloads/envarment/city_pack_3.glb",
    "castle": "/home/am/Downloads/envarment/castle_of_loarre.glb"
}

for name, path in envs.items():
    if not os.path.exists(path): continue
    with open(path, "rb") as f:
        data = f.read(20)
    if len(data) < 20: continue
    magic, ver, length = struct.unpack("<4sII", data[:12])
    chunk_len, chunk_type = struct.unpack("<II", data[12:20])
    with open(path, "rb") as f:
        f.seek(20)
        json_bytes = f.read(chunk_len)
    gltf = json.loads(json_bytes.decode("utf-8"))
    
    accessors = gltf.get("accessors", [])
    meshes = gltf.get("meshes", [])
    materials = gltf.get("materials", [])
    nodes = gltf.get("nodes", [])
    
    # Calculate global AABB across all meshes
    min_x, max_x = 999999, -999999
    min_y, max_y = 999999, -999999
    min_z, max_z = 999999, -999999
    
    for m in meshes:
        for prim in m.get("primitives", []):
            pos_idx = prim.get("attributes", {}).get("POSITION")
            if pos_idx is not None and pos_idx < len(accessors):
                acc = accessors[pos_idx]
                mn = acc.get("min")
                mx = acc.get("max")
                if mn and mx:
                    min_x = min(min_x, mn[0])
                    max_x = max(max_x, mx[0])
                    min_y = min(min_y, mn[1])
                    max_y = max(max_y, mx[1])
                    min_z = min(min_z, mn[2])
                    max_z = max(max_z, mx[2])
                    
    print(f"\n==========================================")
    print(f"ENV: {name}")
    print(f"  Meshes: {len(meshes)}, Materials: {len(materials)}, Nodes: {len(nodes)}")
    print(f"  Bounds X: [{min_x:.2f} to {max_x:.2f}] (Width: {max_x-min_x:.2f})")
    print(f"  Bounds Y: [{min_y:.2f} to {max_y:.2f}] (Height: {max_y-min_y:.2f})")
    print(f"  Bounds Z: [{min_z:.2f} to {max_z:.2f}] (Depth: {max_z-min_z:.2f})")
