# Design: Personalized Nutrition (fueling app)

The locked system. Every Hallmark run reads this first and every screen shares it. Change it on purpose; the file is the rule. Screens: [`docs/design/mockups.html`](docs/design/mockups.html). Audit of the wireframes: [`docs/design/2026-10-22-hallmark-audit.md`](docs/design/2026-10-22-hallmark-audit.md).

## System

- Genre: modern-minimal
- Shape of the first page: app screen (iOS, iPhone 17 at 402 × 874 pt)
- Theme: Ultraviolet, dealt 1/3 (seed `ios-sports-nutrition-app-49e8·9a602e21·2026-10-22·r0`). Vibe: "race-day clarity, every gram explained"
- Axes: light/geometric-sans/cool · posture: restrained (the violet marks the action, the selection and progress, nothing else)
- Modes: light (lavender) and dark (night), from one token set; the hue never moves between modes
- Kept from the theme: the palette, Outfit over Onest, pill controls, 16 pt wells, hairline rows. Not kept: the all-lowercase voice. Labels are engine output and brand names (Intervals.icu, WHOOP), so they stay as written.

## Beta scope

- Beta (free): the core loop (plan, suggest real food, log, revise only the meals still to come) and meal ideas.
- After beta: Goal weight, Caffeine, the seven-day Week overview, food search and the barcode scanner, and subscriptions. Their frames stay in the mockups as the later design; each caption carries an "After beta" tag. The tag is a note on the sheet, not app UI.

## Example day

Every screen draws one Tuesday from engine v1, which uses the ACSM guideline bands only (the kJ-based carb-cost estimate is deferred). Numbers on different screens must add up to it.

- A 70 kg cyclist. Threshold 3×12 ride 17:30–19:15 (1 h 45, planned 1,250 kJ, IF 0.82), not key; the next session is more than 8 h away.
- Day: 560 g carbs, the middle of 6–10 g/kg, GREEN. Pre-ride snack 70 g at 15:30. During 55.5 g/h, about 97 g. Breakfast, lunch and dinner 131 g each (70 + 97 + 393 = 560).
- Protein 112 g (1.6 g/kg), 28 g at each of the four meals; 21 g of dinner's 28 g is the recovery protein (0.3 g/kg). No fat target and no calories until the engine has an energy baseline.
- Today at 14:20: breakfast and lunch logged as planned, so 262 g carbs and 56 g protein are eaten. Reminders: 15:30 snack, 17:25 bottles, 19:30 for the 19:45 dinner.
- Other days: rest 210 g (RED); up to 1 h 420 g (AMBER); over 1 h up to 4 h 560 g (GREEN); over 4 h 700 g (GREEN). A rest day before a long ride takes 70 g from that ride day: Wednesday 280 g (AMBER), Thursday 490 g.
- On target: a meal is on target when each macro is within 5 g or 10% of its target, whichever is larger; a day when it is within 10 g or 5%. Outside that, say the difference plainly ("Carbs 26 g above the target") with no check and no warning. The tolerance is a proposal waiting on dietitian sign-off.

## Tokens

[`docs/design/tokens.css`](docs/design/tokens.css) is the source of truth: light values on `:root`, dark on `[data-mode="dark"]`. The roles:

```css
:root {
  --color-paper: oklch(95% 0.02 300);  --color-paper-2: oklch(92% 0.03 300);  --color-paper-3: oklch(89% 0.035 300);
  --color-ink: oklch(18% 0.02 300);  --color-ink-2: oklch(28% 0.03 300);  --color-muted: oklch(46% 0.05 300);  --color-rule: oklch(84% 0.04 300);
  --color-accent: oklch(50% 0.25 290);  --color-accent-ink: oklch(97% 0.01 300);  --color-focus: oklch(50% 0.25 290);
  --color-code-green: oklch(69% 0.1 182);  --color-code-amber: oklch(85% 0.13 82);  --color-code-red: oklch(45% 0.17 28);
  --font-display: "Outfit", ui-sans-serif, system-ui, sans-serif;  --font-body: "Onest", ui-sans-serif, sans-serif;
  --radius-card: 16px;  --radius-pill: 999px;  --rule-hair: 1px;  --shadow-card: 0 1px 2px oklch(18% 0.02 300 / 0.06);
}
```

