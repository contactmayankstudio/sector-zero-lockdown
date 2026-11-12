#!/usr/bin/env python3
"""
generate_84_campaign_missions.py
Generates 12 Chapters × 7 Sub-Missions = 84 total campaign missions
for Sector Zero: Lockdown in Godot 4 format.
Rotates all distinct 3D environments across missions for continuous variety!
"""

import os
import json

SCENE_TERMINAL     = "res://scenes/environments/AirportTerminal.tscn"
SCENE_AIRPORT_ROAD = "res://scenes/environments/AirportServiceRoad.tscn"
SCENE_URBAN        = "res://scenes/environments/UrbanStreet.tscn"
SCENE_APARTMENT    = "res://scenes/environments/UrbanStreet.tscn"
SCENE_NIGHT_CITY   = "res://scenes/environments/UrbanStreet.tscn"
SCENE_STATION      = "res://scenes/environments/RailwayStation.tscn"
SCENE_TRAIN        = "res://scenes/environments/AbandonedTrain.tscn"
SCENE_INDUSTRIAL   = "res://scenes/environments/DarkIndustrial.tscn"
SCENE_LOCKDOWN     = "res://scenes/environments/FinalLockdown.tscn"

CHAPTERS = [
    {
        "num": 1,
        "name": "Airport Complex",
        "scene": SCENE_TERMINAL,
        "sector": "Sector 01 - Terminal Perimeter",
        "loadout": "USP-45 Tactical / M4A1 Sentinel",
        "subs": [
            ("Terminal Breach", "First outbreak reported in Terminal A. Eliminate initial infected contacts and secure the perimeter.", 0, 12, SCENE_TERMINAL),
            ("Security Failure", "Checkpoint security overwhelmed by fast runners. Clear the screening area before they flank.", 0, 14, SCENE_TERMINAL),
            ("Baggage Hall", "Defend baggage conveyor hub. Contain all incoming hostiles from maintenance passages.", 1, 3, SCENE_AIRPORT_ROAD),
            ("Maintenance Corridor", "Narrow service tunnels under siege. Heavy infected detected pushing through access gates.", 0, 16, SCENE_TERMINAL),
            ("Control Room", "Hold the air traffic control access corridor against relentless multi-angle assaults.", 0, 18, SCENE_TERMINAL),
            ("Runway Defense", "Tarmac overrun by infected squads. Hold the line until evacuation shuttle coordinates align.", 1, 3, SCENE_AIRPORT_ROAD),
            ("Hangar Apex Boss", "Massive mutated baggage loader brute sighted in Hangar 4. Terminate the Alpha specimen.", 2, 1, SCENE_AIRPORT_ROAD)
        ]
    },
    {
        "num": 2,
        "name": "Airport Service Road",
        "scene": SCENE_AIRPORT_ROAD,
        "sector": "Sector 02 - Service Perimeter",
        "loadout": "M4A1 Sentinel / Remington 870",
        "subs": [
            ("Perimeter Breach", "Infected breached the outer security fence. Neutralize front runners along the tarmac.", 0, 14, SCENE_AIRPORT_ROAD),
            ("Cargo Lane", "Overturned freight trucks blocking route. Clear swarming flankers from access lanes.", 0, 16, SCENE_URBAN),
            ("Fuel Depot", "Prevent infected from rupturing aviation fuel tanks. Defend the pumping station.", 1, 3, SCENE_AIRPORT_ROAD),
            ("Service Tunnel", "Subterranean utility road crawling with armored infected. Eliminate the squad.", 0, 18, SCENE_URBAN),
            ("Radar Station", "Defend satellite radar dish from incoming runners approaching from service roads.", 0, 20, SCENE_AIRPORT_ROAD),
            ("Checkpoint Outpost", "Guard outpost under siege. Survive multiple concentrated waves of heavy infected.", 1, 3, SCENE_URBAN),
            ("Convoy Ambush Boss", "Alpha Brute commanding highway blockade. Neutralize the threat to open the route.", 2, 1, SCENE_URBAN)
        ]
    },
    {
        "num": 3,
        "name": "Railway Station",
        "scene": SCENE_STATION,
        "sector": "Sector 03 - Metro Concourse",
        "loadout": "MP5 Tactical / AK-47 Vanguard",
        "subs": [
            ("Station Entrance", "Civilian evacuees turned into hostiles at main turnstiles. Secure the station hall.", 0, 15, SCENE_STATION),
            ("Ticket Concourse", "Vicious infected surging past ticketing counters. Eliminate hostile clusters.", 0, 17, SCENE_APARTMENT),
            ("Main Platform", "Hold platform 3 while automated metro doors cycle. Survive incoming waves.", 1, 3, SCENE_STATION),
            ("Underground Passage", "Pedestrian underpass choke point. Stop fast runners and infected hounds.", 0, 18, SCENE_URBAN),
            ("Track Area", "Open railway tracks infested with mutant stalkers. Clear all hostile movement.", 0, 20, SCENE_STATION),
            ("Maintenance Shed", "Survive heavy ambush inside the train repair warehouse.", 1, 3, SCENE_APARTMENT),
            ("Train Evacuation Boss", "Mutated conductor specimen guarding the armored evacuation train. Terminate.", 2, 1, SCENE_STATION)
        ]
    },
    {
        "num": 4,
        "name": "Abandoned Train Yard",
        "scene": SCENE_TRAIN,
        "sector": "Sector 04 - Freight Rail Yard",
        "loadout": "AK-47 Vanguard / Remington 870",
        "subs": [
            ("Rail Yard Gate", "Rusting freight yard gate breached. Intercept infected moving along boxcars.", 0, 16, SCENE_STATION),
            ("Freight Cargo", "Narrow gaps between container cars. Watch flanks as infected emerge from blindspots.", 0, 18, SCENE_TRAIN),
            ("Switching Station", "Defend automated rail switch junction while power generator boots.", 1, 3, SCENE_TRAIN),
            ("Boxcar Graveyard", "Heavily armored infected soldiers wandering among decommissioned trains.", 0, 20, SCENE_TRAIN),
            ("Crane Depot", "Gantry crane platform under attack from swarming infected hounds and runners.", 0, 22, SCENE_STATION),
            ("Engine House", "Hold engine maintenance hangar against high-density multi-directional horde.", 1, 3, SCENE_TRAIN),
            ("Locomotive Titan Boss", "Giant mutated railyard foreman blocking the main freight line. Destroy target.", 2, 1, SCENE_TRAIN)
        ]
    },
    {
        "num": 5,
        "name": "Industrial Zone",
        "scene": SCENE_INDUSTRIAL,
        "sector": "Sector 05 - Manufacturing Grid",
        "loadout": "AK-47 Vanguard / Desert Eagle .50",
        "subs": [
            ("Warehouse Gate", "Industrial perimeter gate breached by infected factory workers.", 0, 17, SCENE_INDUSTRIAL),
            ("Loading Docks", "Commercial docks under siege. Heavy infected emerging from shipping containers.", 0, 19, SCENE_INDUSTRIAL),
            ("Boiler Room", "Steam-venting corridors. Hold position and contain high-speed hostiles.", 1, 3, SCENE_TRAIN),
            ("Assembly Floor", "Automated assembly line corridor crawling with hardened infected brutes.", 0, 21, SCENE_INDUSTRIAL),
            ("Power Substation", "Defend high-voltage transformers from being overrun by infected hordes.", 0, 23, SCENE_URBAN),
            ("Chemical Yard", "Survive dense toxic smog wave assault in open chemical storage yard.", 1, 3, SCENE_INDUSTRIAL),
            ("Industrial Golem Boss", "Massive cybernetically augmented mutant guarding factory core. Eliminate.", 2, 1, SCENE_INDUSTRIAL)
        ]
    },
    {
        "num": 6,
        "name": "Abandoned Hospital",
        "scene": SCENE_APARTMENT,
        "sector": "Sector 06 - Quarantine Medical Center",
        "loadout": "M4A1 Sentinel / Remington 870",
        "subs": [
            ("ER Triage", "Emergency room triage zone overrun. Put down hostile infected patients and staff.", 0, 18, SCENE_APARTMENT),
            ("Quarantine Ward", "Sealed isolation ward containment failure. Clear all contaminated targets.", 0, 20, SCENE_APARTMENT),
            ("ICU Corridor", "Hold the intensive care corridor while medical data terminal downloads records.", 1, 3, SCENE_INDUSTRIAL),
            ("Laboratory Wing", "Biohazard research lab infested with mutated fast runners and spitters.", 0, 22, SCENE_APARTMENT),
            ("Morgue Breach", "Cryo-storage levels breached. Neutralize resurrected aggressive specimens.", 0, 24, SCENE_NIGHT_CITY),
            ("Roof Helipad", "Survive rooftop helicopter landing pad siege during heavy storm.", 1, 3, SCENE_APARTMENT),
            ("Bio-Abomination Boss", "Grotesque bio-mass experiment specimen guarding hospital exit. Terminate.", 2, 1, SCENE_APARTMENT)
        ]
    },
    {
        "num": 7,
        "name": "Shopping District / Metro",
        "scene": SCENE_STATION,
        "sector": "Sector 07 - Commercial Metro Galleria",
        "loadout": "MP5 Tactical / Remington 870",
        "subs": [
            ("Metro Concourse", "Grand galleria shopping concourse overrun by commercial district horde.", 0, 18, SCENE_STATION),
            ("Escalator Descent", "Descending into subway transit tunnels. Clear entrenched infected clusters.", 0, 20, SCENE_STATION),
            ("Subway Platform", "Hold platform edge against waves of runners surging from dark tunnels.", 1, 3, SCENE_TRAIN),
            ("Retail Galleria", "Glass storefronts shattering as aggressive infected flank from all sides.", 0, 22, SCENE_URBAN),
            ("Mall Atrium", "Central glass atrium under massive multi-level assault.", 0, 24, SCENE_STATION),
            ("Parking Structure", "Multi-story underground garage holdout against heavy armor infected.", 1, 3, SCENE_NIGHT_CITY),
            ("Galleria Titan Boss", "Enormous hulking apex predator dominating the central shopping square. Destroy.", 2, 1, SCENE_STATION)
        ]
    },
    {
        "num": 8,
        "name": "Night City Street",
        "scene": SCENE_NIGHT_CITY,
        "sector": "Sector 08 - Neon Downtown Core",
        "loadout": "AK-47 Vanguard / AWP Arctic Warfare",
        "subs": [
            ("Neon Boulevard", "Wet city asphalt illuminated by flickering neon signs. Repel street vanguard.", 0, 19, SCENE_NIGHT_CITY),
            ("Barricaded Alley", "Civilian road blockade breached. Clear alleyways of fast moving targets.", 0, 21, SCENE_URBAN),
            ("Overpass Collapse", "Defend collapsed highway bridge ramp against ascending hordes.", 1, 3, SCENE_NIGHT_CITY),
            ("Gas Station", "Explosive fuel station forecourt crawling with aggressive infected.", 0, 23, SCENE_URBAN),
            ("Tenement Block", "Apartment stoops and urban intersections teeming with hostile squads.", 0, 25, SCENE_NIGHT_CITY),
            ("Crossroads Siege", "Four-way city intersection siege. Maintain 360-degree tactical vigilance.", 1, 3, SCENE_NIGHT_CITY),
            ("Downtown Tyrant Boss", "Ruthless armored apex Goliath leading downtown infestation. Eliminate.", 2, 1, SCENE_NIGHT_CITY)
        ]
    },
    {
        "num": 9,
        "name": "Military Checkpoint",
        "scene": SCENE_AIRPORT_ROAD,
        "sector": "Sector 09 - Perimeter Fortification",
        "loadout": "AK-47 Vanguard / AWP Arctic Warfare",
        "subs": [
            ("Razorwire Gate", "Outer defense line overrun by reanimated military forces.", 0, 20, SCENE_AIRPORT_ROAD),
            ("Sandbag Trench", "Fortified sandbag emplacements under attack from fast runners.", 0, 22, SCENE_URBAN),
            ("Armory Depot", "Defend military weapons storage facility against armored mutant squad.", 1, 3, SCENE_AIRPORT_ROAD),
            ("Watchtower Defense", "Snipe incoming waves from perimeter barricades before they breach.", 0, 24, SCENE_INDUSTRIAL),
            ("Motor Pool", "Heavily reinforced infected crawling between disabled armored carriers.", 0, 26, SCENE_AIRPORT_ROAD),
            ("Heavy Bunker", "Concrete command bunker perimeter under concentrated tactical siege.", 1, 3, SCENE_AIRPORT_ROAD),
            ("Mutant Warlord Boss", "Heavily armored reanimated commander leading military mutant battalion.", 2, 1, SCENE_INDUSTRIAL)
        ]
    },
    {
        "num": 10,
        "name": "Chemical Facility",
        "scene": SCENE_INDUSTRIAL,
        "sector": "Sector 10 - Toxic Processing Plant",
        "loadout": "AK-47 Vanguard / Remington 870",
        "subs": [
            ("Toxic Runoff", "Chemical drainage channels teeming with acidic mutated horrors.", 0, 21, SCENE_INDUSTRIAL),
            ("Pipe Grid", "High-pressure chemical pipeline maze under constant assault.", 0, 23, SCENE_INDUSTRIAL),
            ("Cooling Tower", "Hold cooling tower platform against high-density toxic swarms.", 1, 3, SCENE_TRAIN),
            ("Reactor Core", "Contain bio-reactor coolant leaks while repelling aggressive mutants.", 0, 25, SCENE_INDUSTRIAL),
            ("Waste Drainage", "Underground effluent channel choke point defense.", 0, 27, SCENE_APARTMENT),
            ("Decontamination Hall", "Sterilization chambers breached by acidic spitters and armored brutes.", 1, 3, SCENE_INDUSTRIAL),
            ("Bio-Chemical Behemoth Boss", "Acid-spewing massive mutated reactor core beast. Terminate immediately.", 2, 1, SCENE_INDUSTRIAL)
        ]
    },
    {
        "num": 11,
        "name": "Factory / Construction Zone",
        "scene": SCENE_INDUSTRIAL,
        "sector": "Sector 11 - Skyscraper Megastructure",
        "loadout": "M4A1 Sentinel / AWP Arctic Warfare",
        "subs": [
            ("Scaffolding Maze", "Multi-tiered construction site perimeter crawling with aggressive climbers.", 0, 22, SCENE_INDUSTRIAL),
            ("Excavation Pit", "Deep foundation trench under siege from cascading infected.", 0, 24, SCENE_NIGHT_CITY),
            ("Cement Works", "Industrial cement mixing silos holdout against armored assault.", 1, 3, SCENE_URBAN),
            ("High-Rise Frame", "Exposed concrete beams under heavy cross-directional attack.", 0, 26, SCENE_INDUSTRIAL),
            ("Crane Overlook", "Defend high-elevation material crane platform.", 0, 28, SCENE_NIGHT_CITY),
            ("Generator Hub", "Survive electrical power grid defense against lightning-fast horde.", 1, 3, SCENE_INDUSTRIAL),
            ("Construction Colossus Boss", "Massive mutated foreman wielding structural steel girders. Eliminate.", 2, 1, SCENE_INDUSTRIAL)
        ]
    },
    {
        "num": 12,
        "name": "Quarantine Zone / Final Boss",
        "scene": SCENE_LOCKDOWN,
        "sector": "Sector 12 - Ground Zero Quarantine Core",
        "loadout": "M4A1 Sentinel / AWP Arctic Warfare / M79 Launcher",
        "subs": [
            ("Red Zone Wall", "The final containment wall dividing Sector Zero from the world. Hold the line.", 0, 24, SCENE_NIGHT_CITY),
            ("Ground Zero Outbreak", "Epicenter of the pathogen outbreak. Intense multi-directional assault.", 0, 26, SCENE_LOCKDOWN),
            ("Biomass Trench", "Bio-organic growth consuming concrete streets. Clear high-threat targets.", 1, 3, SCENE_LOCKDOWN),
            ("Mutation Hive", "Dense mutation nursery guarded by aggressive infected hounds and spitters.", 0, 28, SCENE_LOCKDOWN),
            ("Core Laboratory", "Deep research facility containment floor. Neutralize elite guard squads.", 0, 30, SCENE_LOCKDOWN),
            ("Pre-Boss Lockdown", "Survive the final red-alert emergency lockdown defense before apex chamber.", 1, 3, SCENE_LOCKDOWN),
            ("APEX ALPHA MUTANT FINAL BOSS", "THE APEX PATIENT ZERO SPECIMEN. Defeat the final mutant to lift the Sector Zero lockdown.", 2, 1, SCENE_LOCKDOWN)
        ]
    }
]

