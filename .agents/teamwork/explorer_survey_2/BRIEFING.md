# BRIEFING — 2026-10-09T13:18:20Z

## Mission
Investigate Godot 4 water shader technicalities, gl_compatibility constraints, depth/screen texture support, wave normal mapping, and low-end hardware performance for jungle lake.

## 🔒 My Identity
- Archetype: explorer
- Roles: survey, investigation
- Working directory: /home/am/targetkill/.agents/teamwork/explorer_survey_2
- Original parent: 22f82a51-2f07-4ca9-8758-ceaa338f2f8b
- Milestone: explorer_survey_2

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- gl_compatibility (OpenGL 3.3 / GLES3) rendering and low-end AMD Kabini APU (3.3 GB RAM) compatibility
- No modification to game or source files outside working directory

## Current Parent
- Conversation ID: 22f82a51-2f07-4ca9-8758-ceaa338f2f8b
- Updated: 2026-10-09T13:18:20Z

## Investigation State
- **Explored paths**:
  - `project.godot`: verified gl_compatibility mode, Godot 4.7.2.stable.
  - `resources/mobile_pbr.gdshader`: examined syntax and render_mode.
  - `scripts/QualityManager.gd`: examined legacy profile and CPUParticles3D stripping.
  - `tools/build_advanced_terrain.gd`: examined valley boundaries and terrain layout.
  - Shader compilation tests: verified `#if CURRENT_RENDERER == RENDERER_COMPATIBILITY`, `hint_depth_texture`, Whiteout normal blend, TBN Fresnel.
- **Key findings**:
  - Depth texture supported in gl_compatibility, but requires OpenGL NDC range `[-1.0, 1.0]` (`vec3(SCREEN_UV, depth) * 2.0 - 1.0`).
  - SSR is unsupported in gl_compatibility; reflections must use GGX Specular Sun Glitter, Environment Sky IBL, and static ReflectionProbe.
  - CPUParticles3D is disabled on AMD Kabini profile by QualityManager; AudioStreamPlayer3D is required for reliable atmosphere.
- **Unexplored areas**: None for survey scope.

## Key Decisions Made
- Fully documented cross-renderer NDC math and full blueprint shader in `analysis.md` and `handoff.md`.

## Artifact Index
- /home/am/targetkill/.agents/teamwork/explorer_survey_2/analysis.md — technical analysis
- /home/am/targetkill/.agents/teamwork/explorer_survey_2/handoff.md — 5-component handoff report
