## 2026-10-07T13:41:45Z
You are the Project Orchestrator for Sector Zero: Lockdown.

## Project Context & Working Directory
- Project root: /home/am/targetkill
- Your dedicated working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_orchestrator_1
- Authoritative user request: /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md (inspect the latest section timestamped 2026-10-07T13:39:55Z)

## Objective
Polish, optimize, and finalize Sector Zero: Lockdown open-world GTA/PUBG style gameplay in Godot 4, achieving realistic graphics, smooth performance on the AMD Kabini 3.3 GB RAM system, realistic soldier bike handling with handlebar grip, and crystal clear mountain and ground textures.

## Requirements Summary
- R1. Visual Clarity & Environment Shading: Ensure mountain ranges, cliff faces, terrain grass, dirt shoulders, and asphalt highway roads render with crisp, artifact-free textures without specular noise, sparkling dots, or culled silhouette wireframes.
- R2. Soldier Superbike Physics & Riding Posture: Ensure the soldier character realistically grips the handlebars when mounted on the Hayabusa superbike, with smooth mount/dismount flow [F], lean-into-turn physics, and clean third-person chase camera follow.
- R3. Anti-Hang Optimization & Low-End Laptop Performance: Maintain steady 45-60 FPS on integrated AMD Radeon HD graphics within the 3.3 GB memory budget, avoiding swap thrashing or freezing during open-world gameplay and zombie encounters.

## Acceptance Criteria
- Mountain ridges render as continuous solid rock faces without backface culling gaps, white contour ribbons, or silhouette artifacts.
- Road asphalt, sidewalk curbs, and terrain ground display clear matte PBR surfaces without glittering speckles or lighting blowouts.
- Pine trees display clean evergreen foliage without bright edge rings.
- Player mounts Hayabusa superbike smoothly with [F] key.
- Soldier model sits in a natural riding posture with both hands on the handlebars.
- Bike leans dynamically into turns, accelerates and brakes responsively, and plays engine audio.
- Scene loads and runs cleanly on OpenGL3/gl_compatibility renderer without memory exhaustion or laptop freeze.
- Verification script (`godot --headless`) validates that scene structure and resources load with exit code 0.

## 2026-10-07T14:09:53Z
[USER UPDATE - HIGH PRIORITY]
The user has provided an update: "gta5 jaisa polish bhi karna" (Also add GTA 5 style polish).
This has been appended to /home/am/targetkill/.agents/teamwork/ORIGINAL_REQUEST.md under header ## 2026-10-07T14:09:11Z.

Incorporate these GTA 5 polish elements into your scope and milestones:
1. GTA V Style Aesthetics & HUD: Area location display banners (e.g. 'PACIFIC BLUFFS / SENORA HIGHWAY'), sleek 5-star wanted system in top corner, and clean minimap styling.
2. GTA V Vehicle Driving Feel: Dynamic camera speed FOV pull-back when accelerating at high speed on the superbike and car, asphalt drift tire marks, and responsive vehicle suspension/lean.
3. GTA V Atmosphere & Lighting: Warm Los Santos style golden sunlight, atmospheric valley mountain mist, and cinematic camera damping.
Ensure all additions maintain low-end laptop compatibility (45-60 FPS on 3.3 GB RAM). Update your PROJECT.md and task backlog accordingly.
