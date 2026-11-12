# BRIEFING — 2026-10-07T14:10:00Z

## Mission
Implement Milestone 1: Visual Clarity & Environment Shading fixes diagnosed in Explorer 1's survey report.

## 🔒 My Identity
- Archetype: preview_worker
- Roles: implementer, qa, specialist
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_worker_m1
- Original parent: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Milestone: Milestone 1: Visual Clarity & Environment Shading

## 🔒 Key Constraints
- Exclusive file ownership:
  - tools/build_gta5_open_world.gd
  - resources/materials/mat_real_mountain_cliff.tres
  - resources/materials/mat_real_asphalt_pbr.tres
  - resources/materials/mat_city_sidewalk.tres
  - resources/materials/mat_dirt_pbr.tres
  - resources/materials/mat_real_grass_pbr.tres
  - textures/pbr/*/*.import
  - scenes/environments/WeatherController.gd
  - scenes/environments/CityCarZombieArena.gd
  - scenes/environments/CityCarZombieArena.tscn
- DO NOT touch any vehicle physics or character scripts.
- Integrity mandate: No cheating, no hardcoded test outputs or fake verification.

## Current Parent
- Conversation ID: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Updated: not yet

## Task Summary
- **What to build**: Fix mountain mesh winding order, add skirt polygons, set cull_mode to back-cull, regenerate mountain meshes; enable mipmaps and normal compression on all PBR texture imports; adjust ground materials PBR settings (matte specular, roughness, normal scale, sidewalk albedo); update WeatherController daytime bloom/specular; fix pine foliage material (metallic_specular, roughness, lambert, cap_bottom).
- **Success criteria**: upward normals (`up_y > 0`, `down_y = 0`), no specular warnings, headless diagnostics and vehicle tests pass cleanly with exit code 0.
- **Interface contracts**: /home/am/targetkill/PROJECT.md
- **Code layout**: /home/am/targetkill/PROJECT.md

## Key Decisions Made
- [TBD]

## Artifact Index
- DISPATCH.md — Assignment instructions
- progress.md — Liveness & task progress
- handoff.md — 5-component completion report

## Change Tracker
- **Files modified**: None yet
- **Build status**: Untested
- **Pending issues**: None

## Quality Status
- **Build/test result**: Untested
- **Lint status**: Clean
- **Tests added/modified**: None yet

## Loaded Skills
- None
