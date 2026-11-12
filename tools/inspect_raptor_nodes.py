import json
import struct

with open("/home/am/Downloads/zombee/velociraptor.glb", "rb") as f:
    data = f.read()

chunk_len, chunk_type = struct.unpack("<II", data[12:20])
gltf = json.loads(data[20:20+chunk_len].decode("utf-8"))

print("=== NODES IN VELOCIRAPTOR.GLB ===")
for i, node in enumerate(gltf.get("nodes", [])):
    name = node.get("name", f"node_{i}")
    rot = node.get("rotation", [0, 0, 0, 1])
    scale = node.get("scale", [1, 1, 1])
    trans = node.get("translation", [0, 0, 0])
    matrix = node.get("matrix")
    if "root" in name.lower() or "armature" in name.lower() or i == 0 or len(node.get("children", [])) > 2:
        print(f"Node {i}: '{name}', rot={rot}, scale={scale}, trans={trans}, matrix={matrix}")

# Check meshes
for i, m in enumerate(gltf.get("meshes", [])):
    print(f"Mesh {i}: '{m.get('name')}'")

# Check scenes
print("Scenes:", gltf.get("scenes"))
