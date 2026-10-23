# Astra review: nutrition app plan and implementation

Reviewed 23 October 2026. This is a read-only assessment, not approval of the nutrition rules. No repository files, issue content, commits, branches, or PR content were changed.

## Verdict

Keep the platform choices and the focus on planned training. Tighten the product scope and turn the research into a precise, versioned specification before implementing the full roadmap. The project is ready for a scaffold and a small end-to-end prototype; the present documents are not yet a complete implementation contract.

The first beta should demonstrate one dependable loop: import or enter a workout, explain its fueling targets, suggest actual food, log what was eaten, and revise the remaining plan without losing or double-counting anything. Adaptive weight loss substantially expands the safety and data-quality requirements and should follow that loop.

## Evidence and current state

- Design checkout: `feature/36-design-system`, `059cc713e8a95de3b7ae18b1bee327209b0cfbf0`.
- Setup/research PR head: `0e004b09066b9a3bf9eae4f58fdf7f0f3597d1d8`.
- Main: `dc727bc2bee03785d5eb3b3f4e986211dc267c4a`, protected, both PRs still open.
- Tracked implementation consists of research, HTML/CSS mockups, design specification, workflow/templates, and `scripts/verify.sh`. There is no Xcode app, Swift package, or Supabase implementation.
- `scripts/verify.sh` exited successfully with all three components explicitly skipped because they do not exist. This confirms the bootstrap script works, not application behavior.
- PR #1 reports successful CI jobs. PR #39 reports successful changes/engine/supabase jobs and a skipped app job. No functioning application or clinical validation follows from these results.
- The design branch is three commits behind its setup parent and four commits ahead. The missing parent commits add goal-weight/caffeine research. The PR diff does not delete those additions; this is local stack drift to reconcile before implementation.
- Live issue bodies and milestones were read. The dietitian issue has a request to review the additional rules, not a recorded approval; the privacy-review issue has no comment evidence of approval.

## What is strong

- A pure Swift deterministic engine isolates calculations from UI, storage, and provider APIs. Linux tests are a useful portability constraint.
- SwiftUI and native Apple frameworks plus a thin Supabase backend are proportionate choices for a solo iOS project.
- Offline logging, calories hidden by default, provenance, reversible workout deduplication, and protecting logged meals address real user trust problems.
- The research distinguishes guideline ranges from proposed defaults and records significant unknowns rather than hiding them.
- Diet/allergen hard filters, professional review before athlete exposure, and account deletion are already represented in the backlog.
- The design includes light/dark treatments, text plus glyphs for carb codes, error states, and accessibility reflow considerations.

## Findings and corrective decisions

### 1. High: beta scope postpones the original meal-recommendation promise

