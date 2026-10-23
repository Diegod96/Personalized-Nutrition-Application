# Personalized fueling app for endurance athletes (iOS): research findings

Researched 2026-10-22. Seven Haiku research agents covered planned workouts, food logs, completed workouts and health data, aggregators, competitors, nutrition science, and iOS/compliance. Two follow-up agents filled science gaps and checked eight key claims against primary sources. The Strava, WHOOP, Apple HealthKit and App Review wording below was checked directly against the live pages on 2026-10-22.

This is product research, not legal advice. Integration terms change often; re-check anything you build on.

## 1. Bottom line

1. **The app is feasible, but most of the named sources can't be connected directly by a solo developer today.** Apple Health has to be the backbone: Garmin Connect, WHOOP, Strava, MyFitnessPal and Cronometer all write into it.
2. **Planned workouts are the hardest input.**
   - Intervals.icu is open now and has a planned-workout endpoint plus a calendar-change webhook.
   - TrainingPeaks needs partner approval and only returns 7 days ahead.
   - Garmin reopened its developer program on 2026-10-21, but its Training API still only pushes workouts to Garmin. There's no documented way to read the calendar.
   - Calendar (ICS) feeds are a partial fallback.
3. **Strava's API is effectively off-limits for this product.** Its API Policy (effective 2026-06-01) bans using Strava data in any AI application, bans combining it with other customer data, and bans charging users for functionality related to it. Read Strava-recorded workouts from Apple Health instead.
4. **Food logs need your own logger.** MyFitnessPal and Cronometer have no open API. Their Apple Health exports lose meal identity, and MyFitnessPal's lose meal times, which pre- and post-workout recommendations need. Fuelin and Hexis both built their own loggers.
5. **Make the recommendation engine deterministic.** Published sports-nutrition guidelines give usable numbers (g/kg by training load, pre/during/post windows). Keep any LLM on-device (Apple Foundation Models), or limit it to data you're allowed to send.
   - Strava bans AI use outright.
   - WHOOP bans using its data to "create, develop, test, train, fine-tune or improve" AI systems.
   - Apple only allows HealthKit data to go to third parties that "also provide a health or fitness service to the user."
6. **Competitor gaps:**
   - planned workouts beyond TrainingPeaks
   - food logging people trust
   - removing duplicate activities
   - hydration combined with daily fueling
   - explaining why a target changed, with weight-loss safety rails
7. **Compliance is real work.** The FTC Health Breach Notification Rule likely applies to a multi-source fitness app. Washington's My Health My Data Act needs consent before collection. Have a lawyer review before launch.

## 2. Source access matrix

| Need | Source | Direct API for a solo developer | Through Apple Health | Through an aggregator | MVP verdict |
|---|---|---|---|---|---|
| Planned workouts | **Intervals.icu** | Yes. Personal API key, or OAuth once your app is approved (stays "Pending" until then). `GET /api/v1/athlete/{id}/events`, `CALENDAR_UPDATED` webhook. OAuth default 100 requests per user per day. Strava-sourced data is excluded from the API. Events carry `carbs_per_hour`, a fueling target the athlete or coach sets. Completed activities carry an estimated `carbs_used` (cycling only) and athlete-entered `carbs_ingested`. The spec also lists `carbs_used` on events, but there's no sign it's filled in for planned workouts yet. API Terms (effective 23 Oct 2025): commercial use allowed (§1); if the app displays information derived from Garmin-sourced data, it must show Garmin attribution as Garmin's brand guidelines require (§1.1). | n/a | Terra reads its plans | **Use first** |
| Planned workouts | **TrainingPeaks** | Approved partners only, "not available for personal use." Planned workouts "up to 7 days in the future." Apply at api.trainingpeaks.com/request-access; reply in 7–10 days. | n/a | Terra reads its plans | **Apply now.** Meanwhile the premium-only ICS feed gives about 14 days ahead, updated up to 24 h late, with no interval steps. |
| Planned workouts | **Garmin Connect** | No documented calendar read. The Training API "allows you to publish workouts and training plans to the Garmin Connect calendar" (push only). Program reopened 2026-10-21 (see the Garmin row below). | n/a | Terra lists Garmin provider-created plans (docs seen as excerpts only) | Not an MVP source. Ask Garmin whether approved partners can read scheduled workouts. ICS calendar feed has names and dates only. |
| Planned workouts | Apple WorkoutKit | Only returns workouts your own app scheduled | n/a | n/a | No |
| Food log | **MyFitnessPal** | Private API, approved developers only (API@myfitnesspal.com) | Writes meal summaries and most nutrients, **no timestamps**, nothing before you connect | Terra says "no provider credentials required" but doesn't say how | Import from Health as a secondary input |
| Food log | **Cronometer** | Partner-only (Everfit, Kalix, Practice Better) | Writes 13 nutrients plus other data; meal-level detail undocumented | Terra says it holds the Cronometer credentials | Import from Health as a secondary input |
| Food log | Your own logger | See §3 food databases | Write your entries to Health | n/a | **Required** |
| Completed workouts | **Strava** | OAuth, webhooks. API Policy §5.3 (no AI use, incl. "ingestion into a context window"), §5.4 (may not "combine Strava Data with other customer data for these or any other purposes"), §5.8 (no charging users for related functionality), §6.2 (7-day cache). New developers need a Strava subscription; 10 athletes before review. | Strava writes activities (type, distance, time, calories) | §5.16 bans aggregators that re-expose the API; vendors now say bring-your-own-app only | **Don't integrate directly. Read from Health.** |
| Health + workouts | **WHOOP** | Free. OAuth, v2 webhooks (recovery, sleep, workout). Recovery (HRV as RMSSD, resting HR), sleep, cycles/strain, workouts with kJ, body measurements. Tiers: Sandbox 10 members, then Build 100, Growth 1,000, Scale 5,000 (each reviewed manually), then Production. | Writes sleep and workouts/HR | Junction needs your own WHOOP app | **Integrate directly, deterministic use only** |
| Health + workouts | **Apple HealthKit** | Free, on-device. Weight, body fat, lean mass, workouts, active energy, HRV (SDNN), resting HR, sleep, VO2 max, dietary types. Background delivery at most about hourly; denied reads look identical to "no data." | n/a | All aggregators ship a HealthKit SDK | **Backbone** |
| Health + workouts | Garmin Health/Activity API | Reopened 2026-10-21 after closing in March. Three tiers:<br>• Personal: your own data only, pull.<br>• Starter: free; request form asks for the business model, 12-month user estimate and any AI/ML vendors; push only, no backfill; Activity API (JSON and FIT), Health API, Training, Courses, Women's Health.<br>• Enterprise: about $1,000 entry fee credited to per-active-user billing (DC Rainmaker; Garmin says terms are "tailored"); 1 month+ backfill.<br>Health API lists sleep, stress, Body Battery, body composition, HR; weight, HRV and resting HR aren't named. Agreement terms to clear first (see §7). | Garmin Connect writes workouts (no GPS), weight, body fat, sleep, HR, energy (its page is dated 2021) | Junction default Garmin app; Terra | Through Health for MVP. Apply for Starter at beta for FIT files (power, laps). |