The spacing scale, the type steps, the easings and the durations are in `tokens.css`.

## Fonts

| Face | Weights used | Role | Licence |
| --- | --- | --- | --- |
| Outfit (Smartsheet Inc, Rodrigo Fuenzalida) | 300, 500 | Titles, labels, controls, figures | SIL Open Font License 1.1 (google/fonts `ofl/outfit`) |
| Onest (Dmitri Voloshin, Andrey Kudryavtsev) | 400 | Body and secondary text | SIL Open Font License 1.1 (google/fonts `ofl/onest`) |

Both faces may be bundled in the app binary. Ship `OFL.txt` with them and don't sell the fonts on their own. Three weights in total.

## Carb codes (semantic, never decorative)

- Each code is a tag with three parts: the fill, a level glyph (three bars: filled bars for the level, outlined bars for the rest, 3/2/1 for GREEN/AMBER/RED) and the word. Never the colour alone.
- Two weights: the filled tag for a day (Today's header, Week, Goal weight, the legends) and a quiet tag for a meal. A meal shows its tag only when its code differs from the day's code. The quiet tag is the code colour mixed 32% into paper, the word and bars in ink, with a 1 pt hairline of the code colour mixed 60% into ink.
- The colours mean the carb code and nothing else. Success is ink plus a check. Sync warnings are ink plus a triangle. Toggles, progress and selection use the violet, which sits at hue 290 and is never mistaken for a code.
- Text contrast on the filled tag (WCAG 2): GREEN 7.13:1 light, 7.82:1 dark. AMBER 11.82:1 light, 14.28:1 dark. RED 7.43:1 light, 4.68:1 dark. Quiet tag, ink on the tint: GREEN 12.72 / 9.83, AMBER 14.73 / 7.85, RED 9.53 / 11.38 (light / dark). All pass AA.
- Luminance step GREEN/AMBER: 1.66 light, 1.83 dark (at least 1.4 in both modes).
- Colour blindness: GREEN leans blue-green, so under deuteranopia it reads grey-blue while AMBER reads yellow and RED reads dark olive. Luminance steps under deuteranopia: light AMBER/RED 4.57, GREEN/RED 2.48, GREEN/AMBER 1.85. Dark: 2.77, 1.38, 2.01. The low pairs (dark GREEN/RED most of all) rely on hue (grey-blue against olive), the bar glyph and the word.

## Controls

- Primary: violet fill, `--color-accent-ink` text, capsule, 44 pt (50 pt full width). One per screen.
- Secondary: 1.5 pt ink stroke, capsule, same heights. Text actions are violet text with no arrow; chevrons only mark rows that navigate.
- Every hit target is 44 pt or more. Chips and the unit menu are 36 pt tall, and text actions inside rows (Review, Try again) are 24 pt tall; their hit areas extend to 44.
- Logged meals show a check, "logged" and a lock. The lock means a plan update won't change the meal; you can still edit it. VoiceOver reads "logged, kept when the plan updates". Calories stay hidden until the one global "Show calories" switch in Profile is on; Today has no calorie row.
- Segmented controls use the system look: a `Paper3` track, the selected segment on `SegSelected` with ink text and a soft shadow, never a violet fill. A change applies at once (no Save).
- Progress tracks are `Paper3` with a 1 pt `Rule2` stroke (2.97:1 on light paper, 2.51:1 on dark).
- Outfit Light (300) only at Title 3 (20 pt) and up. Figures at Callout or Body size use Outfit Medium.
- Rule lines end with their source after a single middle dot ("· ACSM 2016"). Text actions never carry an arrow; a trailing chevron icon marks navigation, including a link that leaves the app ("Find one").
- A badge (violet, count) sits on the Profile tab while a connection needs attention; the Profile hub repeats it as "1 needs attention".
- Toolbar actions: Ride plan "Edit" opens a menu (Edit time and duration, Mark as key session, Delete for a manual workout or Hide for a synced one). Goal weight "Edit" changes the goal. Log's title is a menu of today's meals plus "Snack now".
- Logging has four states. Draft: editable foods, an "Eaten at" time apart from the meal's slot, and Log meal. Saving: "Saving…", repeat taps ignored. Saved: read-only foods, the eaten and logged times, Edit meal and Delete meal. Editing: "Edit pre-ride snack", Cancel, and Save changes, which updates the same meal ("Meal updated"). A failed save keeps the entries: "Couldn't save this meal. Your entries are still here." with Try again.
- After logging, an inline confirmation at the top of the saved meal says what was logged and offers Undo and Dismiss. It has no timer. Offline it says "Saved on this phone, syncs later"; that is a saved meal, not an error.

## Increase Contrast

With Increase Contrast on (`colorSchemeContrast == .increased`):
- hairlines use `Rule2` instead of `Rule`;
- progress tracks fill with `Rule2` at 40% under the stroke;
- quiet tags mix the code colour 60% into paper. Their text stays ink (light 10.13 / 13.49 / 5.56; dark GREEN 5.04, RED 7.06), except dark AMBER, which takes `CodeAmberInk` (4.83, where ink would be 3.23).

## AX sizes

At accessibility sizes (`dynamicTypeSize.isAccessibilitySize`) the layout reflows. The mockups draw Today at AX3 (Body 40, Title 1 48, Footnote 33); the app supports every size up to AX5:
- every screen scrolls, and no text is capped, truncated or shrunk to fit;
- buttons and source citations wrap;
- the stat trio goes single column;
- timeline rows put the time above the row;
- the pace picker becomes four checkmarked rows with the full "of body weight a week" label;
- sheets open at the large detent, and their form scrolls between the header row and Save;
- Week and Goal rows stack: day and tag on one line, then workout and grams;
- the Today header uses `ViewThatFits` (date and code tag in one row, else stacked);
- the readings grid becomes a list;
- the caffeine chart's x-axis strides every 12 h, and its labels move to an event list under the chart;
- the tab bar keeps its size and relies on the large content viewer.

## Motion

Quick and dry: 120 ms colour and press feedback, 220 ms for the switch knob, nothing on load, nothing looping. With Reduce Motion on, every change lands at once.

## States

Every data region has loading, empty and error states. The mockups draw one of each (marked *drawn*); the rest are specified here.

| Region | Loading | Empty | Error |
| --- | --- | --- | --- |
| Today: targets and timeline | *drawn*: skeletons shaped like the plan | No plan yet: "Add a workout or mark a rest day" | Plan couldn't update: keep the last plan, say when it was made, Retry |
| Today: Next up | Skeleton card | Nothing left today: the card hides | Uses the timeline's error |
| Ride fueling plan | Skeleton lanes | n/a (opened from a planned ride) | Workout removed upstream: say so, back to Today |
| Week | Skeleton rows | Never empty: every day gets a target | *drawn*: Intervals.icu unreachable, cached plan stays, Try again |
| Log: food search | Spinner in the field's right slot | No match: offer Quick add macros | Offline: search saved foods only, say so |
| Log: meal items | n/a | Nothing added: Recents leads | Save failed: keep the entries, Retry |
| Meal ideas | Skeleton cards | *drawn*: no idea passes the filters, offer to drop the soft one | Couldn't load ideas: Retry |
| Connections | "Checking…" per row | None connected: link to Connect your data | Per source, as drawn for WHOOP (Sign-in expired, Reconnect) |
| Connect your data | Connect button busy | n/a | Connection refused: say which, Try again |
| Log: save | *drawn*: "Saving…", repeat taps ignored | n/a | *drawn*: "Couldn't save this meal. Your entries are still here." Try again. Offline is not an error: "Saved on this phone, syncs later" (*drawn*) |
| Why today's targets | Skeleton sections | n/a (always opened from a plan) | Plan couldn't update: keep the last plan, say when it was made |
| Goal weight | Skeleton stats and week rows | *drawn*: "Set a goal weight" | Fewer than 3 weigh-ins this week: keep last week's targets, say why. *Drawn*: goal paused after 2 weeks of low intake against training |
| Profile | n/a | n/a | A connection needs attention: badge on the tab and the row |
| Caffeine | Skeleton chart | Nothing logged: flat line, "No caffeine today" | Couldn't model: show doses as a list |

## SwiftUI mapping

**Colours → asset catalog** (Any / Dark appearances, sRGB; * means the OKLCH value is outside sRGB and was clipped, so use Display P3 for the exact value):

| Token | Asset | Light | Dark |
| --- | --- | --- | --- |
| `--color-paper` / `-2` / `-3` | `Paper`, `Paper2`, `Paper3` | #F0ECFA, #E7E1F6, #DED6EF | #090811, #100F1B, #181625 |
| `--color-ink` / `-2` | `Ink`, `Ink2` | #131019, #2B2636 | #E8DFFC, #C2B7DA |
| `--color-muted` | `Muted` | #5C5270 | #9E90B8 |
| `--color-rule` / `-2` | `Rule`, `Rule2` | #CEC5E1, #8F83B8 | #28253B, #534B76 |
| `--color-accent` / `-deep` / `-soft` | `Accent`, `AccentDeep`, `AccentSoft` | #6B2AE3, #571DBC, #D4C7FF* | #783FF5, #6527D7, #403267 |
| `--color-accent-ink` | `AccentInk` | #F6F4FB | #F6F4FB |
| `--color-focus` / `--color-link` | `Focus`, `Link` | #6B2AE3, #6B2AE3 | #8A63FE, #AF97FF* |
| `--color-seg-selected` | `SegSelected` | #F9F7FD | #2D2B3E |
| `--color-error` / `--color-success` | `Error`, `Success` | #BE2323, #131019 | #EF675C, #E8DFFC |
| `--color-code-green` / `-ink` | `CodeGreen`, `CodeGreenInk` | #45B0A0, #131019 | #49B3A3, #090811 |
| `--color-code-amber` / `-ink` | `CodeAmber`, `CodeAmberInk` | #F8C562, #131019 | #FCD583, #090811 |
| `--color-code-red` / `-ink` | `CodeRed`, `CodeRedInk` | #9E1614, #F6F4FB | #CE5247, #090811 |

**Type steps** (sizes are the default Large content size; `relativeTo:` makes them scale with Dynamic Type; bundle static instances and confirm their PostScript names):

| Token | Size | Use | SwiftUI |
| --- | --- | --- | --- |
| `--text-large-title` | 34 | Carbs-eaten figure | `Font.custom("Outfit-Light", size: 34, relativeTo: .largeTitle)` |
| `--text-title-1` | 28 | Screen titles | `Font.custom("Outfit-Medium", size: 28, relativeTo: .title)` |
| `--text-title-2` | 22 | Long titles, targets | `Font.custom("Outfit-Medium", size: 22, relativeTo: .title2)`; figures `Outfit-Light` |
| `--text-title-3` | 20 | Smaller targets, week grams | `Font.custom("Outfit-Light", size: 20, relativeTo: .title3)` |
| `--text-headline` | 17 | Row and section titles | `Font.custom("Outfit-Medium", size: 17, relativeTo: .headline)` |
| `--text-body` | 17 | Body, fields, back link | `Font.custom("Onest-Regular", size: 17, relativeTo: .body)` |
| `--text-callout` | 16 | Subtitles | `Font.custom("Onest-Regular", size: 16, relativeTo: .callout)` |
| `--text-subheadline` | 15 | Times, chips, meters, row text | `Font.custom("Outfit-Medium", size: 15, relativeTo: .subheadline)`, or `Onest-Regular` for prose |
| `--text-footnote` | 13 | Details, rules, code tags | `Font.custom("Onest-Regular", size: 13, relativeTo: .footnote)`; tags `Outfit-Medium` |
| `--text-caption` | 12 | Tab labels, step label | `Font.custom("Outfit-Medium", size: 12, relativeTo: .caption)` |

Figures that compare take `.monospacedDigit()`. Whether Outfit and Onest ship tabular figures hasn't been checked yet; check before relying on column alignment.

**Radius and spacing:** wells and groups 16 (`RoundedRectangle(cornerRadius: 16, style: .continuous)`), tiles 10, image slots 12, controls and tags `Capsule()`. Spacing steps 2, 4, 8, 12, 16, 24, 40, 64; screen margin 16; hit target 44; controls 44 and 50; Toggle at the system 51 × 31.

**Components → views:**

| Component | SwiftUI |
| --- | --- |
| Carb code tag | `CarbCodeTag(code:)`: `HStack { LevelBars(level:); Text(code.word) }` on `Capsule().fill(Color("CodeGreen"))` |
| Level glyph | `LevelBars`: three `RoundedRectangle`s, filled for the level and stroked with a 1 pt outline for the rest (never faded), as in Carb codes. Hidden from VoiceOver; the tag reads "GREEN, high carb day" |
| Targets (carbs, protein) | `ProgressView(value:total:)` with a capsule `ProgressViewStyle` tinted `Accent`. No fat meter until the engine has a fat target. One VoiceOver element per nutrient: "Carbs, 262 of 560 grams, 298 to go". The fill stops at full; the numbers still say how far over |
| Next up | `VStack` of title, time, targets and two `Button`s (Log it, Ideas) that VoiceOver reaches one by one; at AX sizes the buttons stack; the countdown isn't announced as it changes |
| Fuel timeline | `LazyVStack` of `TimelineRow`; the ride row is a `NavigationLink` on an `AccentSoft` background. VoiceOver reads time, meal, targets or what was eaten, and "logged" |
| Ride lanes | `Grid` with one `GridRow` per lane (time rail, target, rule line with SF Symbol `ruler`) |
| Grouped rows | `List` `.insetGrouped` with `listRowBackground(Color("Paper2"))`, or a `VStack` with `Divider()` |
| Switch | `Toggle(isOn:)` `.tint(Color("Accent"))` |
| Filter chips | `Toggle` with `.toggleStyle(.button)` in a capsule style; locked diet chips are disabled, with `lock.fill` |
| Primary / secondary button | `.buttonStyle(.borderedProminent)` / `.bordered`, `.buttonBorderShape(.capsule)`, `.controlSize(.large)` |
| Tab bar | `TabView` with four `Tab`s, `.tint(Color("Link"))`; on iOS 26 the system draws the floating glass bar this capsule stands in for |
| Back link | `NavigationStack` back button, tinted `Link` |
| Food search and scanner | `TextField` in a capsule (or `.searchable`) plus a `Button` with `barcode.viewfinder` |
| Amount and unit | `TextField` with `.keyboardType(.decimalPad)` and a `Menu` or `Picker(.menu)` |
| Recipe card | `NavigationLink` with an `AsyncImage` in the 72 pt slot |
| Loading, empty, error | `.redacted(reason: .placeholder)` skeletons, `ContentUnavailableView`, an inline notice with Retry |
| Stat trio (Now, Goal, to go) | `Grid` of three `LabeledContent` columns parted by `Divider()` |
| Pace picker | `Picker(selection:)` with `.pickerStyle(.segmented)` in the system look (not tinted), one line per segment; the footnote says "0.5% (recommended)"; a change applies at once. At accessibility sizes, four checkmarked rows with the full label instead |
| Daily plan rows | The Week row: `CarbCodeTag` plus words ("Lighter", "Hard day: fuel in full"); with Show calories on, "500 kcal under maintenance" |
| Caffeine curve | Swift Charts: `AreaMark` + `LineMark` (`Accent`) from the Bateman model sampled every 5 min; `RectangleMark` for the ride window (`AccentSoft`); `RuleMark` for last caffeine (dashed) and bedtime; `PointMark` for doses; `.accessibilityChartDescriptor` for VoiceOver |
| Curve readings | `Grid` of time and mg pairs under the chart, the same values VoiceOver reads |
| Caffeine card on Today | `NavigationLink` holding a sparkline `Chart` (axes hidden), the total and a warning tag |
| Warning tag | `Label("Gel after last caffeine", systemImage: "exclamationmark.triangle")` on a `Paper3` capsule, ink text, never a code colour |
| Tab roots | Each tab is a `NavigationStack` with a large `.navigationTitle`; pushed screens use the inline title |
| Profile hub | `List(.insetGrouped)` of `NavigationLink`s, the global `Toggle("Show calories")`, a footer `Text`; `.badge(1)` on the Profile `Tab` |
| Code header link | `NavigationLink` wrapping `CarbCodeTag` and the day label, with a chevron, opening Why today's targets |
| Why today's targets | A pushed `ScrollView` of sections: summary (targets, the reason, the plan's time), the day's sessions as `NavigationLink`s, the rule lines with sources, the meal split as `TimelineRow`s, looking ahead, and inputs. Opened from the code header link, a Week day and the session's Why row; back returns to where it came from |
| Toolbar menus | `ToolbarItem(placement: .topBarTrailing) { Menu("Edit") { … } }`; Log's title is a `Menu` in `.toolbarTitleMenu` |
| Quick-add workout | `.sheet` with `.presentationDetents([.medium, .large])`: segmented `Picker`s for sport and effort, `DatePicker` for start, a duration `Picker`, Save. Large at accessibility sizes; the form scrolls and Cancel and Save stay visible |
| Log confirmation | An inline `HStack` at the top of the saved meal with Undo and Dismiss, not a timed overlay. It stays until dismissed and is announced once with `AccessibilityNotification.Announcement` |
| Goal sheet | `.sheet` with a decimal `TextField` (kg), the pace `Picker`, inline validation text and the eligibility notice; the form scrolls |
| Caffeine readings | Each time-and-mg reading is its own element ("22:30, 63 mg"), not one long utterance; the chart carries `.accessibilityChartDescriptor` built from the same samples |
| Quick-add caffeine | A row of `Button`s in a capsule style (Coffee, Espresso, Tea, Gel) |
| Icons | SF Symbols: `chevron.left/right/down`, `lock.fill`, `checkmark`, `exclamationmark.triangle`, `arrow.triangle.2.circlepath`, `magnifyingglass`, `barcode.viewfinder`, `plus`, `heart`, `ruler`, `scope`, `calendar`, `plus.square`, `person` |

## Caffeine model

The curve is computed, never drawn by hand. One-compartment Bateman model, summed over doses: A(t) = D·ka/(ka−ke)·(e^(−ke·t) − e^(−ka·t)), ke = ln2 / half-life (5 h by default, adjustable 3–10 h), ka = 6.0 h⁻¹ (peak about 39 min after a dose). Last call = bedtime − 8.8 h for coffee-sized doses (Gardiner et al. 2023).

## Exports

`docs/design/tokens.css` and `docs/design/base.css` in this project. The asset catalog is built from the table above.