The original goal includes recommending pre- and post-workout meals. [Issue #28](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/28), the meal-ideas library, is Phase 2, while [#37](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/37), adaptive goal weight, is Phase 1. [#16](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/16) already requires an Ideas action, and the mockups expose it.

Decision: bring a small curated and portioned meal/snack library into beta, with diet and allergen filters. Defer adaptive weight loss until logging completeness and training reconciliation are demonstrated. Keep caffeine and additional providers later. A minimal food logger remains useful because imported nutrient aggregates cannot supply reliable meal timing, but a broad database product need not precede the core recommendation loop.

Acceptance evidence: a tester can answer “what should I eat before this workout?” using an actual suggestion with an understandable portion and can log it without reconstructing the meal manually.

### 2. High: the numerical specification and visual acceptance criteria conflict

[Issue #11](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/11) asks for 426 g/day, 70 g before, and approximately 95 g during for Tuesday. The design shows 490 g/day, 80 g before, and about 90 g during (`docs/design/mockups.html:430`, `:457`, `:461`). The research explicitly acknowledges that difference (`docs/research/2026-10-22-fueling-app-research.md:146`). Several UI issues still require matching the original wireframes, while #36 requires preserving their numbers.

This is an acceptance-contract conflict, not evidence that 490 g is itself unsafe. A developer cannot literally satisfy both the engine example and the screen fixture for the same inputs.

Decision: adopt one set of versioned scenario fixtures for rules, screenshots, and issue expectations. Specify rounding separately from internal precision. The written interpolation currently yields about 427.07 g/day and 97.125 g during when applied without intermediate rounding, so exact golden expectations also need an explicit rounding policy.

Explanations must distinguish guideline support from the app's chosen allocation. For example, the Ride screen's 40 g dinner protein is paired only with 0.25–0.3 g/kg at 70 kg (`mockups.html:465–466`); the cited range explains 17.5–21 g, not the full dinner amount. Explain the daily allocation that supplies the balance rather than presenting the reference as its complete derivation.

### 3. High: meal-window allocation has no defined conflict policy

Research §4 subtracts before/during/after targets from a daily budget, but does not specify overlapping purposes, multiple sessions, already-eaten intake above a revised target, or infeasible combinations (`research:132–144`). Staying inside each independent range does not guarantee a coherent day.

Concrete arithmetic counterexample, not an implemented bug: a 70 kg athlete with two 75-minute rides at IF 0.85 and 600 kJ each receives a daily target of about 428 g under the stated interpolation. Two pre-session allocations total 140 g, during allocations total 150 g, and four hours of recovery after the first ride total 280 g when the next session starts under eight hours later. Their sum is 570 g before any other meals, leaving about −142 g under literal subtraction.

Decision: define a shared intake allocation ledger. One meal can fulfill recovery from one session and preparation for another, while counting once toward daily intake. Specify constraint priority and how the app reports a conflict rather than producing a negative meal or silently breaking a rule. Define how next-day carb transfers interact with both days' budgets and already-logged intake.

Acceptance evidence: two sessions, overlapping windows, early-morning training, midnight/time-zone changes, canceled workouts after eating, exceeded daily intake, and a gut-trained ceiling below the nominal guideline range. Require conservation of totals and nonnegative future portions in addition to band checks.

### 4. High: adaptive weight loss claims more certainty than the inputs establish

[Issue #37](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/37) uses an energy-availability floor, but a policy for absent or unreliable fat-free mass is not defined. The example assumes 14% body fat and a baseline expenditure of 2,309 kcal. Weekly recalibration requires three weigh-ins and “mostly complete” logging, without a defined completeness measure or estimator. The UI says the projected pace avoids under-fueling (`mockups.html:539`), which a mathematical floor cannot establish.

The [IOC 2023 consensus](https://bjsm.bmj.com/content/57/17/1073) disputes a universal threshold and describes substantial individual and measurement uncertainty. Treating 30 kcal/kg FFM as a chosen planning constraint does not make it a validated safe boundary or a diagnostic test. A property test can verify the chosen formula, not clinical safety.

Decision: defer automated deficits until a sports dietitian approves the exact algorithm, missing-data behavior, eligibility rules, and copy. Separate guideline evidence, app defaults, and unvalidated modeling assumptions. Do not invent body composition when it is missing. Define a conservative hold/maintenance state, with the exact policy reviewed professionally.

Version the approved rule configuration and attach sign-off to that revision. Closing a paperwork issue with a list of changes should not alone satisfy release approval.

### 5. High: the update latency promise is stronger than the iOS mechanism

[Issue #14](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/14) requires automatic updates within minutes. The architecture uses provider webhook → APNs → app wake → fetch → recompute. [Apple documents](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app) that background notifications may be held or delayed, and a held notification is discarded when the app is force-quit or killed.

Decision: keep on-device computation but specify freshness behavior: foreground reconciliation, best-effort background refresh, visible last-successful-sync information, and a notification that opens the app when necessary. Define what happens to existing local reminders after a moved or canceled workout when the app cannot wake. Do not promise automatic recomputation within minutes in every device state.

Acceptance evidence: foreground, suspended, force-quit, offline, reconnect, expired token, reordered/repeated webhook, and deleted workout. Distinguish server receipt latency from device plan freshness.

### 6. High: identity and provenance contracts need to precede sync and replanning

[Issues #11–15](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/11) cover planned/completed sessions, Health reads and writes, provider imports, offline sync, and meal edits. Their combined behavior needs a single model for identity and ownership.

Decisions needed:

- A planned session and its completion are one training demand, not two independent loads.
- Own food writes read back from Health must not become a second meal.
- Daily imported nutrition summaries without reliable meal times can inform daily totals but cannot silently fulfill a specific pre-workout meal.
- Define source precedence and explicit unresolved-match handling for workout duplicates.
- Persist delete/hide decisions so an import does not resurrect them.
- Define offline edit/delete conflicts, replay identifiers, tombstones, plan revisions, and Health export retry behavior.
- “Logged meals are locked” means protected from automatic replanning, while deliberate user corrections remain possible and traceable.

The independent Astra pass identified a further ownership decision: the report promises cross-device plans while HealthKit inputs remain device-local. Different devices can calculate different outputs. Choose one calculating iPhone for the first release, or define the versioned, permitted shared inputs from which devices calculate. Do not synchronize generated plans without an explicit authority policy.

It also found a vocabulary conflict: #18 promises deletion of imported sessions while `DESIGN.md:60` says Hide for synced sessions. Define local suppression separately from upstream deletion so refresh cannot restore an item the athlete deliberately hid.

Acceptance evidence: the same event delivered twice, a planned workout becoming completed, an own-source Health round trip, two devices editing offline, an upstream deletion, and a relaunch during pending export.

### 7. Medium: research must become explicit decision tables, not copied prose

The proposed carb-use method maps FTP-based IF onto Wmax using an explicitly unverified assumption, and then carries cycling substrate shares into running. The [original van Loon study](https://pmc.ncbi.nlm.nih.gov/articles/PMC2278845/) studied eight trained men at specified cycling workloads, not that FTP mapping or a generalized running algorithm. This is an extrapolation to evaluate, not an established individualized measurement.

The research also needs exact duration/intensity band boundaries, defaults for protein, a total-energy/fat-target calculation, input validity rules, and behavior when evidence or data are insufficient. Labels such as “carbs burned” should express an estimate rather than a measured physiological value.

Decision: give the engine a small versioned rule contract with typed units, input provenance, confidence/fallback reasons, rule priority, rounding, and representative cases. A guideline-band fallback may be preferable to extra physiological precision until the estimator is independently evaluated.

### 8. Medium: verification is well planned but remains bootstrap evidence

Current green checks are expected for documentation/setup; they do not validate sync, Health integration, nutrition, notifications, or native accessibility. [Issue #13](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/13) already requires extending the verification command to start the database, apply migrations, and run SQL/RLS tests, so this is planned work rather than a missing requirement.

Decision: once each component lands, fail its verification if the required implementation or tests disappear. Keep meaningful end-to-end tests for the core loop and device checks for Health/background delivery. Screenshot comparison should share numerical fixtures with the engine, and native accessibility must be tested in the app.

## Rendered design findings

Fresh browser screenshots were captured from the existing HTML. This verifies the prototype rendering, not SwiftUI or native Dynamic Type.

- **High: content is clipped instead of scrollable.** `.content--clip { overflow: hidden; }` appears at `mockups.html:303` and `:354`. Browser measurements found Today content 825 px tall in 714 px, AX3 content 2,318 px in 714 px, and Goal content 697 px in 670 px. Today hides the Caffeine card; the AX3 frame leaves the timeline inaccessible below the fixed tab bar. A separate Goal scrolled frame is illustrative, not an operable scroll path. Fix prototype scrolling and verify bottom-content reachability before treating these frames as accessibility acceptance references. Evidence: [Today at AX3](/tmp/nutrition-astra-review/today-ax3-light.png), [Today](/tmp/nutrition-astra-review/today-light.png).
- **Medium: logging state is ambiguous.** The entry screen remains editable while the Save button says “logged at 15:24.” Totals of 92/80 g carbs and 20/15 g protein say “on target,” but the permissible tolerance is not specified. Define the difference between a draft, a saved meal being edited, and a successful save; define the target tolerance without implying every gram must match. Evidence: [Log](/tmp/nutrition-astra-review/log-light.png), `mockups.html:488–489`.
- **Medium: the promised explanation destination is not designed.** “Why GREEN today” navigates to the ride frame, where the corresponding button has no destination. A static mockup need not implement app behavior, but a daily explanation also needs to handle multiple workouts, look-ahead fueling, and fallback inputs; the single-ride view does not establish that design.
- Loading, Week error, Goal empty, and Goal paused states have visible treatments. Color is supplemented by words and bars. These strengths should be retained while fixing reachability and state semantics.

## Calculation checks

- The caffeine Bateman example is internally consistent: approximately 91.45 mg at 08:10, 26.19 mg at 17:20, 115.33 mg at 18:00, and 62.81 mg at 22:30 with the specified doses and half-life.
- [Gardiner et al. 2023](https://pubmed.ncbi.nlm.nih.gov/36870101/) supports the dose-specific sleep timings cited in the report. These are population-level guidance, not a personalized safe-sleep guarantee. A future implementation still needs prior-day residuals, missing caffeine values, and planned-versus-consumed dose handling.
- Goal example arithmetic is consistent with a fixed 1,500 kcal/week deficit under its own 7,700 kcal/kg assumption: 3 kg requires about 107.8 days. This does not validate the baseline, body composition assumption, or prediction accuracy.

## Recommended build order

1. Reconcile the research/design stack and issue references. Agree one fixture set and explicitly choose the beta promise. Create branches as work starts rather than pre-creating the entire roadmap against an aging base.
2. Build #10 with real app and package tests. Define the canonical session, intake, and plan contracts. Set a minimum iOS version without making optional Foundation Models a hidden prerequisite.
3. Implement a manual-workout/manual-profile vertical slice: reviewed engine rules, Today, one session screen, curated meal ideas, quick logging, and future-only replanning. Use synthetic data until the review gate permits athlete-facing targets.
4. Add Intervals.icu, HealthKit, and Supabase with provenance, reconciliation, idempotency, and explicit freshness. Test one real athlete account end to end, including permission denial and offline use.
5. Complete onboarding, professional approvals for the shipped rules, deletion, remaining beta requirements, and real-device verification. Measure whether users can get a useful suggestion and trust the revised plan.
6. Add adaptive weight loss only after the data-quality and approval criteria are met. Add caffeine, WHOOP, TrainingPeaks, widgets, and broader food coverage when the core loop warrants the added scope.

## Limits

This review cannot establish clinical safety, provider approval, actual food-export fidelity, workout matching accuracy, background reliability, native accessibility, or real user value. No native app exists to test. Provider integrations were not connected to live personal accounts. Selected scientific and Apple platform sources were refreshed; this was not a renewed legal opinion or exhaustive audit of every price and integration term.
