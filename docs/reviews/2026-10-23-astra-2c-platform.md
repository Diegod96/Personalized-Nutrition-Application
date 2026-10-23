# 2c: Draft domain, sync and platform contract

Reviewed 2026-10-23. Architecture proposal, not implemented behavior or release approval. Continues `/tmp/nutrition-astra-review/review.md`. Only this report was written; no repository, GitHub or branch mutations, builds or tests were performed.

## Evidence baseline

Read live issues [#10](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/10), [#12](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/12), [#13](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/13), [#14](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/14), [#15](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/15), [#18](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/18), [#19](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/19), [#21](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/21), [#23](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/23) and [#25](https://github.com/Diegod96/Personalized-Nutrition-Application/issues/25).

Research line references below mean `docs/research/2026-10-22-fueling-app-research.md` at locally available `origin/chore/project-setup`, SHA `0e004b09066b9a3bf9eae4f58fdf7f0f3597d1d8`. Read that ref's AGENTS.md. No fetch was performed; remote-ref currency is not asserted. DESIGN.md and mockups references mean the checkout at `059cc713e8a95de3b7ae18b1bee327209b0cfbf0`, feature/36-design-system. Documentation was retrieved through Firecrawl; some responses were cached, not authenticated integration observations.

## Ranked findings

1. **High: unconditional freshness and reminder promises are impossible with the selected architecture.** #14 requires an upstream move to appear within minutes without manual refresh; #19 requires moved/deleted reminders to follow. Research:392–395 assumes a push wakes the app. Apple permits background push delays and discards held pushes after force-quit; scheduled local notifications remain active until fired or cancelled [A1, A2]. Fix: foreground reconciliation contract, explicitly best-effort background processing, conditional reminder guarantees, and visible freshness. An APNs acceptance response is not a device acknowledgement.
2. **High: independent imports can multiply training demand and intake.** #12 merges overlapping workouts; #14 imports plans; #15 exports foods back to Health. None defines shared identity, replacement, ambiguous matches or intake coverage. Research:37–38 records missing food timing. Fix: canonical TrainingDemand plus provenance, source-scoped identity and a separate daily-import bucket. Do not infer one workout merely from overlap or a meal merely from a timestamp. Proposed model below.
3. **High: cross-device plans lack a calculation authority.** Research:374 promises cross-device sync while :390 keeps HealthKit inputs on device. #13 promises offline sync without a writer/conflict protocol. Fix: one designated calculating/exporting iPhone in v1, server fencing epoch and explicit takeover. Other devices share app-created inputs and display the last accepted plan; they do not independently overwrite it.
4. **High: token encryption and deletion need an access and retry contract.** #13 says Vault or column encryption, #23 lists row deletion and Apple revocation without failure ordering. Vault exposes plaintext through a privileged view [S2]; deletion before capturing revocation work can lose the only usable token. Apple requires fulfilling deletion even without a revocable token [A7]. Fix: private token store, least-privilege server access, authenticated deletion workflow, bounded revocation retry and documented fallback.
5. **Medium: imported deletion and editing semantics conflict.** #18 says edit/delete any imported session; DESIGN.md:60 says Hide for synced workouts. Fix: user overrides and persistent local suppression; no upstream write implied. Provider deletion must not erase a real completed workout or a consumed meal.
6. **Medium: HealthKit assumptions need precise wording and device verification.** Research:42's blanket hourly limit is inaccurate: Apple says frequency is a maximum, with type-specific ceilings [A3]. Research:312 leaves caffeine writes unresolved; Apple's caffeine sample demonstrates them, conditional on sharing permission [A5]. #12's simulator checks cannot establish background delivery, export fidelity or real third-party sample metadata. Retain these as explicit physical-device checks.

These are specification gaps, not observed production defects. Sections below are proposed decisions. Matching thresholds, polling intervals and retention policies are product defaults to approve, not platform guarantees.

## 1. Canonical domain and identity

Every app entity uses an opaque UUID, account owner, schema version and lifecycle state. Mutable synced entities also carry server row version; user operations carry operation UUID, device ID and base version. Provider IDs remain opaque strings even when an API currently returns integers. Never use a time, title or content hash as the permanent entity identity.

### Entities

- **PlannedSession:** UUID; manual or provider origin; provider account/resource key; sport; planned local time, IANA zone and resolved instant when known; duration; intensity/load/kJ with units and provenance; coach carb target; provider snapshot version; local field overrides; active/cancelled/hidden status. Keep original and effective values separate. A provider edit updates the original, preserving an explicit override and displaying the difference.
- **CompletedSession:** UUID; immutable source references; actual start/end, sport and selected summary measurements; confidence; duplicate-group membership. Raw HealthKit samples and their identifiers are local only. Distinct source records remain recoverable when a merge is undone. Future WHOOP adapter adds its own provider references without assuming an HK UUID equals a WHOOP UUID.
- **TrainingDemand:** UUID; optional planned-session ID; zero or more candidate completion IDs; selected canonical completion or explicitly confirmed component set; link state and evidence; included/excluded/provisional status. v1 automatically supports one plan to one completion, with multiple duplicate source representations. Split workouts and multisport components require review; do not silently collapse them. Future demand uses the plan; after confirmed completion, actual duration/work replaces planned demand for remaining-day calculation. Never sum both. Preserve planned coach guidance and its provenance separately from actual workload.
- **FoodEntry:** UUID; meal ID nullable; exact consumed instant and entry zone/date for app-created entries; quantities/units/macros; user revision; origin; export ledger per nutrient; lifecycle. Imported dietary observations are local records referencing a source UUID, not fabricated app-created foods. They may have only a date and no reliable meal ID. Nutrients from one food are separate HealthKit samples and must not be mistaken for separate foods.
- **Meal:** stable UUID; date/zone; user label/slot; associated demand purposes; logged FoodEntry IDs. Planned targets belong to PlanRevision, not to the consumed ledger. A meal can serve recovery and preparation simultaneously, but each entry counts once in daily intake. Automatic replanning never edits logged entries; explicit corrections are permitted and versioned.
- **PlanRevision:** UUID; previous revision ID; authority epoch and device sequence; engine/rule/config versions; input fingerprint; local input generation; server input watermark; day/zone; source freshness; unresolved-input flags; immutable calculated targets/reasons; creation instant. Publish an immutable revision and atomically change a current-plan pointer. Same normalized inputs/config produce the same result and no duplicate revision/notification. Local Health fingerprints and raw evidence stay local.
- **ProviderConnection:** UUID; owner; provider; provider account ID; scopes; generation; status; last attempt/success; last provider snapshot generation; error category. Safe metadata syncs. Token references and credentials are private server data. Reconnect the same provider account through the existing identity namespace; a new account has a different namespace.
- **Tombstone:** UUID; owner; entity/external identity; kind (user delete, local hide, provider removal); server version; originating operation; restore version if applicable. A hide is reversible suppression, not evidence of upstream deletion. Keep the stable external identity so reimport/reconnect does not resurrect it. HK-specific tombstones stay local.

Supporting records: local ExternalIdentity and MatchDecision; local HealthExportLedger and per-type Health query checkpoints; server mutation receipts, authority record, device registration, webhook inbox and deletion job. These support the eight entities rather than adding new user-facing concepts.

### External identities and matching

**Intervals.icu:** `(owner, provider=intervals, athlete_id, resource=calendar_event, event.id)`. The documented event ID is not `external_id`: the latter is optional, supplied by another creating app. Namespaced provider identity survives rescheduling [I1, I2]. Replacing an upstream event with a new ID creates a new identity; offer relinking, do not silently transfer hidden status or logs based only on the title.

**HealthKit:** `(local account/store context, sample type, HKObject.uuid)` identifies an observed object; retain sourceRevision.source.bundleIdentifier and available source revision/device information. A bundle ID identifies the writer, not necessarily the original recording device. When present, `(source bundle, type, syncIdentifier)` is additional lineage with syncVersion ordering. Absence of sync metadata is normal. Never treat a provider's arbitrary syncIdentifier as globally unique or equal to our FoodEntry UUID. HK UUIDs are not a cross-provider join key. Process additions and explicit deleted UUIDs from anchored queries; commit applied changes and new anchor together so a crash replays safely [A4, A6]. Query anchors are local per store/type/predicate, not portable sync tokens.

**WHOOP later:** namespace `(WHOOP account, API version, resource kind, id)`. v2 workout and sleep IDs are UUIDs; v2 recovery webhooks identify the associated sleep, not a workout or legacy cycle. `trace_id` is event tracing metadata, not an object ID [W1]. Do not require WHOOP's Health export to contain the API ID until real samples establish that.

**Confidence states:** exact source replay; confirmed link (explicit provider lineage or user choice); suggested unique candidate; ambiguous multiple candidates; distinct; rejected link. Store the method, inputs and matcher version, not an invented statistical probability.

Proposed candidate heuristics for fixtures: same normalized sport, completed-start difference at most 2 minutes and duration difference at most 5% for possible completed duplicates; same sport/date with start difference at most 90 minutes and duration ratio 0.5–2 for plan/completion suggestions. These broad starting thresholds need calibration. Overlap alone never confirms a merge. A negative user match decision survives reimport and matcher changes. Explicit or user-confirmed links can auto-apply; heuristic suggestions remain reviewable and labelled provisional.

For an unresolved candidate group, display all evidence, provisionally count one representative (confirmed user preference, then configured preferred source, then deterministic ID tie-break), and flag the plan as needing review. Do not silently count every candidate or silently claim the omitted candidates are duplicates. If candidates may be two real sessions, ask the athlete to resolve them before representing the target as settled. Undo restores separate demands and recomputes future allocations. This provisional policy trades possible undercount against duplicate inflation and needs product approval before athlete use.

Prefer one source per measurement: user-confirmed value, then selected recording source for actual duration/work, then a documented fallback. Never sum energy from a workout and its associated active-energy samples. Keep HealthKit SDNN and WHOOP RMSSD distinct; they are different measures, not interchangeable duplicates (research:41–42).

### Nutrition round trip and source precedence

For each exported nutrient use a stable namespaced syncIdentifier such as `app.food.<entryUUID>.<nutrient>` and integer syncVersion equal to that entry's export revision. Persist the intent before saving, then the sample UUID/result. Retries reuse identifier/version; edits increment version. Apple documents replacement when the new matching sync version is higher [A4]. Reconcile each nutrient independently after partial success; never declare a whole meal exported because one nutrient succeeded.

Read-back recognition requires our source bundle plus our identifier namespace/entry mapping. Such samples acknowledge an export and do not add intake. Unknown own-source samples become recoverable orphans for review, not automatically a second logged meal. Account changes must not adopt another account's old Health samples. Export only on the calculating phone. A delete queues removal of app-owned samples, cancels older pending exports and retains a tombstone until resolved. If Health denies writes/deletes, retain the local correction and show export pending/blocked; do not repeatedly recreate a sample the athlete removed in Health without asking.

For third-party nutrition, choose one imported source per day/nutrient unless independent entries are demonstrated. Own entries are always exact consumed records. A selected import that may already include own Health writes is an overlapping coverage total, not additive intake. Show it separately as unallocated imported nutrition until coverage is confirmed; do not sum it with own entries or silently subtract totals to invent meals. A user can explicitly classify non-overlapping imports as additional daily intake. The requirement is correct, explainable coverage, not a false single number.

## 2. Sync, authority and replay

### v1 authority and data boundary

Designate one iPhone to calculate plans, read Health for calculations and export our foods. Other signed-in devices may edit app-created inputs and view the last accepted plan labelled with calculating device and calculation time. They cannot claim their edits have already updated that plan. No server-side replica of FuelingEngine.

Server authority record: `(owner, designated_device, epoch)`. Online takeover increments epoch atomically after explicit user action; only current-epoch plan publications pass. Use a per-device credential validated server-side, not a caller-provided device string alone. The previous phone may calculate a labelled local provisional plan while offline, but its obsolete epoch cannot overwrite the accepted shared plan on reconnect. Before takeover, reconcile outstanding inputs and rebuild Health locally; do not transfer Health anchors. An offline old phone cannot be remotely prevented from issuing already-scheduled reminders or Health writes: v1 requires retiring the old phone's export/reminder role during handoff and warns about this limitation. Strict simultaneous offline fencing would require losing offline export capability.

**Server allowlist:** app-created profile/settings, manual workouts, app-created foods/meal records, imported Intervals calendar snapshots (explicit addition to #13 scope), user overrides/hides, permitted generated plan outputs/reasons, operation receipts, authority/device state, connection metadata and encrypted tokens. A generated plan is derived health-related information; disclose and obtain the required consent before syncing it. Allowlisted serialized output must exclude source sample objects, UUIDs, Health anchors and detailed Health provenance. Do not upload arbitrary input snapshots, diagnostic logs or hashes as a shortcut.

**Local only:** raw HealthKit observations, Health-derived completion records and source identifiers, weight/HRV/sleep/nutrition import records, detailed matching evidence, full engine input snapshot, Health export UUIDs and anchors. Health-derived TrainingDemand links stay local; synced plan outputs may use opaque app demand IDs without the Health reference. App-created food remains app data when exported and read back, rather than becoming a new server copy of imported Health data. Future WHOOP retention/cache rules need separate design before #25; no indefinite WHOOP mirror is approved here.

### Offline operations

SwiftData transaction saves local mutation plus outbox operation UUID. Server transaction validates owner/device/account state, deduplicates `(owner, operationUUID)`, compares base row version, applies permitted mutation and returns a durable result plus monotonic change sequence. A repeated key with different contents is rejected. Pull uses server cursor and includes tombstones; a lost response safely retries the same operation.

For concurrent edits to the same food or timing fields, preserve both proposals in a conflict response; keep the current server value until explicit resolution. Do not average food amounts or choose by phone wall-clock timestamp. Independent new entries merge by UUID. Delete wins over a stale edit of the same entity; restore is a new explicit operation against the deletion version. Editing a logged item remains distinct from automatic replanning. Parent/child meal changes use one transaction. Provider refresh cannot overwrite user override fields.

Keep tombstones and minimal operation receipts for the account lifetime in v1; purge with account deletion. This avoids arbitrary offline expiry resurrecting data. If later compacted, expire device cursors and require full resync before accepting old writes. A new sign-up must never ingest an outbox belonging to the deleted account.

### Webhooks and fetching

Intervals documents a top-level JSON `secret`, batched `events`, athlete ID, type, timestamp, and `CALENDAR_UPDATED` including events/deleted_events [I1]. It does not document an HMAC in the reviewed source. Require HTTPS; bound body size; parse only enough to validate the configured secret with constant-time comparison; redact it from every log; then validate schema and map athlete ID to an active connection. Unknown or disconnected mappings cannot create accounts. This function needs provider authentication rather than a Supabase user JWT; do not disable authentication on unrelated functions.

Store a redacted event receipt durably before 2xx. Proposed idempotency key: hash of provider/app namespace, connection generation, athlete, event type, provider timestamp and canonical event payload excluding secret. Store a payload digest for conflict checks. This is our duplicate-detection key, not a provider-guaranteed event ID. Equal payloads with genuinely different timestamps may cause redundant fetches but cannot cause duplicate entities. Static shared-secret authentication supplies neither signed freshness nor replay protection: replay mitigation comes from durable receipts, rate limiting/coalescing and fetching authoritative state. Do not reject all delayed events by a short timestamp window and lose changes.

Treat webhooks as invalidations, not commands to apply stale snapshots. Serialize reconciliation per connection; increment a dirty generation when notices arrive. Fetch the authenticated calendar, commit a full successful snapshot with a server sequence, then repeat if dirtied during the fetch. Ignore late results from superseded request generations. Coalesce bursts and obey rate limits/backoff; foreground refresh shares that budget. Replayed or reordered notices fetch current state rather than restoring old state. Reconcile on foreground even if every push was lost.

A missing item in a next-14-days response is not proof of deletion: it may have moved out of range. Reconcile previously known active IDs using provider-supported lookup or a covering successful snapshot, and use deleted_events as a reason to verify current state. If provider deletion verification is unavailable, mark missing/unconfirmed, preserve history and avoid new reminders pending resolution. Never infer deletion from 401, timeout, failed pagination or an incomplete response. Source cancellation removes future planned demand; a linked completion and logged meals survive.

WHOOP later uses its documented timestamp-plus-raw-body HMAC-SHA256 signature (base64) and headers [W1]; add freshness checks and durable replay records, allowing a controlled resync for delayed deliveries. Do not copy that signature protocol onto Intervals.

## 3. Freshness and reminders

Replace “updates within minutes” with: **“The app checks your calendar when opened and when you refresh. Background updates are best effort. The plan shows when each source was last checked and when targets were recalculated.”**

Proposed measurable foreground behavior: trigger reconciliation on launch, becoming active, reconnect and manual refresh; while active, inspect server dirty state at most every 60 seconds, coalescing work and observing provider budgets. Begin the request within 2 seconds of the trigger in controlled tests. With fixture services responding within 5 seconds and a bounded 14-day dataset, commit/render within 10 seconds. These are app test budgets, not promises about provider availability. On failure, keep the last plan and show failure within that attempt's timeout. Track last attempt, last successful source reconciliation, source data date, calculation time and server webhook receipt separately. A newer push receipt must not advance “last synced.”

Background push uses `content-available:1`, correct background APNs type/priority and coalescing. Apple advises against more than roughly two or three background pushes per hour and provides about 30 seconds when delivered; delivery can be delayed or dropped [A1]. Persist progress before the deadline and finish the callback. Retry on next execution opportunity. BGAppRefreshTask is another opportunity with expiration handling and resubmission, not a timer or latency guarantee [A8].

HealthKit observers register at launch, request background delivery with the entitlement, drain anchored changes and call completion after durable processing. Requested frequency is an upper frequency, not a promise of immediate delivery; some iOS types have hourly ceilings [A3]. Locked-device access errors, low power, background settings and force-quit require real-device observations. Foreground must repair missed updates independently.

Use an opt-in, coalesced visible alert for a verified calendar change when appropriate: “Your training calendar changed. Open the app to update your fueling plan.” Do not send “eat 80 g now” from stale server output. Alert permission, Focus and delivery conditions still apply; an alert is not proof the plan changed. No health values in generic push payloads.

**Reminder policy:** schedule nonrepeating reminders only within the next 24 hours from the accepted local revision, with IDs keyed by account/demand/purpose and revision recorded in metadata. On a processed move/cancel/hide, remove obsolete pending and delivered reminders and schedule only valid future ones. Never issue past-due replacements. Persist the desired schedule; on next launch diff it against pending requests to repair crashes between cancellation and replacement. Respect quiet hours and per-session toggles.

**When the app cannot wake:** already scheduled local reminders can still fire at the old time, including after upstream cancellation. APNs cannot remotely delete a local pending request; shortening the horizon reduces exposure but cannot eliminate it [A1, A2]. Copy should be conditional (“Check your plan before today's session”), not an unconditional quantity directive. On opening any reminder, reconcile and validate its demand/revision before presenting it as current. A remote change alert can warn the user but does not cancel the old local reminder. If this residual behavior is unacceptable, remove automatic local workout reminders from v1; stronger wording cannot fix it. #19 requires this companion scope correction.

### Acceptance test matrix

All rows must preserve logged food and at most one counted demand per confirmed workout. “Device” means physical-device evidence; injected handlers alone do not prove OS delivery.

| Condition | Test and required result | Evidence |
| --- | --- | --- |
| Foreground | Move session upstream; reconcile within controlled request/render budget; one new revision and revised future reminders | Fixture integration plus live account |
| Suspended | Deliver and separately suppress background push; delivered case processes durably, suppressed case retains stale label and repairs on open | Device timestamps, revision IDs |
| Force-quit | Move/cancel after force-quit; do not expect wake; old local reminder may fire; reopen repairs before claiming freshness | Device recording and notification inventory |
| Offline | Log/edit/hide, relaunch; durable local state and pending operations survive; no false sync-success timestamp | Persistence and UI tests |
| Reconnect | Replay outbox after lost acknowledgements; each operation applied once; pulls tombstones then recomputes; conflict shown | Integration with dropped responses |
| Expired/revoked token | Transient expiry uses supported refresh; revocation/failed reauthorization sets Reconnect; cached plan remains visibly stale | Provider adapter fixtures and real account |
| Reordered webhooks | Update then deletion arrives in reverse order; authoritative current fetch wins; stale response cannot resurrect | Deno and reconciliation tests |
| Repeated webhook | Identical and semantically equivalent batch repeats; bounded fetch/push work, one entity and no repeated revision | Deno/database tests |
| Deleted workout | Confirm upstream removal; remove planned future demand/reminders, retain completion and meals; distinguish moved-out-of-window | Integration and UI |
| Health permission missing | Empty/own-only reads show no available external data, never “read permission denied”; manual entry works | Device allow/deny combinations |
| Health replay/export crash | Replay anchor pages and interrupted nutrient export; one intake contribution; deletions processed before anchor advance | Unit/integration plus Health app check |
| Two devices | Concurrent food edits and delete/edit conflict; old authority publication rejected after takeover; secondary pending-plan label | Two-device/integration |
| Midnight/DST/travel | 23/25-hour days, midnight workout, date-only import, travel across midnight; no lost/double intake | Calendar unit fixtures |
| Notification disabled | No permission or quiet hours suppress alert; freshness remains discoverable in app | Device/UI |

## 4. HealthKit details

**Denied reads:** authorization success means the request completed, not that every read was granted. Apple deliberately hides denial and may return only samples written by this app [A5]. Show “No data available from Apple Health. Check sources and permissions.” Do not label read authorization denied or infer zero consumption, zero exercise or zero weight. Write authorization is inspectable per type; query errors remain actual errors. Preserve last observed history as stale without presenting it as a fresh read; an empty query must not bulk-delete it. Handle limited-history access where supported without assuming the v1 minimum OS supports newer APIs.

**Caffeine:** `dietaryCaffeine` exists and uses cumulative mass quantities. Apple's Coffee Tracker saves and reads caffeine samples [A5], resolving the report's categorical uncertainty. Request sharing permission specifically for caffeine when the feature is used; macro permission is not caffeine permission. Check actual sharing status and handle failed saves. Keep local entries usable if sharing is denied. Availability of the identifier is not proof permission was granted. Do not request caffeine in v1 merely because the API supports it if the feature is deferred.

**Time:** store actual instants in UTC and original IANA zone/local date separately. “Today” uses the current planning zone's calendar start-of-day through next start-of-day, not UTC date or 86,400-second arithmetic. On zone change create a new plan revision for affected future windows; don't rewrite consumed instants or original logged meal assignments. Display travel regrouping explicitly. Session spanning midnight is still one demand; allocate day contributions by the chosen engine policy, never duplicate it. Intervals examples contain offset-free `start_date_local` [I2]; persist the string and known/configured athlete zone. If zone or DST resolution is ambiguous, ask for confirmation rather than silently interpreting it in the server timezone. Exact provider zone semantics remain a live verification item.

**MyFitnessPal:** research:37 describes meal summaries with no timestamps. HealthKit objects still have start/end dates; “untimestamped” here means no reliable consumption time, not no date fields. Treat these as date-level evidence with `timePrecision=day/unknown`, never as a midnight meal or evidence the pre-workout meal was eaten. Cronometer timing is also unverified (research:38,317). Actual export samples must establish granularity, source bundle, update/replacement and duplicate behavior. This review did not verify these products' live exports and does not treat the report as a new provider guarantee.

## 5. Supabase access, secrets and deletion

### RLS and write-path outline

Default deny for anon and no direct grants on private tables. Owner predicate `auth.uid() IS NOT NULL AND auth.uid() = owner_id`; UPDATE needs both USING and WITH CHECK, INSERT WITH CHECK. Reject writes when account is deleting/deleted. Owner ID is immutable. All referenced parents use owner-matching composite keys or equivalent validated constraints. RLS alone does not enforce field immutability, revisions or authority; validated transactional RPCs do. Keep security-definer search paths fixed, revoke public execution, and validate callers. Views must not accidentally bypass policies [S1].

| Table | User read | User mutation | Privileged path |
| --- | --- | --- | --- |
| profiles | Own | Own allowed fields through versioned mutation; no authority/account-state fields | Account bootstrap/deletion |
| settings | Own | Own through conflict-aware mutation | Deletion |
| planned_sessions | Own | Manual rows and override fields through RPC; no imported base edits | Provider fetch upserts base fields |
| meals | Own | Own app-created meal labels/consumed linkage; engine target data elsewhere | Deletion |
| food_entries | Own | Own app-origin only through mutation RPC, parent ownership checked | Deletion |
| plan_revisions/current_plan | Own derived output | Publish RPC only; designated device credential, epoch, input watermark and sequence checked | No arbitrary client overwrite |
| tombstones | Own server-safe tombstones | RPC only; delete/hide/explicit restore; no raw removal | Retention/account purge |
| provider_connections | Own safe status metadata | Connect/disconnect functions only; no arbitrary provider account reassignment | OAuth, refresh, status updates |
| devices | Own safe registration metadata | Register/revoke own device via authenticated endpoint | Private APNs token management |
| calculation_authority | Own | Takeover RPC only; atomic epoch increment | Credential validation |
| mutation_receipts/change_log | Own safe sync results | No direct mutation | Transactional sync functions |
| provider_credentials/Apple credentials | None, including encrypted columns | None | Private token helpers only |
| webhook_inbox/push_outbox | None | None | Provider-authenticated ingress/worker |
| account_deletion_jobs | Own sanitized status via endpoint only | Start own deletion via authenticated endpoint | Retry/purge worker |
| CompletedSession/Health-derived TrainingDemand/ExternalIdentity | No server table in v1 | None | Local-only data |

No client RLS policy should grant the service role to a device. Service-role access bypasses RLS, so each Edge Function must perform its own authenticated owner checks. Tests must cover anon, A/B access, owner changes, cross-owner parents, stale versions, direct RPC misuse, stale authority, safe views and absence of credentials from responses. A “SELECT returned no rows” check alone is insufficient for writes.

### Encryption decision

Recommend **Vault for v1**, with opaque secret references in a private credential table. Vault uses authenticated encryption at rest, with a decrypted view that must be restricted [S2]. Do not expose that view, its RPC wrapper, or token refs through client APIs. Serialize token refresh and update access/refresh credentials together with a credential version so a late refresh cannot overwrite rotated tokens. Do not invent refresh support for a provider; follow its actual OAuth contract.

Alternative: authenticated column encryption in Edge Functions, with nonce, key version and owner/provider associated data; encryption key in Edge secrets, never beside ciphertext. This requires explicit rotation, backup and migration procedures. Avoid custom cryptography and do not equate ordinary disk encryption with application credential protection. Vault is the smaller v1 choice; neither option protects against a compromised privileged function that can decrypt.

Edge secrets hold APNs .p8 signing key, Apple client-secret signing material, provider client secrets and Intervals webhook secret; per-user refresh tokens belong in encrypted storage, not one environment variable each. Supabase documents environment-secret access and server-only elevated keys [S3]. Redact authorization headers, OAuth codes, webhook secrets, request bodies and health values from logs. Use one-time OAuth state tied to authenticated user/connection; validate callback and token subject before linking.

### Account deletion

#13 already correctly requires capturing Apple's authorization code as well as the Supabase ID-token sign-in. Exchange promptly on the server and securely store the usable Apple revocation token bound to verified Apple subject/account. Supabase session tokens are not Apple revocation tokens [A7].

Deletion is an idempotent job: authenticate ownership; atomically mark account deleting, block sync/provider ingestion and plan publishing, invalidate device registrations and queue revocation using the private credential references. Revoke Apple and supported provider tokens before destroying those credentials when possible; then purge application rows, Vault secrets and Auth user, and clear local database/outbox/Keychain/reminders. Retried requests resume rather than recreate the account.

Do not claim “all rows deleted” while a retry job intentionally retains credential material. Proposed bound: complete normal data deletion promptly, retain only restricted revocation job/token material for up to 24 hours of retry, then purge it and expose the manual Apple revocation fallback if needed. This retention window requires an explicit product/privacy decision. Missing Apple credentials must never block account deletion indefinitely: Apple explicitly supplies a manual-revocation fallback [A7]. Sanitized completion metadata must have its own short retention or be removed at job completion; backup expiry must be disclosed, not presented as instant physical erasure.

Revoke sessions and reject writes from still-unexpired JWTs through account-state checks. Drop late webhook events for inactive connections; fresh signup gets new app identity and never replays old local queues. An offline secondary device cannot be instantly wiped; wipe when it next authenticates/reconnects, and state that limit. Previously exported Health samples are a separate user-controlled store: explain whether the athlete wants app-owned samples removed, attempt only those, report permission failures and never delete other apps' samples. Account deletion must not depend on successful Health cleanup.

## 6. Ready-to-paste issue acceptance criteria

These supplement existing useful criteria; replace the specifically conflicting clauses. They are proposals only and were not posted.

### #12 Apple Health

- [ ] Health reads distinguish query errors from no available external data; the UI never claims it knows read permission was denied. Manual input remains available.
- [ ] Per-type anchored imports persist data/deletions and checkpoint together; crash/replay fixtures produce no duplicate intake or workouts.
- [ ] Exact source identities and confirmed matches follow the Canonical domain and sync contract. Overlap alone produces a suggestion, and accept/reject/undo decisions persist across reimport.
- [ ] App-owned nutrient exports use stable sync identifiers and increasing versions. Own-source read-back, partial saves, edits, deletion and restart do not double-count intake.
- [ ] Date-only dietary imports remain unallocated daily evidence and cannot silently fill a timed meal. Tests cover overlapping daily totals and app-created food.
- [ ] Background-delivery entitlement and launch-time observers are configured; completion is called after durable processing. Physical-device checks record requested frequency and observed behavior without asserting guaranteed delivery.
- [ ] Caffeine, if included, requests separate write permission and remains usable locally when export is denied. Physical-device evidence confirms actual exported time and quantity for each supported type.
- [ ] Tests cover midnight, DST, travel, source deletion and no raw HealthKit data in any outbound payload or diagnostic log.

### #13 Supabase foundation

- [ ] Document and enforce the server data allowlist, including imported calendar snapshots and permitted plan outputs; Health samples, source UUIDs, anchors and detailed Health-derived records stay local.
- [ ] RLS and grants cover every exposed table and view. SQL tests exercise anon and two users for read/insert/update/delete, owner reassignment and cross-owner parent references.
- [ ] Client APIs cannot read credentials, encrypted credential columns, Vault secrets/decrypted views or privileged helper outputs. OAuth and APNs secrets remain server-side.
- [ ] Versioned mutation RPCs persist operation receipts; lost acknowledgements and outbox replay apply each operation once. Stale edit/edit conflicts are visible; delete beats stale edit; restore is explicit.
- [ ] A designated calculating/exporting device and fencing epoch control plan publication. A secondary device may sync app-created input but cannot overwrite plans; takeover rejects stale publications.
- [ ] Apple authorization code exchange stores a revocable Apple token bound to the verified account. Tests cover missing/exchange-failed credentials without conflating them with a Supabase session.
- [ ] Account-deleting state blocks further writes and ingestion. Token refresh is serialized and rotation is atomic.
- [ ] Existing scripts/verify.sh supabase SQL/RLS and Deno requirements remain; offline/reconnect tests include deletion and authority conflicts.

### #14 Intervals.icu

Replace the “within minutes” goal and first criterion with:

- [ ] Launch, foreground entry, reconnect and manual refresh trigger reconciliation; controlled tests start a request within 2 seconds and render within 10 seconds when fixture services respond within 5 seconds. Background delivery has no latency guarantee.
- [ ] Show last successful provider reconciliation separately from last attempt, webhook receipt and plan calculation; failed refresh retains a visibly stale plan.
- [ ] Authenticate webhooks using the documented JSON shared secret over HTTPS before processing events. Reject wrong/missing secrets and unknown/inactive athletes; redact the secret from logs.
- [ ] Durable receipts and current-state reconciliation handle duplicate, delayed, reordered and replayed CALENDAR_UPDATED batches without duplicate demands or stale resurrection.
- [ ] Scope every event ID to the connected athlete, preserve overrides/hides across reimport, and distinguish confirmed deletion from moved-out-of-window or incomplete fetch results.
- [ ] A confirmed plan/completion link counts as one demand. Cancellation preserves completed activity and logged intake.
- [ ] Moving/cancelling a processed session repairs future reminders. The UI and verification report explicitly cover stale local reminders when iOS cannot wake the app; notification taps reconcile before showing a current plan.
- [ ] Expired/revoked authorization shows Reconnect after applicable provider recovery fails; backoff respects provider limits. Existing bounded coach-carb override criterion remains.

### #15 Food logger

- [ ] Each app-created entry has a stable UUID, consumed instant, original zone/date and revision. Saving local data and its sync/export intents is crash-safe.
- [ ] Explicit user edits correct logged food; automatic plan revisions never change it. Totals count an entry once even when a meal serves multiple fueling purposes.
- [ ] App save, server sync and Health export have distinct status. Partial or denied Health export never loses a locally saved meal.
- [ ] Export retry/read-back/edit/delete fixtures do not duplicate nutrient totals; third-party daily aggregates are not silently added to overlapping own intake.
- [ ] Offline edits/deletes survive relaunch; concurrent conflicts and Undo follow the canonical version/tombstone rules. Existing logging-speed, units and barcode criteria remain.

### #18 Week and quick-add

Replace “Imported and manual sessions can be edited and deleted” with:

- [ ] Manual sessions support Edit/Delete. Imported sessions support local overrides and Hide/Restore, clearly labelled as changes in this app only.
- [ ] Hidden imported identities remain suppressed after refresh, reconnect and repeated webhook delivery; a new upstream event ID does not silently inherit another event's identity.
- [ ] Provider changes preserve overrides and show differences; clearing an override returns to the latest source value.
- [ ] Hide/delete/restore recomputes future targets and repairs reminders when processed, without changing consumed meals or deleting linked completed evidence.
- [ ] Quick-add stores date/time zone explicitly and tests midnight/DST boundaries. Existing screen and tap-count requirements remain.

### #21 Connections

- [ ] Show per-source last attempt, last successful check, stale/offline/reconnect status and plan calculation time; a push receipt is not a successful sync.
- [ ] Show the designated calculating phone and secondary-device “Waiting for plan update” state; takeover explains offline old-device limits.
- [ ] Matching review shows sources, rationale and provisional inclusion; confirm/reject/undo survives reimport and updates only future targets.
- [ ] Health empty reads use permission-neutral wording. Imported nutrition timing/coverage uncertainty and blocked Health exports are discoverable.
- [ ] Weight “delete” is labelled ignore/hide in this app for externally owned samples; it persists without claiming to delete the source's Health data.
- [ ] Errors appear after a failed attempted sync within its timeout; no promise of a periodic background cycle. UI checks cover offline, expired token and unresolved matching states.

### #23 Account deletion

- [ ] Authenticated deletion is idempotent and immediately blocks new sync, provider ingestion and plan publication; retry cannot recreate data.
- [ ] Use a valid stored Apple access/refresh token for revocation, preserve only the minimum private retry material until the documented deadline, then remove it. Missing tokens do not block data deletion; provide Apple's manual-revocation fallback.
- [ ] Test interruption before/after each revoke and purge step, provider failure, missing Apple token, repeated request and still-valid old JWT.
- [ ] Purge account-owned application data, encrypted secrets, registrations and Auth identity; clear initiating-device data, outbox, Keychain and reminders. Explain offline-secondary-device and backup-expiry limits.
- [ ] Explain previously exported Health samples separately; any cleanup is limited to app-owned samples and permission failures cannot block account deletion.
- [ ] A clean signup with the same Apple ID receives no previous account data, pending operations, suppressed events or late webhook imports.
- [ ] Success evidence separates provider revocation, logical database deletion, local cleanup and any pending restricted retry material. Do not report full completion prematurely.

## 7. New issue draft: Canonical domain and sync contract

**Goal:** Make training demand, consumed intake and generated plans consistent across provider replay, Health read-back and offline edits before integrations implement separate interpretations.

**Scope:** A versioned architecture contract covering the eight domain entities, external identities, matching states/source precedence, intake coverage, authority/fencing, local/server serialization, mutation conflicts/tombstones, webhook invalidation and freshness/reminder semantics. Agree representative fixtures shared by future engine, adapters, storage and UI tests. No native implementation in this issue.

**Acceptance criteria**

- [ ] Define entity fields, IDs, units, lifecycle states and ownership for PlannedSession, CompletedSession, TrainingDemand, FoodEntry, Meal, PlanRevision, ProviderConnection and Tombstone.
- [ ] Define Intervals, HealthKit and future WHOOP identity mappings without assuming shared IDs across providers; preserve accepted/rejected/undone match evidence.
- [ ] Approve the provisional ambiguous-match behavior and test scenarios for a true duplicate, two real overlapping workouts, one plan completed, moved plan, split workout and deleted source.
- [ ] Define own Health export/read-back identity, nutrient-level partial success, edit/delete/retry and account-switch behavior.
- [ ] Define timed versus date-only nutrition and overlapping aggregate coverage so consumed totals never silently double-count or invent meal timing.
- [ ] Approve one calculating/exporting phone, secondary-device behavior, online takeover, epoch fencing and the unavoidable offline old-device limits.
- [ ] Define explicit sync allowlists, conflict resolution, durable outbox/receipts, tombstone retention and account deletion barriers.
- [ ] Define immutable plan revisions with engine/rules/config versions, input watermark, authority epoch and freshness; older results cannot replace newer accepted plans.
- [ ] Approve foreground budgets, best-effort background wording and the stale-reminder policy, including #19's changed acceptance contract.
- [ ] Map the test matrix in this report to future unit, integration and physical-device evidence; amend dependent issue descriptions before implementation begins.

**Verification:** independent review of the contract and synthetic scenario walkthroughs. No successful bootstrap CI run counts as device or integration evidence. If tracked as paperwork, follow AGENTS.md's no-branch paperwork path; otherwise apply the normal issue workflow when implementation starts. This draft is not a created issue.

**Dependencies and consumers:** review with #10 scaffold; contract precedes #12/#13/#14/#15/#18/#19/#21/#23 implementation and informs #11 engine and #25 WHOOP. No new service or dependency is proposed.

## Decisions required and verification limits

Approve: single calculating/exporting phone; provisional candidate inclusion; imported nutrition coverage policy; Hide versus upstream deletion; 24-hour reminder horizon with acknowledged stale delivery; Vault; lifetime tombstones; and bounded deletion/revocation retry retention. These defaults are intentionally explicit so implementation does not make conflicting silent choices.

Not verified: native app behavior; actual HealthKit permissions/background delivery on supported devices; signed entitlements; MFP/Cronometer export metadata or coverage; accurate real-world matching thresholds; approved Intervals OAuth configuration, delivery retries, secret rotation and rate allowance; exact provider timezone/deletion lookup semantics; WHOOP live identifiers/Health linkage/cache behavior; Supabase deployed roles/policies/secrets; Apple token exchange/revocation on a test account. No accounts were connected and no tests were run. Provider schemas and Apple docs establish available mechanisms, not end-to-end reliability. Existing legal and dietitian gates remain outside this architecture review.

## Primary documentation

- **A1** [Apple: pushing background updates](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app).
- **A2** [Apple: scheduling and cancelling local notifications](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app).
- **A3** [Apple: HealthKit background delivery, frequencies and completion](https://developer.apple.com/documentation/healthkit/hkhealthstore/enablebackgrounddelivery(for:frequency:withcompletion:)).
- **A4** [Apple: sync identifier](https://developer.apple.com/documentation/healthkit/hkmetadatakeysyncidentifier) and [sync version](https://developer.apple.com/documentation/healthkit/hkmetadatakeysyncversion).
- **A5** [Apple: Health authorization](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data), [dietaryCaffeine](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/dietarycaffeine), and [Coffee Tracker sample](https://developer.apple.com/documentation/clockkit/creating-and-updating-a-complication-s-timeline). The ClockKit article is a deprecated UI sample, used only as evidence of caffeine reads/writes, not as an app architecture recommendation.
- **A6** [Apple: anchored queries and deleted objects](https://developer.apple.com/documentation/healthkit/executing-anchored-object-queries).
- **A7** [Apple TN3194: account deletion and token revocation](https://developer.apple.com/documentation/technotes/tn3194-handling-account-deletions-and-revoking-tokens-for-sign-in-with-apple).
- **A8** [Apple: BGAppRefreshTask](https://developer.apple.com/documentation/backgroundtasks/bgapprefreshtask) and [earliestBeginDate](https://developer.apple.com/documentation/backgroundtasks/bgtaskrequest/earliestbegindate?changes=_4).
- **I1** [Intervals.icu maintainer: API Integration Cookbook, webhooks](https://forum.intervals.icu/t/intervals-icu-api-integration-cookbook/80090).
- **I2** [Intervals.icu maintainer: downloading planned workouts](https://forum.intervals.icu/t/downloading-planned-workouts-from-the-api/93737).
- **W1** [WHOOP: webhook v2 identifiers and signatures](https://developer.whoop.com/docs/developing/webhooks/).
- **S1** [Supabase: RLS, grants and views](https://supabase.com/docs/guides/database/postgres/row-level-security).
- **S2** [Supabase: Vault and decrypted-view privileges](https://supabase.com/docs/guides/database/vault).
- **S3** [Supabase: Edge Function secrets](https://supabase.com/docs/guides/functions/secrets).