Other sources, briefly:
- **Oura:** self-serve OAuth with webhooks.
- **Polar AccessLink:** open with a free account.
- **COROS:** Partner API only for established companies.
- **Wahoo:** approval-gated.
- **Withings:** needs a Withings+ subscription for the free API plan from 2026-10-12.

### Aggregators (buy vs build)

| Vendor | Notable coverage | Price floor |
|---|---|---|
| Terra | Only vendor verified to read planned workouts (Garmin, Wahoo, Suunto, TrainingPeaks, Intervals.icu). Says it handles MyFitnessPal and Cronometer access. HealthKit SDK. | $399/mo billed annually or $499/mo monthly, plus Planned Workouts add-on from $99/mo plus usage |
| Junction (ex-Vital) | Garmin (default app), Oura, Polar, Cronometer (needs partner application), HealthKit SDK. No TrainingPeaks or Intervals.icu. | $300/mo for 1–500 users |
| Sahha | HealthKit and Health Connect focus; bring your own Garmin app | $299/mo billed annually, 1,000 users |
| Validic Inform | Garmin, WHOOP, Strava (free developer tier, April 2026) | Production pricing not published |
| Open Wearables | MIT-licensed, self-hosted; you hold every provider credential | Free plus hosting |

The aggregator agent's advice holds up: don't build the gated cloud integrations yourself, start with HealthKit, and only pay for Terra if TrainingPeaks and Garmin planned workouts must be in the MVP. First get written answers from the vendor on which Garmin key it uses and how it reads MyFitnessPal.

## 3. Suggested MVP architecture

- **iOS app (SwiftUI) with HealthKit as the main data source.** Read workouts, active energy, weight, body fat, HRV, resting HR and sleep, plus dietary samples from MyFitnessPal and Cronometer.
- **A small backend**, needed because Intervals.icu, WHOOP and later TrainingPeaks require server-side client secrets, token refresh and public webhook endpoints. It also sends push reminders when the plan changes ("ride in 90 min, eat now").
- **Own food logger**, with timestamps and meal slots.
  - Free database options: USDA FoodData Central, and Open Food Facts for barcodes (ODbL share-alike licence).
  - FatSecret Platform: Premier Free for startups under $1M revenue and funding, with attribution.
  - Photo logging is paid everywhere; Passio starts at $99/mo.
  - Write your entries back to Health.
- **Rules engine** (deterministic, see §4) that turns the next 24–72 h of planned sessions into day and meal carb codes, gram targets and timing. Recalibrate energy needs from weight trend versus logged intake.
- **Meal suggestions** from a recipe library tagged by carb and protein content, picked by the rules engine. If you want natural-language phrasing, use Apple's on-device Foundation Models: iOS 26+ on Apple Intelligence devices, 4,096-token on-device context.
- **Milestones (decided 2026-10-23; they replace the earlier MVP/Next/Later phasing):**
  - P0, in parallel: provider access and the dietitian and legal reviews.
  - B0: beta scope, app and engine scaffold, data and rule contracts.
  - B1: the core loop on one device: manual workouts, own logger, rules engine, meal-ideas library, replanning that changes only future meals.
  - B2: the same loop connected: Intervals.icu, Apple Health, Supabase sync.
  - B3: the external TestFlight beta, free. It covers the core loop (plan a workout, suggest real food, log it, revise only future meals) plus the meal-ideas library.
  - A1 and L, after the beta: subscriptions, caffeine tracking, goal weight, WHOOP, TrainingPeaks once approved (ICS until then), Garmin Starter (reopened 2026-10-21, free) for richer completed-workout data, and Terra only if the gaps justify roughly $600/mo.
  - Issue-by-issue placement is in the Astra backlog review (`docs/reviews/2026-10-23-astra-2a-backlog.md`).

## 4. Recommendation engine rules (evidence)

Main source: Thomas, Erdman & Burke, ACSM/AND/DC joint position 2016, *MSSE* 48:543–568, doi 10.1249/MSS.0000000000000852.

| Scenario | Rule | Source |
|---|---|---|
| Daily carbs, light/skill day | 3–5 g/kg | ACSM/AND/DC 2016 |
| Daily carbs, about 1 h/day moderate | 5–7 g/kg | ACSM/AND/DC 2016 |
| Daily carbs, 1–3 h/day moderate-high | 6–10 g/kg | ACSM/AND/DC 2016 |
| Daily carbs, more than 4–5 h/day | 8–12 g/kg | ACSM/AND/DC 2016 |
| Day and meal carb coding | Red/amber/green = low/moderate/high carb, set by the demands of upcoming sessions. Impey "deliberately" gave no gram amounts, so map codes to the g/kg bands above. | Impey et al. 2018, *Sports Med* 48:1031, doi 10.1007/s40279-018-0867-7 |
| Pre-session, sessions over 60 min | "1–4 g/kg consumed 1–4 h before exercise." The grams aren't tied to the hours. Under 1 h out, a small easy-to-digest option (app default, not in the table) | ACSM/AND/DC 2016, Table 2 |
| During, under 45 min | Nothing needed | ACSM/AND/DC 2016, Table 2 |
| During, 45–75 min (sustained high intensity) | "Small amounts including mouth rinse" | ACSM/AND/DC 2016, Table 2 |
| During, 1–2.5 h | 30–60 g/h | ACSM/AND/DC 2016, Table 2 |
| During, over 2.5–3 h | Up to 90 g/h, multiple carb types (glucose plus fructose). 90 is a ceiling; the table sets no 60 g/h minimum | ACSM/AND/DC 2016, Table 2 |
| During, opt-in only | 120 g/h was tolerated in trained cyclists over 2–3 h; small single-lab studies, no performance outcome verified. A 2026 review says "the upper limit of CHO intake could increase from 90 to 120 g/h (at least for trained participants)," calls 120–200 g/h "not yet substantiated," and cites diminishing performance gains above about 78 g/h in recreational cyclists. | Podlogar et al. 2022 (PMC9560939); Morton et al. 2026, *J Nutr* 156:101442 (PMC13197957) |
| Post, under 8 h between two fuel-demanding sessions | 1.0–1.2 g/kg/h carbs for the first 4 h, then back to daily needs. Only for "<8 h recovery between 2 fuel demanding sessions," not before any next session. Burke 2011 and a 2025 review say there's no benefit above 1.2 (not re-checked) | ACSM/AND/DC 2016, Table 2; Burke et al. 2011; *Sports Med* 2025 review |
| Post, protein | 0.25–0.3 g/kg (about 15–25 g) within 0–2 h | ACSM/AND/DC 2016 |
| Daily protein | 1.2–2.0 g/kg, about 0.4 g/kg per meal over at least 4 meals. Women: 1.4–2.2 g/kg, higher end in the luteal phase and around menopause | ACSM/AND/DC 2016; Schoenfeld & Aragon 2018; ISSN 2023 (doi 10.1080/15502783.2023.2204066) |
| Fat | 20–35% of energy | ACSM/AND/DC 2016 |
| Fluid | 0.4–0.8 L/h, individualised; keep body-mass loss under 2% | ACSM/AND/DC 2016 |

