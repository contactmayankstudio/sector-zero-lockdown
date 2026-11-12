# Sector Zero: Lockdown — UI/UX Before & After Audit

**Date:** 2026-09-18  
**Project:** Sector Zero: Lockdown (Godot 4.3 Mobile FPS)  
**Target:** Android 16:9 Landscape (1280x720 baseline, 960x540 compact)  
**Role:** Lead Game Director & Senior UI/UX Designer  

---

## 1. Executive Summary & Existing Baseline

An inspection of the existing codebase, scenes, and rendered capture (`screenshots/preview_Armory.png`) revealed critical UI/UX shortcomings in the Armory, Cash presentation, and Weapon Equip pipeline:

1. **Cash Presentation**:
   - Displayed as plain, unstyled text (`CASH: $0`) using a real-world dollar sign (`$`).
   - Lacks fictional in-game token identity, banknote stack iconography, and wallet framing.
   - Missing animated count-up, transaction feedback, and visual reward fanfare.

2. **Armory Weapon Navigation**:
   - Rendered as a simple vertical stack of text buttons (`PISTOL`, `RIFLE`, `SHOTGUN`, `M4A1`...).
   - No weapon silhouette or icon rendering.
   - No category tags, locked indicators, or unlock prices visible on the list cards.
   - Selected state relies on a single left cyan border line on a plain grey rectangle.

3. **3D Weapon Preview (Showroom)**:
   - Floating in void space without a dedicated studio environment or backdrop.
   - Lighting is harsh and unbalanced (single directional + omni light causing blown-out or washed-out materials).
   - Weapon scale is inconsistent and uncentered.
   - No touch-drag rotation or camera framing.

4. **Equip Flow Disconnect**:
   - **Critical Bug**: There is NO `EQUIP` button. Once a weapon is unlocked, players cannot set it as their active loadout.
   - `Player.gd` defaults `current_weapon_index = 0` regardless of player selection.
   - `SaveManager` lacks persistent `equipped_weapon` storage and synchronization.

5. **Upgrade Panel & Typography**:
   - Stats are listed in cramped horizontal rows with plain text costs.
   - No visual progress bars or stat comparison preview (`current → next`).
   - Missing accuracy and recoil metrics.
   - Buttons lack tactile mobile touch feedback, confirmation states, and debounce protection.

---

## 2. Technical Inventory & Component Analysis

| Component | Scene / Script | Current State | Target State |
| :--- | :--- | :--- | :--- |
| **Cash Wallet** | `CashDisplay.tscn` / `CashDisplay.gd` | Basic container with credit chip SVG; hard-coded string formatting. | Fictional Banknote Stack icon, custom wallet container, smooth counter, pulse/shake feedback, zero dollar sign. |
| **Armory Screen** | `ArmoryUI.tscn` / `ArmoryUI.gd` | Flat text list, unlit 3D viewport, no Equip flow. | Tactical sci-fi 3-column layout: Left (Cards), Center (3D Showroom), Right (Stats & Upgrades). |
| **3D Showroom** | `ArmoryUI.tscn` (`3DView`) | DirectionalLight + OmniLight; washed out materials; static auto-spin. | Studio 3-point lighting (Key, Fill, Rim), soft dark pedestal, interactive touch drag, centered framing. |
| **Equip Pipeline** | `WeaponManager.gd` / `Player.gd` | Hardcoded slot 0; no `equipped_weapon` field in SaveManager. | Full persistence: `SaveManager.data.equipped_weapon` synced to `Player.gd` spawning and Armory UI cards. |
| **Weapon Cards** | Custom in script | Raw `Button.new()` with string text. | Reusable `WeaponCard` component: icon, name, category, ownership badge, price, equipped badge, active highlight. |
| **Stat Progression** | `ArmoryUI.gd` | Plain labels (`22.0 $120`). | Visual dual-tone progress bars, `X → Y` upgrade previews, touch-sized upgrade buttons. |

---

## 3. Weapon Assets Audit (Real vs Placeholder)

- **Legitimate CC0 / Project 3D Weapons** in `assets/3d/weapons/`:
  1. `usp45.glb` (Pistol)
  2. `m4a1.glb` (Assault Rifle)
  3. `remington870.glb` (Shotgun)
  4. `ak47.glb` (Combat Rifle)
  5. `desert_eagle.glb` (Heavy Handgun)
  6. `mp5.glb` (SMG)
  7. `awp.glb` (Sniper Rifle)
  8. `combat_knife.glb` (Melee)
  9. `crossbow.glb` (Tactical Special)
  10. `grenade_launcher.glb` (Heavy Explosive)

- **Quarantined Commercial Assets** (strictly excluded from Armory and exports):
  - `quarantine_suspect_assets/apex_legends_*` (Brimstone, Flatline, Vantage Sniper)
  - `quarantine_suspect_assets/serious_sam_3_minigun.glb`
  - `quarantine_suspect_assets/gta_grove_street.glb`

- **Rule Enforcement**:
  - The active Armory will strictly expose the 10 legitimate, high-quality, CC0-verified weapons.
  - Quarantined models remain excluded from all production scenes and presets.
  - Procedural/primitive placeholders (`scar_l`, `g36`, `famas` dummy names) will not pollute the active 10-weapon catalog.

---

## 4. Performance & Low-End Android Constraints

- **Rendering Backend**: `gl_compatibility` (OpenGL ES 3.0 / WebGL 2).
- **Draw Call Budget**: < 40 in Armory menu.
- **Lighting**: 3 lightweight directional/omni lights in isolated `SubViewport` with `transparent_bg = true`.
- **Viewport Resolution**: Match window size dynamically; disable unnecessary post-processing, glow, and DOF shaders.
- **Texture Memory**: Reusable SVG vector icons for UI; 256x256 / 512x512 PBR textures for weapon models.

---

## 5. Verification Plan

1. **Before/After Visual QA**:
   - Capture 1280x720 baseline screenshot of redesigned Armory and Cash Wallet.
   - Capture 960x540 compact landscape screenshot to verify responsive layouts.
   - Verify weapon 3D materials, normals, and textures under showroom lighting.
2. **Automated Regression Suite**:
   - `test_weapons_economy.gd`: 58/58 passed (maintain 100%).
   - `test_ui_screens.gd`: Maintain 6/6 UI screen groups passing.
   - `test_campaign_contract.gd`: 186/186 passed.
3. **Gameplay Integration**:
   - Equip weapon in Armory -> enter mission -> verify equipped weapon model and stats active in player's hands.
   - Upgrade stat -> verify SaveManager persistence across simulated restart.
