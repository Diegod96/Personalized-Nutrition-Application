# Backlog and build-order review, round 2a

Reviewed 23 October 2026. Read-only. This continues `/tmp/nutrition-astra-review/review.md`; it converts the earlier recommendations into issue edits, dependency corrections and a smaller delivery plan. No repository or GitHub content was changed.

## Evidence and counting

Read all 37 live issue bodies, milestones and comments with `gh issue list` and individual `gh issue view` calls. All #2–#38 were OPEN. Checked-out HEAD was `059cc713e8a95de3b7ae18b1bee327209b0cfbf0`; the requested local research ref was `origin/chore/project-setup` at `0e004b09066b9a3bf9eae4f58fdf7f0f3597d1d8`. No fetch was performed. Research line references below refer to that ref, not the older checked-out report. Design line references refer to HEAD. The feature template is `.github/ISSUE_TEMPLATE/feature.md:8–39`.

Counts use one primary verdict per existing issue: **2 OK, 29 Edit, 3 Split, 3 Move, 0 Merge = 37**. Thus 35 existing issues need body changes, including the splits and moves. Three existing issues cross the beta boundary: #28 enters; #22 and #37 leave. Six missing contract/decision/implementation issues plus three split-out feature issues make **9 new issue drafts**. N1–N9 are placeholders, not allocated GitHub numbers. Retiming within beta is separate from these move counts.

All proposed timings, catalog size and scope choices below are review proposals. They are not approved nutrition rules or product decisions. Replace placeholder IDs after issue creation. Preserve unaffected existing issue text; table cells specify exact additions/replacements. Use the common verification block after the table for every edited feature issue.

## Ranked findings and smallest fixes

### High 1. The release gate does not represent either the current milestone or the proposed beta

#24 requires "External testers can complete onboarding and see a plan" and depends on #22 subscriptions, but omits Phase 1 #36 and #37. #16 requires "Log it and Ideas", while #28 is Phase 2. Seeing a plan does not demonstrate that its suggestions can be logged or that changed workouts preserve intake.

Smallest fix: approve N1, bring #28 into beta, defer #22/#37, update #24's exact dependency list and make the acceptance journey include suggestion, logging, workout change, offline restart and reconnect. Keep the current core Health/Intervals promise. Do not silently call a manual-only prototype the external beta.

### High 2. The approval dependency has no safe completion meaning

#9 says "Written sign-off, or a list of changes"; #24 says "Dietitian and legal reviews are closed". Closing #9 after receiving requested changes would satisfy that wording without approval. Conversely, adding #9 as a hard build prerequisite for #11 would create a practical loop because #9 also requires "Golden tests updated to match".

Smallest fix: keep #9 open until approval names the shipped rules/fixtures revision and implementation evidence. Give it an early reviewed-spec checkpoint, and a final release checkpoint after #11/N4. Synthetic implementation can start first. Apply the same distinction to #8's "Written read received" versus disposition of release-blocking legal findings. #9's existing comment adds goal/caffeine review, so explicitly separate those later approvals from the beta subset.

### High 3. Contracts lack owners and the apparent DAG understates integration work

#13 promises "offline first" sync; #12 merges workouts "reversibly"; #18 allows imported sessions to be "edited and deleted"; `DESIGN.md:60` instead says "Hide for a synced one". #11's inputs include completed and planned sessions without a matching/ownership contract. #23 only depends on #13 although deletion must cover the provider connections and local writes created elsewhere.

Smallest fix: N2 owns identity, provenance, local overrides, suppression, tombstones, allowed server fields and one calculating phone. Split #13 so schema/auth and actual offline replay each have a verifiable completion boundary. Add #14/#12/N9 to #23. Do not implement per-screen versions of these behaviors.

### High 4. A coherent day still has no independent acceptance gate

#11 combines target selection and meal allocation; its criterion "every output stays inside its §4 range" cannot prove conservation or prevent counting one meal twice. Research §4 lines 134–144 moves carbs across dates and subtracts session allocations from a daily total. No issue owns conflict priority, overlap allocation, user meal-window preferences, or an intake correction after replanning.

Smallest fix: keep target calculation in #11 and put meal allocation in N4, using N2's intake model and N3's shared fixtures. #16/#17/#28 consume the resulting revision. This gives the multi-session counterexample from the first review a named implementation owner and a release-blocking test.

### High 5. The old numeric specification survives an explicit ownership decision

#11's body still requires slow-loss tests, but its [owner comment](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/11#issuecomment-6352602171) says "The goal-weight logic, including slow loss, now has its own issue: #37." This is a stale issue body, not an unresolved ownership discussion. #36 requires keeping "every number and label from the wireframes", whereas #11 expects 426 g and the mockup shows 490 g (`docs/design/mockups.html:430`; research lines 148–156 explicitly compare them). #16 also requests fat progress although #11 supplies no complete fat-target algorithm.

Smallest fix: remove slow loss from #11 and beta onboarding; make N3 the numerical contract for engine and screenshots. For the narrow beta, show carb/protein targets only and retain fat as a logged nutrient without a target. Scope-review that design difference in N1/#36 rather than inventing a fat/energy algorithm here.

### Medium 6. Happy-path criteria hide missing work and unnecessary platform coupling

#15 demands household units "on every food", but no issue specifies food-specific serving masses or unknown nutrients. #20's "under 60 seconds with defaults" does not define timing boundaries and makes external authorization appear part of a deterministic local test. #18's "four taps or fewer" does not say which fields start prefilled. #14/#19/#21/#34 have no common freshness semantics. #27 unnecessarily requires #26 even if direct API access is granted before the fallback exists.

Smallest fix: split fast local logging from catalog integration; use measured, named test setups; define freshness once in N5; make calendar migration conditional in #27. These are scope and acceptance changes, not new libraries or services.

## Dependency audit

Parsing the explicit `Depends on` sections produces no cycles among #2–#38. #36's #1 is a PR dependency, not a missing feature issue. The graph is incomplete, not cyclic.

Specific gaps beyond the first review:

