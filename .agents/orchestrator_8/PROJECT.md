# Project: Sector Zero: Lockdown — Combat Juiciness & Visceral Feedback System

## Architecture
This project implements the Combat Juiciness & Visceral Feedback System and AAA Tactical UI/UX Overhaul in Godot 4.3 under the `gl_compatibility` renderer:
1. **Screen Blood Splatter & Low-HP Feedback (R1)**: Dynamic fading blood droplets on the HUD dissipating over 2.5 seconds upon damage; rhythmic pulsing red vignette and looping heartbeat audio when health drops below 30% (<30 HP), cleanly subsiding when health recovers (>=30 HP).
2. **Visceral Headshot Decapitation & Impact FX (R2)**: Bone scaling and mesh hiding for instant decapitation on lethal headshots across all zombie archetypes; directional crimson blood spray and neck stump fountain using mobile-safe `CPUParticles3D`; synchronized with 2.5x critical hitmarker and bone crunch audio.
3. **Cinematic Last-Kill Slow-Motion Cam (R3)**: Final kill of Wave 3 or Giant Butcher Boss defeat triggers 0.2x `Engine.time_scale` for 1.8 real-world seconds with `AudioServer.playback_speed_scale` and `AudioEffectLowPassFilter` pitch/bass dip before cleanly restoring normal speed for `ResultUI`.
4. **Dedicated AAA Tactical UI/UX Polish Overhaul (User Directive)**: High-contrast typography, sci-fi/tactical glowing borders, polished button press feedback (scale dip, sound, hover glow), and mobile touch ergonomics across `MainMenu`, `ArmoryUI`, `MissionSelectUI`, `ResultUI`, and `HUD`.
5. **Performance & Mobile Compatibility Safeguards (R4)**: Clean execution in `gl_compatibility`, 30 FPS stability, zero orphaned nodes, <1 MB memory growth over 3 cycles, 100% pass rate on `test_realistic_overhaul.tscn` and all 13 missions in `validate_all_missions.gd`.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | F1: Screen Blood Splatter & 2.5s Dissipation | Dynamic canvas drawing of viscous droplets with gravity drip and smooth 2.5s cubic ease-out fade on damage | M1 | Survey (Explorer 1 / HUD) |
| 2 | F2: Low-HP Red Screen Vignette (<30 HP) | Radial gradient vignette pulsing with physiological cardiac double-thump at <30 HP; fades out upon recovery >=30 HP | M1 | Survey (Explorer 1 / HUD) |
| 3 | F3: Looping Heartbeat Audio & Recovery Fade | 16-bit 44.1kHz PCM seamless heartbeat audio stream playing during low-HP; smoothly fades out on health recovery | M1 | Survey (Explorer 1 / Audio) |
| 4 | F4: Visceral Headshot Decapitation | Immediate bone pose scale collapse (Vector3.ZERO) and head/eye mesh hiding on lethal headshots across all zombie models | M2 | Survey (Explorer 2 / Zombies) |
| 5 | F5: Directional Blood Burst & Neck Fountain FX | Directional CPUParticles3D bullet exit spray along hit_dir and neck stump blood fountain attached to collapsing torso | M2 | Survey (Explorer 2 / FX) |
| 6 | F6: Hitmarker & 2.5x Audio Synchronization | Synchronous execution of raycast, decapitation, blood spray, golden hitmarker, and sfx_headshot_crunch | M2 | Survey (Explorer 2 / Audio) |
| 7 | F7: Cinematic Last-Kill Slow-Motion Cam | Wave 3 final kill and Boss defeat trigger 0.2x Engine.time_scale for 1.8 real-world seconds before ResultUI | M3 | Survey (Explorer 3 / WaveManager) |
| 8 | F8: Audio Pitch & Low-Pass Bass Dip | AudioServer playback speed scaling and AudioEffectLowPassFilter bass isolation during slow-motion window | M3 | Survey (Explorer 3 / Audio) |
| 9 | F9: AAA Tactical UI/UX Polish Overhaul | Overhaul MainMenu, Armory, MissionSelect, ResultUI, and mobile HUD with dark tactical styling, glowing accents, tactile button feedback | M5 | User Directive (2026-09-13) |
| 10 | F10: Mobile gl_compatibility & Memory Safeguards | Zero shader compile stalls, particle pooling / cleanup, <1 MB memory growth over 3 reload cycles | M4 | Survey (Explorer 3 / Verification) |
| 11 | F11: Automated Regression & Mission Validation | 100% pass on scenes/test/test_realistic_overhaul.tscn, 13/13 missions in tools/validate_all_missions.gd | M4 | Survey (Explorer 3 / Verification) |
| 12 | F12: Forensic Integrity Audit | Independent verification by teamwork_preview_auditor confirming authentic logic and zero hardcoded cheats | M4 | Survey (Integrity Forensics) |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Screen Blood Splatter & Low-HP Feedback (R1) | Implement BloodSplatterOverlay (2.5s dissipation), LowHPVignette (<30 HP cardiac pulse & fadeout), and sfx_heartbeat_loop in HUD.tscn, scripts/HUD.gd, and audio assets. | none | IN_PROGRESS |
| M2 | Visceral Headshot Decapitation & Impact FX (R2) | Implement lethal headshot detection, bone scaling & mesh hiding in EnemyBase.gd / RealisticZombie.gd, directional blood spray & neck fountain CPUParticles3D FX, and audio sync. | M1 | PLANNED |
| M3 | Cinematic Last-Kill Slow-Motion Cam (R3) | Implement final kill Wave 3 & Boss defeat detection in GameManager.gd, 0.2x Engine.time_scale for 1.8s real-time, audio pitch/bass dip, and seamless ResultUI transition. | M1, M2 | PLANNED |
| M5 | Dedicated AAA Tactical UI/UX Polish Overhaul | Polish MainMenu, Armory, MissionSelect, ResultUI, and mobile HUD button states with glowing accents, tactile feedback, and clean mobile ergonomics. | none | PLANNED |
| M4 | Performance, E2E Verification & Forensic Audit (R4) | Verify 100% pass on test_realistic_overhaul.tscn, validate_all_missions.gd, 3-cycle arena memory test (<1MB growth), run reviewer, challenger, and forensic auditor. | M1, M2, M3, M5 | PLANNED |