**Energy estimates for a planned session**
- **Cycling:** kcal ≈ kJ ÷ (4.184 × gross efficiency). At 20–25% efficiency, 1 kJ of work is about 0.96–1.2 kcal, so kJ ≈ kcal works. Lab studies put gross efficiency nearer 18–21% (de Koning et al. 2012, PMID 22706941; not re-checked), so the carb-cost rule below uses 20%: 1 kJ ≈ 1.2 kcal.
- **Running, level:** 3.40 J/kg/m (Minetti et al. 2002, doi 10.1152/japplphysiol.01177.2001), about 0.81 kcal/kg/km, roughly the same at any speed. The common "1 kcal/kg/km" rule overestimates it by about 23% (0.81 is 19% below 1). Grade changes it a lot: about 18.9 J/kg/m at +45%.
- **Swimming:** about 4 kcal/kg/km for a 70 kg swimmer, from a single 1974 study. Low confidence.

**Resting energy**
- Cunningham: 1980, 500 + 22 × lean mass; 1991, 370 + 21.6 × fat-free mass. Use it when fat-free mass is known (athlete literature default).
- Otherwise use revised Harris-Benedict, or Mifflin-St Jeor (men 9.99W + 6.25H − 4.92A + 5; women −161).
- In athletes, these equations miss measured resting energy by roughly 5–16%. Recalibrate from weight trend and intake rather than trusting one equation.

**Picking a number inside each range (proposed defaults; a sports dietitian must sign off)**

The guidelines above give ranges. Hexis and Fuelin don't publish how they choose inside them. Fuelin's FAQ lists RMR, FTP and threshold pace as inputs and nothing more; Hexis says only that carb codes adapt "across a 72-hour training window." So the engine needs its own rules. These defaults stay inside the ACSM ranges and use what Intervals.icu gives us (planned kJ, duration and intensity factor, IF).

**v1 decision (2026-10-23): guideline bands only.** Every day's target is the midpoint of its ACSM band, picked by the day's training hours. Rest and light days use 3 g/kg. The proposed boundaries are rules D1–D4 in `docs/reviews/2026-10-23-astra-2b-engine.md` §2: no training 3 g/kg; up to 1 h, 5–7 g/kg; over 1 h up to 4 h, 6–10 g/kg; over 4 h, 8–12 g/kg. The exact cut-offs are app policy for the dietitian to approve. The before, during and after rules (items 3–5) still apply; the IF scale for the during rate is a window rule, not the estimator. The kJ-based session carb cost in item 1 stays documented as a deferred, low-confidence option. It isn't used until it's validated and a sports dietitian approves it.

1. **Session carb cost: how many grams the session burns (deferred estimator, not used in v1).**
   - Cycling: grams ≈ planned kJ × 1.2 kcal/kJ × carb share ÷ 4.1 kcal/g.
   - Carb share by intensity, from van Loon et al. 2001 (*J Physiol* 536:295, PMC2278845; 8 trained male cyclists after an overnight fast; plasma glucose plus muscle glycogen):

     | Intensity | Carb share of energy | Carbs burned |
     |---|---|---|
     | 40% Wmax | 46% | 1.44 g/min |
     | 55% Wmax | 51% | 2.04 g/min |
     | 75% Wmax | 76% | 3.91 g/min |

     The 46% is from the paper's results text; its Table 2 components, rounded, add up to 45%.
   - To use FTP-based IF, assume FTP ≈ 75% of Wmax (a ramp-test rule of thumb, unverified). On that assumption 40%, 55% and 75% Wmax are IF ≈ 0.53, 0.73 and 1.0. The estimator's anchors are rounded, chosen coefficients rather than exact source values: IF 0.55 → 45%, IF 0.73 → 51%, IF 1.0 → 76%. Interpolate linearly; hold at 76% above IF 1.0 (no data). This works out to about 0.13 g per kJ for easy riding, 0.15 at endurance and 0.22 at threshold.
   - Running and swimming: the cycling carb shares aren't validated for them, so they use the guideline bands only. (Level running costs about 0.81 kcal/kg/km, but there's no approved way to split that into carbs.)
   - No power (manual quick-add, strength): skip the estimate and use the middle of the ACSM band for the day.
   - Caveats: fasted men with full glycogen stores. Women look similar (Romijn et al. 2000, abstract only). After a low-carb day the table overstates carb use.
   - Benchmarks for later, not inputs: Rothschild et al. 2024 (*Sports Med*, doi 10.1007/s40279-024-02131-z) built training-load models of session carb use with a 10–14% mean error in cyclists. Intervals.icu reports carbs used for completed rides from two models (kJ-based and TSS-based, lower value wins), per a forum post. We haven't read usable equations for either.
2. **Day target.** v1: the midpoint of the ACSM band for the day (3 g/kg on rest and light days). Deferred estimator: rest-day base + today's session carb costs, clamped to the ACSM band for the day.
   - Base: 3 g/kg, the bottom of the light-day band. Hexis's webinar gives 3–5 g/kg for rest days. The dietitian tunes this.
   - 72-hour look-ahead: when tomorrow's session lasts more than 2.5 h or starts before 10:00, move up to 1 g/kg of tomorrow's pre-session carbs into this evening.
   - Carbs eaten during a session count toward the day's total, shown on their own line. Hexis's Tour de France webinar says riders get "55 - 60% of their total daily carbohydrate intake on the bike." None of the guidelines say either way.
3. **During** (sessions over 60 min):
   - 1–2.5 h: 30 g/h at IF 0.65 or below, rising linearly to 60 g/h at IF 0.85 or above. Precision Fuel & Hydration describes the same idea: "scaling toward 60g as duration and intensity increase."
   - Over 2.5 h: 60–90 g/h on the same intensity scale. The 60 g/h floor is an app choice; ACSM's "up to 90 g/h" is a ceiling, not a minimum.
   - Above 90 g/h, up to 120 g/h, only if the athlete opts in and has practised it (Morton et al. 2026).
   - Never above the athlete's own gut-trained maximum.
   - If a coach set `carbs_per_hour` on the Intervals.icu event, use it, within the same safety cap.
4. **Before** (sessions over 60 min): 1 g/kg by default. Use 2 g/kg for sessions over 2.5 h or races when the meal is at least 2 h before the start. Never more than 1 g/kg per hour of lead time, or 4 g/kg in total. This stays inside the ACSM 1–4 g/kg range and keeps the pre-session meal a realistic size. The per-hour cap is an app choice: ACSM doesn't tie grams to hours.
5. **After:** only when both the session just finished and the next one are fuel-demanding and there are less than 8 h of recovery between them (ACSM 2016, Table 2: "<8 h recovery between 2 fuel demanding sessions"), 1.0 g/kg per hour for the first 4 h (1.2 if the next session is key). Otherwise the recovery meal is its share of the day target. Protein at least 0.3 g/kg.
6. **Everything else:** day target − before − during − after, spread across the remaining meals.

**Tuesday from the wireframes, v1 (guideline bands only)** (70 kg; Threshold 3×12, 17:30–19:15, 1 h 45; 1,250 kJ; IF 0.82; pre-ride snack 15:30; breakfast, lunch and dinner; next session at least 8 h away; not a key session). The wireframes use these numbers.

