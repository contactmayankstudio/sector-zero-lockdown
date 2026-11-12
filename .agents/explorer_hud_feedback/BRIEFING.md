# BRIEFING — 2026-09-13T18:34:00Z

## Mission
Investigate HUD, Player damage signaling, and audio infrastructure for Requirement R1: Screen Blood Splatter & Low-HP Feedback.

## 🔒 My Identity
- Archetype: explorer
- Roles: explorer_hud_feedback
- Working directory: /home/am/targetkill/.agents/explorer_hud_feedback
- Original parent: e02d2964-7812-4936-894c-476d2b599b6f
- Milestone: Combat Juiciness & Visceral Feedback System - R1: Screen Blood Splatter & Low-HP Feedback

## 🔒 Key Constraints
- Read-only investigation — do NOT implement
- Mobile/gl_compatibility compatibility (30 FPS budget, zero memory leak, low-spec AMD APU / Android target)
- No modification of production files directly (produce analysis report in working directory)

## Current Parent
- Conversation ID: e02d2964-7812-4936-894c-476d2b599b6f
- Updated: 2026-09-13T18:29:17Z

## Investigation State
- **Explored paths**:
  - `scenes/UI/HUD.tscn` and `scripts/HUD.gd`
  - `scenes/player/Player.tscn` and `scenes/player/Player.gd`
  - `scripts/Zombies/EnemyBase.gd`, `assets/zombies/RealisticZombie.gd`, `scenes/zombies/AcidSpit.gd`
  - `scripts/AudioManager.gd`, `project.godot`, and `audio/` directory
  - `scenes/test/test_realistic_overhaul_e2e.gd` (88/88 PASSED) and `tools/validate_all_missions.gd`
- **Key findings**:
  1. `HUD.tscn` / `HUD.gd` uses a CanvasLayer with full-screen Controls (`DamageOverlay`, `ClawScratchOverlay`, `DirectionalDamage`) using `mouse_filter = MOUSE_FILTER_IGNORE`.
  2. No 2.5s dynamic blood splatter overlay or low-HP vignette exists currently; `DamageOverlay` is merely a flat ColorRect.
  3. No heartbeat audio file exists in `res://audio/`.
  4. `Player.gd` regenerates health at 8 HP/sec out of combat (`damage_cooldown <= 0.0`), updating `hud.update_health()` continuously, ensuring automatic testable recovery above 30 HP.
  5. `gl_compatibility` constraints favor custom `_draw()` Control for blood splatters (zero memory allocation/node churn, 0 particles) and `TextureRect` with `GradientTexture2D` radial gradient for low-HP vignette (zero fragment shader fill-rate penalty).
  6. Heartbeat audio can be synthesized cleanly via Python standard library `wave`/`struct` as a 16-bit 44.1kHz dual-thump ("lub-dub") seamless loop (`sfx_heartbeat_loop.wav`).
- **Unexplored areas**: None. All target files and systems thoroughly analyzed.

## Key Decisions Made
- Architecture for Blood Splatters: Dedicated `BloodSplatterOverlay` Control using procedural `_draw()` with array of splatter dicts (droplets + downward runny trails), fading smoothly over exactly 2.5 seconds with cubic ease-out.
- Architecture for Low-HP Vignette: `LowHPVignette` TextureRect with cached radial gradient, driven by a double-pulse physiological heartbeat rhythm in `_process(delta)` when health < 30 HP, smoothly fading to 0 upon health >= 30 HP.
- Architecture for Heartbeat Audio: 16-bit PCM WAV `sfx_heartbeat_loop.wav` in `res://audio/player/` with playback controlled via `HeartbeatAudio` player in `HUD` and API methods in `AudioManager`.

## Artifact Index
- /home/am/targetkill/.agents/explorer_hud_feedback/BRIEFING.md — persistent working memory
- /home/am/targetkill/.agents/explorer_hud_feedback/DISPATCH.md — dispatch instructions
- /home/am/targetkill/.agents/explorer_hud_feedback/progress.md — liveness heartbeat
- /home/am/targetkill/.agents/explorer_hud_feedback/handoff.md — complete handoff report