## Interface Contracts

### HUD ↔ Player (`scripts/HUD.gd` ↔ `scenes/player/Player.gd`)
- `HUD.update_health(value: float, max_val: float = 100.0)`
  - If `value < previous_health`: triggers `trigger_blood_splatter(clamp(dmg / 20.0, 0.8, 2.0))`.
  - If `value < 30.0`: activates `is_low_hp = true`, driving rhythmic double-pulse red vignette and looping heartbeat.
  - If `value >= 30.0`: activates `is_low_hp = false`, smoothly fading out vignette and heartbeat.
- `HUD.trigger_blood_splatter(intensity: float = 1.0)`: Public method adding dynamic droplets that dissipate over 2.5 seconds.

### Zombie Decapitation & Combat (`scripts/Zombies/EnemyBase.gd` ↔ `scripts/Combat/HitZone.gd`)
- `EnemyBase.take_damage(amount: float, is_headshot: bool = false, hit_dir: Vector3 = Vector3.ZERO)`:
  - Stores `last_hit_was_headshot = is_headshot` and `last_hit_dir = hit_dir`.
  - When `current_health <= 0`: in `_on_died()`, if `last_hit_was_headshot`:
    - Executes `_trigger_decapitation(last_hit_dir)`.
    - Collapses head bone (`set_bone_pose_scale(b_head, Vector3.ZERO)`).
    - Hides head mesh instances.
    - Spawns directional blood burst aligned with `last_hit_dir` and attaches neck stump fountain to `model_instance`.

### Slow-Motion Manager (`scripts/GameManager.gd` ↔ `scripts/MissionManager.gd` ↔ `scenes/UI/ResultUI.gd`)
- `GameManager`:
  - Tracks living spawned enemies.
  - When lethal damage is dealt to final enemy of Wave 3 in non-endless mission, or to Boss:
    - Sets `Engine.time_scale = 0.2`.
    - Modulates `AudioServer.playback_speed_scale = 0.5` and enables `AudioEffectLowPassFilter` on Master bus.
    - Uses `get_tree().create_timer(1.8, true, false, true)` for exact 1.8s real wall-clock duration.
    - Restores `Engine.time_scale = 1.0`, restores audio speed, disables filter, and triggers `MissionManager.finish_mission(true)`.

### UI/UX Polish Standards (`scenes/UI/*`)
- Dark tactical palette: Deep charcoal `#0e1117`, gunmetal `#1a1f29`, tactical amber/orange accents `#ff8c00` / glowing cyan `#00d2ff`.
- Buttons: Hover glow border (`StyleBoxFlat`), press scale dip (0.97 scale tween on press, 1.0 on release), standard UI click sound.
- Mobile layout: Minimum touch target 48x48dp, safe margins, uncaptured mouse cursor (`Input.MOUSE_MODE_VISIBLE`).

## Code Layout
- `scenes/UI/HUD.tscn`, `scripts/HUD.gd`: BloodSplatterOverlay, LowHPVignette, HeartbeatPlayer
- `audio/player/sfx_heartbeat_loop.wav`: 16-bit 44.1kHz seamless heartbeat loop
- `scripts/Zombies/EnemyBase.gd`, `assets/zombies/RealisticZombie.gd`: Decapitation logic, hit_dir tracking, bone scaling, mesh hiding
- `scripts/Combat/HitZone.gd`: Damage multiplier and headshot signaling
- `scripts/GameManager.gd`: Living zombie tracking, final kill detection, 0.2x slowmo for 1.8s, audio pitch/bass dip
- `scenes/UI/MainMenu.tscn`, `scenes/UI/ArmoryUI.tscn`, `scenes/UI/MissionSelectUI.tscn`, `scenes/UI/ResultUI.tscn`: Tactical AAA styling and button interactions
- `scenes/test/test_realistic_overhaul.tscn`, `tools/validate_all_missions.gd`: Regression and mission verification
