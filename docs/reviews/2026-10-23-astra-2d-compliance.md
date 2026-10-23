# Compliance, safety and release-readiness review

Reviewed 23 October 2026. Continuation of `/tmp/nutrition-astra-review/review.md`. Review only, not legal advice, clinical approval, or an App Store approval prediction. No app code was built and no repository or GitHub content was changed.

## Verdict and evidence scope

**Not ready for external TestFlight distribution.** The backlog contains sensible intentions but does not yet establish approval of the exact rules, privacy implementation, provider permissions, or the release build. Keep adaptive deficits and performance caffeine disabled until their specific gates are satisfied. Core fueling also requires the review promised in #9.

Evidence checked:

- Design checkout `059cc713e8a95de3b7ae18b1bee327209b0cfbf0`; clean working tree at inspection. `docs/design/mockups.html` references below refer to this checkout.
- Research and AGENTS read through `git show origin/chore/project-setup:...`, local ref `0e004b09066b9a3bf9eae4f58fdf7f0f3597d1d8`. No fetch; these are not a claim about the remote's current head. `research:L` below means `docs/research/2026-10-22-fueling-app-research.md:L` at that ref.
- Live issue bodies/comments: #2–#9, #20, #22–#24, #32, #35, #37, #38. All were OPEN. #8 has no comments; #9 has the request to review goal weight and caffeine, not a recorded sign-off.
- Primary sources below retrieved with Firecrawl, requesting a live fetch. This establishes the public text returned, not which agreement any developer account has accepted.
- `git ls-files` shows documentation/design/setup files, no App, FuelingEngine or Supabase implementation. Native permissions, deletion, billing and safety enforcement therefore remain unverified. Mockups were read as source, not rendered or exercised again in this round.

Issue links use `https://github.com/Diegod96/Personalized-Nutrition-Application/issues/<number>`.

## Ranked findings

### High 1. The weight-loss safety claim is not supported by the floor or inputs

