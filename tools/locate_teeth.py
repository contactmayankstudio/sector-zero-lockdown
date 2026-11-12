import json
import struct

with open("/home/am/Downloads/zombee/velociraptor.glb", "rb") as f:
    data = f.read()

chunk_len, chunk_type = struct.unpack("<II", data[12:20])
gltf = json.loads(data[20:20+chunk_len].decode("utf-8"))

accessors = gltf.get("accessors", [])
meshes = gltf.get("meshes", [])
nodes = gltf.get("nodes", [])

print("Total nodes:", len(nodes))
for i, node in enumerate(nodes):
    name = node.get("name", "")
    mesh_idx = node.get("mesh")
    if mesh_idx is not None:
        m = meshes[mesh_idx]
        pos_acc = None
        for prim in m.get("primitives", []):
            p = prim.get("attributes", {}).get("POSITION")
            if p is not None:
                pos_acc = accessors[p]
                break
        min_v = pos_acc.get("min") if pos_acc else None
        max_v = pos_acc.get("max") if pos_acc else None
        print(f"Node {i} '{name}' -> Mesh {mesh_idx} '{m.get('name')}' min={min_v} max={max_v}")
