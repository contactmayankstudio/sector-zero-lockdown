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
print("CHECKING EXTERNAL RESOURCE DEPENDENCIES IN SCENES")
print("==================================================")

for rel_path in SCENES:
    full_path = os.path.join(base_dir, rel_path)
    if not os.path.exists(full_path):
        print(f"[ERROR] Scene missing: {rel_path}")
        continue
    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    
    ext_resources = re.findall(r'\[ext_resource\s+type="([^"]+)"\s+path="([^"]+)"\s+id="([^"]+)"\]', content)
    broken = []
    for rtype, rpath, rid in ext_resources:
        disk_path = rpath.replace("res://", base_dir + "/")
        if not os.path.exists(disk_path):
            broken.append((rtype, rpath, rid))
            
    if broken:
        print(f"\n[FAIL] {rel_path} has {len(broken)} broken dependencies:")
        for rtype, rpath, rid in broken:
            print(f"   - ({rtype}) {rpath}")
    else:
        print(f"[PASS] {rel_path}: all {len(ext_resources)} dependencies exist on disk.")
