## 2026-10-07T14:40:12Z
You are teamwork_preview_worker_m1_2.
Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1_2
Your parent is: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720

MANDATORY FIRST STEP:
Read:
1. /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md (specifically 2026-10-07T13:39:55Z and 2026-10-07T14:09:11Z)
2. /home/am/targetkill/PROJECT.md
3. /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_1/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE FILE OWNERSHIP:
You exclusively own and may edit:
- /home/am/targetkill/tools/build_gta5_open_world.gd
- /home/am/targetkill/resources/materials/mat_real_mountain_cliff.tres
- /home/am/targetkill/resources/materials/mat_real_asphalt_pbr.tres
- /home/am/targetkill/resources/materials/mat_city_sidewalk.tres
- /home/am/targetkill/resources/materials/mat_dirt_pbr.tres
- /home/am/targetkill/resources/materials/mat_real_grass_pbr.tres
- /home/am/targetkill/textures/pbr/*/*.import
- /home/am/targetkill/scenes/environments/WeatherController.gd
- /home/am/targetkill/scenes/environments/CityCarZombieArena.gd
- /home/am/targetkill/scenes/environments/CityCarZombieArena.tscn
DO NOT touch any vehicle physics or character scripts.

OBJECTIVE - MILESTONE 1: Visual Clarity & Environment Shading
Implement the fixes diagnosed in Explorer 1's survey report:
1. Mountain Mesh Normals & Winding Fix:
   - In `tools/build_gta5_open_world.gd`, fix the quad index winding order from clockwise `(i0, i2, i1)` / `(i1, i2, i3)` to counter-clockwise `(i0, i1, i2)` / `(i1, i3, i2)` so SurfaceTool calculates upward normals.
   - Add boundary skirt polygons extending from perimeter vertices down to y = -5.0m to seal open mesh boundaries.
   - In `resources/materials/mat_real_mountain_cliff.tres`, set `cull_mode = BaseMaterial3D.CULL_BACK` (0).
   - Regenerate the mountain meshes in `scenes/environments/CityCarZombieArena.tscn` using the fixed generator (or run a generator script) so that mountain meshes have upward normals and clean culling.
2. PBR Textures Mipmap Generation & Normal Compression:
   - For all `.import` files in `textures/pbr/` (asphalt, grass, ground, walls, mountain): set `mipmaps/generate = true` and `compress/normal_map = 1`.
   - Ensure Godot recognizes/reimports the textures with mipmaps enabled to eliminate sub-pixel sparkling dots.
3. Ground Materials Matte PBR Tuning & Lighting Balance (including GTA 5 Atmosphere F22):
   - In `mat_real_asphalt_pbr.tres`, `mat_dirt_pbr.tres`, `mat_real_grass_pbr.tres`, `mat_city_sidewalk.tres`: set `metallic_specular = 0.10` (or 0.05 for dirt/grass), set `roughness` to 0.92-0.96, and set `normal_scale` to 0.4-0.5.
   - In `mat_city_sidewalk.tres`: darken albedo from `Color(0.85, 0.85, 0.85)` to realistic matte concrete `Color(0.52, 0.52, 0.54)` to prevent HDR bloom blowouts.
   - In `WeatherController.gd`: set `road_specular = 0.10` in clear/sunny weather presets; clamp/disable `glow_bloom` during daylight (or set `glow_bloom = 0.0`) to stop sky-bleed white contour ribbons on mountains; ensure warm Los Santos golden sunlight and atmospheric valley mountain mist.
4. Pine Tree Foliage Clean Shading:
   - In `CityCarZombieArena.gd` (lines 73-86), replace broken `.specular = 0.05` with `pine_mat.metallic_specular = 0.0`.
   - Set `pine_mat.roughness = 1.0` and `pine_mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT`.
   - Set `c_mesh.cap_bottom = false` on foliage cones to remove flat disc rim edge reflections.

VERIFICATION:
Run and verify with:
- `godot --headless --script res://tools/diagnose_requirement1.gd`
- `godot --headless -s tools/test_arena_vehicles.gd`
Verify that mountain meshes report upward normals (`up_y > 0`, `down_y = 0`), no specular warnings, and scenes load cleanly with exit code 0.