- #5 names a callback "from the Supabase foundation issue" but only lists #2. Start its application after #2; verify its deployed callback after #13. Neither a pending application nor a recorded rejection means production OAuth is ready.
- #7 completes on "Application submitted" and attribution, but #15 explicitly excludes FatSecret and there is no FatSecret implementation issue. Keep the application optional. N7 covers the first catalog providers; FatSecret remains a future approved scope addition rather than an implied dependency.
- #16/#17 need #15/#28 for their actions; #17 needs #19 for its reminder toggle. Mockups or engine output alone cannot satisfy those UI journeys.
- #20 needs #11 and an actual plan screen to prove "first plan", and must not force Health/provider authorization to make a manual plan. Keep the optional connection path as a later checkpoint within #20.
- #21 needs the engine/allocation revision to prove outlier confirmation changes targets. A rejected local outlier must not imply deleting a third-party Health record.
- #24 does not depend on #28 and does not cover design acceptance. Add both after the scope decision. Its present omission of #37 is resolved by deferral, not by adding an adaptive-loss release dependency.
- #25/#27/#32 require N2/N5 and a deterministic planned/completed matching contract, not merely a backend. #32 lacks #12 despite promising Health deduplication.
- #26's "about 14 days" is a provider-data observation, not an app-controlled guarantee. Define an exact import window and test available events within it.
- #31's "all ... app-created data" exceeds its named food/sessions/targets list. Decide the export schema explicitly and test local unsynced entries.
- Avoid a new cycle: #11 must not depend on N4 if N4 uses #11. N3 contains expected values and rule decisions before engine implementation; tests consuming them land with #11/N4. N2 precedes #13, N9 implements sync afterward. #9 has release checkpoints, not a hard edge back into #11.

## Per-issue edits

Each number links to its live evidence. Quoted phrases are from that issue unless a file or comment is named. Dependency lists in the draft column replace the existing list. Retain independent review, PR evidence and human merge requirements from AGENTS.md.

