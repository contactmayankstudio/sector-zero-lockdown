## 2026-09-18T04:45:54Z
You are a read-only exploration agent (teamwork_preview_explorer) assigned to investigate Requirement R2: Campaign Data Integrity & Mission Flow for 'Sector Zero: Lockdown' in /home/am/targetkill.
Your assigned working directory is /home/am/targetkill/.agents/explorer_r2.
Your parent orchestrator conversation ID is 237eaf46-e809-4bcf-b125-d5770dc95b5a.

CRITICAL CONSTRAINTS:
- Do NOT modify or create source code, test files, or assets in the game project. You are read-only except for writing your analysis to your working directory /home/am/targetkill/.agents/explorer_r2/.
- Read ORIGINAL_REQUEST.md at /home/am/targetkill/.agents/ORIGINAL_REQUEST.md (specifically entry dated 2026-09-18T04:43:32Z) first.
- Read PROJECT_STATUS.md at /home/am/targetkill/PROJECT_STATUS.md and scripts/Tools/test_campaign_contract.gd.

TASK OBJECTIVES:
1. Inspect all 12 campaign mission resources in resources/missions/ (mission_01.tres through mission_12.tres) and endless mode (endless.tres).
2. Check wave configurations:
   - Are all active wave counts normalized to exactly 3 waves per mission?
   - Are there residual 4th wave definitions or inconsistent wave data?
   - Verify enemy rosters, groups, and spawn pacing for each wave.
3. Verify scene references and directional spawn markers:
   - What scene is linked to each mission resource?
   - Do all linked environment scenes (UrbanStreet.tscn, AirportServiceRoad.tscn, RailwayStation.tscn, etc.) contain the required directional spawn markers (SpawnFront, SpawnBack, SpawnLeft, SpawnRight)?
   - Are there any missing spawn markers, mismatched node paths, or broken scene dependencies?
4. Inspect mission completion and objective logic in scripts/GameManager.gd, scripts/Objectives/, scripts/UI/, etc.:
   - How are boss defeat objectives handled?
   - Can a boss objective trigger early mission completion before all configured waves are cleared?
   - Is mission completion idempotent (preventing duplicate payouts, callbacks, or restart glitches)?
5. Document exact file paths, line numbers, inconsistencies found, and step-by-step fix recommendations for workers.

OUTPUT REQUIREMENTS:
- Write your complete findings to /home/am/targetkill/.agents/explorer_r2/handoff.md.
- Send a completion message back to parent (conversation ID 237eaf46-e809-4bcf-b125-d5770dc95b5a) referencing your handoff file.
