## 2026-09-18T04:46:00Z
You are a read-only exploration agent (teamwork_preview_explorer) assigned to investigate Requirement R3 (Clean Asset Provenance & License Quarantine) and Requirement R4 (Android Build & Export Readiness) for 'Sector Zero: Lockdown' in /home/am/targetkill.
Your assigned working directory is /home/am/targetkill/.agents/explorer_r3_r4.
Your parent orchestrator conversation ID is 237eaf46-e809-4bcf-b125-d5770dc95b5a.

CRITICAL CONSTRAINTS:
- Do NOT modify or create source code, test files, or assets in the game project. You are read-only except for writing your analysis to your working directory /home/am/targetkill/.agents/explorer_r3_r4/.
- Read ORIGINAL_REQUEST.md at /home/am/targetkill/.agents/ORIGINAL_REQUEST.md (specifically entry dated 2026-09-18T04:43:32Z) first.
- Read ASSET_LICENSES.md, export_presets.cfg, project.godot, and PROJECT_STATUS.md.

TASK OBJECTIVES:
1. Asset Provenance & Quarantine (R3):
   - Inspect quarantine_suspect_assets/ and check what assets are currently quarantined and why.
   - Scan all active game scenes in scenes/ (environments, weapons, UI, enemies) and resource files in resources/ to confirm whether any reference files in quarantine_suspect_assets/, real/, or other unverified directories.
   - Audit ASSET_LICENSES.md: Does it accurately document all bundled assets, their authors, source URLs, and permissive licenses (CC0, MIT, CC-BY)? Are there any bundled assets missing from the license manifest?
2. Android Build & Export Readiness (R4):
   - Inspect export_presets.cfg: Examine the Android preset (ARM64, package name, min/target SDK, export mode).
   - Check export paths and keystore configs: Are paths portable (e.g., relative or environment-independent) or do they contain hardcoded machine-specific paths?
   - Check export filters: Are quarantined folders (quarantine_suspect_assets/), test folders, and raw asset repositories properly excluded from the Android export preset?
   - Identify the exact Godot CLI command needed for automated/headless Android export validation (or dry-run export verification) and what dependencies (Android build templates, SDK, keystore) are present or needed.
3. Document exact file paths, line numbers, gaps found, and step-by-step fix recommendations for workers.

OUTPUT REQUIREMENTS:
- Write your complete findings to /home/am/targetkill/.agents/explorer_r3_r4/handoff.md.
- Send a completion message back to parent (conversation ID 237eaf46-e809-4bcf-b125-d5770dc95b5a) referencing your handoff file.