| Issue | Verdict | Evidence and reason | Ready-to-paste draft change |
|---|---|---|---|
| [#2](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/2) | OK | "Working name chosen and recorded here", bundle ID and working support email are observable paperwork outputs. No missing build dependency. | No required change. Keep Phase 0. Verification evidence should include the chosen values and a successful support-email round trip without private message contents. |
| [#3](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/3) | OK | "Membership active", capability-enabled App ID and stored APNs key are clear. Depends on #2. Signing may wait in #10. | No required change. Keep Phase 0. Attach redacted account/capability evidence; never attach the key. |
| [#4](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/4) | Edit | "If approved, the integration issue is unblocked" conflates application completion with build readiness. | **Replace Done when:** Application submitted; dated approved/pending/rejected status recorded; if approved, sandbox access and granted scopes confirmed without credentials in the issue; otherwise #27 remains gated and manual entry remains available. **Depends on:** #2. Optional long-lead paperwork, not a beta gate. |
| [#5](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/5) | Edit | "Approval status recorded" allows pending status to look done; callback depends on #13 implicitly. | **Add checkpoints:** Application request may start after #2. Beta integration is ready only when OAuth approval and exact redirect URI are confirmed and a test account completes authorization against #13's callback. Pending/rejected approval keeps external Intervals access blocked; personal API keys are development-only. **Depends on:** #2; callback verification requires #13. |
| [#6](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/6) | Edit | "Sandbox active" does not cover the stated 10-member limit or wider tester access. | **Add Done when:** Record permitted member count, granted scopes, terms revision and a successful sandbox authorization with no secrets in evidence. Expansion beyond the approved tier remains a separate release gate for #25. **Depends on:** #2; terms disposition from #8 before live use. Keep optional paperwork outside the beta critical path. |
| [#7](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/7) | Edit | "Application submitted" is not access granted; no feature owns FatSecret implementation. | **Add Done when:** Record pending/approved/rejected status, granted access and attribution terms if approved. This issue registers the application only and does not add FatSecret to #15 or N7. **Depends on:** #2. Optional paperwork; not required for beta logging. |
| [#8](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/8) | Edit | "Written read received" gives no resolution of blocking findings or geographic scope. | **Replace Done when:** Record intended launch jurisdictions and the beta data inventory from N2; record the lawyer's reviewed revision, decisions and closure of all beta-blocking findings; host the matching privacy policy and approve onboarding/retention/deletion copy. Review later providers separately before enabling them. **Depends on:** N1 and N2 for final disposition; consultation may start immediately. |
| [#9](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/9) | Edit | "Written sign-off, or a list of changes" is insufficient. Comment additionally requests #37/#38 review. | **Replace Done when:** Dietitian approves the identified beta rules/configuration and fixture revision, screening/referral copy and library content; requested changes are implemented and verified against #11/N4/#28; approval names the release revision. A list of changes leaves this issue open. Goal-weight and caffeine approvals are separate later gates. **Checkpoints:** reviewed spec after N3; final approval after #11/N4/#28/#20. Synthetic tests may run before approval; no athlete-facing targets before it. |
| [#10](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/10) | Edit | "Decide the minimum iOS version here" hides a product decision; "one placeholder test" is only bootstrap evidence. | **Add AC:** Apply N6's deployment target and capability decisions; test launch and local save/reload on the minimum supported runtime and CI runtime; app and engine jobs fail if required targets/tests disappear after scaffold creation. Four tabs may remain for internal scaffolding; external beta navigation follows N1. **Depends on:** N6; #2 for final bundle ID. #3 gates device signing only. |
| [#11](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/11) | Edit | Slow-loss ownership moved by comment but not body. "one per §4 row" accidentally includes deferred fluid/fat/goal/caffeine scope. | **Replace Scope:** Implement N3's versioned beta carb/protein target decision table, source/reason IDs and input validation. Own daily/session targets and duration tolerance; meal allocation belongs to N4. No deficits, adaptive goal weight, caffeine or hydration in this issue. **Replace AC:** Golden cases cover each enabled rule and exact boundary; invalid/missing inputs produce the specified fallback; identical canonical inputs yield identical targets and explanations. Replace Tuesday literals with the named N3 fixture and rounding policy. **Depends on:** #10, N2, N3. #9 is the athlete-exposure gate. |
| [#12](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/12) | Edit | "a jump beyond a threshold" and "overlapping workouts" lack parameters; imports/exports have no echo test. | **Replace beta Scope:** Read completed workouts and weight; write the app's logged nutrition. Defer sleep/HRV/body-composition and third-party dietary imports until a feature consumes them. **Add AC:** N3 defines weight plausibility; N2 defines matching and source precedence. Own writes read back do not duplicate intake; user corrections/deletes retry safely; merge/undo survives refresh and relaunch; absent permission still permits manual entry. Verify supported simulator cases plus Health behavior on a physical phone. **Depends on:** #10, N2, N3; #3 for signed-device evidence. |
| [#13](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/13) | Split | Schema/auth/APNs and "offline first" sync are independently large boundaries. SQL/RLS verification is already explicitly required and must be retained. | **Retain here:** Auth, schema, RLS, encrypted provider/Apple tokens, APNs helper and database/Deno verification. **Move to N9:** local-to-server replay and reconnect conflict handling. **Add AC:** Each operation denies another user's access, including child-row reassignment and provider token access; migrations work from an empty DB and supported prior revision; Apple revocation credential is captured securely. **Depends on:** #10, #3, N2. |
| [#14](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/14) | Edit | "within minutes with no manual refresh" has no device-state definition; authenticated delivery alone does not prove replay correctness. | **Replace latency AC:** Implement N5's foreground/background/offline matrix, show last successful reconciliation and preserve a visibly stale cached plan on failure. **Add AC:** Repeated/reordered updates, upstream deletion, canceled authorization and token expiry follow N2; planned and completed copies count once; coach override obeys N3 precedence; no stale callback restores a deleted account. **Depends on:** #13, #11, #5, #12, N2, N5, N9. #5 must be approved for external beta. |
| [#15](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/15) | Split | USDA/OFF/barcodes and "household measures on every food" need a catalog contract; the beta loop can use saved foods and suggestions. | **Retain here:** Offline quick macro entry, custom foods with known serving masses, Recents/Favorites, timestamp/meal slot, deliberate edit/delete/undo and saving a #28 suggestion. **Move to N7:** USDA/OFF search, barcode scanning and broad units. **Add AC:** Save/relaunch retains exact items; edit/delete updates totals once; unknown macros stay unknown; local save success is distinct from sync/export pending. Measure the four-item Recents flow from opening Log to saved confirmation with seeded foods and record time, target under 30 seconds. **Depends on:** #10, N2, N3. Health export integration is verified with #12 before #24. |
| [#16](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/16) | Edit | "Log it and Ideas" lacks #15/#28 edges; "fat progress" lacks a target rule. | **Replace beta Scope:** Show carb/protein progress and N4's remaining plan; fat remains an intake detail without a target. Use one Profile calorie setting. **Add AC:** Log it opens the intended meal draft; Ideas returns a portioned suggestion to that draft; save updates progress once; moving/canceling a workout preserves saved intake and shows a revision reason; no remaining meals produces an explicit complete state. Use #36/N3 for screenshots. **Depends on:** #11, #15, #17, #18, #28, #36, N4. |
| [#17](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/17) | Edit | "Why GREEN today" in a session view is not a day explanation; reminder and Ideas actions lack dependencies. | **Replace Scope:** Explain this session's targets and link to a daily explanation showing all contributing sessions/look-ahead/fallbacks. Add functional Ideas and reminder actions. Move feedback collection with #30 after beta. **Add AC:** The reason text and numbers come from the same revision; missing kJ is labeled unavailable; a removed/hidden session exits safely; overlapping pre/recovery allocations disclose shared credit. **Depends on:** #11, #28, #19, #36, N4. |
| [#18](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/18) | Split | Week overview and quick-add can ship independently. "delete any session" conflicts with DESIGN.md:60. | **Retain here:** Manual create/edit/delete, imported local overrides, Hide/Unhide and key-session flag, accessible from Today. Hide never deletes the provider original; local overrides persist and can be reset explicitly. **Move seven-day overview to N8. Add AC:** From the add sheet, accepting visible defaults and saving takes at most four taps; record defaults and separately test custom start/duration/effort. Saved workouts survive relaunch and replan only future allocations. Hide survives the next import. **Depends on:** #10, N2, N3. Provider-backed verification follows #14. |
| [#19](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/19) | Edit | "correct" times and "Reschedule whenever the plan changes" omit time zones, denied permission and stale plans. | **Add AC:** Use N3 fixture times and N5 freshness rules. One reminder per stable purpose/revision; move/cancel/hide replaces or removes pending reminders; past reminders are not replayed after reconnect; quiet-hour precedence, denial, DST/time-zone change and per-session opt-out are tested. Verify delivered reminders on a physical phone in supported states, and disclose unsupported guarantees. **Depends on:** N4, N5, #36. |
| [#20](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/20) | Edit | "under 60 seconds with defaults" is underspecified; Health/Intervals are currently hard prerequisites. Owner comment requires persisted screening for #37. | **Replace beta Scope:** Persist reviewed screening state, manual weight, meal windows, diet/allergen preferences and performance/maintenance selection locally; hide slow loss. Show the first eligible manual/rest-day plan without provider authorization. Connect Health/Intervals optionally. **Add AC:** No unknown/failed eligibility state produces targets; reopening/deep-linking cannot bypass screening. Record timing from local onboarding start to first plan, excluding documented OS/OAuth waits, with a named seeded test setup and target under 60 seconds. **Depends on:** #10, #16, N2; reviewed #8/#9 copy gates athlete testing. Connection checkpoint uses #12/#14/#21. |
| [#21](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/21) | Edit | "one sync cycle" is undefined; "delete weight outliers" does not identify data ownership. | **Add AC:** Show N5's last successful sync, stale/error state and reconnect result. Reject an imported outlier locally without deleting source data; confirm/reject and undo merge survive reimport and produce one revised plan. Remove inactive TrainingPeaks/export placeholders from beta. **Depends on:** #12, #14, N4, N5, #36. |
| [#22](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/22) | Move | StoreKit is a #24 prerequisite, but validating the core loop does not require charging testers. | **Milestone:** After beta, commercial release. **Add AC:** Specify the paid/free feature matrix, trial eligibility, cancellation versus expiry, pending/refunded/revoked entitlement behavior and offline entitlement policy; test each with StoreKit. Beta is free and has no paywall. **Depends on:** #10, #3, #20, N1. Remove from #24. |
| [#23](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/23) | Edit | "All ... server rows" and "Apple revoke call succeeds" do not address partial failure or local replay after deletion. | **Add AC:** Deletion is resumable and idempotent; report completion only after the required revoke/deletion steps succeed. Erase local data, queued sync/export work and scheduled reminders; late webhook/reconnect cannot recreate deleted data. Define and verify treatment of own Health exports and backups in #8's policy. Re-signup starts empty. Beta revokes Apple/Intervals; later integrations must extend this checklist. **Depends on:** #13, #12, #14, #19, N2, N9, #8. |
| [#24](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/24) | Edit | "see a plan" is not the core loop; closed approvals lack revision identity. | **Replace AC:** The approved beta build passes the end-to-end script below on a physical phone; screening, permission denial, offline restart, reconnect and deletion checks pass; privacy inventory matches actual shipped data; #8/#9 approve this revision with no open blockers; changed screens have native light/dark/accessibility evidence and explained design deviations; external TestFlight build is available. **Depends on:** #3, #5, #8, #9, #11, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #23, #28, #36, N1–N6, N9. Remove #22; #37/#38/N7/N8 are excluded. |
| [#25](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/25) | Edit | "Webhook updates appear" and workout merge lack change/delete/replay cases; recovery data has no defined beta consumer. | **Add AC:** Persist source IDs and match WHOOP/Health/planned instances using N2; replay/reorder/delete are idempotent; token expiry/disconnect follows N5; show the actual imported fields and define where recovery/sleep appears without inventing a target adjustment. Verify within the approved sandbox member limit. **Depends on:** #13, #12, #6, #8, #21, N2, N5, N9. |
| [#26](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/26) | Edit | "about 14 days ahead" is not an exact parser AC; "Removing the feed removes its sessions" risks losing linked intake. | **Replace AC:** Import available events in [today, today + 14 local dates); test UID/recurrence instance identity, TZID, all-day events, cancellation, missing duration and malformed input. Disconnect suppresses that feed's future demand without deleting intake/history; update/remove reuses N2 reconciliation. Treat subscription URLs as secrets. **Depends on:** #18, N2, N5; N9 if feed configuration syncs. |
| [#27](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/27) | Edit | "replaces the calendar feed" makes fallback implementation mandatory even for users without it. | **Replace AC:** With approved scopes, import available events over an exact seven-local-date horizon; update/delete/reconnect follows N2/N5. If a calendar feed exists, migrate by provenance with no duplicate demand and preserve local hides/overrides; otherwise direct connection works alone. **Depends on:** #4 approval, #13, #21, N2, N5, N9. #26 is required only for the calendar-migration test path, not basic API connection. |
| [#28](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/28) | Move | Phase 2 despite #16/#17 Ideas actions. "closest" lacks ranking, portions and logging behavior. | **Milestone:** Beta local loop. **Replace Scope:** Bundle 12 reviewed meal/snack suggestions with ingredient masses, per-serving macros, supported diets/allergens and bounded portions. Define ranking as normalized carb/protein distance with stable ID tie-break, using N3's approved weighting/portion policy. **Add AC:** Missing allergen metadata excludes an idea; no-match can relax only soft prep-time preferences; chosen portion opens a #15 draft with exact nutrients and target linkage; all supported filters and no-match state tested. **Depends on:** #11, #15, #36, N2, N3, N4. #9 approves content before athlete exposure. |
| [#29](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/29) | Edit | "individualized" and "optional personal sweat-rate test" do not specify inputs/errors; a fluid range does not prove individualization. | **Add AC:** Approve a decision table for baseline versus individualized guidance, sweat-test inputs/units, invalid data and missing conditions; fixtures cover both paths and label uncertainty. Sodium remains unavailable until the exact rule revision is approved. Add physical-device/simulator screenshot of the changed During section. **Depends on:** #11, #17, N3, N4; #9 supplies a separate hydration release approval. |
| [#30](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/30) | Edit | "e.g. repeated hungry" gives neither count nor magnitude, and range tests do not prove feedback attribution. | **Move #17 feedback capture here. Add AC:** Version the response vocabulary, observation window, minimum valid responses, adjustment step, caps, decay/reset, opt-out and conflict priority with coach/gut limits. Approve golden cases before implementation; store feedback against the canonical session/revision and change future portions only. **Depends on:** #17, #11, N2, N3, N4; new #9 approval for these adjustment rules. |
| [#31](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/31) | Edit | "all ... app-created data" exceeds the listed tables and may omit unsynced data. | **Replace AC:** Publish a versioned export field list for app-created profile/settings, sessions/overrides, intake and plan revisions; include local unsynced records, units, UTC timestamps plus time zone and source IDs. Document excluded provider/Health data and secrets. Test quoting, newlines, Unicode, formula-like text and exact record counts; open sample files in Numbers and Excel. **Depends on:** N2, N9, #15, #18, N4; #8 reviews exclusions. |
| [#32](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/32) | Edit | "dedupe against Apple Health copies" has no #12 edge; application approval and implementation share a gate. | **Add checkpoints:** Obtain written approval/terms answers before live integration. Then test delivery authentication, replay/deletion, canonical completed/planned matching and attribution in every display/export destination. Do not promise backfill until granted capabilities are confirmed. **Depends on:** #8, #13, #12, #21, N2, N5, N9 plus recorded Garmin access. Keep later scope. |
| [#33](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/33) | Edit | "arrive ... at the planned times" lacks permission/state boundaries; "ends cleanly" lacks an assertion. | **Add AC:** Define notification mirroring versus a Watch app explicitly; test the supported phone/watch state matrix, denial, disconnect, delayed prompts, cancel and time-zone changes. Ending/canceling a session removes its pending prompts and ends its Live Activity; define the long-session fallback at the supported duration limit. **Depends on:** #19, N2, N5, N6. Physical-device evidence required; do not infer runtime behavior from screenshots. |
| [#34](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/34) | Edit | "Widgets refresh when the plan changes" is unbounded and has no stale-data or privacy policy. | **Replace AC:** Publish the latest shared snapshot after local plan commit; show its timestamp and stale state under N5; test no-plan, expired timeline, account deletion and deep-link routing. Confirm actual widget refresh behavior on device and document delays rather than promising immediate display. **Depends on:** #16, N2, N5, N6. |
| [#35](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/35) | Edit | A stub-only test cannot establish "Output never changes a number" or origin filtering. | **Add AC:** Render numbers directly from the engine outside generated prose; reject/fall back on unsupported numeric claims, unavailable model, error or invalid output. Only an allowlisted provenance-filtered input may reach the model; test derived summaries as well as direct fields. Test a supported real device and unsupported fallback. **Depends on:** #11, #8, N2, N6. |
| [#36](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/36) | Edit | "keep every number and label" conflicts with #11; DESIGN.md:54/60 already changes calorie placement and delete/hide semantics. | **Replace numeric AC:** Every beta screen references N3 scenario/version; fixture values supersede legacy literals. #36 owns tokens/layout/navigation/state references, not nutrition calculations. Mark future Goal/Caffeine/Week/catalog states as later scope. Provide beta mappings for manual setup, daily explanation, meal-window/preferences, logging/edit/undo and deletion states. Review all rendered beta states with scrolling; require native checks when implemented. **Depends on:** PR #1, N1, N3, N6. |
| [#37](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/37) | Move | "mostly complete logging", "sustained ... flag" and "about" values are not deterministic. Deferred scope still needs an explicit contract. | **Milestone:** Later, reviewed adaptive goals. Remove its logic from #11/#20 beta bodies. **Add prerequisite:** Approve exact completeness estimator, missing/uncertain FFM behavior, eligibility, pause/resume conditions, baseline estimation, gain/loss priority and date rounding before implementation. Test missing data and holds, not only a fully populated example. **Depends on:** #11, #12, #15, #20, N2, N3, N4, N9 and a new revision-specific #9 approval. |
| [#38](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/38) | Edit | "24-hour curve" omits prior-day residuals; "around 200 mg" lacks a threshold; pregnancy guidance conflicts with beta exclusion. | **Add AC:** Approve exact dose bands, missing-caffeine handling, prior-day dose horizon, planned-versus-consumed display and rounding. Own Health round trips count once. Test bedtime crossing midnight, edited/deleted doses and no exposure for excluded users; pregnancy wording follows the approved eligibility policy rather than reopening onboarding. Food-provider enrichment may wait for N7; quick-add remains valid. **Depends on:** #15, #12, #17, N2, N3, N6; #9 approves caffeine separately. |

### Common verification text for edited feature issues

Paste into each feature's Verification section, keeping its specific checks:

> Map each acceptance criterion to a named test or a written device/manual check. Use the shared scenario ID and rules revision for numerical expectations. Run `scripts/verify.sh` for implemented components locally and in PR CI; skipped components are not feature evidence. Obtain independent review, resolve findings, and attach native screenshots of changed states in light/dark modes and the selected accessibility size. Compare with the approved #36 beta frame and explain intentional differences. Physical-device-only behaviors require device evidence. Record remaining limitations. The human merges.

Paperwork #2–#9 remains branchless under AGENTS.md:38; record decisions and evidence on the issue. N1/N6 below are also paperwork decisions despite using the requested full draft format. N2/N3 include versioned contract/fixture artifacts, so they are feature work. No new branch is needed merely to prepare this review.

## New issue drafts

These drafts use the repository's requested Goal / Scope / Out of scope / Acceptance criteria / Verification / References / Depends on structure. Decision values are proposals to approve, not silently adopted requirements. Each split-out issue has its full draft here, so no extra unnamed issue is required to implement the proposed split.

### N1. Record the exact beta promise and deferred scope

Suggested label: `paperwork`. Milestone: B0 decisions and contracts.

## Goal

Agree the smallest external beta that lets an eligible athlete choose food for a planned workout, log it and trust an updated plan.

## Scope

- Free beta on one calculating iPhone. Manual profile and workouts, rest days, carb/protein targets, a small bundled meal library, local food logging, Intervals.icu, completed-workout/weight Health reads, own nutrition Health writes, offline persistence/sync, reminders and account deletion.
- Three beta navigation destinations: Today, Log and Profile. Quick-add is available from Today. Keep the four-tab shell only during scaffolding; remove the empty Week destination before release.
- Carb/protein targets only. Fat may be logged but has no target meter. No invented fat or total-energy budget. Calories remain hidden by default; if enabled, display logged calories only.
- Explicitly defer broad food search/barcodes, seven-day overview, subscription billing, adaptive weight goals, caffeine, WHOOP, TrainingPeaks/ICS, hydration adaptation, feedback adaptation, widgets and AI wording.
- Define eligible beta population, launch jurisdictions, supported sports and supported diet/allergen vocabulary with the appropriate #8/#9 reviewers. Unsupported sports receive the approved fallback, not a fabricated precision estimate.

## Out of scope

- Clinical approval, legal advice, provider access approval or implementation.
- Multi-phone concurrent planning and commercial release.

## Acceptance criteria

- [ ] Diego records approval or corrections to every scope choice above.
- [ ] A checklist maps each included capability to an existing or N-numbered issue and to #24's end-to-end script.
- [ ] #24 no longer blocks on #22; #28 is included; #37 is explicitly deferred and slow-loss controls are absent from beta onboarding/design.
- [ ] #36 lists beta frames and intentional differences from the original wireframes, including three-tab navigation and no fat target.
- [ ] Record one outcome test: an eligible tester can choose a suggested portion, save it, move/cancel a workout and explain what changed without losing intake.
- [ ] Intervals OAuth availability is a release gate. A manual-only build may be called an internal prototype; a changed external promise requires an explicit scope decision.

## Verification

- Tests: trace every included capability to a named issue/test or manual check; audit the revised release dependency list.
- Screenshots: not applicable to this paperwork decision; #36 owns proposed screens and #24 owns native evidence.

## References

- #16 "Log it and Ideas"; #28 currently Phase 2; #22 and #37 currently Phase 1.
- #24 "External testers can complete onboarding and see a plan".
- Research §3 lines 65–78; §9 lines 327–335.

## Depends on

- None. #8/#9 review population and jurisdiction details before external release.

### N2. Define the canonical session, intake and plan data contract

Suggested labels: `feature`, `area:engine`, `area:backend`. Milestone: B0 decisions and contracts.

## Goal

Make every import, edit, log and plan revision refer to the same training demand and intake records.

## Scope

- A versioned contract with typed units, stable IDs, timestamps/time zones, provenance, optional/unknown values and schema migration rules. Implement shared pure-Swift value types after #10; document server mapping without mirroring raw Health samples.
- Planned session versus completed observation, source priority, explicit unresolved matches and reversible merges. Specify local edits versus provider updates, manual deletion versus imported hide/unhide and stable suppression keys.
- Intake entry versus planned meal, deliberate user corrections, operation IDs, source export IDs and retry state. A saved food retains its nutrient snapshot if its catalog entry later changes.
- Plan revision includes input/rules/fixture versions, calculation timestamp, daily/session allocations and reason IDs. Screening state and diet/allergen/meal-window settings have explicit owners and persistence rules.
- Field-by-field local/server data allowlist. The beta has one calculating phone; app-created records may sync, but raw Health samples and generated plans from another device cannot silently override its local calculation. Define replacement-phone recovery and retirement of the old writer.

## Out of scope

- Provider transport, Supabase sync implementation, calculation rules and unrestricted simultaneous multi-device editing.

## Acceptance criteria

- [ ] A published schema names types, units, null semantics, owning source, server eligibility and conflict policy for every persisted field.
- [ ] Pure-value fixtures cover planned-to-completed reconciliation, duplicate delivery, reversible matching, imported override/reset, hide/unhide, source deletion and intake edit/delete.
- [ ] Own nutrition write/readback and retry use one canonical intake identity; source aggregates with unknown timing cannot satisfy a specific meal window.
- [ ] DST/midnight/travel policy states which local date owns an intake/session and how persisted timestamps retain meaning.
- [ ] A plan revision does not mutate an intake snapshot. An intentional edit produces a new operation and recomputes derived totals once.
- [ ] One-phone ownership, account switching, replacement-phone recovery and post-deletion rejection have explicit transitions.
- [ ] #11–#15, #18, #23 and N4/N9 reference this contract instead of creating private variants.

## Verification

- Tests: serialization/round-trip, identity and state-transition fixtures using pure Swift; manually inspect the server-field allowlist against #8's inventory.
- Screenshots: none; this issue publishes types and contracts. Consumer screens verify the behaviors later.

## References

- #11 planned/completed input list; #12 "reversibly" and Health writes; #13 offline sync; #23 account deletion.
- `DESIGN.md:60` manual Delete versus synced Hide; research §10 lines 374–390.

## Depends on

- N1 and N6 for contract decisions.
- #10 for the shared Swift package artifact. Draft the contract alongside scaffolding; consumers wait for the artifact.

### N3. Publish one versioned rule decision table, scenario set and rounding policy

Suggested labels: `feature`, `area:engine`, `needs-dietitian-review`. Milestone: B0 decisions and contracts.

## Goal

Give engine tests and screen verification the same exact inputs and expected values.

## Scope

- A versioned machine-readable fixture set, loaded by engine tests and app preview/UI-test data, plus a human-readable rule table.
- Enumerate enabled beta rules only. Define day-band boundaries, supported sports/fallbacks, protein defaults, pre/during/post precedence, coach/gut-cap precedence, duration tolerance and missing/invalid inputs. Define meal-window and portion/ranking parameters consumed by N4/#28.
- Separate computational precision, stored nutrient precision, displayed grams/rates and displayed total rounding. Specify how rounded meal rows reconcile to the displayed day total, and stable tie-breaking.
- A citation and classification per rule: source-supported range, app-selected default or unresolved assumption. Resolve every beta-affecting assumption with #9 before athlete exposure.
- Scenarios include the existing Tuesday example, rest day, early start, multiple sessions, conflicting recovery/pre windows, exceeded intake, upstream cancellation, missing weight/IF and revised duration near the tolerance boundary.

## Out of scope

- FuelingEngine implementation, new clinical claims, goal-weight/caffeine/hydration algorithms and screenshot-only duplicate fixture data.

## Acceptance criteria

- [ ] Each enabled rule has exact units, input validity, boundary inclusion/exclusion, precedence, output fields and a cited expected case.
- [ ] Tuesday uses one full-precision calculation and a documented rounding sequence. Research illustrative approximations and old mockup literals are explicitly superseded; no test asserts both 426 g and 490 g for identical inputs.
- [ ] Cases exercise either side of 45, 60, 75 and 150 minutes, the eight-hour recovery boundary, lead-time boundaries, missing values and the approved gut-cap/coach conflicts.
- [ ] Each scenario fixes clock, locale, time zone, sessions, intake, settings, rules revision and exact outputs/reason IDs. Snapshot data is loaded from the same fixture source.
- [ ] The fixture loader detects unknown schema versions, duplicate IDs and absent required fields. A manifest maps every beta screen and enabled rule to cases.
- [ ] Proposed parameters are identified as pending until #9's spec checkpoint. Any final approval change updates the fixture revision and all consumer tests together.

## Verification

- Tests: fixture-schema/loader validation and independently recomputed arithmetic for representative cases. #11 and N4 add the behavioral golden tests against these expected values.
- Screenshots: #36 records the fixture/version behind each numerical beta frame; app screenshot verification follows implementation.

## References

- #11 golden tests and Tuesday literals; #36 "keep every number and label".
- Research §4 lines 84–101 and 113–156; §9 line 332.
- `docs/design/mockups.html:430` current 490 g target.

## Depends on

- N1, N2. #9's reviewed-spec checkpoint is required to freeze athlete-facing parameters, not to author synthetic draft cases.

### N4. Implement a shared intake allocation ledger and future-only replanning

Suggested labels: `feature`, `area:engine`, `needs-dietitian-review`. Milestone: B1 local end-to-end loop.

## Goal

Allocate a day's remaining food across training and meal windows without losing or double-counting what the athlete ate.

## Scope

- Pure-Swift allocation over #11 targets and N2 records. A food's physical amount counts once in daily intake; its contribution may satisfy overlapping training purposes under a documented shared-credit rule.
- Define daily target, consumed amount, remaining allocation and unmet/conflicting constraints separately. Apply N3's priority table for overlapping sessions, coach/gut caps, look-ahead transfers and exceeded targets.
- Persisted user meal windows and ad-hoc snacks. A look-ahead transfer records source/destination dates and cannot rewrite already-consumed intake on either day.
- Revision diff and stable reason IDs for the consumer UI. Treat deliberate corrections as user operations, distinct from automatic replanning.

## Out of scope

- UI, transport, clinical threshold invention and adaptive weight loss.

## Acceptance criteria

- [ ] Golden cases cover two sessions with overlapping recovery/pre windows, an early next-day session, midnight/DST, cancellation after eating, consumed amount above a revised target and a gut cap below the nominal guidance range.
- [ ] Daily intake counts each canonical entry once; multiple purpose credits never add physical intake twice. Allocation totals reconcile under the explicit rounding policy.
- [ ] Future portions are nonnegative. When constraints cannot all be satisfied, return the named conflict and approved fallback; never silently alter consumed intake or claim all ranges were met.
- [ ] Repeating the same calculation is deterministic and does not accumulate credits/transfers. Reordering the same canonical inputs produces the same result.
- [ ] Moving/canceling a workout changes only future allocations. Intentional intake edit/delete produces the expected new totals and reason without duplicating a Health export.
- [ ] Property tests cover conservation and identity in addition to range tests; the first review's two-session oversubscription case is included by fixture ID.

## Verification

- Tests: `scripts/verify.sh engine`, golden/property tests with source/parameter citations and fixed clocks, locally and Linux CI.
- Screenshots: none here; #16/#17 demonstrate the revision and shared-allocation explanations.

## References

- #11 "remaining carbs and protein spread over meals"; #16 "Logged meals keep their values".
- Research §4 lines 134–144; §9 lines 332–333.
- First-pass review finding 3, numerical multi-session counterexample.

## Depends on

- #11, N2, N3. #9 approves the shipped allocator policy before athlete exposure.

### N5. Specify freshness and stale-plan behavior across app and notifications

Suggested labels: `feature`, `area:integration`. Milestone: B0 decisions and contracts.

## Goal

Tell an athlete when their plan last reconciled and give every integration the same behavior when updates are delayed.

## Scope

- State table for foreground, suspended, force-quit, offline, reconnect, expired/revoked authorization, duplicate/reordered events and source deletion.
- Distinguish provider observation, server receipt, app fetch success, plan revision commit and reminder scheduling. A webhook receipt alone cannot mark a plan current.
- Proposed foreground test budget: start reconciliation within one second of app-open or explicit retry under a controlled clock; with an immediate fixture response, publish the revision within five seconds. After 15 seconds without a completed response, show an actionable stale/error state and retain the last usable plan. Background delivery is best effort, with no unconditional minutes guarantee.
- Define notification identifiers, expiry, quiet-hour precedence and stale reminders. If the app cannot run, do not promise already-scheduled reminders can be replaced; make notification wording conditional and refresh on open. Record the residual limitation for release review.

## Out of scope

- Provider/APNs implementation and a guaranteed device wake time.

## Acceptance criteria

- [ ] Every state/event pair has a transition, displayed last-success time, retry behavior and target/reminder policy.
- [ ] Use a fake clock/network to specify foreground success, timeout, recovery and reordered-event expectations with exact elapsed times.
- [ ] #14 removes its unconditional "within minutes" criterion; #19/#21 adopt this matrix; later #25/#26/#27/#32/#33/#34 reference it.
- [ ] Duplicate events do not create duplicate reminders; reconnect never delivers a burst of expired reminders; refresh failure never silently labels the old plan current.
- [ ] The release script names the real-device states that must be checked and states what cannot be guaranteed if the app cannot wake.

## Verification

- Tests: state-machine/spec cases with a deterministic clock, then consumer integration tests in #14/#19/#21.
- Screenshots: #36 supplies stale/timeout/reconnect reference states; native evidence comes from consumers and #24.

## References

- #14 "within minutes with no manual refresh"; #19 reschedule/cancel; #21 "one sync cycle".
- `DESIGN.md:90–99` cached-plan and connection states; research §10 lines 392–395.
- First-pass review finding 5. This issue converts the already-identified limitation into a measurable contract; it does not claim new platform verification.

## Depends on

- N1, N2.

### N6. Decide minimum iOS version and capability fallbacks

Suggested label: `paperwork`. Milestone: B0 decisions and contracts.

## Goal

Choose which iPhones the beta supports before project settings and native UI depend on an accidental OS baseline.

## Scope

- Record the minimum deployment version separately from the Xcode/SDK version used in CI.
- Inventory the actually selected SwiftData, SwiftUI navigation, Health, notifications and authentication APIs and their availability.
- Recommend iOS 18 as a candidate baseline to evaluate, not an approved choice. Confirm a matching test runtime/device is available or record the supported alternative and reason.
- Keep optional Foundation Models and future Watch/widget features from raising the beta baseline implicitly.

## Out of scope

- Implementing backports, changing the project or enabling on-device AI.

## Acceptance criteria

- [ ] Diego approves one exact minimum version after reviewing the target-device/runtime inventory and API availability evidence.
- [ ] Record CI SDK/toolchain and the minimum-runtime plus current-runtime verification matrix; identify unavailable runtimes before implementation planning.
- [ ] Every higher-OS-only API in the proposed beta design has an availability guard/fallback or is removed from scope.
- [ ] #10 and #36 reference the same decision; #35 explicitly remains optional on supported devices.

## Verification

- Tests: review official API availability and available simulator/device versions during implementation setup; verify the chosen matrix is executable.
- Screenshots: none for the decision; #10 records launches on the chosen runtime matrix.

## References

- #10 "Decide the minimum iOS version here"; #35 supported-device fallback.
- `DESIGN.md:155` iOS 26 tab-bar mapping; research §10 lines 356–368.

## Depends on

- N1.

### N7. Add catalog search, barcode lookup and food-specific serving conversions

Split from #15. Suggested labels: `feature`, `area:food`. Milestone: A1 after-beta convenience.

## Goal

Find packaged and database foods while preserving the fast local logger and accurate serving amounts.

## Scope

- USDA search through an Edge Function and Open Food Facts barcode lookup, provider provenance and required attribution.
- Convert mass units directly; offer household/item units only where that food supplies a known serving mass. Keep energy/macros independently sourced and distinguish zero from unknown.
- Cache usable food snapshots and permit custom foods when lookup fails. Keep saved-entry nutrients stable across catalog changes.

## Out of scope

- FatSecret until access and integration scope are separately approved; photo logging; universal household conversions.

## Acceptance criteria

- [ ] Fixtures cover g/oz conversions and food-specific tbsp/each serving masses, including missing/zero/invalid masses.
- [ ] Unsupported household units are unavailable with an explanation; users can enter grams or a custom serving mass.
- [ ] Search/barcode results show provenance and serving basis; empty, offline, denied-camera, timeout and provider-error states preserve the draft.
- [ ] Editing amount, changing food and manual macro override recompute totals once; retrying Save does not duplicate the entry.
- [ ] Credentials remain server-side; attribution is visible; cache/retention terms are recorded with #8 as needed.
- [ ] Real-provider lookup is checked with a test food and barcode; fixture tests do not stand in for integration evidence.

## Verification

- Tests: unit conversions, missing nutrient semantics, provider adapters and error handling, plus native scanner check on a physical phone.
- Screenshots: Log search/barcode/empty/offline states against #36's later catalog frames and original wireframe 5.

## References

- #15 original search/barcode/units scope; #7 optional FatSecret paperwork.
- Research §9 line 327, logging accuracy complaints; `DESIGN.md:94` offline search.

## Depends on

- #15, #13, N2, N3; #8 for provider-specific data/attribution disposition.

### N8. Add the seven-day plan overview

Split from #18. Suggested labels: `feature`, `area:ios`. Milestone: A1 after-beta convenience.

## Goal

Let athletes inspect upcoming fueling and open the existing workout editor from a week view.

## Scope

- Seven local dates showing code, workouts, carb targets and look-ahead reasons from the current revision.
- Navigate to #17; reuse #18 quick-add/edit/hide controls without a second session-editing implementation.
- Add Week navigation only when this screen is ready.

## Out of scope

- A second rules engine, new workout source and automatic changes to logged intake.

## Acceptance criteria

- [ ] Fixed-clock fixtures show exactly seven consecutive local dates across DST/month/year boundaries.
- [ ] Every day, including rest/unplanned days, has the same target as its daily detail for the same revision.
- [ ] Look-ahead transfers explain both affected dates without counting a transferred amount twice.
- [ ] Empty-source, loading, stale/error, multiple-session and large-text states are usable; cached targets remain visibly timestamped.
- [ ] Opening, editing or hiding a session uses existing canonical IDs and updates both views consistently.

## Verification

- Tests: date mapping, shared revision identity and navigation/edit UI checks.
- Screenshots: Week light/dark/accessibility states against #36's Week frame and original wireframe 4.

## References

- #18 original Week scope; `DESIGN.md:93`; research §4 line 134.

## Depends on

- #18, #17, #16, #36, N4, N5.

### N9. Implement durable offline replay for app-created records

Split from #13. Suggested labels: `feature`, `area:backend`, `area:ios`. Milestone: B2 connected loop.

## Goal

Keep saved meals and workout edits intact through offline use, interrupted sync and account changes.

## Scope

- SwiftData durable outbox and Supabase replay following N2's record ownership, operation IDs, conflict and tombstone rules.
- Local commit succeeds independently of upload/export; expose pending, retrying and complete states. Do not upload raw Health data.
- One calculating phone per account for beta. Persist the ownership state and allow explicit replacement-phone recovery; reject writes from the retired phone.
- Migration/restart behavior for pending operations and deletion fences used by #23.

## Out of scope

- Multi-device concurrent planning, mirroring Health samples and provider API transport.

## Acceptance criteria

- [ ] Create/edit/delete while offline, restart the app and reconnect: each operation converges once with the correct final totals.
- [ ] Crash between local commit, send and acknowledgment; replaying the same operation does not duplicate records or lose a later edit.
- [ ] Tombstones prevent stale writes from restoring deleted records; account-switch/deletion fences reject queued work for the old identity.
- [ ] Replacement-phone recovery restores the permitted app-created data, reacquires local Health inputs and recomputes its own revision; the retired writer cannot overwrite it.
- [ ] Schema migration preserves unsynced records and export references; corruption/failure leaves an actionable recoverable state rather than reporting success.
- [ ] Two-account tests deny cross-account access and confirm no raw Health sample fields enter the sync payload.

## Verification

- Tests: interrupted transport/fake-clock cases, local persistence tests, SQL/RLS and Deno tests via `scripts/verify.sh` locally and CI.
- Screenshots: Log pending-sync/retry state and Profile replacement-phone/error state against #36's approved mappings. Record a physical-phone offline/relaunch/reconnect check.

## References

- #13 "The app works offline and syncs on reconnect"; #15 save/edit; #23 local wipe.
- `DESIGN.md:61` "Saved on this phone, syncs later"; research §10 lines 374–390.

## Depends on

- #13, #15, #18, N2. #23 consumes the deletion fence afterward, avoiding a reciprocal dependency.

## Proposed milestone layout and delivery order

This replaces the broad Phase 1 bucket with verifiable slices. Internal slices do not authorize exposing unapproved targets to athletes. Long-lead paperwork runs alongside build work; it is not a single predecessor to every feature.

| Milestone | Existing issues | New issues | Exit evidence |
|---|---|---|---|
| P0: Access and review, parallel | #2, #3, #5, #8, #9. #4/#6/#7 remain optional long-lead paperwork for later integrations. | None | Account/callback evidence and review checkpoints. Final #8/#9 approval gates B3, not synthetic scaffolding. |
| B0: Scope, scaffold and contracts | #10, #36 | N1, N2, N3, N5, N6 | Approved beta scope/OS; real app/package tests; canonical types; rule/fixture and freshness contracts; beta design/state mappings. |
| B1: Local end-to-end loop | #11, #15 narrowed, #18 narrowed, #28 moved in, #19, #17, #16; early local-profile/screening checkpoint of #20 | N4 | Manual profile/workout or rest day produces targets, an actual suggested portion, a durable log and an explained future-only revision. Use synthetic profiles until approval. |
| B2: Connected loop | #13 narrowed, #12 narrowed, #14, #21; finish optional connections in #20; #23 | N9 | Intervals + completed Health workout count once; own Health export counts once; offline replay and token/reconnect/deletion checks pass. |
| B3: External TestFlight beta | #24; final #8/#9 approval evidence | None | All listed beta dependencies verified; physical-device core-loop script, native UI evidence and approvals refer to the shipped revision. |
| A1: After-beta convenience and commercialization | #22 moved out, #25, #26, #27, #29, #30, #31, #38 | N7, N8 | Each feature stands alone with its provider/reviewer gates. Subscription deployment requires the approved entitlement/free-tier contract. |
| L: Later, separate high-uncertainty work | #32, #33, #34, #35; #37 moved out | None | Device/provider/clinical prerequisites resolved before implementation. Adaptive goals wait for data-quality evidence and new approval. |

There are no merges proposed. #11 and #37 have distinct responsibilities once the stale slow-loss text is removed. #16/#17 remain separate screens; #28 owns reusable meal suggestions. #19 owns scheduling; screen toggles call it. #13 owns backend foundation; N9 owns replay. #18 owns session mutations; N8 only presents a week.

Suggested topological sequence, with independent work in the same stage:

1. N1, then N6 and #2; start #3/#5 paperwork and #8/#9 consultations.
2. #10, then N2. Draft N3/N5; freeze the beta rules after #9's spec checkpoint. Reconcile #36 against N1/N3/N6.
3. #11, #15 and #18; then N4; then #28 and #19; then #17 and #16. Build #20's local setup early using the N2 profile contract and finish it against the working first-plan screen.
4. #13 and #12 can proceed once their contracts/scaffold exist. N9 follows #13/#15/#18. #14 follows approved #5, #12/#13/N9/#11/N5; then #21 and #20's optional connection path. #23 follows the implemented data owners and scheduling.
5. Resolve #8/#9 final findings; run #24 against the exact release build. Keep human merge and release decisions intact.

The stage order is a proposal, not authorization to create branches. Create each branch as its work begins from the appropriate approved base. Do not pre-create the roadmap against the current design branch.

### Concrete external-beta acceptance journey for #24

1. On a supported physical phone with a new test account, complete approved eligibility/manual-profile setup. Decline Health and notification permissions; still reach a usable manual/rest-day plan. An ineligible or unknown screening state never exposes targets.
2. Add a manual workout, inspect before/during/after targets and their reasons, choose a portioned idea, save the suggested food and inspect exact logged nutrients. Confirm hard diet/allergen filters and the no-match state.
3. Move then cancel the workout after eating. Saved intake remains unchanged; only future allocations change; the displayed reason and reminders refer to the committed revision. Test a two-session shared-meal fixture as well.
4. Relaunch offline, deliberately correct a logged item and save another. Reconnect; verify final totals and one server record/export per canonical entry. Failed sync must not be presented as a failed local save.
5. Connect approved Intervals OAuth and Health. Move an upstream session, receive its completed Health counterpart and confirm one training demand. Repeat/reorder an update, hide/unhide an import and expire/reconnect authorization. Record the N5 foreground/background/force-quit limitations rather than promising a wake.
6. Enable notifications and verify a delivered reminder, rescheduling and cancellation in the documented supported states. Inspect light/dark, large text, VoiceOver traversal, editable draft, save/undo, no suggestions and stale-plan states.
7. Delete the account, interrupt/retry a deletion step, then reconnect the old session and deliver a delayed event. No data returns. Sign in again cleanly. Confirm #8's published Health-export/retention policy matches observed behavior.

## What I could not verify

- No application, provider integration or nutrition implementation was built or run. This audit does not establish algorithm correctness, clinical safety, actual sync latency, Health export fidelity, notification delivery, accessibility or usability timing.
- No live provider accounts, OAuth approvals, legal documents or dietitian approval artifacts were supplied. The live #9 comment requests more review; it is not approval. #8 had no comments. I did not infer that private approvals do or do not exist.
- Research was read from the specifically requested local remote-tracking ref. No fetch was permitted, so I did not establish whether that ref is the latest remote PR head. I did not inspect or modify PR status, CI, branch protection or branch history beyond identifying the read refs and worktree status.
- No new external medical, legal, pricing or platform research was performed. Findings concern the internal backlog contract and its evidence. Platform capability and proposed iOS 18 availability must be checked in N6; the freshness proposal uses the limitation already documented in the first review and makes no newly verified timing claim.
- No browser or simulator rendering was repeated. Design observations are source-based here; earlier screenshots belong to the first-pass review. The new drafts require native evidence before acceptance.
- Live issue bodies/comments were read on this review date; later edits may supersede this report. No GitHub issue, milestone, label, PR, file in the repository or Git state was changed.

## Report checks

Verified 37 unique per-issue rows covering #2–#38, the stated verdict counts, and all seven required template headings in each of N1–N9. The proposed beta hard-dependency graph also has no cycles when early review checkpoints are distinguished from final release approvals. Repository `git status --short` was empty before and after this review. The only written file was this report.