Evidence: research:162–180 and [#37](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/37) prescribe 0.25–1% weekly loss, 30 kcal/kg FFM, 1,200/1,500 kcal and BMI 18.5 floors. `mockups.html:539` claims the projected pace avoids under-fueling; `:552` calls 30 an IOC guide while lean mass is estimated. The [IOC 2023 consensus](https://bjsm.bmj.com/content/57/17/1073) describes individual/sex/system variation and disputes a universal EA threshold. Its discussion of 30 is not approval of an automated deficit algorithm.

A property test can establish a computational invariant, not physiological safety. Missing FFM, incomplete intake, uncertain exercise expenditure, and short-term weight changes can invalidate the apparent headroom. No-deficit hard days and hidden calories help but do not establish adequate intake across the week. BMI and generic calorie minima likewise are not athlete-specific safety certification.

Smallest correction: remove the assurance, identify the floor as a provisional planning constraint, and disable automatic deficits until a named sports dietitian approves the exact inputs, estimator, defaults, population and fallback behavior. Do not substitute assumed body fat. Incomplete/implausible inputs must enter an approved hold state, not silently preserve a potentially unsafe deficit. Refer to a clinician for symptoms or concerns regardless of an apparently adequate estimate. Owner: #9/#37/#24.

### High 2. Screening and resumption are underspecified and conflicting

Evidence: research:228 lists LEAF-Q, REDs CAT2 and SCOFF together without an operational protocol. [#20](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/20) excludes conditions from any plan, but its comment and #37 discuss exclusion only from weight loss. `mockups.html:820` names diabetes; #37's eligibility list does not. `:827` introduces a two-week trigger absent from #37; `:834–835` permits resume after confirming a conversation.

These instruments are not interchangeable:

- [SCOFF original validation](https://www.bmj.com/content/319/7223/1467) is a five-question suspicion screen, not a diagnosis or permission to diet. Its original threshold was two positive responses; that does not independently validate this app, population, translations, or a shortened version. A negative score must not override symptoms/history.
- [LEAF-Q original study](https://bjsm.bmj.com/content/48/7/540) evaluated female athletes aged 18–39, with validation against EA/reproductive/bone outcomes in endurance athletes. It complements disordered-eating screening; its 78% sensitivity and 90% specificity cannot be generalized to all users or called an eating-disorder diagnostic accuracy figure.
- [IOC CAT2 within the consensus](https://bjsm.bmj.com/content/57/17/1073) separates screening, severity/risk assessment, and clinical diagnosis/treatment. A consumer quiz should not reproduce clinical risk stratification or sport-clearance decisions as automated diagnoses.

Decision: a sports dietitian plus an eating-disorder/REDs-qualified clinician should choose the instrument, population, exact licensed wording, scoring and referral protocol. The app may mechanically apply an approved eligibility rule; a qualified clinician interprets clinical significance. Determine handling for nonresponse, uncertainty, prior disorder, pregnancy changes, and symptoms. Do not claim a shortened bespoke screen is validated.

Suggested referral copy for professional review: “We have paused weight-loss targets because your entries may suggest you need more support with fueling. This is not a diagnosis, and incomplete logs can affect the estimate. Please speak with a sports dietitian or healthcare professional before restarting.” Provide an accessible referral link without transmitting screening answers. The two-week wait and one-tap self-attestation need explicit clinical approval; do not imply that either proves resolution. Owner: #9/#20/#37.

### High 3. Closing paperwork is still being used as release authorization

Evidence: [#9](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/9) permits “Written sign-off, or a list of changes”; [#24](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/24) requires reviews to be closed. Neither ties approval to a shipped rule/configuration version or proves findings were resolved. #9's goal and AGENTS Verification step 6 require professional review before athlete exposure/TestFlight.

Require an approval record containing reviewer name, credentials and relevant jurisdiction; date; rule/configuration hash and code commit; source editions; intended ages/populations; exact features and exclusions; approved copy/screens; test fixtures; missing-data behavior; residual concerns and explicit approve/conditional/not-approved disposition. Track each condition to resolution. Clinical advice needs appropriate clinical expertise; legal/privacy approval and engineering verification remain separate.

Re-review triggers: changed numbers, equations, input sources/quality assumptions, population, screen scoring, safety/referral/resume flow, caffeine advice, AI wording that alters meaning, new evidence or a safety incident. A new build can reuse approval only with a documented check that the approved scope is unchanged. Keep confidential review details private and publish only an approved nonconfidential decision record. Owner: #8/#9/#24.

### High 4. Privacy work does not yet specify the complete collection, rights and incident workflows

Evidence: [#8](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/8) asks for a legal read and hosted policy/copy; #20 puts profile and connections before screening; its comment asks to store screening answers. [#23](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/23) covers rows/tokens/local wipe but not recipient propagation, backups, offline resurrection or rights requests. research:269 reduces FTC duties to a 60-day deadline. The [FTC guidance](https://www.ftc.gov/business-guidance/resources/complying-ftcs-health-breach-notification-rule-0) and [RCW 19.373](https://app.leg.wa.gov/RCW/default.aspx?cite=19.373&full=true) require more; see the shipping specification below.

Smallest correction: move age/eligibility and appropriately scoped consent ahead of unnecessary imports, define what sensitive answers truly need persistence, and make consent, withdrawal, deletion, processor contracts and incident response testable release gates. Derived targets and flags remain sensitive; “no raw HealthKit uploads” does not make synchronized plans anonymous. Owner: #8/#20/#23/#24.

### High 5. Provider compliance needs provenance and permissions, not merely an on-device model

Evidence: [#35](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/35) excludes Strava inputs and conditions WHOOP use on legal review, but does not address derived numbers, prompts, evaluation fixtures or model outputs. research:17–20 and :280 imply on-device wording is the safer route. [Strava §5.3–5.4](https://www.strava.com/legal/api_policy) explicitly reach derivatives; [WHOOP §4](https://developer.whoop.com/api-terms-of-use/) defines data to include copies/derivatives and restricts retention and AI-related development/use. Moving inference onto the phone does not erase contractual restrictions.

Smallest correction: keep #35 off for beta or use fixed, approved templates. If enabled later, pass only an allowlisted, provenance-checked payload; mixed-source targets retain restrictions. Legal advice alone does not grant provider permission. Resolve contract ambiguity with the relevant rights holder before relying on an exception. Owner: #8/#35 and provider issues.

### High 6. Caffeine advice lacks an approved ceiling and can imply unjustified precision

Evidence: #38 permits 2–3 mg/kg while merely warning at 200 mg single/400 mg daily; research:213 explicitly leaves the ceiling to the dietitian. At 70 kg, 3 mg/kg is 210 mg before other intake. `mockups.html:559–569` presents a precise last-caffeine time and suggests saving caffeine for race day. A race does not remove the sleep concern. The research itself says no safe residual bedtime level exists (:205), and Apple scrutinizes harmful or medically framed advice ([1.4/1.4.1](https://developer.apple.com/app-store/review/guidelines/#physical-harm)).

Do not treat 400 mg as a target or a universal safe limit. Approve total and per-dose constraints, remaining intake budget, contraindication/medication handling, and unknown caffeine content before performance suggestions ship. Preserve prior-day residuals; distinguish planned from consumed doses and deduplicate Health imports. Label timing and residuals as estimates. No automatic suggestion to raise a low dose merely because it is below a study range. Decide whether supplement/drug-like presentation raises 1.4.2 review concerns; this review does not classify caffeine guidance as a drug calculator. Owner: #9/#38/#24.

### Medium 7. Paywall and Health permission disclosures are requirements, not yet inspectable designs

Evidence: #22 says only “Trial terms show before purchase”; #24 owns usage strings; Profile shows a general disclaimer (`mockups.html:510`), and Connect lists only workouts/weight/HRV/sleep (`:583`) despite planned nutrition/caffeine reads and writes. No native plist, purchase screen or deletion flow exists in the tracked checkout.

Specify trial duration, eligibility, renewal price and billing period, auto-renewal, cancellation path, terms/privacy links, and prominent annual total. Define separate read/write purpose strings and permission timing for the actual shipped types. The disclaimer cannot cure a stronger safety assurance. No advertising/tracking is a sound plan, but is not proof that diagnostics, backend logs and future SDKs disclose nothing. Owners: #12/#20/#22/#23/#24.

### Medium 8. Public-repo hygiene and confidentiality need explicit boundaries

GitHub reports PUBLIC. Research:247–257 and :323–350 disclose positioning and competitor analysis; that is a commercial choice, not a compliance breach by itself. Research:282–286 and #8 ask for legal/provider decisions in public artifacts. Do not publish attorney communications, privileged analysis, confidential partner responses, patient/tester data or identifying screening details. Publish only counsel-approved summaries and private evidence references. WHOOP's [§3 confidentiality terms](https://developer.whoop.com/api-terms-of-use/) make confidential partner materials particularly relevant.

`.gitignore:1–15` omits `.env` patterns and key/certificate patterns such as `.p8`, `.p12` and private-key files. Existing AGENTS and #3/#5–#7 correctly keep secrets outside the repo. A narrow scan of tracked working-tree files found zero common private-key/token assignment patterns, which is not a full secret audit. Recommend ignores for local secret files, tracked example files with placeholders, and enabled secret scanning/push protection where available. Check history/artifacts before first credentials are used. No evidence of an exposed live secret was found; history, GitHub security settings, Actions artifacts and external forks were not audited.

## App Store requirement-to-owner map

Primary source: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/); health-specific source: [HealthKit privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy).

| Rule | Concrete requirement and acceptance evidence | Owners / observed gap |
|---|---|---|
| 1.4.1 and general 1.4 | Explain estimation method/limitations; no diagnostic or guaranteed-safe claim; advise professional input before medical decisions; supply supporting methodology in review notes. Validate both store copy and in-app wording. | #9/#20/#24/#37/#38. Current under-fueling assurance fails this review. Disclaimer alone is insufficient. |
| 2.5.1; relevant 2.5.4 | Public HealthKit APIs for stated fitness purposes, real Health integration, intended background use. Permissions and unsupported/denied states work on device. | #12/#20/#24. No native evidence. Do not promise background delivery guarantees. |
| 3.1.1 | Use StoreKit IAP for the chosen in-app digital subscription model; restore eligible purchases. | #22. No purchase implementation verified. |
| 3.1.2(a–c) | Ongoing subscription value, clear benefit/period/price, honest trial, eligible vs ineligible offers, no unexpected forced subscription, localized total price and cancellation/manage access. | #22/#24. “Terms show” needs the explicit criteria below. |
| 5.1.1(i–iv) | Reachable policy in app and metadata; purposes, data/recipients, retention/deletion, consent/withdrawal; minimize data; meaningful permission descriptions and manual alternatives where possible. | #8/#20/#24 plus #12/#13. Age/consent must precede unnecessary imports. |
| 5.1.1(v) | In-app initiation of full account deletion when accounts are supported; reasonable authentication; explain subscription handling without blocking deletion. Review whether account requirement is justified by sync. | #23/#24; add failure/retry/end-to-end deletion evidence. |
| 5.1.2 | Explain sharing/secondary uses and obtain appropriate permission, explicitly including third-party AI if ever used; no silent repurposing. | #8/#20/#35. On-device inference avoids a cloud transfer, not provider contracts or consent duties. |
| 5.1.3 | No health-data ad targeting/marketing; disclose specific collected health data; accurate Health writes; no app-managed personal-health storage in iCloud. | #12/#13/#24/#38. Check SwiftData configuration and backup behavior; do not conflate Apple's Health sync with this app's storage. |
| 4.8 | Apple-only primary authentication fits the plan. If third-party/social primary login is added, offer an equivalent privacy-preserving option unless an actual exception applies. Provider OAuth connections are not necessarily primary login. | #3/#13/#20/#24. Test Sign in with Apple and deletion token revocation. |

Proposed purpose-string intent, to tailor to the final type list: read workouts/body measurements/nutrition to estimate fueling and show intake; write only user-confirmed food nutrients/caffeine to Apple Health. Do not request every type at first launch. `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` need accurate separate purposes; Health authorization is not blanket consent for server synchronization or provider sharing. Denied reads appear as no data, so avoid claiming to know denial from an empty result. Never export modelled caffeine remaining in the body as consumed dietary caffeine.

For the paywall, [Apple subscription guidance](https://developer.apple.com/app-store/subscriptions/) specifically requires the trial duration and subsequent charge and gives prominence to the total annual charge over a monthly equivalent. StoreKit's native components help, but surrounding copy and actual configured products still need inspection.

## US privacy shipping specification

### FTC Health Breach Notification Rule

**Likely PHR vendor, subject to counsel's documented classification.** A user-managed nutrition/fitness record combining entered meals with HealthKit and tracker data has the multi-source capacity described in [FTC guidance](https://www.ftc.gov/business-guidance/resources/complying-ftcs-health-breach-notification-rule-0). A consumer app need not be HIPAA-covered for this rule to apply. Do not assume a later dietitian feature automatically creates HIPAA coverage; assess the parties, service and data flow separately.

A breach includes unauthorized acquisition/disclosure of unsecured identifiable health information, not just hacking. Examples relevant here are a cross-account RLS leak, health-bearing logs sent outside authorization, or an SDK receiving screening or plan data without authorization. Encryption at rest is not an exemption when the recipient obtains readable data. Keep the assessment and evidence even where notification is not required.

Ship an incident runbook with a named owner, discovery clock, containment steps, affected-person/data/recipient inventory, notice templates and vendor escalation contacts. Individuals: without unreasonable delay, at most 60 calendar days after discovery. FTC: for 500 or more affected people, contemporaneously with individual notices within that limit; below 500, within 60 days after calendar-year end. Media: at least 500 residents of a state/DC/territory triggers additional locale notice. Include notice delivery/substitute-notice procedures and service-provider notice obligations. The 60 days is a maximum, not a waiting period. An actual incident needs counsel's assessment of all applicable deadlines.

### Washington My Health My Data

Counsel should assess Washington nexus, consumer coverage and exemptions; the solo/small-business status is not a blanket exemption. Weight, pregnancy/ED screening, inferred health status, caffeine/sleep records and identifiable derived plans are within the risk inventory. Primary source: [RCW 19.373.010–.060](https://app.leg.wa.gov/RCW/default.aspx?cite=19.373&full=true).

Correct the research's absolute consent summary: §.030 permits collection/sharing to the extent necessary for a requested product/service; §.010 excludes certain purpose-consistent processor disclosures from “sharing.” Do not label every Supabase operation a separate statutory sharing event. Document each recipient's role and any exception relied on. Otherwise obtain collection consent and separate, distinct sharing consent before the respective activity. HealthKit and Apple contractual permission requirements apply independently.

Ship:

1. **Consent and controls:** plain categories, purposes, recipient categories and withdrawal method; separate optional connection/Health-write/cloud-sync/AI choices as applicable; no bundled “agree to everything.” Record notice/version, scope and time without unnecessary raw answers. Withdrawal stops future processing covered by the withdrawn permission and is distinct from deletion. Gate before screening/import collection that requires consent.
2. **Consumer-health-data policy:** a conspicuous homepage link to a dedicated policy, reachable in app. Cover collected categories and purposes, source categories, shared categories, recipient categories and specific affiliates, and rights/request/appeal mechanisms. Include inference, screening, local vs server handling, retention, vendors and no sale/no advertising promises accurate to implementation. A buried paragraph in a generic policy is not the whole delivery requirement (§.020).
3. **Rights/deletion pipeline:** access/confirmation, recipient accounting as required, withdrawal and deletion, request authentication, a 45-day response clock with a justified single 45-day extension, appeals and attorney-general complaint route. Delete active data and propagate to processors/affiliates/recipients; archived/backup deletion may be delayed only within the statutory maximum of six months after authentication. Prevent restored backups/offline clients/webhooks from resurrecting deleted accounts (§.040).
4. **Contracts/security:** binding processing instructions and assistance obligations for Supabase and other actual processors (§.060), minimum access/security controls (§.050), subprocessor/region/retention inventory, deletion propagation and breach-notice contacts. Review the executed DPA and service terms, not just a vendor's compliance badge. Provider integrations may be independent recipients, not processors; classify them individually. Health-bearing food queries, support tickets and diagnostics also belong in the map. HIPAA BAAs are a separate question, not a substitute for these contracts.

Account deletion should remove app data and revoke credentials while preserving a narrowly justified minimal deletion/audit record. Explain that deletion does not cancel an App Store subscription; offer Manage Subscription without forcing cancellation first. Decide and disclose handling of app-written Health samples, which are distinct from imported samples the app does not own; do not promise to delete another app's source records.

## Provider-specific disposition

### Strava: no direct API; Apple Health route is plausible, not a blanket clearance

[API Policy §5.3](https://www.strava.com/legal/api_policy) prohibits commercial API-data use in AI operation as well as training and includes derived data/context windows. §5.4 restricts analysis and combining data, including derivatives; §5.8 restricts charging for API-related functionality. The personal Strava MCP exception is not authorization for this commercial product.

The [API Agreement §2.3](https://www.strava.com/legal/api) defines Strava Data by access/collection from API Materials. That supports distinguishing independently user-authorized HealthKit reads from using the Strava API. I did not find an express permission in those documents approving this app's downstream HealthKit scenario. Do not present HealthKit as a contractual bypass. Obtain counsel's written scope analysis; seek Strava clarification if ambiguity remains. Preserve source metadata and prohibit #35 from receiving Strava-origin samples or derived/mixed targets until cleared. User consent cannot override a provider prohibition. Manual entry and nonrestricted sources provide a fallback.

### WHOOP: deterministic computation is only one part of the review

[WHOOP terms §3–4](https://developer.whoop.com/api-terms-of-use/) restrict medical/professional advice, competition, AI-related development and retention; the data definition includes derivatives. §4.2 has an express-authorization/applicable-law qualification, but ordinary OAuth is not evidence of a waiver for this product's entire intended use. There is no broad affirmative “deterministic use is always permitted” clause in the returned text.

Describe the exact nonmedical fueling and caffeine functionality to WHOOP/counsel. Resolve cached/raw and derived-plan retention against actual cache headers and rights, including persistent food/plan synchronization and AI wording. Record approvals needed for the intended functionality, user opt-in for allowed disclosures, attribution, tier capacity, deletion and token controls. #6 registration alone is insufficient. Leave WHOOP-derived model prompts and professional/diagnostic claims off pending resolution.

### Intervals.icu: the missing terms were located

[Official API Terms, effective 23 October 2025](https://forum.intervals.icu/t/intervals-icu-api-terms-and-conditions/114087), §1 grants commercial use and derived-output rights; no specific AI prohibition appears in the returned terms. §1.1 requires Garmin attribution when displaying information derived from Garmin-sourced activities. This applies before a direct Garmin integration, including targets/explanations derived from those activities. Preserve provenance, inspect the applicable branding rules and update #5/#14/#35 requirements. The [official API access guide](https://forum.intervals.icu/t/api-access-to-intervals-icu/609) calls for OAuth for multi-user apps and excludes Strava-sourced data. An application request/status record in #5 is not evidence of approved production access. These terms do not remove privacy duties or grant rights to arbitrary other-source data mixed into an output.

### Garmin: retain the written-clearance gate

The retrieved [Garmin Connect Developer Program Agreement, FRM-0952 Rev. B](https://developerportal.garmin.com/sites/default/files/Garmin%20Connect%20Developer%20Program%20Agreement.pdf) contains §5.2(q)'s combination/integration restriction unless authorized by the agreement or Garmin in writing; §5.2(t)'s competition restriction; and §4.6's broad rights to Licensee Data transferred to Garmin. §4.6 does not by itself mean Garmin owns every local app datum, nor does it erase statutory consumer rights.

[#32](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/32) correctly requires legal review and written Garmin answers. Make those answers cover multisource nutrition/caffeine, a paid product, allowed derived outputs, any AI, attribution, retention, and the actual direction of data transfer. Do not send screening answers/Health-derived plans into Garmin by default. Also review §4.1's permitted data-use scope and §5.1 security/incident obligations. A Starter registration or generic API approval is not necessarily clearance for these uses. Application Requirements, accepted account-specific terms and negotiated exceptions were not available. TrainingPeaks approval in #4 also needs review of the actual issued agreement before connection; no such grant was evidenced.

## Age gate and professional boundaries

The proposed 18+ gate is a reasonable scope choice, not proof of age or a general legal safe harbor. #20 currently collects profile/Health data before Step 3. Put a neutral minimum-age check first, minimize date-of-birth retention, block adult-target generation on unknown/underage status, and prevent bypass via goal edits, restore, imports or sync. Do not collect identity documents without a demonstrated need. Define how to correct age and handle later-discovered minors. Have counsel review the audience, store age rating and any children's-privacy obligations; an App Store rating is not age verification.

Resolve whether exclusions remove all personalized plans or only deficits/performance dosing. For excluded users, offer professionally approved general education/referral if appropriate, without diagnostic claims or personalized treatment. A disease disclaimer cannot establish that the service is outside regulated practice. This review does not decide medical-device status or state dietetics licensure requirements.

## Ready-to-paste acceptance criteria

These are proposed replacements/additions, not edits made to GitHub. Parent dependencies (#12/#13/#14/#35) must carry the implementation details they own.

### #8 Privacy and terms review

- [ ] Counsel records launch territories, intended adult population, FTC PHR-vendor assessment, Washington applicability, and scope-of-practice/claims decisions for the specified feature set.
- [ ] A versioned data-flow inventory includes screening answers/flags, HealthKit-derived plans, food queries, provider tokens, logs, backups and every recipient; each has purpose, retention, rights basis and owner.
- [ ] The hosted privacy and dedicated consumer-health-data policies, collection consent, separate sharing consent where required, and withdrawal/rights copy are approved against that inventory.
- [ ] Executed processor terms and subprocessor handling, including Supabase deletion and incident obligations, are reviewed; unresolved terms block the affected flow.
- [ ] Strava-through-Health scope, WHOOP deterministic/AI/retention uses, Intervals.icu Garmin attribution and any direct Garmin uses have explicit dispositions. Provider authorization is obtained where required, not inferred from this review.
- [ ] A breach and consumer-rights runbook has named ownership, deadlines, contact channels, notice templates and a completed tabletop exercise.
- [ ] Approval identifies version, scope, date and outstanding conditions; privileged advice/provider correspondence stays private with an approved public summary. A list of changes is not release approval.

### #9 Sports dietitian review

- [ ] Named qualified reviewers approve the exact versioned rule configuration, code revision, sources, population, fixtures, limitations and user-facing claims, or explicitly withhold approval.
- [ ] Core fueling, goal-weight and caffeine each have a separate approve/conditional/not-approved disposition; all conditions for enabled features are resolved before athlete exposure.
- [ ] Missing FFM, unreliable expenditure/intake, eligibility changes, safe fallback, pause/resume and overlapping training scenarios are reviewed and represented in tests/manual checks.
- [ ] Screening instrument/version, permitted wording, relevant population, scoring, nonresponse, referral and resumption protocol are approved with REDs/eating-disorder clinical input; the app does not diagnose or issue sport clearance.
- [ ] The EA floor is not described as a guarantee or universal diagnostic threshold; pace, calorie/BMI defaults and protein rules have explicit reviewer decisions.
- [ ] Caffeine single-dose/total limits, contraindication handling, unknown intake, model uncertainty and sleep messaging are approved.
- [ ] Re-review triggers and responsibility are recorded. A request for changes leaves the affected release gate unsatisfied until verified resolution and explicit approval.

### #20 Onboarding

- [ ] Age eligibility and required notice/consent precede unnecessary Health/provider imports or sensitive screening storage; unknown or underage eligibility cannot produce adult personalized targets.
- [ ] The agreed exclusion policy consistently governs initial plans, weight-loss features and caffeine suggestions, including later changes and restored/synced settings.
- [ ] Consent is purpose-specific, optional sharing choices are separate where required, and refusal/withdrawal paths work without misleading prompts; consent version/scope/time is recorded.
- [ ] Screening uses the approved instrument and protocol, with nonresponse handling and nondiagnostic referral copy; store only the approved minimum needed to enforce eligibility.
- [ ] Health read/write purposes and requested types match shipped functionality; denied/unavailable data has a manual or approved fallback.
- [ ] First eligible plan precedes the paywall; the one-minute goal never skips or preselects safety/consent answers. UI checks cover eligibility refusal, declined permissions and returning users.

### #22 Subscriptions

- [ ] Before confirmation, show benefits, localized full price/billing period, trial duration and eligibility, post-trial renewal price/period, auto-renewal and cancellation/manage instructions, plus working privacy and terms links.
- [ ] Annual total is prominent; an equivalent monthly figure does not obscure the billed amount. Ineligible users are not promised a free trial.
- [ ] Purchase, restore, pending/cancelled purchase, renewal, expiry, revocation/refund and supported billing-retry/grace behavior are verified against actual StoreKit products.
- [ ] Manage Subscription works; account deletion is available independently and clearly explains that deletion does not cancel billing.
- [ ] The first eligible plan precedes purchase, and screenshots cover trial-eligible, ineligible, error and subscribed states with accessible text.

### #23 Account deletion

- [ ] Profile offers in-app deletion with reasonable identity confirmation and clear scope/status; a failure can be retried without leaving the account misleadingly marked deleted.
- [ ] An end-to-end inventory test removes active rows, derived plans, screening state, storage objects, tokens and local caches, including other synced devices; webhooks/offline replay cannot recreate them.
- [ ] Apple token revocation and supported provider revocations complete or enter a monitored retry path; do not erase the only revocation credential before handling revocation.
- [ ] Processor/recipient deletion propagation, backup expiry within applicable limits and restore-time suppression are verified; completion evidence contains no secrets or health details.
- [ ] Explain upstream provider records and app-written Health samples accurately; do not claim removal of other apps' Health records. Subscription management is offered without blocking deletion.
- [ ] Rights requests, response deadlines, justified extensions and appeals operate through the published channel; a clean new signup does not restore deleted data.

### #24 External TestFlight release

- [ ] The release manifest records build number/commit, rule/configuration hash, enabled features/providers, territories and the exact clinical/legal approval records. Closed issues alone do not satisfy this gate.
- [ ] Every approval condition is resolved; unapproved goal-weight, caffeine, AI or provider paths are absent or demonstrably disabled, including deep links and restored settings.
- [ ] The shipped build passes real engine/app/backend checks, independent review and on-device permission, consent, eligibility, billing and full deletion scenarios; skipped scaffold checks do not count.
- [ ] Hosted policies/support links, privacy label, Health purpose strings, terms, review notes and screenshots match actual data flows and claims, with no unapproved health-data advertising/analytics or iCloud storage.
- [ ] Provider approvals/capacity, attribution, retention and processor contracts cover the external tester cohort; incident/rights contacts and the release rollback/feature-disable procedure are operational.
- [ ] External Beta App Review is completed as required; a representative eligible tester reaches a plan and an excluded tester follows the approved referral path on the exact release build.
- [ ] Release owner signs the completed evidence checklist before external distribution, with any remaining limitation explicitly accepted within the approved scope.

### #37 Goal weight

- [ ] The feature remains disabled until the exact adaptive algorithm, safety copy and eligibility/resumption protocol have explicit professional approval tied to a version.
- [ ] FFM provenance/age, input plausibility, intake completeness and weight-trend requirements are defined. Missing/unreliable inputs trigger the approved non-deficit hold behavior, without assumed body composition.
- [ ] Tests enforce approved floors, pace limits, session protection and no deficit on hard/pre-key days across incomplete logs, rescheduling, multiple sessions and time-zone changes; no test is described as proving clinical safety.
- [ ] Eligibility is enforced on-device and in restored/synced settings; pregnancy, ED concerns and other approved exclusions trigger the specified hold/referral behavior.
- [ ] Copy identifies estimates and uncertainty, removes guaranteed avoidance of under-fueling, and does not represent BMI/EA minima as clearance to lose weight.
- [ ] Pause trigger, data-quality distinction, duration and resume requirements are approved; a generic confirmation cannot bypass the approved protocol.
- [ ] Calories remain hidden by default, logged meals are unchanged by replanning, and fixtures/screens use the approved rule revision.

### #38 Caffeine

- [ ] Curve/logging and performance advice have separate professional approval scopes; performance advice stays off until limits and eligibility are approved.
- [ ] The engine enforces the approved single-dose and total-intake ceilings, accounting for other known intake; missing caffeine values are not zero and unknown intake suppresses unsafe suggestions under the approved rule.
- [ ] Tests cover repeated doses, prior-day residuals, planned versus consumed doses, edits/deletions, Health deduplication and eligibility changes.
- [ ] Timing/residual copy explicitly describes estimates, no guaranteed sleep protection, and no universal safe bedtime amount. Race-day copy does not waive sleep warnings or encourage dose escalation.
- [ ] Pregnancy/minor exclusions and clinician-approved contraindication handling apply to every suggestion entry point, restore and sync.
- [ ] Only confirmed consumed caffeine is written to Health with the correct units/timestamps and consent; estimated in-body caffeine and planned doses are never exported as intake.
- [ ] Approved golden cases and device/screenshots verify warnings, alternatives, eligibility and accessibility, in addition to the arithmetic example.

## Pre-external-TestFlight checklist

1. Freeze the feature/provider/territory scope and exact build/configuration. Record whether #37/#38/#35 are disabled or approved.
2. Obtain explicit scoped clinical and legal dispositions; close every blocking condition and verify the implementation matches reviewed copy/rules.
3. Complete age/consent/eligibility/referral flows, hosted policies, data inventory, processor terms and provider permissions/attribution.
4. Exercise access/withdrawal/deletion, revocation retries, backup/restore suppression and incident-response tabletop with evidence.
5. Run real verification and independent review; inspect the native app on device for Health permissions, offline/empty data, safety holds, billing and deletion. Keep numerical correctness separate from professional safety approval.
6. Inspect privacy metadata, purpose strings, subscription terms, support links, app/store claims, source attribution and review instructions for the exact build.
7. Verify provider cohort capacity and tester authorization; complete required Beta App Review. Record release-owner go/no-go, support and rollback plans before external invitations.

## Decisions required and verification limits

Decide: adult-only/exclusion scope; whether adaptive deficits and performance dosing belong in first beta; qualified review ownership and resume protocol; stored screening detail; permitted server-derived health data; launch jurisdictions; provider/AI provenance policy; exact subscription products/trial; and what legal/provider evidence can be public.

Not verified: native runtime, plist/entitlements, RLS/security controls, database/backups, executed contracts, actual provider approvals/headers, clinician/legal sign-offs outside issue text, App Store Connect products/privacy configuration, accepted Garmin account terms/Application Requirements, complete secret history/artifacts, screening reuse licenses, and medical/legal classification. No new UI rendering, app tests, fetches or remote mutations were performed. Public texts and issue wording establish gaps and requirements, not an actual deployed violation. No evidence supports declaring the app clinically safe or legally compliant today.
