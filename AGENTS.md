# AGENTS.md

## What this is

An iOS sports-nutrition app for endurance athletes. It reads planned workouts (Intervals.icu first) and Apple Health data, and a deterministic rules engine sets carb and protein targets around each workout. The research behind the fueling rules is in [`docs/research/2026-10-22-fueling-app-research.md`](docs/research/2026-10-22-fueling-app-research.md), and the screens are in [`docs/research/2026-10-22-wireframes.html`](docs/research/2026-10-22-wireframes.html). This is a solo project: keep tooling and dependencies to what is listed here.

## Stack and layout

- **iOS app:** Swift 6 and SwiftUI, SwiftData (offline-first), HealthKit, StoreKit 2, Sign in with Apple, local notifications.
- **Rules engine:** `FuelingEngine`, a pure-Swift package with no UI or Apple-only framework dependencies, so its tests run on Linux.
- **Backend:** Supabase: Postgres with row-level security, Auth, Edge Functions in TypeScript/Deno, Cron.

```
App/                      Xcode project
Packages/FuelingEngine/   Swift package (rules engine)
supabase/                 migrations and Edge Functions
docs/                     research report and wireframes
scripts/verify.sh         the one verification command
```

## Workflow

1. Every feature starts as a GitHub issue (use the Feature template).
2. Create its branch: `gh issue develop <n> --name feature/<n>-<slug> --base main`.
3. Work on that branch only.
4. Open a PR whose body says `Closes #<n>` and fill in the PR template.
5. The human merges.

Rules:

- Commit or push only when asked.
- Stage by explicit path. No `git add -A`, `git add .` or `git commit -a`. Check `git diff --cached --name-only` before committing.
- Never commit agent scratch: `.claude/`, `tmp/`, plans, scratch scripts.

## Verification loop

Run these steps for every issue, in order. A step is done only when its done-condition holds.

1. **Map.** Read the issue, the report section and wireframe screen it references, and the code it touches.
   Done when every acceptance criterion maps to a test or a screenshot.
2. **Build.** Implement on the issue branch and write a test for each acceptance criterion. Fueling-rule tests are table-driven "golden cases", and each case cites the §4 rule or source it checks.
   Done when every criterion has its test.
3. **Verify.** Run `scripts/verify.sh` locally, then push and let CI run on the PR.
   Done when both are green.
4. **Review.** Get an independent review of the PR diff against the issue's acceptance criteria. Fix findings on the same branch and go back to Verify.
   Done when no findings are open.
5. **Validate.** Run the app in the iOS Simulator, capture every changed screen (`xcrun simctl io booted screenshot <file>.png`, or XCUITest attachments), and compare each with the wireframe screen named in the issue. Attach the screenshots to the PR. Skip this step for changes with no UI.
   Done when every changed screen matches its wireframe or the difference is explained in the PR.
6. **Ship.** Fully check the PR template, then the human merges. Fueling-rule changes also need dietitian sign-off before a TestFlight release.
   Done when the PR is merged.

## Commands

`scripts/verify.sh` is the one command that both CI and agents run. Parts that don't exist yet are skipped with a message and exit 0.

```sh
scripts/verify.sh            # engine, app and supabase
scripts/verify.sh engine     # swift test --package-path Packages/FuelingEngine
scripts/verify.sh app        # xcodebuild test on an iOS Simulator
scripts/verify.sh supabase   # deno test in supabase/functions
```

- For `app`, override the scheme and simulator with the `SCHEME` and `DESTINATION` env vars. The scheme defaults to the Xcode project's name.
- The app's test result bundle is written to `build/TestResults.xcresult`.

## CI

`.github/workflows/ci.yml` runs on every pull request and on pushes to `main`. Each job calls `scripts/verify.sh <part>`:

- `engine` runs on Linux in the official Swift 6 Docker image, so `FuelingEngine` must not import Apple-only frameworks.
- `app` runs on macOS with Xcode 26 and uploads `build/TestResults.xcresult` as an artifact, also on failure. It only runs when something under `App/` or `Packages/` changed, or `scripts/verify.sh` or the workflow itself.
- `supabase` runs on Ubuntu with Deno.

A newer push to the same branch cancels the run in progress.

## Guardrails

- Never send raw HealthKit samples to the server. Send only derived values the feature needs.
- Secrets live in GitHub Actions secrets or Supabase secrets, never in the repo.
- No Strava API integration. Strava workouts are read through Apple Health.
- Calories are not shown by default.
- A plan update never changes a meal the athlete already logged.
- Fueling outputs must stay inside the §4 ranges of the research report. A rule or number change needs a cited test and the `needs-dietitian-review` label.
