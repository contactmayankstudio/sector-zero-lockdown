## 2026-09-18T05:05:33Z

You are a specialized worker agent (teamwork_preview_worker) assigned to execute Milestone M1: Clean Asset Provenance & License Quarantine (Requirement R3) for 'Sector Zero: Lockdown' in /home/am/targetkill.
Your assigned working directory is /home/am/targetkill/.agents/worker_m1.
Your parent orchestrator conversation ID is 237eaf46-e809-4bcf-b125-d5770dc95b5a.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

INPUT DOCUMENTS (MUST READ BEFORE STARTING):
1. /home/am/targetkill/.agents/ORIGINAL_REQUEST.md (entry dated 2026-09-18T04:43:32Z)
2. /home/am/targetkill/.agents/orchestrator_9/SCOPE.md (Milestone M1 specifications & contracts)
3. /home/am/targetkill/.agents/explorer_r3_r4/handoff.md (Detailed investigation, exact lines, and step-by-step instructions)

EXCLUSIVE WRITE OWNERSHIP:
You own and may edit:
- scenes/environments/UrbanStreet.tscn
- scenes/environments/ApartmentComplex.tscn
- scenes/environments/NightCityStreet.tscn
- scenes/player/Player.gd
- scripts/UI/ArmoryUI.gd
- scenes/weapons/Weapon.gd
- assets/zombies/RealisticZombie.gd
- assets/zombies/RealisticZombie.tscn
- scenes/zombies/Zombie.tscn
- scripts/MissionCardUI.gd
- ASSET_LICENSES.md
- quarantine_suspect_assets/ (and moving unverified files into it)

TASK OBJECTIVES:
1. Sever GTA Grove Street:
   - In scenes/environments/UrbanStreet.tscn, remove the GTAGroveStreet instance (lines 55-56) and ext_resource 17_gta_grove (line 11).
   - Wire in clean CC0 city street geometry (e.g. res://scenes/environments/models/street_city_7_for_games_free.glb) or clean modular props.
   - Move scenes/environments/GTAGroveStreetDirect.tscn to quarantine_suspect_assets/.
   - In scripts/MissionCardUI.gd, replace thumbnail reference to gameplay_real_grove_flatline.png with a clean screenshot (e.g. res://preview_MissionSelect.png or res://preview_HUD.png).
2. Clean Environment Scenes:
   - In scenes/environments/ApartmentComplex.tscn, remove RealApartment.scn and wire to clean modular meshes or assets/3d/environments/industrial_street.glb.
   - In scenes/environments/NightCityStreet.tscn, remove RealCityStreet7.scn and RealCityBuildings8.scn and wire to clean street meshes.
   - Move scenes/environments/models/Real*.scn to quarantine_suspect_assets/.
3. Normalize Weapons to CC0:
   - In scenes/player/Player.gd, normalize weapon_configs to the 10 CC0 weapons (usp45, m4a1, remington870, ak47, desert_eagle, mp5, awp, combat_knife, crossbow, grenade_launcher). Remove entries for flatline, car_smg, minigun, sniper, hawk_shotgun.
   - In scripts/UI/ArmoryUI.gd, update armory weapon list and previews to the 10 CC0 weapons.
   - In scenes/weapons/Weapon.gd, remove 'apex_car' alias.
   - Move assets/3d/weapons/downloaded/ and scenes/weapons/models/AK74uClean.scn to quarantine_suspect_assets/.
4. Normalize Zombie Archetypes to CC0:
   - In assets/zombies/RealisticZombie.gd and RealisticZombie.tscn, remove RealDoomZombie.scn and ValveBiped bone references. Wire archetypes to clean CC0 models in assets/3d/zombies/ (zombie_normal.glb, zombie_fast.glb, zombie_heavy.glb, zombie_boss.glb, infected_dog.glb).
   - In scenes/zombies/Zombie.tscn, replace zombie_doom.glb with assets/3d/zombies/zombie_normal.glb.
   - Move scenes/zombies/models/Real*.scn and proprietary character models to quarantine_suspect_assets/.
5. Update ASSET_LICENSES.md:
   - Accurately document all bundled assets, authors, licenses (CC0, MIT), and source URLs.
   - Document Section 7 quarantine status confirming all proprietary assets are strictly segregated.
6. Verification:
   - Run a python scan across all .tscn, .tres, and .gd files to verify 0 references to quarantine_suspect_assets, real/, gtarovestreet, realapartment, realdoom, etc.
   - Run godot --headless -s scripts/Tools/test_weapons_economy.gd (must pass 100%).
   - Run godot --headless -s scripts/Tools/test_ui_screens.gd (must pass 100%).