| Step | Rule | Output |
|---|---|---|
| Day band | 1–4 h of training: 6–10 g/kg = 420–700 g | GREEN |
| Day target | Band midpoint, 8 g/kg | 560 g |
| Before | 1 g/kg, about 2 h before | 70 g |
| During | u = (0.82 − 0.65) ÷ 0.20 = 0.85; 30 + 30u = 55.5 g/h × 1.75 h = 97.125 g | about 97 g |
| After | Next session at least 8 h away, so no rapid refuelling; dinner gets its ordinary share | see next row |
| Breakfast, lunch, dinner | 560 − 70 − 97.125 = 392.875 g, 130.958 g each | 131 g each (70 + 97 + 393 = 560) |
| Protein | 1.6 g/kg (proposed default inside 1.2–2.0), 28 g in each of four meals. The recovery dinner's 0.3 g/kg (21 g) is part of its 28 g, not extra | 112 g a day |

The engine keeps the unrounded values and rounds only for display.

**The same Tuesday with the deferred estimator** (for reference only; not used in v1):

| Step | Rule output |
|---|---|
| Carb share at IF 0.82 | 0.51 + (0.82 − 0.73) ÷ 0.27 × 0.25 = 59.333% |
| Session carb cost | 1,250 × 1.2 × 0.59333 ÷ 4.1 = 217.07 g |
| Day target | 210 + 217.07 = 427.07 g (6.1 g/kg, inside 6–10) |
| Before | 70 g |
| During | 97.125 g |
| Breakfast, lunch, dinner | 427.07 − 70 − 97.125 = 259.95 g |

An earlier version of this example showed 426 g and about 95 g because it rounded the share to 59% and the during rate to 55 g/h before multiplying. The band-only day is about 133 g higher than the estimate because the midpoint ignores the session's planned work.

**Goal weight (proposed; after the beta; a sports dietitian must sign off)**

The athlete enters current and goal weight and picks a weekly pace. The daily energy target moves to reach the goal, MyFitnessPal-style, but inside the training rules above.

1. **Pace:** 0.25%, 0.5% (default), 0.75% or 1% of body weight per week, never more than 1 kg a week.
   - Garthe et al. 2011 (24 athletes; *IJSNEM* 21:97, PMID 21558571): lean mass rose 2.1% at 0.7% a week and was unchanged in the faster group (which achieved 1.0% a week). The authors recommend 0.7%.
   - MacroFactor's Fat-Loss Handbook gives 0.25–1% a week, with 1 kg a week as "a good 'upper limit' for most people."
   - Gaining: 0.25–0.5% a week (secondary source, not re-checked).
2. **Starting estimate:** 7,700 kcal per kg (3,500 per lb), the same constant MyFitnessPal uses (500 kcal a day per pound a week). It "consistently" overestimates loss over time (*Proc Nutr Soc* 2022, PMID 35103583), so it's only the first week's guess.
3. **Weekly recalibration (adaptive, as in MacroFactor):** every Monday, re-estimate expenditure from the 7-day weight trend and logged intake. This needs at least 3 weigh-ins and mostly complete logging that week. Otherwise the targets hold and the app says why.
4. **Where the deficit goes:**
   - None on GREEN days or the day before a key session. A key session is a race, a session the athlete marks as key, or any session over 2.5 h, the same trigger as the carb look-ahead above.
   - The weekly deficit goes on AMBER and RED days, taken from fat and non-session carbs.
   - Before, during and after carbs never shrink.
5. **Floors:**
   - **Energy availability:** no planned day below 30 kcal per kg of fat-free mass after training (IOC 2023 treats about 30 as a guide). When this floor caps the deficit, the app slows the pace and moves the projected date instead of under-fueling.
   - **Calories:** never below 1,200 (women) or 1,500 (men), MyFitnessPal's defaults.
   - **Goal weight:** no goal below BMI 18.5. This is a design default; we found no published rule for apps.
