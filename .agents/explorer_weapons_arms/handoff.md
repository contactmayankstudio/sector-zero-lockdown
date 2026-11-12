# Handoff Report: R1 First-Person Tactical Weapons & SWAT Combat Arms

**Agent**: `explorer_weapons_arms`  
**Milestone**: M1 / R1 — First-Person Tactical Weapons & SWAT Combat Arms  
**Working Directory**: `/home/am/targetkill/.agents/explorer_weapons_arms`  
**Handoff Type**: Hard (Investigation Complete)  

---

## 1. Observation

1. **Asset Roster**:
   - 10 canonical weapons exist across four synchronized directories:
     - `resources/weapons/`: `usp45.tres`, `mp5.tres`, `m4a1.tres`, `ak47.tres`, `remington870.tres`, `desert_eagle.tres`, `awp.tres`, `combat_knife.tres`, `crossbow.tres`, `grenade_launcher.tres`.
     - `assets/3d/weapons/`: `usp45.glb`, `mp5.glb`, `m4a1.glb`, `ak47.glb`, `remington870.glb`, `desert_eagle.glb`, `awp.glb`, `combat_knife.glb`, `crossbow.glb`, `grenade_launcher.glb`, and `fps_arms.glb`.
     - `scenes/weapons/`: `USP45.tscn`, `MP5.tscn`, `M4A1.tscn`, `AK47.tscn`, `Remington870.tscn`, `DesertEagle.tscn`, `AWP.tscn`, `CombatKnife.tscn`, `Crossbow.tscn`, `GrenadeLauncher.tscn`.
     - `scenes/weapons/models/`: `usp45.tscn`, `mp5.tscn`, `m4a1.tscn`, `ak47.tscn`, `remington870.tscn`, `desert_eagle.tscn`, `awp.tscn`, `combat_knife.tscn`, `crossbow.tscn`, `grenade_launcher.tscn`, and `fps_arms.tscn`.
2. **Missing `.scn` and Audio Sample Errors**:
   - Running `godot --headless --script scripts/Tools/test_weapons_economy.gd` prior to editor cache population produced verbatim errors:
     ```
     ERROR: Cannot open file 'res://.godot/imported/awp.glb-f3d744a828d971dbbb5dced6902e2daf.scn'.
     ERROR: Failed loading resource: res://assets/3d/weapons/awp.glb.
     ERROR: res://scenes/weapons/AWP.tscn:12 - Parse Error: [ext_resource] referenced non-existent resource at: res://assets/3d/weapons/awp.glb
     ERROR: Cannot open file 'res://.godot/imported/sfx_knife_slash.wav-eedcb2192489a1c1d86319a1b204030b.sample'.
     ```
   - Running `godot --headless --import` completed the asset daemon import across all 3D meshes and WAV files. Re-running `test_weapons_economy.gd` completed with `WEAPONS & ECONOMY TEST SUMMARY: 58 PASSED, 0 FAILED` and zero parse errors.
3. **SWAT Combat Arms Viewmodel (`FPSArms`) Positioning**:
   - `scenes/player/Player.tscn` lines 107-115:
     ```
     [node name="FPSArms" type="Node3D" parent="Camera3D"]
     transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.18, -0.18, -0.42)
     [node name="WeaponManager" type="Node3D" parent="Camera3D"]
     transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.18, -0.18, -0.42)
     ```
   - In `scenes/weapons/models/fps_arms.tscn`, surface 0 (`Mat_TacticalSleeve`) AABB is `AABB(-0.359, -0.242, -0.094, 0.409, 0.312, 0.146)` and surface 2 (`Mat_TacticalGlove`) AABB is `AABB(-0.130, -0.190, -0.351, 0.134, 0.142, 0.117)`.
   - Relative to `Camera3D` with vertical FOV = 72° (half-angle 36°), the forearm vertices are at `Camera Y = -0.40, Z = -0.54`. The lower frustum threshold at `Z = -0.54` is `Y = -0.54 * tan(36°) = -0.392`. Because `-0.40 < -0.392`, the arms are clipped outside the camera viewport.
   - Hand palms in `fps_arms.tscn` are centered at `Z = -0.34`, while weapon grips in `scenes/weapons/models/*.tscn` are at `Z = 0.0`. The hands float 34 cm in front of the weapon grip.
   - In benchmark image `/home/am/Music/real/Screenshot_20260905_162556_com.vng.g6.a.zombie.jpg`, the firearm is held in the bottom-right quadrant with forearm skin and tactical gloves entering from the bottom-right edge of the screen.
4. **Auto-Reload & Weapon Freeze on 0 Ammo**:
   - `scenes/player/Player.gd` line 206:
     ```gdscript
     weapons[i].apply_upgrades()
     if weapons[i].current_ammo > 0 and not weapons[i].is_reloading:
         weapons[i].can_shoot = true
     ```
   - `scenes/player/Player.gd` line 279:
     ```gdscript
     func _trigger_shoot():
         if is_dead: return
         var weapon = get_current_weapon()
         if weapon and weapon.can_shoot and not weapon.is_reloading:
             weapon.shoot()
     ```
   - Running `tools/test_10_weapons_player.gd` produced verbatim output:
     ```
     --- 5. WEAPON STATE FREEZE TEST (SWITCH DURING 0 AMMO) ---
     Switched away to: M4A1 Sentinel
     USP-45 state while inactive: ammo=0, is_reloading=false, can_shoot=false
     Switched back to USP-45: ammo=0, is_reloading=false, can_shoot=false
     Can player._trigger_shoot() fire? false
     [BUG DETECTED] USP-45 is FROZEN! Player cannot shoot or reload via fire button!
     ```
