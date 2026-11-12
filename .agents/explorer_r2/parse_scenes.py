import os
import re

SCENES = [
    "scenes/environments/UrbanStreet.tscn",
    "scenes/environments/AirportServiceRoad.tscn",
    "scenes/environments/RailwayStation.tscn",
    "scenes/environments/AbandonedTrain.tscn",
    "scenes/environments/DarkIndustrial.tscn",
    "scenes/environments/ApartmentComplex.tscn",
    "scenes/environments/NightCityStreet.tscn",
    "scenes/environments/AirportTerminal.tscn",
    "scenes/environments/FinalLockdown.tscn"
]

base_dir = "/home/am/targetkill"

print("==================================================")
print("PARSING ENVIRONMENT SCENES FOR SPAWN POINTS")
print("==================================================")

for rel_path in SCENES:
    full_path = os.path.join(base_dir, rel_path)
    print(f"\n--- SCENE: {rel_path} ---")
    if not os.path.exists(full_path):
        print(f"  [ERROR] File not found: {full_path}")
        continue
    
    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        
    # Find nodes named Spawn*
    # Patterns like: [node name="SpawnFront" type="Node3D" parent="ZombieSpawner"]
    spawn_nodes = re.findall(r'\[node name="(Spawn[^"]*)"', content)
    print(f"  Spawn nodes defined in scene ({len(spawn_nodes)}): {spawn_nodes}")
    
    # Check directions in spawn_nodes
    directions_in_nodes = {"front": False, "back": False, "left": False, "right": False}
    for sn in spawn_nodes:
        sn_lower = sn.lower()
        for d in directions_in_nodes:
            if d in sn_lower:
                directions_in_nodes[d] = True
                
    for d, found in directions_in_nodes.items():
        if not found:
            print(f"  [CRITICAL] Direction '{d.upper()}' has NO matching Spawn node in scene!")
            
    # Find GameManager / ZombieSpawner node and its spawn_points exported array
    # e.g., spawn_points = [NodePath("SpawnFront"), ...]
    sp_match = re.search(r'spawn_points\s*=\s*\[(.*?)\]', content, re.DOTALL)
    if sp_match:
        sp_text = sp_match.group(1)
        # extract NodePath(...)
        nodepaths = re.findall(r'NodePath\("([^"]+)"\)', sp_text)
        print(f"  GameManager exported spawn_points ({len(nodepaths)}): {nodepaths}")
        
        # Check directions in exported nodepaths
        directions_in_exported = {"front": False, "back": False, "left": False, "right": False}
        for np in nodepaths:
            np_name = np.split("/")[-1].lower()
            for d in directions_in_exported:
                if d in np_name:
                    directions_in_exported[d] = True
                    
        for d, found in directions_in_exported.items():
            if not found:
                print(f"  [CRITICAL] Direction '{d.upper()}' is NOT in GameManager.spawn_points array!")
                
        # Compare defined nodes vs exported nodepaths
        for sn in spawn_nodes:
            # check if any nodepath ends with sn
            matching = [np for np in nodepaths if np.endswith(sn)]
            if not matching:
                print(f"  [WARNING] Spawn node '{sn}' exists in scene but is OMITTED from spawn_points array!")
    else:
        print("  [ERROR] No spawn_points exported property found on GameManager!")
