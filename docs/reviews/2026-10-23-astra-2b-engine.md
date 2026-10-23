# FuelingEngine draft contract: rules v0.1

Review/specification only, 23 October 2026. **Not approved for athlete-facing recommendations.** This continues `/tmp/nutrition-astra-review/review.md`. Only this report and `2b-calc.py` were written; no repository or GitHub changes were made.

## Evidence and interpretation

`R:line` below means `docs/research/2026-10-22-fueling-app-research.md` at **origin/chore/project-setup, 0e004b09066b9a3bf9eae4f58fdf7f0f3597d1d8**, read with `git show`, not the older checked-out report. Design references mean `docs/design/mockups.html` at HEAD **059cc713e8a95de3b7ae18b1bee327209b0cfbf0**, feature/36-design-system. The working tree was clean at the initial read. No fetch was performed; remote-tracking freshness is not asserted.

Live issue bodies read: [#11 engine](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/11), [#37 goal weight](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/37), [#38 caffeine](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/38), [#19 reminders](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/19). These contain unresolved specifications, not clinical approvals.

Notation: **R** = specified in report; **P** = proposed product policy requiring approval; **U** = unresolved, return unavailable or conflict rather than fabricate a number. Evidence confidence describes support for a rule, not precision or a statistical confidence interval. Guideline support does not validate this app's interpolation, scheduling or personalization.

## Ranked findings

1. **High: independently valid targets are not a valid meal plan.** R:132–144 subtracts windows without overlap or infeasibility handling. For two 75-minute rides at 600 kJ, IF .85, 70 kg: day = 428.146341 g; naive windows = 570 g. Sharing one 70 g meal reduces unique intake to 500 g, still 71.853659 g above the day. Proposed remedy: the shared ledger below, with a permitted increase within the day band and explicit unmet requirements if infeasible. This changes the literal day formula and needs approval.
2. **High: golden fixtures disagree with both formulas and screens.** R:146–154 and #11 request 426/70/about 95; mockups:430,457,461 show 490/80/about 90. Exact R:127,137 interpolation gives **427.073171/70/97.125**. Rounding 59.333% to 59% before calculating explains part of the discrepancy, not a reproducible rounding contract. Adopt 427/70/about 97 for display, pending approval, and update all fixture consumers together.
3. **High: complete macros and loss safety cannot be determined from the listed inputs.** R:99–111 supplies ranges and alternative resting equations, not a total-expenditure baseline or protein selector. #37 requires an FFM floor while body-fat measurement is out of scope. Example: if Tuesday's total expenditure were 3,809 kcal and protein 112 g, residual fat would be 183.634 g, **43.39% of energy**, outside 20–35%. Do not invent a baseline or claim a safe deficit from an unknown FFM. See energy constraints below.
4. **Medium: sources require qualifiers that the algorithm drops.** ACSM Table 2 specifies rapid recovery between two fuel-demanding sessions; R:143 says any next session. ACSM's 45–75-minute high-intensity and 1–2.5-hour endurance categories overlap; R:136 chooses >60 minutes without resolving modality. Long-duration “up to 90” is not a universal minimum of 60. Sources and consequences are detailed below.
5. **Medium: physiological precision exceeds evidence.** R:127's FTP/Wmax mapping is expressly unverified, and R:128 carries cycling oxidation into running. Van Loon's lowest-workload text reports 46%, not R:123's 45%; 75% workload reports 3.91 rather than 3.90 g/min. More importantly, substrate oxidation is not automatically a dietary replacement prescription. Keep the estimator low-confidence, retain provenance, and prefer band fallback for unsupported modalities.
6. **Medium: thresholds, tolerances, transfers and rounding are policy, not published rules.** R:86–90,134 and #11 leave them incomplete. A hard daily floor, an early-morning transfer, an unavailable pre-meal and a gut ceiling can be mutually incompatible. The output must represent this honestly rather than satisfy #11's unconditional “every output stays inside” assertion by hiding exceptions.

## 1. Versioned interface and typed values

`RuleSetID = rules-v0.1-draft` plus immutable configuration hash, source-report SHA, approval status, effective date and fixture revision. Any change to numeric coefficients, precedence, thresholds or rounding creates a new revision. An approval must identify that exact revision. Proposed coefficients below are not enabled by implication of writing this document.

Inputs are a value snapshot; the engine reads no wall clock, HealthKit, network, UI framework or mutable singleton. Caller supplies `asOf: Instant`, planning timezone, day boundaries and meal slots. Given identical snapshot and rule revision, output is identical. All arithmetic uses finite values, typed units and deterministic tie breaks.

| Input | Unit/type and validity | Provenance and missing behavior |
|---|---|---|
| Body mass | `BodyMassKg`, finite >0; P automatic-planning review envelope 30–250 kg inclusive, outside = confirmation/manual review, never clamp | Seven-day average of daily means of deduplicated measured samples, using only samples at/before asOf. Require at least one day in that window; include sample count and span. Confirmed current manual mass fallback; no default 70 kg. Envelope and freshness are engineering policies, not clinical limits. |
| Height, age, equation coefficient | `HeightCm` >0, P 100–230 cm review envelope; age in years >=18 for v0.1 personalized adult planning; explicit resting-equation parameter choice | Measured/user-entered. Never infer an equation's male/female coefficient from name or gender identity. Missing input disables that resting equation. P upper age review envelope 100 years. |
| Body composition | `Fraction` 0<bodyFat<1; `FatFreeMassKg` >0 and <=mass | Measured or explicit user estimate with timestamp/method. FFM = mass*(1-bodyFat) only if compatible dates/units; never assume 14%. P expire after 90 days for deficit computation. Unknown/unreliable FFM disables automated loss. |
| Cycling work | `MechanicalWorkKJ` >=0, not metabolic energy | Measured meter work or planned/estimated work identified separately; P >30,000 kJ/session flagged for review. Active positive-duration ride with zero work is suspect, not valid zero demand. |
| Power and FTP | `PowerW`, FTP >0; mean power >=0; normalized power separately typed | Measured/estimated/user-entered, with device/source and date. Work = mean W*seconds/1000 if no kJ. IF = normalized power/FTP, never mean power/FTP silently. P FTP 50–600 W review envelope, freshness 90 days. No source establishes these validation cutoffs. |
| Intensity | `CyclingIF`, finite >0; P review envelope (0,2]; running intensity is a separate type | Provider IF accepted with explicit semantics even if local FTP missing. Threshold ratios for pace, HR and power are not interchangeable. Low/high endpoint holding in estimator is tagged extrapolation. |
| Session | ID, revision, planned/completed/cancelled; sport enum; start/end instants; duration seconds >0, P <=24 h auto-plan; key/race flags; explicit fuel-demanding classification | Stable canonical ID merges completion with plan once. Overlapping duplicate sessions require reconciliation; do not add both. Future cancelled sessions contribute no demand. Completed portion of a partly cancelled session remains. |
| Distance | `DistanceKm` >=0; level/grade descriptor for running | Measured/planned/user-entered. P >500 km requires review; zero/missing running distance disables distance-based energy, not the entire daily-band fallback. |
| Meals/intake | Stable ID, revision, consumedAt or unknown time; C/P/F grams >=0, fluid L >=0, caffeine mg >=0; status planned/logged | Actual food values remain distinct from targets. Unknown is not zero. Logged records immutable to automatic planning; explicit user edits create a new input revision. Imported daily aggregates count only once and cannot satisfy timed windows without timestamps. |
| Settings | Gut ceiling `CarbRateGPerHour` >=0; coach request same unit; opted-in AND practised high intake; meal availability; quiet hours; timezone; calorie visibility | User/coach-entered is not measured gut capacity. Missing ceiling = “not supplied,” not evidence of tolerance. Normal proposed cap 90; >90 requests require opt-in, practise and approved rule configuration, absolute cap 120. |
| Energy baseline | `EnergyKcalPerDay` >0, explicitly excluding exercise; coverage enum gross/net and method | Measured/estimated/calibrated. Cannot add exercise to an already exercise-inclusive daily estimate. Reject unknown coverage for total-energy arithmetic. |
| Eligibility | adult status, pregnancy, clinical referral/ED flags, low-energy warning, goal | Unknown safety eligibility blocks loss and caffeine suggestions. Flagged conditions route to professional guidance; logging can remain available. No diagnostic inference. |

Every scalar is `Observed<Value> {value, origin: measured|providerPlanned|estimated|userEntered|coachEntered, observedAt, sourceID, methodID, qualityFlags}`. Derived outputs reference all input IDs, not just one source. Validation envelopes above are P and must not be advertised as biological safe ranges.

Output: `PlanRevision {rulesID, inputHash, asOf, timezone, status: ready|partial|conflicted|unavailable, days, sessions, ledger, transfers, reasons, reminders}`. Each target includes **ideal**, **feasible planned**, guideline range if applicable, rule IDs, provenance, evidence grade, fallback reason, conflicts and one-line explanation. Null/unavailable is distinct from zero. Expose daily C/P/F grams, energy kcal (visibility independent of calculation), fluid guidance, day and meal codes, during g/h and total grams, consumed totals, remaining portions, overage and unallocated shortfall. An estimate is labelled estimated carbohydrate oxidation, not measured “carbs burned.”

## 2. Decision tables

### Day bands, codes and estimator

Sources R:86–90,118–135; coefficient evidence van Loon is low-confidence for this use. **All exact day boundaries here are P**, because the guideline describes approximate training categories. `H` is sum of reconciled active session hours in the local day. A sport-specific workload override may be explicitly approved; otherwise use the table, with `durationOnlyBand` flag. Do not automatically call strength “light” merely because its energy estimate is absent.

| Rule ID | Exact proposed branch | Formula/output | Evidence/confidence |
|---|---|---|---|
| D1 | H=0, or explicitly confirmed light/skill day | [3m,5m] g; default 3m | R:86,133; guideline band high, base P |
| D2 | 0<H<=1, unless explicit light override | [5m,7m] | R:87; exact boundary low-confidence P |
| D3 | 1<H<=4 | [6m,10m] | R:88; extension across 3–4 h gap P, must be reviewed |
| D4 | H>4 | [8m,12m] | R:89 “more than 4–5”; exact 4-hour switch P |
| E1 | 0<IF<=.55 | share=.45 | R:127; lower endpoint holding P, low confidence |
| E2 | .55<IF<=.73 | .45 + (IF-.55)/.18*.06 | R:127; low, extrapolated |
| E3 | .73<IF<=1 | .51 + (IF-.73)/.27*.25 | R:127; low, extrapolated |
| E4 | 1<IF<=2 review envelope | share=.76, extrapolation flag | R:127; no supporting observations above endpoint |
| E5 | Valid cycling kJ and IF | cost=kJ*1.2*share/4.1 g | R:118; low-confidence composite estimate |
| D5 | All active sessions have supported cost | B=clamp(3m+sum(cost), lower, upper) | R:132; app policy, not physiological identity |
| D6 | Any session cost unavailable | B=midpoint of whole-day band; do not add known costs again | R:129 fallback; mixed-day precedence P |
| D7 | Day code | D1 RED; D2 AMBER; D3/D4 GREEN; rest with inbound transfer AMBER; key/race GREEN for deficit protection | R:90/169; mapping P. Codes describe fueling context, not health status. |
| D8 | Meal code | GREEN if serves key, during, rapid recovery or long-session preparation; else AMBER if serves other preparation/recovery/look-ahead; else inherit day code | R:90; semantic mapping P, not independently published gram thresholds |

All easy-only long days and short high-intensity days need review of band selection; duration alone is a deliberately coarse fallback. Exactly 60 minutes selects D2, 60 minutes +1 second D3. This discontinuity cannot be cured by rounding; boundary-crossing edits bypass tolerance.

### Session windows

Let `u=clamp((IF-.65)/.20,0,1)`. Unknown intensity uses u=.5 (P) with `missingIntensity`, not a pretend IF measurement. Let `t` be duration minutes and `lead` hours before start.

| Rule ID | Exact branch | Ideal output and limits | Evidence/confidence |
|---|---|---|---|
| W1 | 0<t<45 | No required during carbohydrate; planned 0, optional actual intake still counts | R:92; guideline |
| W2 | 45<=t<=60 | Optional small amount/mouth rinse, no numerical prescription; planned swallowed 0 by default | R:93; exact priority P |
| W3 | 60<t<=150 | During rate 30+30u g/h | R:136–137; interpolation P. In 60<t<=75 use endurance branch and flag overlap policy, especially for sustained-high-intensity sport. |
| W4 | t>150 | During rate 60+30u g/h | R:138; 60 minimum is app preference, not universal guideline floor |
| W5 | W3/W4 coach override | Desired rate=coach request, otherwise W3/W4; feasible <=gut ceiling and <=90, or <=120 with opt-in+practise+approved policy | R:139–141. Requests outside normal range carry explicit flags, including >90 even when authorised. Opt-in alone does not automatically raise 90 to 120. |
| W6 | t>60 and 1<=lead<=4 | Pre=1m, or 2m if (t>150 or race) AND lead>=2; cap at min(lead*m,4m) | R:142; P default within guideline |
| W7 | t>60 and 0<lead<1 | No standard gram minimum. P optional .25m, capped at lead*m, only if athlete accepts and slot exists | R:91 “small” is nonnumeric; flag shortened window; not a compliant 1–4 h pre meal |
| W8 | No available pre slot, or lead<=0 | Feasible pre=0, ideal demand retained, `noPreMealWindow` | P, not proof that fasted session is adequately fueled |
| W9 | t<=60 | No required pre allocation; normal meals remain | R:142 scope |
| W10 | 0<=next.start-current.end<8h, both fuel-demanding | Recovery 1m g/h for first min(4h,gap); 1.2m if next key | R:97,143; source qualifier restored. Truncating at next start P; never allocate a meal during the next session as recovery. Remaining unmet 4-hour intent flagged if gap<4h. |
| W11 | gap>=8h or next not fuel-demanding | No separate carbohydrate reserve; recovery meal receives ordinary budget share | R:143. Exactly 8h does not trigger rapid recovery. |
| W12 | Recovery protein | At least .3m g in [end,end+2h]; included in daily protein, never added twice | R:98,143; meal may exceed this as daily allocation, so explain both reasons |
| W13 | Hydration | .4–.8 L/h guidance only; no exact personalized target without context | R:101. Individualize; do not force fluid to satisfy a band irrespective of sweat loss. |

For W10, `fuel-demanding` is explicit approved classification, default P endurance >60 minutes or race/key. The next session means next qualifying session, not an unrelated short mobility activity. Negative gap = overlap conflict, not rapid-recovery calculation. Intervals within a session use half-open time ranges; a boundary event belongs to the later interval, preventing double credit. Optional mouth rinse has no swallowed carbohydrate ledger entry unless actually swallowed.

### Fallback chains

| Missing/context | Ordered behavior |
|---|---|
| No cycling kJ | Integrate valid measured/planned mean power over duration; else whole-day band midpoint. Do not substitute normalized power for mean work. |
| No FTP | Use provider IF with known semantics; else derive from normalized power and valid FTP if later supplied; otherwise midpoint day and midpoint during rate. Known kJ alone does not determine substrate share. |
| Run without power | Running power is not cycling mechanical work. Distance+mass can give level-running energy .81*m*km (R:105), but no approved mapping from pace/HR zones to cycling IF exists. P disable running substrate estimate; use day midpoint even when pace exists, with `unsupportedRunningShare`. |
| Swimming | No substrate estimate; day midpoint. R:106's 4 kcal/kg/km is low-confidence and not used for automatic energy budgeting without approval. |
| Strength/manual quick-add | Duration/category band midpoint; explicit intensity optional for during policy; no fabricated kJ or exercise calories. Unknown duration means day band unavailable, not rest. |
| Missing body-fat | Carb/protein can proceed from mass; RMR via approved complete Mifflin inputs or external baseline. No FFM-based loss allowance. |
| Missing body mass | Day/pre/protein absolute grams unavailable; offer g/kg ranges only. Mass-independent during guidance can remain if duration/eligibility known, but mark plan partial. Never produce a complete daily ledger from 70 kg. |
| Invalid, stale or conflicting data | Reject affected field, record reason, use next supported fallback. Do not drop an invalid active workout and call the day rest. |

### Protein, fat and energy

| Rule | Draft exact behavior | Status/source |
|---|---|---|
| Daily protein | P perform/maintain=1.6m g; loss=2.0m only when approved and eligible; allowed adult reference 1.2–2.0m; female-specific approved reference 1.4–2.2m | R:99,176. No automatic cycle adjustment. Both proposed defaults lie in intersection of reported bands. |
| Distribution | P four designated feeding opportunities, equal remainder after recovery minima; .4m each when total=1.6m and four slots. More/fewer meals require explicit scheduling and conflict reporting, not multiplying .4m by arbitrary meal count. | R:99; default/distribution P |
| Resting energy | P choose Cunningham 1980: 500+22*FFM when reliable; else report's Mifflin: 9.99m+6.25heightCm-4.92age+coefficient (5 or -161). Do not switch between Cunningham versions silently. | R:109–111; equation choice P |
| Nonexercise energy | B0=explicit validated baseline, or approved activity factor * RMR, with factor and exercise exclusion recorded. **No default activity factor yet.** | U; R gives none |
| Exercise energy | Cycling gross=1.2*kJ approximation; optional exact efficiency formula 1/(4.184*.20) must be a different revision. Running level=.81*m*km; other sports unknown unless valid estimate supplied. Convert gross to net by subtracting resting energy during exercise before adding to a 24h baseline; never mix net and gross. | R:103–111 plus P coverage policy |
| Total-energy estimate | Emaint=B0+sum(net exercise); Egoal=Emaint-deficit. If any necessary component unknown, E unavailable and deficit=0/disabled, not a guessed complete estimate. | P/U |
| Fat | At fixed C,P,E, F=(E-4C-4P)/9; require F>=0 and .20E<=9F<=.35E. Equivalently E must lie in [4(C+P)/.80,4(C+P)/.65]. | R:100; macro energy factors P. The oxidation conversion 4.1 is not silently reused for food-label energy. |
| Incompatible energy/macros | Return `energyMacroConflict`, ideal E and C/P, fat unavailable as a recommended target. Dietitian decides whether to raise C within its band, change protein or revise expenditure. Never label the residual fat as compliant or alter energy to hide the conflict. | P |
| Missing E | C/P may be partial outputs; F/E absolute targets unavailable. May show fat percentage guidance, not gram target. | P |

Tuesday has no validated baseline, height/age/FFM or activity factor in its fixture. Consequently its fat and energy targets are **unavailable**, not zero. Proposed protein=112 g, four slots at 28 g including recovery; recovery component is 21 g of that meal, not another 21 g. The design's 40 g dinner is possible under another distribution, but R:98's .25–.3m explains only 17.5–21 g (mockups:465–466).

### Goal, caffeine and safety subcontracts

These complete the §4 inventory but remain gated proposals, not new shipping scope for #11.

| Rule | Draft boundary/formula | Evidence/status |
|---|---|---|
| Loss pace | Requested weekly kg=min(m*selectedFraction,1); fraction in {.0025,.005,.0075,.01}; initial requested weekly deficit=7700*kg | R:162–166; model, not forecast guarantee |
| Daily loss allowance | Zero on GREEN or day before key (race, marked key or duration>150min), ineligible/unknown eligibility, unreliable FFM/E, or sustained low-energy flag. Otherwise <=approved per-day cap and max(0,Emaint-max(30*FFM+netExercise,sexSpecificFloor)); additionally preserve C band, session windows and fat bounds. | R:169–179; unknown cap => disabled. The 30 floor is a planning constraint, not a diagnosis or guarantee. |
| Calorie/BMI floor | 1200/1500 per report's selected equation category; unknown category disables loss. Goal BMI<18.5 refused, exactly 18.5 allowed by draft. | R:174–175; product defaults, not individualized safety proof |
| Weekly distribution | P equal water-filling across eligible days up to each feasible allowance; unmet deficit reduces pace, never becomes debt on later hard days. | R:170; allocation P |
| Recalibration | Fewer than 3 distinct weigh-in days in prior 7 => hold. Completeness and expenditure estimator undefined => hold even with 3 weigh-ins until approved. Do not mark missing logs complete. | R:167; U |
| Gain | Disabled in v0.1: .25–.5% cited secondarily but no allocation/safety contract | R:165; U |
| Caffeine kinetics | ke=ln(2)/halfLife; halfLife in [3,10]h, default5; solve ln(ka/ke)/(ka-ke)=2/3h for ka>ke. For dose D at t0, A(t)=D*ka/(ka-ke)*(exp(-ke*dt)-exp(-ka*dt)) if dt>=0, else0; sum logged doses, planned curve separate. | R:198–200; P unit-bioavailability model, ka policy needed for exact fixtures |
| Caffeine history | Include prior-day doses, not midnight reset. P retain 7 days; mark earlier residual unknown when history incomplete. | P; report only specifies plotted 24h window |
| Caffeine sleep | P dose<200mg uses bed-8.8h, dose>=200 uses bed-13.2h; late iff doseTime>cutoff. 200mg exact edge is app policy; studies describe particular doses. No safe-bedtime concentration threshold. | R:203–205 |
| Caffeine suggestions | Off unless eligible adult, not pregnant, opted in and dietitian ceiling known. P request=min(2m,200mg,remaining allowance,approved ceiling); if capped below2m do not claim effective dose. Cumulative adult suggestion cap400mg/day; logged excess is retained and warned, not capped. | R:212–213 and #38; 2m selection P |
| Caffeine warnings | Actual total>400mg adult or>200mg pregnancy warns; single>200mg note/warn. Do not suppress actual intake because suggestions disabled. | R:213; no guarantee below limits |
| Clinical safety | No automatic deficit for under18, pregnancy, ED flags or sustained low energy; refer rather than diagnose; no automatic train-low; no carbohydrate phase change; hide calories by default | R:177–180,226–232 |

Caffeine calculation with exact 40-minute peak produces ka=5.717978753/h and 91.172/26.220/115.078/62.883 mg at the four report times. This rounds to #38's 91/115/63 expectations. Report approximate values do not uniquely specify absorption. This is a model fixture, not verified pharmacokinetics for an individual.

Hard constraints: finite/nonnegative future portions; no automated edits to logged intake; no suggestion exceeding gut/app caps; no enabled deficit without all required eligibility and floor inputs; no silently violated daily or session band; no duplicate intake counting. An infeasible guideline minimum returns a flagged shortfall, not an unsafe forced amount. Real logged intake may exceed any target/cap and must remain factual. No safety claim follows merely from satisfying constraints.

## 3. Allocation ledger

### Objects and accounting

One `IntakeSlot` per physical eating/drinking opportunity, with ID, time interval, local accounting day, C/P/F variables, locked actual amounts if logged, and optional capacity. `WindowRequirement` has nutrient, time range, minimum/ideal/maximum, source, priority and eligible slot IDs. A slot can satisfy several compatible purposes. Its grams are counted **once** in day totals even when credited to recovery A and pre B.

Overlapping requirements are inequalities on the same slot variables, not independent reservations. Example: 70 g required for recovery and 70 g pre in the same eligible slot requires max(70,70)=70, not140. Adjacent recovery hour windows do not share credit. A day's aggregate unknown-time intake contributes to daily consumed totals but not any timed constraint. Logged grams in a window count toward that window, with no rewriting of the original entry or its historical label.

### Priority and deterministic solve (P)

1. Lock actual intake; reject duplicate identity; enforce nonnegative future variables and hard caps. Eligibility/referral gates precede planning.
2. Preserve current during fueling within applicable cap, then rapid recovery, then pre-session preparation, then recovery protein minima and regular meal distribution (nutrient ledgers separate). Within same class prefer key/race, earlier start, stable session ID. This order is a policy, not a guideline claim.
3. Meet all feasible session requirements by sharing eligible slots. Increase the provisional daily target only as much as needed, up to its day-band upper bound, rather than creating negative “other meals.” Record `sessionNeedsRaisedDay` with old/new amounts. General meal preferences are soft; zero ordinary carbs is possible and must be shown, not hidden.
4. If hard caps, available slots or the upper day band make full satisfaction impossible, minimise requirement shortfalls lexicographically by priority. Each unmet requirement gets its own flag and amount. Do not relax gut caps or day upper bound for newly planned grams. Logged excess is handled separately.
5. Among equal solutions minimise increase above provisional day; then equalise residual grams across ordinary eligible slots (sum squared deviation, equal weights by default); deterministic timestamp/ID tie break. Do not place food into unavailable/past slots. If none remain, expose unallocated shortfall.

For a requirement whose range applies to total pre intake, apply the lead-time upper cap to **all grams in its nominated pre slot**, including grams credited to recovery. Do not evade capacity by renaming extra food “recovery.” During items cannot masquerade as ordinary meals to evade the g/h ceiling. Actual logged violations are immutable and flagged, with no further suggested intake that worsens the cap.

```text
validate, reconcile sessions and deduplicate intake
derive provisional daily budgets B[d], ranges [lo[d], hi[d]]
build timed requirements and available physical intake slots
lock logged amounts, including actual food consumed for cancelled sessions

solve a no-transfer baseline across the 72h planning horizon:
    L[d] = unique logged grams
    new total target T[d] in [B[d], hi[d]] if increase is needed
    future total <= max(0, hi[d] - L[d])
    satisfy session inequalities where possible; minimise priority shortfalls
    choose minimum necessary T[d], then distribute ordinary residual
    never reduce T[d] below lo[d]

propose bounded next-day transfers, earliest eligible session first
accept a transfer only if both days remain feasible and protected windows stay met
solve again with accepted transfers; rollback infeasible optional transfers
emit desired, feasible, actual and unmet values separately
round display ledger with conservation; produce revision-tagged reminders
```

For each nutrient/day: `L + F + U = T + O`, where L=logged, F=future allocated, U=unallocated shortfall, O=max(0,L-T); F,U,O>=0. When feasible and L<=T, U=O=0 and L+F=T. When L>T, normally F=U=0 and L=T+O. **A continued session requirement when L>T is a separate conflict**: retain the requirement, do not claim that earlier untimed eating fulfills it; any proposed extra intake needs explicit policy rather than breaking accounting. Show `budgetAlreadyConsumed` and `timedFuelUnmet`. Immutable logging and conservation cannot mean forcing actual intake back to target.

### Look-ahead transfer (P, not metabolic equivalence)

Trigger when next local day's session duration>150min OR local start<10:00; exactly10:00 does not trigger. Look ahead 72h for context but transfer only from next day to prior evening. Assign stable transfer ID `(rulesID, sessionID, donorDay, recipientDay)` so recomputing cannot repeat it.

Propose x up to min(m, tomorrow's unlogged pre component, tonight's available slot capacity). Also bound x by tonight's upper-band slack and tomorrow's lower-band slack. Preserve at least 1m of next-day pre food when a standard 1–4h pre window exists. A no-pre-window early session can shift its provisional preparation component, but carries `noPreMealWindow`; tonight is not falsely credited as food eaten 1–4h beforehand.

Update recipient T+=x and donor T-=x, decrement donor's future pre component by x, and allocate x in recipient evening. Therefore horizon sum of targets is conserved. If tomorrow is already at its lower bound, transfer=0 with `lookaheadBlockedByFloor`; an additive top-up would be a different policy. Transfers never cross into a locked/past meal. If tomorrow's session is cancelled after the top-up was consumed, retain actual intake, retire the transfer's future plan effect and recompute; no compensating restriction or carbohydrate debt.

### Other required states

- **Cancelled after pre meal:** delete only unconsumed plan requirements; actual pre food remains in L under the same ID. Recompute the day band and remaining nonnegative budget. No instruction to undo eating.
- **Above revised target:** show overage separately, no negative portions, no carried-forward debt. Do not call logged intake noncompliant with an earlier target retroactively.
- **Gut cap below guideline/default:** cap suggestions first; preserve both desired and feasible during amounts. Flag `gutCeilingBelowDefault` and, if actually below a guideline minimum, `belowGuidelineRange`. Reallocate residual daily grams to ordinary eligible meals, not secretly back into the during line.
- **Midnight/timezones:** use input timezone/day intervals, not ambient device time. Split during intake by timestamp across days; no duplicate total session demand. Ambiguous time requires resolution before reminders. Replanning timezone does not change actual instants or IDs.
- **No feasible solution:** status conflicted/partial, explicit range, achieved amount and shortfall. Never a fabricated fully compliant plan.

## 4. Precision, display and tolerance (P)

Keep internal formulas unrounded (Double acceptable with comparison epsilon 1e-9 g and deterministic operation order; rational calculations here provide reference values). Validate caps before display. Golden tests use absolute error <=1e-6 g for arithmetic, not loose screenshot tolerances.

Daily and slot display grams: nearest integer, halves upward. Reconcile planned displayed slots to rounded daily total using largest remainder, stable timestamp/ID ties; never round a hard-capped slot upward past its cap (constrained remainder distribution). Actual logs retain their recorded precision and are not adjusted to make a screen sum. Rate display one decimal g/h; total from unrounded rate*actual duration, never multiply an already-rounded rate. If constrained integer display is infeasible, show one decimal/approximation rather than false exact conservation. Explanatory percentages may round, but calculations do not consume them.

“On target” is a neutral logging comparison, not clinical safety: P each macro within `max(5g, .10*target)` inclusive of its target, AND no timing/safety conflict; target=0 matches only actual=0. Day tolerance=max(10g,.05*target). Missing targets mean no comparison. Thus 92/80 g carbs **is not on target** (12>8), whereas 20/15 g protein is within proposed tolerance (5<=5); mockups:488 must not label the combined meal on target. These thresholds require product/dietitian approval.

Duration stability: compare against **last accepted plan anchor**, not last incoming edit, to prevent drift from many small changes. Retain numeric targets only when abs(duration delta)<=min(5 minutes,5% of anchor duration), unchanged sport/start/IF/work/distance/intake/settings/rule version, no branch/window/day-band crossing, no newly violated rate or energy constraint, and all affected target differences<=5g each. Otherwise recompute. For retained during grams, recompute effective rate against new duration and enforce all limits. Cancellation, logging, eligibility and coach/gut changes always bypass stability. Reasons retain anchor and fresh values. Exactly threshold is included. This is not a deadband on safety constraints.

Reminders (#19): proposed Tuesday pre 15:30, bottles17:25 (start minus5min), recovery19:30 (end plus15min) for meal19:45. These offsets come from mockups:469, not nutrition evidence. Include planRevision/sessionID/windowID in notification intents, cancel obsolete intents, respect quiet hours/per-session toggle, and suppress impossible past/no-slot meal prompts. Pure engine tests can verify intents, not OS delivery.

## 5. Computed scenario fixtures

Run `python3 /tmp/nutrition-astra-review/2b-calc.py`. Arithmetic assertions passed. All inputs below are synthetic. Unless specified: mass70kg, no calorie deficit, no coach override, no gut cap supplied, no other/look-ahead session, four protein opportunities =>112g/day under P; energy/fat unavailable. All full ledger scenarios **need a policy decision** because allocation/band/default rules are not yet approved. The “spec-determined” label is reserved below for arithmetic that the report actually determines, not approval of the full scenario.

| Fixture and explicit inputs | Computed expected output (internal grams unless marked display) | Status and required flags |
|---|---|---|
| Tuesday: ride17:30–19:15,1250kJ,IF.82; pre15:30; ordinary meals breakfast/lunch/dinner; next session>=8h | share .593333333; cost217.073170732; B427.073170732; pre70; rate55.5g/h, during97.125; ordinary259.948170732, each86.649390244. Display day427, pre70,during97; ordinary87/87/86 using largest remainder. | **Spec-determined:** cost/B/pre/during from R formulas once no early rounding chosen. **Needs a policy decision:** exact rounding and ordinary ledger. GREEN under D3. P protein four*28g; recovery 21g included. |
| Two rides:07:00–08:15 and13:00–14:15, each600kJ,IF.85; pre slots06:00,12:00; non-key; recovery first at08:30,09:30,10:30,12:00 | Each cost109.073170732; B428.146341463; during75 each; pre70 each; first recovery280. Shared12:00 meal70 serves recovery+pre. Unique=70+75+280+75=500. Raise target to500 (7.142857g/kg, inside420–700); ordinary residual0. | **Needs a policy decision:** raise by71.853658537 and shared meal. Flag `sessionNeedsRaisedDay`. No overlapping time requirement receives additive duplicate grams. If raising forbidden, at least71.853659g of unique demands cannot fit. |
| Early05:30–07:15 ride, same work/IF as Tuesday; no available pre slot and no feasible prior evening transfer; ordinary meals08:00,12:00,19:00 | B427.073170732; pre ideal70/feasible0; during97.125; ordinary329.948170732, each109.982723577; display day427,during97,ordinary110 each. | **Needs a policy decision.** `noPreMealWindow`; meal08:00 includes recovery protein>=21. No claim that extra breakfast carbs replace missing pre timing. |
| Run17:00–18:30,15km, no running power, no threshold/HR conversion, moderate category; pre15:00 | D3 midpoint560; cost unavailable; during midpoint45g/h*1.5=67.5; pre70; ordinary422.5. Level-running energy estimate850.5kcal possible, but not complete day energy. | **Needs a policy decision.** `unsupportedRunningShare`, `durationOnlyBand`, `missingIntensity`. Do not apply cycling IF=.75 from an invented HR conversion. |
| Rest day before next-day11:00–14:00 ride; work missing, IF.75; pre09:00; available prior dinner | Base rest210, tomorrow midpoint560; transfer70 => rest280, tomorrow490. Tomorrow pre140 becomes70; during75g/h*3=225; other195. Horizon total770 unchanged. | **Needs a policy decision.** Rest AMBER due look-ahead; tomorrow GREEN. Source does not settle moving versus adding. If donor at420 floor, transfer0. |
| Tuesday cancelled completely at16:00, pre70 eaten15:30, no other intake/work | Revised rest target210; locked70 remains; future140. Protein target112 under P, actual protein deducted separately if known. | **Needs a policy decision:** rest default/allocation. **Spec-determined invariant:** actual70 unchanged. No during requirement/reminders. |
| Cancelled workout, revised rest target210, actual logged carbs300 | Future0; overage90; realized total300, not210; 300=210+90. | **Needs a policy decision:** comparison/treatment; immutable log explicit in #11. No negative future meal and no next-day debt. |
| 3h ride11:00–14:00, no work, IF.75, pre09:00, gut40g/h | Day560 midpoint; desired75g/h=225; feasible40g/h=120; pre140; ordinary300. | **Needs a policy decision.** `gutCeilingBelowDefault`; 105g removed from during relative to desired and retained elsewhere in daily budget. 40 is below app60–90, but NOT below ACSM “up to90.” If contract calls60 the minimum, explicit app-range conflict required. |
| Missing mass, Tuesday duration/IF/work known | Estimated session oxidation217.073170732 and during55.5g/h/97.125g remain computable; day, pre, protein, fat and full ledger unavailable. No code implying a complete safe day. | **Needs a policy decision:** partial UI. **Spec-determined:** formula lacks mass only for cost/during. `missingBodyMass`; g/kg ranges can be explanatory. |

The remaining-meal numbers are mathematical allocations, not ready-made food portions. For the two-ride fixture zero ordinary carbohydrate exposes how demanding the combined constraints are; it is not a recommendation to omit meals or their protein/fat. Recovery after the second ride receives its share of remaining carbs, here zero, while protein requirement remains. That is an important dietitian review point even though no stated long-recovery carbohydrate minimum is broken.

Additional boundary fixtures required before implementation: t=44:59/45:00/60:00/60:01/75:00/75:01/150:00/150:01; IF=.55/.65/.73/.85/1 with epsilon on either side; lead=0/1/2/4h; gap=0/4/8h; H=0/1/4h; start09:59:59/10:00; gut0/29/40/90/120; no future meal; all intake un-timed; duplicate completed/planned workout; cancelled partly completed session; cross-midnight session; DST day; repeated transfer; loss blocked with missing FFM; hard cap plus display remainder. Cases deliberately violating a range must assert the conflict object, not “all grams always in range.”

**Canonical mockup recommendation:** adopt Tuesday **427 g/day,70 g before,55.5 g/h,about97 g during**, internal values above. Use 87/87/86 ordinary carbohydrate allocations if equal meals are approved. Use112g/day protein with28g in each of four designated meals, explaining recovery's21g component; do not preserve arbitrary40g dinner under a different unstated policy. Keep fat/energy absent until their inputs and policy are supplied. Update #11 and the research arithmetic as well as light/dark Today, Week, Ride, logging examples, food suggestions and reminder fixtures. Do not tune formulas to hit490. If product elects coarser5g food displays, create a separate explicitly balanced fixture revision instead of silently substituting95 for97.125.

## 6. Primary-source sanity check

Sources were retrieved through Firecrawl during this review. These are narrow checks, not a systematic evidence review.

- **ACSM/AND/DC 2016:** full paper retrieved from [South African Institute for Drug-Free Sport PDF](http://drugfreesport.org.za/wp-content/uploads/2018/04/Position-stand-on-Nutrition-Athletic-Performance-ACSM-2016-1.pdf), DOI [10.1249/MSS.0000000000000852](https://doi.org/10.1249/MSS.0000000000000852). Table2 confirms the broad daily/pre/during/recovery bands. It describes rapid recovery as “<8 h recovery between 2 fuel demanding sessions.” Therefore R:143 is overbroad for arbitrary next activities. The table's sustained-high-intensity45–75min and endurance1–2.5h categories overlap by context; exact minute priorities are app policy. Its ultra-endurance duration is >2.5–3h, so a precise150min switch is also policy. Fluid guidance is individualized; turning .4–.8L/h into a compulsory universal cap/floor would misread it. No source support found here for the proposed IF interpolation or mass-per-hour lead-time cap.
- **van Loon2001:** [full text, results and Table2](https://pmc.ncbi.nlm.nih.gov/articles/PMC2278845/). Eight trained men completed consecutive30min cycling stages at40/55/75% maximal workload after an overnight fast. Results text reports carbohydrate shares46±9%,51±9%,76±6%; high-stage oxidation3.91±.32g/min. The report's45% and3.90 are slightly different approximations. More consequential: no FTP-based IF calibration, running validation, or daily dietary replacement formula is established. Even using the assumed FTP=.75Wmax,40%Wmax corresponds to IF.533333, not.55;55% corresponds to.733333. Preserve report anchors only as explicitly chosen coefficients pending review, not exact source-derived transformations.
- **Morton2026:** [full review](https://pmc.ncbi.nlm.nih.gov/articles/PMC13197957/). The abstract treats120g/h as a possible extension for trained participants, while120–200g/h practices lack established efficacy. This supports a guarded opt-in research discussion, not universal120 prescriptions. The review also discusses feeding state and individual variability; using a fixed fasted-cycling share as personalized oxidation ignores those factors. R:96 is appropriately cautious about the cited metabolic studies. Its “no performance outcome verified” should describe what was checked, not be read as a blanket claim that the whole literature has no performance findings.
- **Burke2011:** [primary PubMed abstract](https://pubmed.ncbi.nlm.nih.gov/21660838/) confirms small amounts/mouth rinse around1h,30–60g/h for longer events and up to90 for>2.5h. Publisher full-text targeted retrieval returned no answer; a search returned garbled table text from a hosted copy, which was not treated as independently verified full text. Rapid-recovery qualification is independently visible in the2016 primary table. Could not independently verify R:97's absolute “no benefit above1.2” against Burke's full argument or the unspecified2025 review; avoid treating that phrase as a universal biological ceiling.
- **Impey2018:** [full text, conceptual RAG model](https://pmc.ncbi.nlm.nih.gov/articles/PMC5889771/). Authors deliberately omit quantitative meal amounts and describe a flexible conceptual model. R:90 is accurate on that point. Neither app color thresholds nor a universal1g/kg next-evening transfer follows from it. The paper itself highlights uncertainty in real-world session glycogen costs, nonlinearity and modality differences. RAG should not imply measured glycogen or automatically prescribe train-low.

Other §4 caveats found from internal arithmetic: R:105 says1kcal/kg/km overestimates.81 by19%; relative to.81 the overestimate is23.46%, whereas.81 is19% below1. R:176's2g/kg body mass equals2.3g/kg FFM only near13% body fat, not generally (at30% body fat it is2.857g/kg FFM). Neither needs a new formula guessed in code. Cunningham variants, female-specific protein advice, running/swimming estimates, goal safety thresholds and caffeine source papers were not all independently re-audited in this pass.

## 7. Decisions for dietitian and product owner

1. Approve/replace the substrate estimator, report coefficients versus exact source figures, and disable running transfer of cycling shares unless validated. Decide whether band-only is the first release's safer evidentiary contract.
2. Approve exact daily bands including3–4h, short hard/light long sessions,60–75min overlap, sport-specific “fuel demanding,” and coach override behavior.
3. Approve day-target increase within band to meet unique session needs, priority if upper bound is insufficient, and how to respond when actual intake already exhausted the budget but a session still requires fuel.
4. Approve transfer versus additive top-up; minimum retained next-day breakfast; early-morning no-slot behavior; acknowledge that evening food does not establish equivalent pre-session availability.
5. Approve protein default/distribution, energy baseline/coverage, fat conflict handling and missing-data holds. Resolve #37's FFM, completeness, deficit cap and forecast estimator before automated loss.
6. Approve gut-ceiling conflicts and >90g/h eligibility; distinguish app preference from guideline minimum. Confirm hydration remains individualized.
7. Approve input review envelopes, freshness, numeric/display tolerance and stable-plan threshold; reconcile the mockup “on target” label and canonical Tuesday fixture.
8. Approve caffeine ceiling, kinetics and exact dose cutoff; confirm suggestion gates and residual-history handling. Tie sign-off to the rule hash and fixture revision.

## Verification limits

Checked: first review, named report revision, live issue bodies, mockup lines, primary-source excerpts/full texts as specified, reproducible arithmetic and selected conservation assertions. No app code was built, no repository tests/CI or simulator were run, and no clinical correctness, actual intake completeness, device behavior, food portion feasibility or independent dietitian approval was established. The pseudocode is a specification, not a tested optimizer. Rule tables contain explicit P/U items and must not be mistaken for a completed implementable clinical contract. Live GitHub issue bodies were checked; remote branch freshness was not, because fetching was forbidden.
