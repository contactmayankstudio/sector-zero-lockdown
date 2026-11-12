# Dispatch: explorer_slowmo_wave

## Mission
Investigate Wave progression, Boss defeat, Time Scale, Audio Modulation, and Verification Targets for Requirements R3 & R4 (Cinematic Last-Kill Slow-Motion Cam & Performance/Verification).

## Target Systems
- `scripts/Managers/WaveManager.gd`, `scripts/Managers/GameManager.gd`, `scenes/UI/ResultUI.gd`
- Detecting final kill of Wave 3 or Boss defeat
- Slow-motion scaling: `Engine.time_scale` (0.2x for 1.8s real time)
- Audio pitch/bass dip: AudioServer bus pitch shift / low-pass filter / master pitch
- Transition back to normal speed for Victory/Result UI
- Verification targets: `scenes/test/test_realistic_overhaul.tscn`, `tools/validate_all_missions.gd`, arena reloads/memory checks.

## Output
Write complete findings and recommendations to `/home/am/targetkill/.agents/explorer_slowmo_wave/handoff.md`.

## 2026-09-13T18:26:32Z
Investigate Requirement R3: Cinematic Last-Kill Slow-Motion Cam and Requirement R4: Performance & Verification Targets:
- Upon eliminating the final zombie in Wave 3 or defeating the Giant Butcher Boss, momentarily scale game time down to 0.2x speed for 1.8 seconds with an audio pitch/bass dip to deliver a satisfying cinematic climax before restoring normal speed for the Victory/Result UI.
- All new overlays, particle systems, and time-scale logic must run cleanly in Godot 4.3's gl_compatibility renderer, maintaining 30 FPS stability and zero memory growth across extended play sessions (<1MB across 3 cycles).
- Verification targets: scenes/test/test_realistic_overhaul.tscn, tools/validate_all_missions.gd, and sequential arena reloads.

Examine:
1. scripts/Managers/WaveManager.gd, scripts/Managers/GameManager.gd, and scenes/UI/ResultUI.gd (how waves are tracked, how final kill of Wave 3 is detected, how boss defeat is detected, and where the victory sequence is delayed/triggered).
2. Engine.time_scale manipulation: How to scale to 0.2x for 1.8s (real-time seconds vs scaled seconds, handling Timer with process_mode = PROCESS_MODE_ALWAYS or SceneTreeTimer(..., false, false, true)).
3. Audio pitch and bass dip: AudioServer master or music/sfx bus modulation, pitch shift effect vs AudioServer.playback_speed / pitch_scale, restoring cleanly.
4. Verification scripts: scenes/test/test_realistic_overhaul.tscn, tools/validate_all_missions.gd, how they run and what assertions they test.
5. Node cleanup and memory safeguards: Preventing orphaned particle nodes, audio players, or tweens.
