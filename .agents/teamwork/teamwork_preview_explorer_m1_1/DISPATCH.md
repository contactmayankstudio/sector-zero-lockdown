## 2026-10-10T18:45:13Z
You are Explorer 1 for Milestone 1 (F1, F2, F3: Terrain Colliders, Scene Serialization & Shoulder Transitions).
Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_1
You MUST read /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md and /home/am/targetkill/PROJECT.md before starting work.
Also read the prior survey report at /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_1_gen6/handoff.md.
You are read-only. Do NOT modify source code files or project assets.

Your objective is to design the exact implementation plan for:
1. Pre-baking ConcavePolygonShape3D colliders into `scenes/environments/CityCarZombieArena.tscn` for:
   - MountainWest, MountainEast, ValleyFloor, MountainNorthWall, MountainSouthWall, DirtPath_West, DirtPath_East, MountainRoad_West, MountainRoad_East, SidewalkLeft, SidewalkRight, DirtShoulderLeft, DirtShoulderRight.
   - Inspect `tools/bake_terrain_colliders.gd`. Design the exact GDScript code to load the scene, generate `create_trimesh_shape()`, assign CollisionShape3D nodes to static bodies, set `owner = scene_root` properly so Godot PackedScene serializes them into the file, and re-save the scene.
2. In `scenes/environments/CityCarZombieArena.gd`:
   - Eliminate runtime `create_trimesh_collision()` calls in `_ensure_solid_terrain_collisions()` (which causes a 65s freeze and 350MB+ allocation spike triggering OOM 137).
3. Highway transition and barrier cleanup:
   - Remove the 8 `ConcreteBarrierA.scn` obstacles (`Barrier_0` through `Barrier_7`) at x = ±10.5m in `CityCarZombieArena.tscn` to allow unobstructed vehicle passage off-road.
   - Smooth sidewalk heights so step onto sidewalks and dirt shoulders is flush (<= 0.02m).

Produce your implementation blueprint at `/home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_1/handoff.md`.
Use send_message to report completion when done.
