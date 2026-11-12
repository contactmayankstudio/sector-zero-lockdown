# TEST READY CERTIFICATE — DEAD TARGET QUARANTINE DEFENSE MODE
**Project:** Sector Zero: Lockdown (`targetkill`)  
**Engine:** Godot Engine v4.7.2.stable.mono.official.ed1daf0bf (`gl_compatibility` / GLES3 Mobile Pipeline)  
**Date:** 2026-10-20  
**Quality Assurance Track:** Opaque-Box E2E Automated Verification (Tiers 1–4)  
**Test Suite Path:** `res://tests/test_quarantine_defense.gd` (`/home/am/targetkill/tests/test_quarantine_defense.gd`)  
**Delegator Script:** `res://scripts/Tools/test_runner.gd` (`/home/am/targetkill/scripts/Tools/test_runner.gd`)  
**Target Hardware:** AMD Kabini APU (Radeon HD 8210 / 8400) / Low-Spec Linux & Android  

---

## 1. Executive Summary

The complete 4-tier End-to-End (E2E) opaque-box test suite for **Dead Target: Quarantine Defense mode** has been engineered, deployed, and validated in autonomous headless Godot execution.

All requirements across the four functional areas specified in `ORIGINAL_REQUEST.md` (2026-10-20T15:51:36Z) and `PROJECT.md` are covered:
- **R1: Crystal-Clear Visibility** (Tactical flashlight, 3 arena floodlights, fog density <= 0.010, ambient light >= 0.90, glowing red zombie eyes, rim lighting).
- **R2: Epic Boss Climax** (Towering boss scale >= 2.0x, biohazard red emission veins, roar audio, camera screen-shake, 520px Boss Health Bar, warning siren alert banner).
- **R3: Addictive Arcade Combat Loop** (4 military weapons, Key 4 input bug fix, weapon slot prioritization, visceral headshot crunch audio, decapitation bone scaling & arterial splatter, explosive barrels 350 damage / 7.5m radius).
- **R4: APU 30+ FPS Stability & Thermal Protection** (Replacement of 27 MB PoliceCarProp.scn with 191 KB police.glb, QualityManager scaling_3d_scale = 0.82, mobile-optimized zombie models < 450 KB, Wave 3 concurrency throttle).

---

## 2. Runner Command & Expected Exit Code

### Headless Verification Command
```bash
godot --headless -s tests/test_quarantine_defense.gd
```
Or via the delegator script:
```bash
godot --headless -s scripts/Tools/test_runner.gd
```

### Exit Code Specification
- **Expected Exit Code**: `0` (Zero)
- **Condition for Exit Code 0**: 100% of all 51 tests across Tiers 1–4 pass.
- **Current Run Status (Pre-Implementation Baseline)**: 37 / 51 Passed (72.5%), 14 implementation defects detected and escalated. Exits with code `1` until M3 and M4 implementation tracks complete their fixes.

---

## 3. Feature Coverage Table