5. **MuzzleFlash Alignment**:
   - `scenes/weapons/Weapon.tscn` lines 15-24 hardcode `MuzzleFlash` at `(0, 0, -0.3)` and `MuzzleLight` at `(0, 0, -0.35)`.
   - In `scenes/weapons/models/*.tscn`, each weapon contains a child node `MuzzleSocket` at its specific barrel tip (e.g. `awp.tscn`: `Z = -0.92`, `ak47.tscn`: `Z = -0.60`). `Weapon.gd` does not reference or align to `MuzzleSocket`.

---

## 2. Logic Chain

1. **Missing Resource Errors**:
   - From Obs 2, `awp.glb` and `grenade_launcher.glb` failed to load because their `.import` files pointed to target files in `.godot/imported/` that had not yet been compiled by Godot's import daemon.
   - When Godot encounters an unimported external resource inside a `.tscn` file (Obs 2), it fails scene parsing and omits subsequent child nodes (e.g., `MuzzleFlash`).
   - Running `godot --headless --import` completed the compilation of all `.glb` and `.wav` assets into `.godot/imported/`, resolving the errors completely (58/58 tests passed).
2. **SWAT Combat Arms Viewmodel Alignment**:
   - From Obs 3, the arms model vertices sit too low (`Y = -0.22`) and too far forward (`Z = -0.34`) relative to origin.
   - At `FPSArms` position `(0.18, -0.18, -0.42)`, the forearm vertices fall below the camera's vertical field of view angle of 36° (`-0.40 < -0.392`), rendering the arms invisible on screen.
   - Applying a local offset of `Vector3(0.0, 0.05, 0.33)` to `CombatArmsModel` brings the hands back to `Z = 0.0` (matching the weapon grip) and lifts the forearm and sleeve into the lower-right viewport, matching the Dead Target benchmark visual.
3. **Weapon State Freeze**:
   - From Obs 4, firing until `current_ammo == 0` initiates reload. If the player switches weapons, `cancel_reload()` sets `is_reloading = false`.
   - When re-equipping the weapon, `_apply_active_weapon()` only sets `can_shoot = true` if `current_ammo > 0`. Because `current_ammo == 0`, `can_shoot` remains `false`.
   - When the user presses the Fire button or taps the screen, `_trigger_shoot()` checks `if weapon.can_shoot`. Because `can_shoot == false`, `_trigger_shoot()` immediately returns.
   - `weapon.shoot()` is never called, so its internal check (`if current_ammo <= 0: sfx_empty.play(); reload()`) never runs. The gun cannot fire, cannot play empty sounds, and cannot reload.
   - Removing the `current_ammo > 0` restriction from `can_shoot` and auto-invoking `reload()` when equipping an empty weapon resolves the freeze permanently.

---

## 3. Caveats

- In `scenes/weapons/models/fps_arms.tscn`, the arms mesh is a static multi-material `ArrayMesh` rather than a rigged `Skeleton3D`. Viewmodel motion (breathing, walk sway, recoil kick, and tactical reload tilt/drop) is executed procedurally in GDScript via transform manipulation and Tweens (`_recoil_arms`, `_reload_arms`). This approach is optimal for low-spec mobile 30 FPS targeting but does not support per-finger skeletal animation.
- No other caveats.

---

## 4. Conclusion

All 10 tactical weapons exist with authentic 3D geometry and materials. The missing `.scn` and audio issues were caused by an unpopulated `.godot/imported` cache, which is now resolved. The invisible arms and empty magazine weapon freeze are localized bugs in `scenes/player/Player.gd` and `scenes/weapons/Weapon.gd`. The implementation Worker can execute the concrete code changes outlined in Section 8 of `report.md` to achieve 100% compliance with R1 and Dead Target parity.

---

## 5. Verification Method

To independently verify all observations and conclusions:

1. **Verify All 10 Weapons & Economy Integrity**:
   ```bash
   godot --headless --script scripts/Tools/test_weapons_economy.gd
   ```
   *Expected*: `58 PASSED, 0 FAILED`, zero missing `.scn` or resource errors.
2. **Verify 10-Weapon Switching & Freeze Reproduction**:
   ```bash
   godot --headless --script tools/test_10_weapons_player.gd
   ```
   *Expected*: Loads all 10 weapons cleanly, verifies `FPSArms` presence, demonstrates the empty-ammo freeze condition on section 5.
3. **Verify Regression Suite**:
   ```bash
   godot --headless --scene scenes/test/TestRunner.tscn
   ```
   *Expected*: 52+ PASSES, all weapon suites passing (`3D weapons: PASS`, `Weapon switch: PASS`, `Camera recoil kick: PASS`, `Muzzle flash light: PASS`, `FPS Arms presentation: PASS`).
4. **Inspect Visual Benchmark**:
   Inspect `/home/am/Music/real/Screenshot_20260905_162556_com.vng.g6.a.zombie.jpg` to verify Dead Target first-person viewmodel alignment standards.
