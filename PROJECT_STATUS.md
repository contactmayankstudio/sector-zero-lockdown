# Sector Zero: Lockdown - Project Status

Date: 2026-09-09

## Current Baseline

- Godot 4.3 project configured for Mobile and gl_compatibility.
- Main menu, campaign mission resources, weapon data, enemy scenes, save system, UI screens, and Android preset are present.
- Campaign resources exist for missions 1-12 plus endless mode.
- Existing focused tests cover weapon data/economy, zombie combat, infected dog behavior, and several scene systems.

## Changes In This Milestone

- Fixed a malformed HUD signal block in `scripts/HUD.gd`, restoring script parse integrity and allowing the headless regression suite to continue past the startup crash.
- Quarantined assets with names indicating possible commercial-game origins into `quarantine_suspect_assets/`.
- Replaced the active GTA Grove Street reference in `scenes/environments/UrbanStreet.tscn` with `street_city_7_for_games_free.glb`.
- Normalized mission 3-12 runtime wave counts to three.
- Prevented boss-objective missions from completing before their final configured wave is cleared.
- Added automatic reload initiation when a non-melee weapon is fired with an empty magazine.
- Fixed the weapon/economy regression harness to respect deferred node readiness; it now completes at 58/58.
- Added a campaign contract test covering all 12 mission resources, active wave count, scene paths, and directional spawn markers.
- Added bounded save-version validation with automatic normalization of older supported saves.
- Refined the tactical mobile UI: reusable button states, larger touch targets, phone-first main-menu layout, and enlarged HUD controls.
- Updated the UI acceptance test to verify 12 campaign cards plus the Endless card.
- Added an offline Daily Ops system with date-based challenge rotation, persistent progress, and one-time cash rewards.
- Added Daily Ops progress display to the Main Menu and a dedicated smoke test.
- Added a dedicated `DailyOps.tscn` screen with challenge progress, reward state, and mission navigation.
- Added Endless combat scoring with headshot/archetype bonuses, live HUD score, result-screen score, and persistent personal best.
- Removed duplicate Endless result-screen cash payout so each enemy reward is credited once during the run.
- Added Airport Service Road back-direction spawn marker to the active spawner list.
- Updated Android export filtering to exclude `real/`, quarantine assets, and unverified test candidates from distribution packages.
- Added a dedicated Endless score smoke test.
- Updated `ASSET_LICENSES.md` with the quarantine state.
- Added an isolated tram-station candidate preview from `real/`; it is explicitly not approved for production pending license verification.

## Verification

- Editor diagnostics report no errors in the changed GDScript, mission resources, or Urban Street scene.
- The focused weapon/economy runner completes with 58/58 passed and exit code 0; Godot reports a non-fatal leaked-object warning from the harness at shutdown.
- The UI verification runner passes all 5 screen groups: Main Menu, Mission Select, Gameplay HUD, Armory, and Result UI.
- The Daily Ops smoke test passes challenge selection, bounded progress, and persistence.
- The UI verification runner now passes all 6 screen groups, including Daily Ops.
- Endless score smoke test passes base, headshot, boss bonus, and personal-best persistence checks.
- The mission gameplay runner loads the production scene but emits stale embedded-UID warnings from the Vitruvian GLB and does not reach a clean completion summary within the available headless timeout.
- Physical Android device testing has not been performed.
- Android APK export has not been verified from this checkout.
- Blender 3.0.1 and Godot 4.3 are installed; candidate scene diagnostics are clean, but a reliable headless visual preview completion signal was not available.

## Current Release Gate

Not release-ready. Legal provenance, export verification, content consistency, and physical Android validation still require work.

## Top 20 Improvement Register

1. **P0** Resolve provenance for quarantined assets and remove anything uncleared.
2. **P0** Make the headless regression runner exit with a deterministic summary and status.
3. **P0** Add campaign data validation for exactly three waves and valid scene references.
4. **P0** Add idempotent mission completion tests covering duplicate callbacks and restarts.
5. **P1** Remove legacy fourth-wave data or redesign it as explicit replay content.
6. **P1** Align mission titles, descriptions, locations, scenes, and enemy rosters.
7. **P1** Add missing directional spawn markers and deterministic spawn tests.
8. **P1** Make Android export paths portable and verify an ARM64 export.
9. **P1** Add explicit save schema migration and unsupported-version handling.
10. **P1** Consolidate duplicate SaveManager implementations.
11. **P1** Create one canonical weapon/content manifest for scenes, data, and models.
12. **P1** Replace unconditional visual/audio acceptance assertions with executable checks.
13. **P2** Validate empty-magazine auto-reload with a focused controller test.
14. **P2** Add replay-safe endless difficulty curves and boss cadence tests.
15. **P2** Add offline daily challenge rotation and persistence tests.
16. **P2** Expand objective support beyond kill, survive, and boss-kill.
17. **P2** Improve mission pacing with safe randomized group composition.
18. **P3** Capture visual previews for every major environment and weapon.
19. **P3** Profile draw calls, texture memory, frame time, and scene loading.
20. **P4** Perform physical Android touch, pause/resume, thermal, and battery validation.
