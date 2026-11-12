import glob
import re

# Precise spawn locations for each environment type:
# Wide streets/roads: X in [-1.8, 1.8], Z in [-15, -18]
# Corridors / Tunnels / Indoors: X in [-1.2, 1.2], Z in [-10, -14]

street_maps = [
    "scenes/environments/UrbanStreet.tscn",
    "scenes/environments/NightCityStreet.tscn",
    "scenes/environments/AirportServiceRoad.tscn",
]

medium_maps = [
    "scenes/environments/RailwayStation.tscn",
    "scenes/environments/AirportTerminal.tscn",
    "scenes/environments/ApartmentComplex.tscn",
    "scenes/environments/CastleFortress.tscn",
    "scenes/environments/DarkIndustrial.tscn",
    "scenes/environments/FinalLockdown.tscn",
    "scenes/environments/SupermarketInfection.tscn",
]

narrow_maps = [
    "scenes/environments/HorrorLabCorridor.tscn",
    "scenes/environments/MetroSubwayTunnel.tscn",
    "scenes/environments/SurvivorTavern.tscn",
    "scenes/environments/AbandonedAlley.tscn",
    "scenes/environments/AbandonedTrain.tscn",
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Determine limits
    if filepath in narrow_maps:
        max_x = 1.2
        min_z = -14.0
        max_z = -10.0
    elif filepath in medium_maps:
        max_x = 1.5
        min_z = -16.0
        max_z = -12.0
    else: # street
        max_x = 1.8
        min_z = -18.0
        max_z = -15.0

    pos_map = {
        "SpawnFront": (0.0, 0.0, max_z),
        "SpawnBack": (0.8, 0.0, min_z),
        "SpawnLeft": (-max_x, 0.0, round((min_z + max_z) / 2.0, 1)),
        "SpawnRight": (max_x, 0.0, round((min_z + max_z) / 2.0, 1)),
        "SpawnFrontLeft": (round(-max_x * 0.6, 1), 0.0, round(max_z - 1.0, 1)),
        "SpawnFrontRight": (round(max_x * 0.6, 1), 0.0, round(max_z - 1.0, 1)),
        "BossSpawn": (0.0, 0.0, round(min_z + 1.0, 1)),
    }

    modified = False
    for node_name, (tx, ty, tz) in pos_map.items():
        pattern = re.compile(
            rf'(\[node name="{node_name}" type="Node3D" parent="ZombieSpawner"\]\s*\n\s*transform = Transform3D\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,)\s*[^,]+,\s*[^,]+,\s*[^)]+(\))'
        )
        def repl(match):
            nonlocal modified
            modified = True
            return f"{match.group(1)} {tx}, {ty}, {tz}{match.group(2)}"

        content, n = pattern.subn(repl, content)
        if n > 0:
            print(f"[{filepath}] Updated {node_name} -> ({tx}, {ty}, {tz})")

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Saved {filepath}")

for path in street_maps + medium_maps + narrow_maps:
    process_file(path)

print("All environment spawn points successfully updated to open road/corridors!")
