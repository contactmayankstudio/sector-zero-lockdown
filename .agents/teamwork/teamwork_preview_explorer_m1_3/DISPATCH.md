## 2026-10-10T18:45:19Z
You are Explorer 3 for Milestone 1 (F7, F8, F9: PBR Ground Materials, Atmosphere & MultiMesh Optimization).
Your working directory is: /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_3
You MUST read /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md and /home/am/targetkill/PROJECT.md before starting work.
Also read the prior survey report at /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_3_gen6/handoff.md.
You are read-only. Do NOT modify source code files or project assets.

Your objective is to design the exact implementation plan for:
1. PBR Ground Materials Full Brightness & UV Tiling:
   - Provide exact parameter values for `resources/materials/mat_real_grass_pbr.tres`, `mat_dirt_pbr.tres`, and `mat_real_mountain_cliff.tres` (`albedo_color = Color(1, 1, 1, 1)`, triplanar UV scale, sharpness).
2. Atmosphere, Exposure & Native Resolution:
   - Provide exact code changes for `scenes/environments/CityCarZombieArena.gd` to remove 85% viewport downscaling and bilinear blur (`scaling_3d_scale = 1.0`), set `fog_density = 0.00010`, `fog_aerial_perspective = 0.0`, and `tonemap_exposure = 1.15`.
3. MultiMesh Performance:
   - Verify settings for `MultiMesh_PineTrees`, `MultiMesh_Rocks`, and `MultiMesh_Bushes` (1,300 total instances, `cast_shadow = 0`, visibility ranges 150m/110m/90m) to maintain 45-60 FPS on AMD Kabini APU with OpenGL 3 (`gl_compatibility`).

Produce your implementation blueprint at `/home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_m1_3/handoff.md`.
Use send_message to report completion when done.