6. **Protein while losing:** about 2.0 g/kg body weight. That equals 2.3 g/kg of fat-free mass only near 13% body fat (at 30% body fat it's 2.86 g/kg FFM), so it isn't a general FFM figure. 2.3 is the low end of the 2.3–3.1 g/kg FFM in Helms et al. 2014 (PMC4033492), which the ISSN 2017 protein stand cites (secondary source, not re-checked).
7. **Eligibility and safety:**
   - No weight-loss pace for under-18s, during pregnancy, or for anyone the eating-disorder screen flags.
   - A sustained low-energy-availability flag pauses the deficit.
   - Calories stay hidden by default. The goal screen shows pace and projected date; calories appear with "Show calories." Levinson et al. 2017 found 73% of eating-disorder patients who used MyFitnessPal said it at least somewhat contributed to their disorder (PMC5700836).

Worked example (Alex, 70 kg, goal 67 kg, 0.5% a week; this week's plan from the wireframes):

| Step | Value |
|---|---|
| Requested pace | 0.35 kg a week, about 2,695 kcal a week |
| Daily cap from the energy-availability floor (fat-free mass 60.2 kg at an assumed 14% body fat; base 2,309 kcal) | about 500 kcal on each AMBER or RED day |
| This week: Mon, Fri, Sun. Wednesday is held because it's the day before Thursday's 3 h ride, which is also when its carbs are topped up | −1,500 kcal, about 0.19 kg |
| Projected goal date | about 6 Feb 2027 (21 Dec 2026 at the full pace) |
| Protein | 140 g a day |

**Caffeine (proposed; after the beta; a sports dietitian must sign off)**

1. **Logging:** caffeine comes from logged foods and from Apple Health's `dietaryCaffeine` type.
   - Food sources: USDA FoodData Central (nutrient 1057), Open Food Facts where present, and gel labels.
   - Gel labels, a snapshot to re-check before shipping: Maurten Gel 100 CAF 100, 100 mg; PF 30 Caffeine Gel, 100 mg; GU Roctane, 70 mg; SiS GO Energy + Caffeine, 75 mg.
   - Quick-add buttons for coffee, espresso, tea and gels.
2. **The curve:** caffeine in the body, in mg over 24 hours. It's a one-compartment model with first-order absorption and elimination, summed over doses.
   - Half-life defaults to 5 h. Healthy adults are typically 3–7 h; the setting is adjustable from 3 to 10 h. It's longer with oral contraceptives and in late pregnancy, and shorter in smokers.
   - Absorption is set so each dose peaks about 40 minutes after it's taken (Blanchard & Sawers 1983: peak at 29.8 ± 8.1 min).
   - Markers show each dose, the planned session window, bedtime and a "last call" line.
3. **Sleep:** Gardiner et al. 2023 (*Sleep Med Rev*, PMID 36870101) found caffeine cut total sleep by 45 minutes on average.
   - Coffee (107 mg) "should be consumed at least 8.8 h prior to bedtime," and a pre-workout serving (217.5 mg) at least 13.2 h before.
   - The app's last call is bedtime − 8.8 h for coffee-sized doses and − 13.2 h for doses around 200 mg or more. It warns when a planned or logged dose falls after last call.
   - No source gives a safe level at bedtime, so the curve shows the estimate without a pass or fail line.
4. **Performance (opt-in only):** ISSN 2021 (Guest et al., PMC7777221) found:
   - "doses of 3–6 mg/kg" improve performance, and the minimal effective dose "may be as low as 2 mg/kg";
   - "The most commonly used timing … is 60 min pre-exercise";
   - caffeinated gels and gum work, mainly in aerobic exercise;
   - "9 mg/kg" brings "a high incidence of side-effects."

   The app suggests at most 2–3 mg/kg, only when the athlete opts in, and never to under-18s or during pregnancy.
5. **Limits:** FDA: 400 mg a day for most adults. EFSA: a 200 mg single dose (about 3 mg/kg). Pregnancy: 200 mg a day (EFSA, ACOG). ISSN's 3–6 mg/kg (210–420 mg at 70 kg) is above EFSA's single dose, so the dietitian sets the app's ceiling.

Worked example (Tuesday; coffee 100 mg at 07:30, caffeinated gel 100 mg at 17:20, bed at 22:30, half-life 5 h):

| Time | Caffeine in body |
|---|---|
| 08:10 (coffee peak) | about 91 mg |
| 17:20 (gel) | 26 mg |
| 18:00 (on the bike) | 115 mg |
| 22:30 (bedtime) | 63 mg, 50 of it from the gel |

Coffee's last call is 13:42, so the app flags the gel and suggests a non-caffeinated gel, or saving caffeine for race day. The gel is also only 1.4 mg/kg, below the roughly 2 mg/kg ISSN minimum.

**Safety**
- **Low energy availability (IOC 2023 REDs consensus, doi 10.1136/bjsports-2023-106994):** the commonly used cut-off of about 30 kcal per kg fat-free mass per day is "a guide, rather than a diagnostic end-point." Flag sustained low intake against load and refer to a professional; never diagnose.
- **Screening tools:** LEAF-Q (female athletes; 78% sensitivity, 90% specificity), REDs CAT2, SCOFF.
- **Calorie tracking can harm vulnerable users.** In one study of eating-disorder patients who used MyFitnessPal, 73% said it at least somewhat contributed to their disorder (PMC5700836). Consider an onboarding screen, an option to hide calories, and a focus on carbs and timing.
- **Scope of practice:** general performance targets are wellness guidance. Plans for diabetes, pregnancy, eating disorders or other conditions are medical nutrition therapy, which US states license (my reading of the 2024 CDR/AND scope documents). Exclude or refer those users, and consider an 18+ age gate. No dietetic body publishes a specific consumer-app exclusion list.
- **Menstrual cycle:** the evidence doesn't justify changing carbohydrate grams by cycle phase.
- **"Train low":** keep periodised, low-intensity and occasional. Avoid it entirely for anyone flagged for low energy availability (Impey 2018; IOC 2023).

## 5. Competitive landscape

| App | Daily-target method | Food logging | Integrations | Price | App Store (US) |
|---|---|---|---|---|---|
| **Fuelin** (Thrive AI Labs; sports dietitians on staff) | Green/yellow/red carb meals from planned and completed workouts, RMR, FTP/threshold pace; Smart Meals (100+ recipes); meal windows; Smart Adjustments; AI chat (beta) | Own AI text/voice logger, barcode; MyFitnessPal and Lose It! through Apple Health | Planned: TrainingPeaks, TriDot, Humango, Final Surge, RunDot, V.O2, Pushing Limits. Completed: Garmin, Strava, Apple Health. TrainingPeaks' featured nutrition partner. | Autopilot $29/mo or $139/yr; Copilot (1:1 coach) $99/mo or $399/yr per App Store | 4.5 (about 1.3K) |
| **Hexis** (co-founded by Sam Impey, author of Fuel for the Work Required) | Green/amber/red "Carb Coding," adapting across a 72-hour training window; Live Energy; intra-workout fueling; Race Planner | Own logger, 1M+ foods, rebuilt Aug 2026 (Smart Log, Scan food) | Garmin (completed only), TrainingPeaks, Intervals.icu, WHOOP, Apple Health. Strava not listed on its site. | €24.99/mo or €129.99/yr on hexis.live; €16.99/mo or €109.99/yr on athlete.hexis.live | 2.7 (30) |
| Saturday | Hourly fuel and hydration from sweat rate, weather, products | Product scanning | TrainingPeaks, Intervals.icu | $7.99/mo or $69.99/yr | 4.6 (18, Canada) |
| MacroFactor | Adaptive calories/macros from intake and weight; not training-based | Strong verified database | Apple Health only | $71.99/yr | not checked |
| Garmin Connect nutrition (launched 2026-01-05) | Calorie/macro targets from profile; no meal plans | Search, barcode, camera AI, voice | Native | Part of Connect+ | n/a |
| Fuelish Pro | AI coach, race-goal plans | AI chat | Garmin | Free | not checked |

Supersapiens shut down in early 2024. WHOOP and TrainingPeaks have no meal planner of their own; they lean on other apps (TrainingPeaks syncs MyFitnessPal and partners with Fuelin).

**Common complaints**
- **Fuelin:** Runna and Garmin plans don't import; low calorie estimates for Strava-only users; duplicate Strava imports can't be deleted; slow support; one user called its weight-loss advice potentially dangerous.
- **Hexis:** poor food search, crashes and logouts, a bug that set body weight to 450 lb, barcode unreliability, price.

**Openings**
1. Planned workouts beyond TrainingPeaks (Intervals.icu is open; Runna and Garmin plans are a known pain).
2. Logging quality people trust (users pair MacroFactor with a fueling app today).
3. Deduplicating Garmin and Strava double uploads before they inflate targets.
4. Hydration and sodium combined with the daily plan.
5. Explaining why a target changed, with weight-loss guardrails.
6. Price: Fuelin and Hexis charge about $130–140/yr, MacroFactor $72/yr, and free options set a low floor.

## 6. Platform and compliance must-dos

- **HealthKit (Apple docs, checked 2026-10-22):** "You must not disclose any information gained through HealthKit to a third party without express permission from the user. Even with permission, you can only share information to a third party if they also provide a health or fitness service to the user."
- **App Review:**
  - 5.1.3: no advertising, marketing or data mining with health data, and no health data in iCloud.
  - 5.1.2(i): disclose and get permission before sharing data, "including with third-party AI."
  - 5.1.1(v): account deletion, and "An app may not store credentials or tokens to social networks off of the device." That could bite if a backend held Strava tokens, which is another reason to read Strava through Health.
  - 1.4.1: extra scrutiny for anything medical-adjacent.
  - 3.1.2: subscription rules.
- **WHOOP API Terms (effective 2026-10-06):** no using WHOOP data to "create, develop, test, train, fine-tune or improve any large language model or any other machine learning or artificial intelligence model, application, or system." No exposing it to third parties without opt-in. No permanent copies beyond the cache header.
- **FTC Health Breach Notification Rule (2024 amendments):** a fitness app that syncs trackers is "probably" a personal health record vendor. Unauthorized disclosure counts as a breach, with a 60-day notice deadline and penalties up to $53,088 per violation.
- **Washington My Health My Data Act:** consent before collecting consumer health data, and separate consent before sharing. Applies regardless of company size.
- **HIPAA:** generally doesn't apply to a consumer app. It does if dietitians who bill insurance electronically put client records into the app; then you need a business associate agreement.
- **GDPR:** for an EU launch, health data needs explicit consent (Art. 9(2)(a)).
- **Branding:** "Powered by Strava" or "Compatible with Strava" (if Strava is ever used); Garmin attribution on Garmin-derived data, including AI output, and on anything the app shows that is derived from Garmin-sourced data arriving through Intervals.icu (Intervals.icu API Terms §1.1); "Works with Apple Health" badge rules.
- **Backend HIPAA options if ever needed:** Supabase requires Team or Enterprise plus a HIPAA add-on. Google's business associate agreement covers only named Firebase/GCP products. Cloudflare and Neon are unverified.

## 7. Decisions and next steps

1. **Apply for the TrainingPeaks Partner API now.** It's the slowest gate (selective, 7–10 days to reply) and the largest source of planned workouts.
2. **Register an Intervals.icu OAuth app and a WHOOP developer app.** Both are free; Intervals.icu stays "Pending" until approved, and WHOOP starts at 10 members.
3. **Decide the AI approach.** Rules engine plus recipe library, with on-device Foundation Models for wording, is the lowest-risk path. A cloud LLM needs a consent flow and must never see Strava data, and should not see WHOOP data or HealthKit data without a clear legal read.
4. **Decide on Strava.** Recommendation: no direct integration; read Strava activities from Apple Health. If Strava matters more than that, ask developers@strava.com for a written position first.
5. **Get a privacy lawyer's read** on the FTC rule, Washington's law, Strava §5.3/§5.4 (the term "AI Application" is never defined), and WHOOP's AI clause.
6. **Apply for Garmin Starter once there's a beta.** The program reopened on 2026-10-21 and Starter is free. Have the lawyer from item 5 read the agreement first, and ask Garmin in writing about three clauses:
   - §5.2(q): you may not "combine or integrate the API with any software, technology, services, or materials, unless authorized (i) herein or (ii) by Garmin in writing." Our app combines Garmin data with other sources.
   - §5.2(t): you may not "use the API or any Garmin Brand Feature to compete with Garmin." Garmin Connect has had its own nutrition logging since 2026-01-05.
   - §4.6: Garmin may use data you send it "for any and all purposes."

   Also ask whether approved partners can read scheduled workouts.

## 8. Conflicts and things we couldn't verify

- **Garmin reopening (2026-10-21):** the closure and reopening are confirmed by DC Rainmaker and Garmin Rumors.
  - Only DC Rainmaker gives the 1,000-user Starter cap, the $1,000 Enterprise fee, and April 1, 2027 as the date existing partners start paying. Garmin's pages publish no prices and say Starter "User Capacity: Limited."
  - DC Rainmaker says Starter approval "should be virtually instant." Garmin gives no approval time.
  - Not checked: the Activity API's field list, and the Application Requirements document (rate limits, retention).
- **Hexis pricing:** its two sites list different prices.
- **Fuelin Copilot price:** comes from the App Store listing only.
- **Terra:** its planned-workout read support was seen in docs excerpts only. It doesn't explain how it reads MyFitnessPal "without provider credentials."
- **TrainingPeaks:** field list, fees, rate limits, and AI/storage terms not found. (Intervals.icu's API Terms were found and read on 2026-10-23; see §2.)
- **ACSM/AND/DC 2016 carbohydrate table:** now read in full from a hosted copy of the paper (2026-10-23), which confirmed the Table 2 rows in §4. Still not verified: the "no benefit above 1.2 g/kg/h" recovery claim from Burke 2011 and the 2025 review.
- **Day-band boundaries:** ACSM's training categories are approximate ("1–3 h/day", "more than 4–5 h/day"), so the v1 cut-offs at 1 h and 4 h are app policy for the dietitian to approve.
- **Carb-cost estimates disagree:** an Intervals.icu user reported 266 g used on a 3 h Zone 2 ride against 136 g from EatMyRide, and said Intervals.icu "seems to greatly overstate" carbs used (forum, Aug 2025). The Intervals.icu method description comes from a forum member, not the developer. Our own deferred estimator (§4 item 1) isn't validated either: the FTP ≈ 75% Wmax mapping is a rule of thumb, and van Loon measured eight fasted trained men cycling.
- **Hexis rest-day carbs:** Roadman's review reverse-engineers about 28% of rest-day calories from carbs (about 1.5 g/kg for its 82 kg example). Hexis's own webinar says 3–5 g/kg. Treat Roadman's number as unverified.
- **TrainingPeaks Fueling Insights** predicts carb and fat use for planned structured workouts (built with Iñigo San Millán). Whether the Partner API exposes it is unknown.
- **Goal weight, not verified:**
  - MyFitnessPal's full list of pace options.
  - MacroFactor's exact update rules (only help-center summaries were read).
  - Any published goal-BMI floor or app-store minimum-calorie rule.
  - The gain-rate source.
  - Helms et al. 2014's protein figures (read through a secondary source).
- **Caffeine, not verified:**
  - Any "safe" residual level at bedtime.
  - Whether HealthKit allows writing `dietaryCaffeine` (the type exists).
  - Open Food Facts' caffeine coverage and units.
  - The ISSN statement on gels taken 10 minutes before exercise (agent-quoted).
  - Gel labels, which are a snapshot.
  - The 5 h default half-life: a typical value, not a fitted one. One caffeine app uses 5.7 h.
- **Apple Health food data:** whether MyFitnessPal and Cronometer food records can be split into meals.
- **Exclusion list:** no published dietetic guidance on which users a consumer app should exclude (diabetes, pregnancy, under-18s); the recommendation in §4 is a reasoned default.
- **Not researched:** Apple Watch, widget and App Intents specifics, and Live Activities beyond the 8-hour limit.

## 9. Fuelin and Hexis complaints we can design around

Mined 2026-10-22 from Apple's public review feeds (Fuelin: about 260 reviews across US, GB, AU and CA; Hexis: 76 across GB, US, AU, CA, IE, NL and ES), Google Play (Fuelin 40 reviews; Hexis about 5 review texts out of 62 ratings), Trustpilot (Hexis, 35), the TrainerRoad and Slowtwitch forums, and release notes. Reddit blocked both scrapers, so Reddit appears only as search snippets. Counts are approximate tallies.

| # | Complaint (who) | Evidence | What we do instead |
|---|---|---|---|
| 1 | **Food logging is slow and inaccurate** (both; Hexis's top complaint) | Fuelin: about 35 reviews. Ounces logged as grams, cups-only portions, calories recalculated wrongly after edits. Hexis: about 14 database reviews and about 12 on barcodes. UK brands missing, custom foods wiped (Apr 2026), no tablespoon unit, scanner "works maybe 10% of the time." Hexis's Aug 2026 rebuild improved the interface; database complaints continued. | Fast paths first: recents, favourites, "repeat yesterday," quick-add macros. Grams, ounces and household units on every food, plus a manual calorie/macro override. Barcode lookup across Open Food Facts plus a regional database. Users can keep logging in MyFitnessPal or Cronometer and have it imported through Apple Health. |
| 2 | **Crashes, freezes, failed logins, lost data** (both) | Fuelin: about 40 reviews, about half of Google Play. Hexis: about 8 crash, 5 login and 3 data-loss reviews; account creation failed on 2026-10-16. | Native SwiftUI, offline-first local store with background sync, Sign in with Apple. The app works without a network. |
| 3 | **Paywall and billing traps** (both) | Fuelin: about 30 reviews on a long intake quiz followed by a $29/mo paywall with no trial, plus about 20 on billing and cancellation ("Good luck trying to cancel"). Hexis: about 9 (charged after cancelling, emails unanswered, at least 4 refund requests). | Free trial or a useful free tier, with value shown before payment. App Store subscriptions only, so users cancel in iOS Settings. Renewal reminders. |
| 4 | **Planned workouts don't import, or import badly** (both) | Fuelin: about 30 reviews. Runna, Garmin calendar and Intervals.icu are missing; Strava duplicates can't be edited or deleted; TrainingPeaks "polluted my workouts." Hexis: reconnecting Garmin and Intervals.icu failed (May 2026). | Intervals.icu at launch (Fuelin doesn't have it), TrainingPeaks once approved, ICS feeds and a 10-second manual "quick add" for everything else. Duplicate detection across Health sources, editable and deletable imports, and a connection-status screen that says when sync broke. |
| 5 | **Targets too low or unsafe** (Fuelin) and **bad data inflating targets** (Hexis) | Fuelin: about 12, e.g. "carb recommendations after over an hour of max effort is zero," and a TrainerRoad post calling weight-loss targets "bordering on disordered eating." Hexis: weight randomly set to 450 lb, doubling the day's calories. | Carb floors tied to session load. Capped deficits, with no deficit on hard days. Plausibility checks on weight (reject big jumps and ask to confirm). A low-energy-availability flag that refers users to a professional. Every target shows the rule behind it. |
| 6 | **The plan rewrites meals already eaten** (Fuelin), **targets jump around** (both) | Fuelin: about 10, e.g. "meals get removed after they have already been eaten," and calories drop when a ride finishes a minute short. | Logged meals are locked; changes only reflow future meals. A tolerance band so small duration differences don't move targets. A one-line reason for each change. |
| 7 | **Rigid structure** (both) | Hexis requires a scheduled workout to plan the day. Fuelin asked for custom meal windows (fixed in 2.2.3) and unscheduled snacks. | Rest days and unplanned days get a full plan. User-set meal windows and ad-hoc snacks. |
| 8 | **Recipes ignore diet and allergens** (Fuelin) | About 15, e.g. vegetarian users shown meat, and recipes containing entered allergens. | Allergens and diet are hard filters on a tagged recipe library, applied by rules, not by an AI model. |
| 9 | **Long onboarding** (Fuelin) | About 15 reviews about a 5-minute quiz, then a paywall. | Short onboarding with sensible defaults, refined as data arrives. |
| 10 | **Privacy** (Fuelin) | Its App Store privacy label (as scraped) lists usage data used to track across apps for third-party advertising. Reviewers objected to a request for an Instagram handle. | No ad tracking. HealthKit rules forbid it for health data anyway, and it makes a clean privacy label a selling point. |

**Feature requests worth taking:**
- Hydration and sodium guidance (Hexis).
- An "I felt hungry / bloated / flat" feedback button that adjusts the plan (Fuelin).
- Writing logged macros to Apple Health (Fuelin).
- Pause or holiday mode (Fuelin).
- A slower-deficit option (Fuelin).
- Data export (Hexis).
- Plant-based protein ideas (Hexis).
- Cycle-aware targets were requested (Fuelin), but the evidence in §4 doesn't support changing carb grams by phase. At most offer the ISSN protein bump.

**What users praise (keep these):** targets that adjust automatically to TrainingPeaks plans, carb guidance before and during long rides, race-prep fueling, Hexis's Live Energy view, and education and real human onboarding.

Sources: `https://itunes.apple.com/{country}/rss/customerreviews/page=N/id=1579806995/sortby=mostrecent/json` (Fuelin), the same feed with `id=1610334327` (Hexis), `https://play.google.com/store/apps/details?id=com.thriveailabs.fuelin.app`, `https://www.trainerroad.com/forum/t/does-a-genuinely-good-ai-nutrition-app-exist/104923`, `https://forum.slowtwitch.com/t/any-experience-with-fuelin-app/1288174`, and `https://roadmancycling.com/blog/hexis-review` (2026-07-28; discloses a Hexis partnership).

## 10. Recommended tech stack

Researched 2026-10-22 (vendor pricing, SDK and compliance pages). The guiding rule: the phone does the work, the backend stays thin, and as few vendors as possible ever hold health data. Each vendor is another processor agreement under Washington's My Health My Data Act and another breach surface under the FTC rule.

### iOS app (Apple frameworks, no third-party UI or state libraries)

| Need | Choice |
|---|---|
| Language and UI | Swift 6, SwiftUI |
| Local store, offline-first | SwiftData |
| Health data | HealthKit, with observer queries and background delivery |
| Fueling rules (§4) | A plain Swift package (`FuelingEngine`): pure functions, unit-tested, runs on the device |
| Login | Sign in with Apple (AuthenticationServices). Email-only or Apple-only login avoids Guideline 4.8's equivalent-login requirement. |
| Subscriptions (after the beta; the beta is free) | StoreKit 2 with `SubscriptionStoreView`. Entitlements come from `Transaction.currentEntitlements`, with no server needed at launch. |
| Meal reminders | Local notifications scheduled on the device from the day's plan |
| Optional AI wording | Foundation Models (on-device; iOS 26+, Apple Intelligence devices) |
| Later | WidgetKit, Live Activities, Apple Watch, WorkoutKit |
| Crashes and metrics | Xcode Organizer and MetricKit (free, first-party) |

### Backend: Supabase Pro ($25/mo)

One vendor covers all the backend jobs:
- **Postgres with row-level security** for accounts, food logs, plans and settings. This gives cross-device sync without iCloud.
- **Supabase Auth**, using `signInWithIdToken(.apple)` from supabase-swift (official; v2.55.4, released 2026-10-13).
- **Edge Functions** (TypeScript) for:
  - OAuth code exchange and refresh for Intervals.icu, WHOOP and later TrainingPeaks
  - their webhooks
  - APNs pushes sent directly with a .p8 key
  - the FatSecret proxy
  - Apple's token-revoke call on account deletion
- **Supabase Cron** for token refresh and nightly jobs.

It's standard Postgres, so leaving later is a `pg_dump`. Dev projects on the free tier pause after a week idle, which is fine for development.

Two gaps to build:
- **Apple token revocation on account deletion.** Supabase doesn't do it (supabase/auth issue #1308). Capture the authorization code at sign-in, exchange it for a refresh token, and call `appleid.apple.com/auth/revoke` from an Edge Function when the user deletes their account.
- **Encrypting stored provider tokens.** Use a column-level secret or Supabase Vault, plus row-level security on every table.

What the server stores: our own data (food logs, plans, settings, provider tokens). Avoid mirroring raw HealthKit samples; the engine reads them on the device.

How plan changes reach the user:
1. Intervals.icu or WHOOP sends a webhook to an Edge Function.
2. The function sends a push.
3. The app wakes, fetches the change, recomputes the plan on the device, and reschedules local reminders.

The engine stays in one place, in Swift.

### Not using now, and when to add

| Option | Why not now | Add when |
|---|---|---|
| Clerk | Supabase Auth plus Sign in with Apple already covers login. Clerk's BAA is Enterprise-only. The iOS SDK (1.6.1, 2026-10-07) has no clear GA announcement. It would be another vendor holding user identity. | Never needed unless you leave Supabase Auth. Even with Android/web, Supabase Auth adds Google sign-in. |
| Railway | No auth, cron or Swift SDK. Its Postgres is self-run, without managed point-in-time recovery. Its BAA needs a $1,000 commitment. An 8-hour platform-wide outage on 2026-05-19 after Google Cloud suspended its account (Railway's own incident report). | If you outgrow Edge Functions and need a long-running service, e.g. heavy sync workers. Fly.io or Cloud Run are the alternatives. |
| PlanetScale | Database only (no auth, functions or cron), no free tier, BAA unclear (Enterprise). Built for sharding scale this app won't need for years. | Write volume beyond a single Postgres, a long way off. |
| RevenueCat | StoreKit 2 handles iOS-only subscriptions natively. RevenueCat is free up to $2,500 monthly tracked revenue, then 1%. | Android/web, paywall A/B tests, or when the server needs subscription status and you don't want to build App Store Server Notifications V2. |
| OneSignal / FCM | APNs direct is free and needs no SDK | Marketing campaigns or multi-channel messaging |
| Sentry | Organizer and MetricKit are enough at launch. Sentry's BAA needs the Business tier. | If crash triage needs breadcrumbs. Scrub with `beforeSend` and keep health values out. |
| Product analytics | App Store Connect analytics covers launch | Aptabase (no identifiers, $10/mo for 200K events) or TelemetryDeck. PostHog only with its Boost-tier BAA. |
| Cloud LLM | HealthKit, WHOOP and Strava terms (§6) | Only with a consent screen and data those terms allow |

### Cost at launch

- Apple Developer Program: $99/yr.
- Supabase Pro: $25/mo (about $30–50/mo at 10,000 users by the research estimate).
- FatSecret Premier Free (startups under $1M) or USDA/Open Food Facts: $0.
- Everything else above: $0.

That's roughly **$25/mo plus $99/yr**. Clerk + Railway + PlanetScale would be three vendors with a floor around $45–80/mo, and you'd still have to build cron and webhooks.

### HIPAA path (only if dietitians bring client records)

Supabase Team ($599/mo) plus its HIPAA add-on (the price isn't published; a 2025 maintainer comment said about $350/mo). Or move the Postgres to Neon Scale, which includes HIPAA on usage pricing. Plan this before any dietitian feature ships.

## Key sources

- Strava API Policy, effective 2026-06-01: https://www.strava.com/legal/api_policy
- Strava developer program update: https://communityhub.strava.com/insider-journal-9/an-update-to-our-developer-program-13428
- WHOOP API Terms of Use, effective 2026-10-06: https://developer.whoop.com/api-terms-of-use/
- WHOOP app approval tiers: https://developer.whoop.com/docs/developing/app-approval/
- Intervals.icu API access (updated 2026-10-14): https://forum.intervals.icu/t/api-access-to-intervals-icu/609
- Intervals.icu API Terms and Conditions, effective 2025-10-23: https://forum.intervals.icu/t/intervals-icu-api-terms-and-conditions/114087
- ACSM/AND/DC 2016 position stand, full text (hosted copy): http://drugfreesport.org.za/wp-content/uploads/2018/04/Position-stand-on-Nutrition-Athletic-Performance-ACSM-2016-1.pdf
- Astra review of this report and the backlog (2026-10-23): `docs/reviews/2026-10-23-astra-review.md`, with the engine contract in `docs/reviews/2026-10-23-astra-2b-engine.md`
- TrainingPeaks API help: https://help.trainingpeaks.com/hc/en-us/articles/234441128-TrainingPeaks-API
- TrainingPeaks partner API update (2026-09-12): https://www.trainingpeaks.com/blog/an-update-on-trainingpeaks-partner-api/
- TrainingPeaks calendar feed: https://help.trainingpeaks.com/hc/en-us/articles/204072184-Sync-your-calendar
- Garmin Connect Developer Program: https://developer.garmin.com/gc-developer-program/overview/
- Garmin Training API: https://developer.garmin.com/gc-developer-program/enterprise/training-api/
- Garmin Connect Developer Program Agreement: https://developerportal.garmin.com/sites/default/files/Garmin%20Connect%20Developer%20Program%20Agreement.pdf
- DC Rainmaker on the reopened program (2026-10-21): https://www.dcrainmaker.com/2026/10/garmin-connect-api-revamps-connect-developer.html
- van Loon et al. 2001, fuel use by intensity: https://pmc.ncbi.nlm.nih.gov/articles/PMC2278845/
- Morton et al. 2026, carbohydrate guidelines during exercise: https://pmc.ncbi.nlm.nih.gov/articles/PMC13197957/
- Rothschild et al. 2024, predicting session carb use: https://pmc.ncbi.nlm.nih.gov/articles/PMC11985602/
- Intervals.icu carbs used and ingested: https://forum.intervals.icu/t/carb-utilisation-and-ingestion-on-activities/78676
- TrainingPeaks Fueling Insights: https://help.trainingpeaks.com/hc/en-us/articles/34580444343053-Substrate-Utilization-Fueling-Insights
- Fuelin method overview: https://fuelin.com/articles/the-magic-behind-fuelin
- Hexis Tour de France webinar Q&A: https://hexis.live/blog/fuelling-the-tour-de-france-webinar-your-questions-answered
- Garthe et al. 2011, weight-loss rate in athletes: https://pubmed.ncbi.nlm.nih.gov/21558571/
- MyFitnessPal, how initial goals are calculated: https://support.myfitnesspal.com/hc/en-us/articles/360032625391-How-does-MyFitnessPal-calculate-my-initial-goals
- MacroFactor Fat-Loss Handbook: https://macrofactor.com/wp-content/uploads/2025/11/MacroFactor-Fat-Loss-Handbook.pdf
- ISSN position stand on caffeine (Guest et al. 2021): https://pmc.ncbi.nlm.nih.gov/articles/PMC7777221/
- Gardiner et al. 2023, caffeine and sleep: https://pubmed.ncbi.nlm.nih.gov/36870101/
- Apple HealthKit privacy: https://developer.apple.com/documentation/healthkit/protecting-user-privacy
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- WorkoutKit scheduler: https://developer.apple.com/documentation/workoutkit/workoutscheduler
- MyFitnessPal API: https://www.myfitnesspal.com/apps/api/version
- Cronometer Pro FAQ: https://cronometer.com/blog/cronometer-pro-faq/
- FatSecret API editions: https://platform.fatsecret.com/api-editions
- USDA FoodData Central API: https://fdc.nal.usda.gov/api-guide
- Terra pricing: https://tryterra.co/pricing
- Fuelin FAQ: https://fuelin.com/faq
- Hexis athlete app: https://hexis.live/athlete-app
- FTC Health Breach Notification Rule guidance: https://www.ftc.gov/business-guidance/resources/complying-ftcs-health-breach-notification-rule-0
- Washington My Health My Data Act: https://app.leg.wa.gov/RCW/default.aspx?cite=19.373&full=true
- IOC REDs consensus 2023: https://doi.org/10.1136/bjsports-2023-106994
- Impey et al. 2018, Fuel for the Work Required: https://doi.org/10.1007/s40279-018-0867-7
- Minetti et al. 2002, energy cost of running: https://doi.org/10.1152/japplphysiol.01177.2001
