# Sector Zero: Lockdown — Comprehensive UI/UX Audit

**Date:** 2026-09-16  
**Role:** Final UI/UX Polish Engineer & Game UI Director  
**Target Platform:** Mobile Android (Landscape 1280x720 base viewport, touch-first)  
**Target Specs:** MediaTek Helio P35 / PowerVR GE8320 / Mali-G52 / Adreno 610 (Gl-Compatibility)

---

## Executive Summary

Sector Zero: Lockdown is a 3D tactical offline FPS featuring 12 missions and an endless survival mode. While gameplay and weapon handling are solidly implemented, the user interface currently suffers from several presentation and usability bottlenecks:
1. **Plain / Real-world Currency Presentation:** Currency is represented using raw string formatting (`CASH: $0`, `$5000`) with the `$` dollar sign instead of a dedicated military sci-fi credit chip / tactical fictional currency badge.
2. **Linear Mission Select:** Missions are arranged in a plain vertical scrolling list rather than a top-down tactical campaign map for Sector Zero.
3. **Navigation & Back Handling Inconsistencies:** No native handling for Android hardware back requests (`NOTIFICATION_WM_GO_BACK_REQUEST`), meaning back actions do not exit submenus or prompt safely.
4. **Armory & Upgrade Screen Divergence:** Two screens exist (`scenes/UI/ArmoryUI.tscn` and `scenes/UI/UpgradeUI.tscn`). `ArmoryUI.gd` had hardcoded prices ($5000) that bypassed `WeaponManager` and lacked transactional spending safety.
5. **HUD & Pause Menu Usability:** HUD pause menu lacks a confirmation dialog for destructive actions (Restart Mission, Abandon to Map), and touch controls need ergonomic positioning and safe area spacing for notched devices.
6. **Result UI Debriefing Polish:** Results screen lacks military debriefing telemetry, animated cash count-up, and clear distinction between next mission progression and armory re-supply.

---

## Detailed System Audits

### 1. Main Menu (`scenes/UI/MainMenu.tscn`, `scripts/MainMenuUI.gd`)
* **Alignment & Spacing:** Buttons are stacked vertically in a central container with basic spacing; text is readable but plain.
* **Currency Display:** Top bar displays `CASH: $0` using a standard green label and real-world dollar sign.
* **Touch Targets:** Menu buttons have adequate height (~50px), but lack tactical sci-fi aesthetics (angled bevels, status pips, glowing indicators).
* **Transitions & Background:** 3D camera floats over a bare tarmac plane. Needs subtle tactical scanlines, grid pulse, or smooth camera sway.
* **Android Back Behavior:** Pressing hardware back button on Android does nothing.
* **Planned Fixes:**
  - Integrate new tactical `CashDisplay` component at top-right.
  - Add subtle camera breathe/sway animation and tactical CRT/scanline overlay.
  - Implement `NOTIFICATION_WM_GO_BACK_REQUEST` with a clean tactical quit confirmation modal.
  - Maintain backwards-compatible node hierarchy for test suite (`Title`, `StartButton`, `UpgradesButton`, `SettingsButton`, `CashLabel`).

---

### 2. Mission Select (`scenes/UI/MissionSelect.tscn`, `scripts/MissionSelectUI.gd`)
* **Current Presentation:** Vertical `ScrollContainer` displaying 13 cards (`MissionCard.tscn`). Lacks the strategic visual identity of Sector Zero.
* **Map & Layout:** No tactical campaign map visualization. Player cannot see geographic layout (Airport, Railway, Urban, Industrial, Quarantine Boss Zone).
* **Navigation:** Top bar has plain buttons and `CASH: 0` text.
* **Android Back Behavior:** Hardware back button is unhandled.
* **Planned Fixes:**
  - Build `MissionMap` top-down tactical campaign map component as the primary view with 12 mission nodes + endless sector node, connecting route lines, and sector region indicators.
  - 4 node visual states: Completed (blue/green, checkmark, glow, stars), Current/Unlocked (orange/blue pulse, active halo), Locked (dark disabled, lock icon, requirement tag), Boss Sector (heavy warning marker, crimson hazard styling).
  - Drag-pan and zoom buttons (+ / -) for mobile navigation.
  - Maintain the backing `ScrollContainer/VBoxContainer` with 13 cards for full compatibility with existing automated testing suites.
  - Connect hardware back button to return to Main Menu.

---

### 3. Mission Briefing (Embedded Briefing Modal)
* **Visual Presentation:** Simple rectangular dark panel (`BriefingModal`) with plain white and gold text.
* **Telemetry & Intel:** Contains basic description and objective text, but lacks tactical classification tags, enemy threat icons, and structured rewards.
* **Planned Fixes:**
  - Upgrade into `MissionInfoPanel` with tactical military styling: Threat level star rating, intelligence summary, enemy composition (Normal, Heavy, Fast, Spitter, Hound, Boss), wave count, reward summary (`SECTOR CASH`), and dual actions (`DEPLOY OPERATION` and `CLOSE INTEL`).
  - Smooth tactical fade and scale tween on display.

---