def main():
    target_dir = "/home/am/targetkill/resources/missions/campaign"
    os.makedirs(target_dir, exist_ok=True)

    print("Generating 84 Campaign Mission Resources in:", target_dir)

    all_missions = []
    env_pool = [
        SCENE_TERMINAL,
        SCENE_AIRPORT_ROAD,
        SCENE_URBAN,
        SCENE_APARTMENT,
        SCENE_NIGHT_CITY,
        SCENE_STATION,
        SCENE_TRAIN,
        SCENE_INDUSTRIAL,
        SCENE_LOCKDOWN
    ]
    global_idx = 0

    for chap in CHAPTERS:
        c_num = chap["num"]
        c_name = chap["name"]
        sector = chap["sector"]
        loadout = chap["loadout"]
        subs = chap["subs"]

        for s_idx, sub_item in enumerate(subs, 1):
            title, desc, obj_type, target_count = sub_item[0], sub_item[1], sub_item[2], sub_item[3]
            # Every single mission gets the next fresh environment in rotation!
            sub_scene = env_pool[global_idx % len(env_pool)]
            global_idx += 1
            if c_num == 12 and s_idx == 7:
                sub_scene = SCENE_LOCKDOWN

            mission_id = f"{c_num}-{s_idx}"
            file_name = f"mission_{c_num:02d}_{s_idx:02d}.tres"
            file_path = os.path.join(target_dir, file_name)

            # Unlock requirement
            if c_num == 1 and s_idx == 1:
                unlock_req = ""
            elif s_idx > 1:
                unlock_req = f"{c_num}-{s_idx-1}"
            else: # s_idx == 1 and c_num > 1
                unlock_req = f"{c_num-1}-7"

            # Cash reward scaling (Balanced economy: guns affordable around/after level 10)
            base_cash = 120 + (c_num - 1) * 80 + (s_idx - 1) * 15
            if s_idx == 7:
                base_cash += 50 + (c_num - 1) * 20 # Boss bounty bonus

            # Difficulty stars
            diff_stars = min(5, 1 + (c_num - 1) // 3)

            # Enemy compositions - exciting, intense zombie waves
            normal_cnt = 6 + c_num // 2 + s_idx
            fast_cnt = 3 + c_num // 3 + s_idx // 2

            if s_idx == 7:
                # Apex boss waves
                w1 = {"wave_num": 1, "groups": [
                    {"enemy_type": "normal", "count": 6 + c_num // 3, "spawn_direction": "front", "delay": 0.7},
                    {"enemy_type": "fast", "count": 3 + c_num // 4, "spawn_direction": "left", "delay": 0.9}
                ]}
                w2 = {"wave_num": 2, "groups": [
                    {"enemy_type": "normal", "count": 7 + c_num // 3, "spawn_direction": "back", "delay": 0.7},
                    {"enemy_type": "fast", "count": 4 + c_num // 4, "spawn_direction": "right", "delay": 0.8},
                    {"enemy_type": "heavy", "count": 2, "spawn_direction": "front", "delay": 1.2}
                ]}
                w3 = {"wave_num": 3, "groups": [
                    {"enemy_type": "boss", "count": 1, "spawn_direction": "front", "delay": 0.4},
                    {"enemy_type": "normal", "count": 5, "spawn_direction": "left", "delay": 1.0},
                    {"enemy_type": "fast", "count": 3, "spawn_direction": "right", "delay": 1.2}
                ]}
                obj_type = 2 # BOSS_KILL
                target_count = 1
            elif s_idx % 2 == 0:
                # Flanking waves
                w1 = {"wave_num": 1, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt, "spawn_direction": "front", "delay": 0.8}
                ]}
                w2 = {"wave_num": 2, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt, "spawn_direction": "left", "delay": 0.7},
                    {"enemy_type": "fast", "count": fast_cnt, "spawn_direction": "right", "delay": 0.9}
                ]}
                w3 = {"wave_num": 3, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt + 2, "spawn_direction": "back", "delay": 0.7},
                    {"enemy_type": "fast", "count": fast_cnt + 1, "spawn_direction": "front", "delay": 0.8}
                ]}
                obj_type = 0 # KILL_COUNT
                target_count = sum(g["count"] for w in [w1, w2, w3] for g in w["groups"])
            else:
                # Direct assault waves
                w1 = {"wave_num": 1, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt, "spawn_direction": "front", "delay": 0.8}
                ]}
                w2 = {"wave_num": 2, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt, "spawn_direction": "front", "delay": 0.7},
                    {"enemy_type": "fast", "count": fast_cnt, "spawn_direction": "left", "delay": 0.9}
                ]}
                w3 = {"wave_num": 3, "groups": [
                    {"enemy_type": "normal", "count": normal_cnt + 2, "spawn_direction": "back", "delay": 0.7},
                    {"enemy_type": "fast", "count": fast_cnt + 1, "spawn_direction": "right", "delay": 0.8}
                ]}
                obj_type = 0 # KILL_COUNT
                target_count = sum(g["count"] for w in [w1, w2, w3] for g in w["groups"])

            waves_json = json.dumps([w1, w2, w3])
            spawn_config_json = json.dumps([
                {"type": "normal", "weight": max(0.4, 0.8 - c_num * 0.03)},
                {"type": "fast", "weight": min(0.4, 0.2 + c_num * 0.02)},
                {"type": "heavy", "weight": min(0.2, 0.05 + c_num * 0.015)}
            ])

            content = f"""[gd_resource type="Resource" script_class="MissionData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/MissionData.gd" id="1_m1s2d"]

[resource]
script = ExtResource("1_m1s2d")
mission_id = "{mission_id}"
display_name = "{mission_id} {title.upper()}"
description = "{desc}"
objective_type = {obj_type}
target_count = {target_count}
wave_count = 3
reward_cash = {base_cash}
unlock_requirement_id = "{unlock_req}"
scene_path = "{sub_scene}"
location_name = "{sector} - {title}"
difficulty_stars = {diff_stars}
recommended_loadout = "{loadout}"
spawn_config = {spawn_config_json}
waves = {waves_json}
is_endless = false
"""
            with open(file_path, "w") as f:
                f.write(content)

            all_missions.append({
                "id": mission_id,
                "file": file_name,
                "title": title,
                "scene": sub_scene,
                "unlock": unlock_req,
                "cash": base_cash
            })

    print(f"Successfully generated {len(all_missions)} campaign missions.")
    print("First mission:", all_missions[0])
    print("Final mission:", all_missions[-1])

    # Also update mission_endless.tres to unlock after 12-7
    endless_path = "/home/am/targetkill/resources/missions/mission_endless.tres"
    endless_content = """[gd_resource type="Resource" script_class="MissionData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/MissionData.gd" id="1_m1s2d"]

[resource]
script = ExtResource("1_m1s2d")
mission_id = "mission_endless"
display_name = "Endless Survival"
description = "Sector lockdown lifted. Survive infinite escalating waves of infected across the quarantine perimeter."
objective_type = 1
target_count = 999
wave_count = 999
reward_cash = 2500
unlock_requirement_id = "12-7"
scene_path = "res://scenes/environments/NightCityStreet.tscn"
location_name = "Quarantine Outpost - Infinite Zone"
difficulty_stars = 5
recommended_loadout = "Minigun / AK-74u / AWP Sniper"
spawn_config = [{"type": "normal", "weight": 0.5}, {"type": "fast", "weight": 0.3}, {"type": "heavy", "weight": 0.2}]
waves = []
is_endless = true
endless_base_count = 6
endless_scale_per_wave = 2
"""
    with open(endless_path, "w") as f:
        f.write(endless_content)
    print("Updated mission_endless.tres unlock requirement to '12-7'.")

if __name__ == "__main__":
    main()