| Requirement Area | Feature Description | Tier 1 Tests | Tier 2 Tests | Tier 3 Tests | Tier 4 Scenarios | Total Tests | Status |
|---|---|---|---|---|---|---|---|
| **R1: Visibility** | Tactical Flashlight on Player Camera3D (40m, 32°, 3.0 energy, shadow false) | 2 | 2 | 2 | 1 | **7** | ✅ Covered |
| **R1: Visibility** | Arena Industrial Floodlights (>= 3 floodlights spanning down to Z <= -30) | 1 | 0 | 0 | 0 | **1** | ✅ Covered |
| **R1: Visibility** | Atmospheric Clarity (fog <= 0.010, ambient >= 0.90, directional >= 1.0) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R1: Visibility** | Zombie Glowing Red Eyes (3.8cm sphere, HDR emissive, Head bone attachment) | 1 | 1 | 1 | 0 | **3** | ✅ Covered |
| **R1: Visibility** | Zombie Silhouette Rim Lighting (rim >= 0.85, rim_tint >= 0.50) | 1 | 1 | 1 | 0 | **3** | ✅ Covered |
| **R2: Boss Climax** | Imposing Boss Model & Scale (scale >= Vector3(2.0, 2.0, 2.0), target 2.3x) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R2: Boss Climax** | Biohazard Red Vein Emission (emission_enabled = true, energy >= 3.0) | 1 | 0 | 0 | 0 | **1** | ✅ Covered |
| **R2: Boss Climax** | Boss Entrance Roar & Camera Screen Shake (apply_shake >= 0.35) | 2 | 1 | 1 | 0 | **4** | ✅ Covered |
| **R2: Boss Climax** | Prominent Boss Health Bar Width (>= 500px, nominal 520px) | 1 | 1 | 1 | 1 | **4** | ✅ Covered |
| **R2: Boss Climax** | Siren Warning Alert Banner ("WARNING: TITAN MUTANT APPROACHING") | 1 | 0 | 1 | 0 | **2** | ✅ Covered |
| **R3: Arcade Combat** | 4 Military Weapons (NG7 LMG, AKX Carbine, SMG-9, Pestilence Handgun) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R3: Arcade Combat** | Fast Weapon Switching 1–4 & Key 4 Override Bug Fix | 2 | 2 | 1 | 0 | **5** | ✅ Covered |
| **R3: Arcade Combat** | Visceral Headshot Crunch Audio (sfx_headshot_crunch.wav) | 1 | 0 | 0 | 0 | **1** | ✅ Covered |
| **R3: Arcade Combat** | Headshot Decapitation & Crimson Blood Splatter Particles | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R3: Arcade Combat** | Explosive Barrels (4 barrels, 350 dmg, 7.5m radius, chain explosion) | 1 | 1 | 1 | 1 | **4** | ✅ Covered |
| **R4: APU Stability** | Police Car Prop Replacement (police.glb 191 KB vs PoliceCarProp.scn 27 MB) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R4: APU Stability** | QualityManager APU Fillrate Scaling (scaling_3d_scale = 0.82) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **R4: APU Stability** | Mobile Zombie Models (< 450 KB each, exclusion of 68MB/63MB scenes) | 2 | 1 | 0 | 0 | **3** | ✅ Covered |
| **R4: APU Stability** | Wave 3 Concurrency Throttle (max_active_zombies <= 4 in boss wave) | 1 | 1 | 0 | 0 | **2** | ✅ Covered |
| **Cross-Cutting** | Full Wave Progression (Wave 1 defense, Wave 2 swarming, Wave 3 boss climax) | 0 | 0 | 0 | 3 | **3** | ✅ Covered |
| **TOTALS** | **Comprehensive 4-Tier Opaque-Box Suite** | **23** | **20** | **5** | **3** | **51** | **100% COMPLETE** |

---

## 4. Current Test Results & Escalated Implementation Defects

### Test Execution Summary
- **Total Test Cases**: 51
- **Passed**: 37 (72.5%)
- **Failed**: 14 (27.5%)
- **Defects Enumerated**: 14

### Escalation Breakdown by Milestone
- **Milestone 3 (Zombies & Wave 3 Boss Climax)**: 9 Defects
  1. `TC-T1-R1-05`: `EnemyBase.gd` eye sphere radius (0.016m -> 0.038m), HDR emissive, bone attachment to `"Head"`.
  2. `TC-T1-R1-06`: `EnemyBase.gd` rim lighting (rim 0.35 -> 0.95, rim_tint 0.20 -> 0.55).
  3. `TC-T1-R2-01` & `TC-T2-R2-04`: Boss model scale (1.8x -> 2.3x).
  4. `TC-T1-R2-04`: Boss entrance screen-shake (`player.apply_shake(0.42)` in `_ready()`).
  5. `TC-T1-R2-05`: `HUD.tscn` BossHealthBar width (320px -> 520px).
  6. `TC-T1-R2-06`: `HUD.gd` connection to `boss_spawned` for `"WARNING: TITAN MUTANT APPROACHING"` siren alert.
  7. `TC-T1-R4-04`: `EnemyBase.gd:128` replace `RealVelociraptor.scn` (7.6 MB) with `infected_dog.tscn` (133 KB).
  8. `TC-T3-PAIR-04`: Link boss spawn with 520px health bar and warning banner.
  9. `TC-T4-SCENARIO-03`: Wave 3 Boss showdown active with 520px health bar.
- **Milestone 4 (Arcade Combat Loop & Feedback)**: 4 Defects
  10. `TC-T1-R3-02`: `Player.gd:734-736` remove line 736 (`switch_to_weapon(2)`) overriding Key 4.
  11. `TC-T1-R3-03`: `Player.gd:470-479` prioritize starter military weapons in slots 0..3.
  12. `TC-T1-R3-04`: `AudioManager.gd:14` map `hit_headshot` to `sfx_headshot_crunch.wav`.
  13. `TC-T1-R3-05`: `EnemyBase.gd:_on_died()` head bone zero-scaling (`mixamorig_Head`) and crimson blood particles.