### 4. Gameplay HUD (`scenes/UI/HUD.tscn`, `scripts/HUD.gd`)
* **Top Bar:** Crowded layout combining health, wave, mission name, objective, cash, ammo, and score.
* **Touch Ergonomics:** Fire button (126x126px) is bottom-right; reload, grenade, and switch buttons are placed in close proximity and could lead to misclicks on smaller screens.
* **CASH Display:** Cash is permanently shown in the top right (`CASH: 0`), cluttering combat focus.
* **Pause Menu:** Contains `ResumeBtn`, `RestartBtn`, `SettingsBtn`, and `ExitBtn`. Pressing `RestartBtn` or `ExitBtn` immediately triggers action without confirmation, risking loss of active mission progress.
* **Planned Fixes:**
  - Redesign Cash in HUD: integrate compact tactical cash badge or dynamic reward toast when cash is earned in survival mode.
  - Refine touch control layout with safe-area spacing and distinct tactical silhouettes.
  - Add Confirmation Dialog for Restart Mission and Return to Map inside Pause Menu.
  - Support Android hardware back button to toggle pause state or dismiss active pause dialogs.

---

### 5. Mission Results Screen (`scenes/UI/ResultUI.tscn`, `scripts/ResultUI.gd`)
* **Visuals:** Basic centered box with vertical label stack.
* **Audio & Juiciness:** Good sound effects, but visual presentation lacks military debriefing punch.
* **Cash Rewards:** Displays raw `Reward: +$X CASH`.
* **Action Buttons:** Next Button and Replay Button are placed vertically without an Armory shortcut or clean tactical hierarchy.
* **Planned Fixes:**
  - Tactical debriefing header with rank badge (S / A / B / C / F).
  - Combat performance breakdown grid (Kills, Headshots, Accuracy, Damage Taken, Time).
  - Animated count-up for earned `SECTOR CASH` using fictional currency badge.
  - Clear button hierarchy: `CONTINUE / NEXT MISSION` (Primary Blue), `ARMORY` (Secondary Tactical), `REPLAY` (Subtle), `MISSION MAP` (Tertiary).
  - Safe navigation back to Mission Map and Armory.

---

### 6. Armory & Weapon Upgrade (`scenes/UI/ArmoryUI.tscn`, `scripts/UI/ArmoryUI.gd`, `UpgradeUI.tscn`)
* **Duplication & Drift:** `ArmoryUI.gd` had hardcoded prices ($5000 unlock) and did not use `WeaponManager.purchase_weapon` or `WeaponManager.purchase_upgrade`. `UpgradeUI.gd` had correct stat calculations but lacked the full 3D rotating weapon view.
* **Visual Presentation:** Left scroll list with 16 buttons; right stat panel with basic progress bars.
* **Transaction Safety:** Direct subtraction from `save_mgr.data.cash` without centralized validation against negative balances.
* **Planned Fixes:**
  - Harmonize `ArmoryUI` with canonical `WeaponManager` (10 distinct weapons, verified upgrade curves, sound integration).
  - Display weapon category tags (Assault Rifle, Sniper Rifle, Heavy Ordinance, Shotgun, Sidearm, Melee).
  - Show stat comparison bars: Current Level vs Next Level benefit.
  - Action buttons with clear states: `OWNED`, `LOCKED` (with price), `UPGRADE` (with cost), and `INSUFFICIENT CASH` feedback (shake / red pulse).
  - Connect to `SaveManager.spend_cash()` and `CashDisplay`.

---

### 7. Settings Screen (`scenes/UI/SettingsUI.tscn`, `scripts/SettingsUI.gd`)
* **Visuals:** Basic scrolling list of sliders.
* **Back Navigation:** Hardcoded back destination (`MissionSelect.tscn`), which is broken when opened from Main Menu or HUD pause menu!
* **Planned Fixes:**
  - Track previous scene state dynamically (`origin_scene`) to return properly to Main Menu, Mission Select, or HUD.
  - Add Android hardware back button handling.
  - Polish sliders and dropdowns with tactical sci-fi styling.

---

### 8. CASH System Architecture (`SaveManager.gd`, `WeaponManager.gd`)
* **Symbol & Naming:** Code frequently formats cash as `$%d` or `+$%d`.
* **API Completeness:** `SaveManager.gd` has `add_cash(amount: int)` but lacked a dedicated `spend_cash(amount: int) -> bool` method.
* **Double-Spending & Integrity:** Needs atomic spend validation preventing negative balance and duplicate reward exploits.
* **Planned Fixes:**
  - Remove all real-world currency symbols (`$`, `₹`, `€`). Replace with `CASH` or `SECTOR CASH` token styling.
  - Implement `spend_cash(amount: int) -> bool` in `SaveManager.gd` with balance check, atomic deduction, save, and event emission.
  - Build standalone reusable `CashDisplay` component (`scenes/UI/Components/CashDisplay.tscn`, `scripts/UI/Components/CashDisplay.gd`) with counter tweens and shake feedback.

---

## Planned Implementation Schedule

1. **Phase 2 (CASH Redesign):** Update `SaveManager.gd`, create `CashDisplay.tscn` and `scripts/UI/Components/CashDisplay.gd`, build fictional currency icon, integrate across all screens.
2. **Phase 3 (Tactical Campaign Map):** Implement `MissionMap`, `MissionNode`, `MissionRoute`, and `MissionInfoPanel`. Embed in `MissionSelect.tscn` while maintaining card list for test compatibility.
3. **Phase 4 (Screen Polish):** Upgrade Main Menu, HUD, Pause Menu (with confirmation dialog), Result UI, and Armory UI.
4. **Phase 5 (Mobile & Android Polish):** Add `NOTIFICATION_WM_GO_BACK_REQUEST` handlers, touch ergonomics, and verify budget performance.
5. **Phase 6 (Validation & Documentation):** Execute test suites, verify zero regressions, document in `UI_UX_IMPLEMENTATION.md` and `KNOWN_ISSUES.md`.
