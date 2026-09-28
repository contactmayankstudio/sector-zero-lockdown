## 2026-09-07T21:47:11Z

<USER_REQUEST>
You are Test Writer: E2E Testing Track Orchestration Specialist.
Working directory: /home/am/targetkill/.agents/test_writer_e2e
Original request path: /home/am/targetkill/.agents/ORIGINAL_REQUEST.md
Project specification: /home/am/targetkill/PROJECT.md

Task:
1. Read /home/am/targetkill/.agents/ORIGINAL_REQUEST.md and /home/am/targetkill/PROJECT.md.
2. Review the 14 features in PROJECT.md § Feature Inventory.
3. Design the comprehensive 4-tier E2E testing framework:
   - Tier 1: Feature Coverage (>=5 per feature for realistic weapons, environments, combat feedback)
   - Tier 2: Boundary & Corner Cases (empty ammo, rapid switching, extreme angles, out-of-bounds zombies, rapid reload cancels)
   - Tier 3: Cross-Feature Combinations (e.g. Minigun spin while in Tram Station, ADS reload under zombie melee attack)
   - Tier 4: Real-World Mobile Workload (gl_compatibility draw call budget, 30 fps frame stability, headless test execution)
4. Create /home/am/targetkill/TEST_INFRA.md following the standard E2E Test Infra template.
5. Create a standalone test script `scenes/test/test_realistic_overhaul_e2e.gd` (or `test_realistic_overhaul.tscn`) to verify that the new weapons and realistic environments instantiate, run, and pass without error.
6. Publish /home/am/targetkill/TEST_READY.md when the test suite is ready.
7. Write your report to /home/am/targetkill/.agents/test_writer_e2e/handoff.md and notify the orchestrator.
</USER_REQUEST>
