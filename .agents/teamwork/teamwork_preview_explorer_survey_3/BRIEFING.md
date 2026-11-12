# BRIEFING — 2026-10-07T14:05:00Z

## Mission
Survey the codebase for Requirement 3: Anti-Hang Optimization & Low-End Laptop Performance & Verification.

## 🔒 My Identity
- Archetype: explorer
- Roles: survey, performance analysis, verification tooling review
- Working directory: /home/am/targetkill/.agents/teamwork/teamwork_preview_explorer_survey_3
- Original parent: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Milestone: survey

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- Analyze performance profiles & memory budget for AMD Kabini (3.3 GB RAM target), OpenGL3/gl_compatibility renderer configuration
- Open-world loading, terrain chunks, LOD, shadow settings, texture compression/sizes, zombie spawning/AI performance
- Verification tooling inspection (headless test scripts, scene validation)
- Identify bottlenecks, heavy textures, unoptimized shaders, memory leaks

## Current Parent
- Conversation ID: a6b5fa14-4f3f-4337-ac5b-dfa19a56c720
- Updated: 2026-10-07T13:43:30Z

## Investigation State
- **Explored paths**:
  - `project.godot`: rendering method `gl_compatibility`, `scaling_3d=0.85`, shadow map 1024, etc.
  - `scripts/QualityManager.gd` & `scripts/Performance/PerformanceManager.gd`: ANDROID_LEGACY vs BALANCED profiles, adaptive frame pacing throttling.
  - `scenes/environments/CityCarZombieArena.tscn` & `.gd`: Open-world GTA/PUBG arena with mountains, highway, 48 trees, vehicles, weather.
  - `scenes/vehicles/DrivableBike.tscn` & `.gd`: Hayabusa superbike with 3.3 MB text PackedByteArray, dynamic lights.
  - `scenes/vehicles/DrivableCar.tscn` & `.gd`: Drivable car with 6.7 MB text PackedByteArray.
  - `textures/pbr/*`: 1K textures imported with `compress/mode=0` and `mipmaps/generate=false` causing severe aliasing and texture cache misses.
  - `scenes/zombies/Zombie.tscn` & `scripts/Zombies/EnemyBase.gd`: 33 initial zombies each spawning an OmniLight3D eye glow.
  - `scenes/test/TestRunner.tscn`, `scenes/test/test_realistic_overhaul.tscn`, `tools/test_arena_vehicles.gd`: Automated test runners.
- **Key findings**:
  1. Memory budget: Game in headless uses ~566 MB static RAM, safe within 3.3 GB Kabini budget if kept under 1 GB to avoid OS swap thrashing.
  2. Scene load time bottleneck: Text parsing 10+ MB of `.tscn` data (`DrivableCar.tscn` 6.7 MB, `DrivableBike.tscn` 3.3 MB) takes ~9.6 seconds in headless; binary `.scn` reduces this dramatically.
  3. Non-mipmapped uncompressed textures: `compress/mode=0` and `mipmaps/generate=false` on all PBR terrain/cliff textures cause shimmering noise and cache thrashing.
  4. Dynamic light proliferation in `gl_compatibility`: 33 zombie eye lights, vehicle headlights/spotlights, streetlights create massive multi-pass draw call overhead.
  5. Inverted mountain normals + triplanar mapping: 12 texture reads per fragment on huge mountain meshes; normals point downward (-Y).
  6. QualityManager profile bypass: `CityCarZombieArena.gd` overrides 3D scale to 1.0 and forces shadows on, bypassing profile settings.
  7. Verification status: `test_arena_vehicles.gd` passes with code 0; `TestRunner.tscn` passes 51/54; `test_realistic_overhaul.tscn` fails 25/59 due to retired weapons; no comprehensive Requirement 3 scene validator exists yet.
- **Unexplored areas**: Implementation of optimizations (deferred to implementer agents).

## Key Decisions Made
- Completed systematic codebase profiling and measurement in headless Godot.
- Isolated exact files, lines, and metrics for all 4 objective areas.

## Artifact Index
- DISPATCH.md — record of incoming dispatch
- progress.md — liveness heartbeat and progress tracking
- BRIEFING.md — persistent working memory
- measure_perf.gd — headless memory and node profiling script
- test_leak_source.gd / test_zombie_leak.gd — leak isolation tests
- handoff.md — comprehensive survey report
