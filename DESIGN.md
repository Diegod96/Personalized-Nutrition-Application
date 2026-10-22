# Design: Personalized Nutrition (fueling app)

The locked system. Every Hallmark run reads this first and every screen shares it. Change it on purpose; the file is the rule. Screens: [`docs/design/mockups.html`](docs/design/mockups.html). Audit of the wireframes: [`docs/design/2026-10-22-hallmark-audit.md`](docs/design/2026-10-22-hallmark-audit.md).

## System

- Genre: modern-minimal
- Shape of the first page: app screen (iOS, iPhone 17 at 402 × 874 pt)
- Theme: Ultraviolet, dealt 1/3 (seed `ios-sports-nutrition-app-49e8·9a602e21·2026-10-22·r0`). Vibe: "race-day clarity, every gram explained"
- Axes: light/geometric-sans/cool · posture: restrained (the violet marks the action, the selection and progress, nothing else)
- Modes: light (lavender) and dark (night), from one token set; the hue never moves between modes
- Kept from the theme: the palette, Outfit over Onest, pill controls, 16 pt wells, hairline rows. Not kept: the all-lowercase voice. Labels are engine output and brand names (Intervals.icu, WHOOP), so they stay as written.

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

- Each code is a tag with three parts: the fill, a level glyph (three bars, filled 3/2/1 for GREEN/AMBER/RED) and the word. Never the colour alone.
- Two weights: the filled tag for the day (Today's header, Week, the legend) and a quiet tag for each meal on Today's timeline (a 32% tint of the code colour with the word and bars in ink), so meal names lead.
- The colours mean the carb code and nothing else. Success is ink plus a check. Sync warnings are ink plus a triangle. Toggles, progress and selection use the violet, which sits at hue 290 and is never mistaken for a code.
- Text contrast (WCAG 2): GREEN 7.13:1 light, 10.76:1 dark. AMBER 11.82:1 light, 14.28:1 dark. RED 7.43:1 light, 4.68:1 dark. All pass AA.
- Colour blindness: GREEN leans blue-green, so under deuteranopia it reads grey-blue while AMBER reads yellow and RED reads dark olive. Luminance steps under deuteranopia: light AMBER/RED 4.57, GREEN/RED 2.48, GREEN/AMBER 1.85. Dark: 2.77, 1.91, 1.45. The low pairs rely on the blue-yellow difference and on the bar glyph.

## Controls

- Primary: violet fill, `--color-accent-ink` text, capsule, 44 pt (50 pt full width). One per screen.
- Secondary: 1.5 pt ink stroke, capsule, same heights. Text actions are violet text with no arrow; chevrons only mark rows that navigate.
- Every hit target is 44 pt or more. Chips and the unit menu are 36 pt tall, and text actions inside rows (Review, Try again) are 24 pt tall; their hit areas extend to 44.
- Logged meals show a check, "logged" and a lock. Calories stay hidden until "Show calories" is switched on.

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
| Goal weight | Skeleton stats and week rows | No goal: "Set a goal weight" | Fewer than 3 weigh-ins this week: keep last week's targets, say why |
| Caffeine | Skeleton chart | Nothing logged: flat line, "No caffeine today" | Couldn't model: show doses as a list |

## SwiftUI mapping

**Colours → asset catalog** (Any / Dark appearances, sRGB; * means the OKLCH value is outside sRGB and was clipped, so use Display P3 for the exact value):

| Token | Asset | Light | Dark |
| --- | --- | --- | --- |
| `--color-paper` / `-2` / `-3` | `Paper`, `Paper2`, `Paper3` | #F0ECFA, #E7E1F6, #DED6EF | #090811, #100F1B, #181625 |
| `--color-ink` / `-2` | `Ink`, `Ink2` | #131019, #2B2636 | #E8DFFC, #C2B7DA |
| `--color-muted` | `Muted` | #5C5270 | #9E90B8 |
| `--color-rule` / `-2` | `Rule`, `Rule2` | #CEC5E1, #A295CB | #28253B, #534B76 |
| `--color-accent` / `-deep` / `-soft` | `Accent`, `AccentDeep`, `AccentSoft` | #6B2AE3, #571DBC, #D4C7FF* | #783FF5, #6527D7, #403267 |
| `--color-accent-ink` | `AccentInk` | #F6F4FB | #F6F4FB |
| `--color-focus` / `--color-link` | `Focus`, `Link` | #6B2AE3, #6B2AE3 | #8A63FE, #AF97FF* |
| `--color-error` / `--color-success` | `Error`, `Success` | #BE2323, #131019 | #EF675C, #E8DFFC |
| `--color-code-green` / `-ink` | `CodeGreen`, `CodeGreenInk` | #45B0A0, #131019 | #68D0BF, #090811 |
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
| Level glyph | `LevelBars`: three `RoundedRectangle`s, the unfilled ones at 30% opacity |
| Targets (carbs, protein, fat) | `ProgressView(value:total:)` with a capsule `ProgressViewStyle` tinted `Accent` |
| Fuel timeline | `LazyVStack` of `TimelineRow`; the ride row is a `NavigationLink` on an `AccentSoft` background |
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
| Pace picker | `Picker(selection:)` with `.pickerStyle(.segmented)`, selected segment tinted `Accent` |
| Daily deficit rows | The Week row: `CarbCodeTag` plus `Text(kcal)` in `.monospacedDigit()`, shown only when Show calories is on |
| Caffeine curve | Swift Charts: `AreaMark` + `LineMark` (`Accent`) from the Bateman model sampled every 5 min; `RectangleMark` for the ride window (`AccentSoft`); `RuleMark` for last call (dashed) and bedtime; `PointMark` for doses; `.accessibilityChartDescriptor` for VoiceOver |
| Curve readings | `Grid` of time and mg pairs under the chart, the same values VoiceOver reads |
| Caffeine card on Today | `NavigationLink` holding a sparkline `Chart` (axes hidden), the total and a warning tag |
| Warning tag | `Label("Gel after last call", systemImage: "exclamationmark.triangle")` on a `Paper3` capsule, ink text, never a code colour |
| Icons | SF Symbols: `chevron.left/right/down`, `lock.fill`, `checkmark`, `exclamationmark.triangle`, `arrow.triangle.2.circlepath`, `magnifyingglass`, `barcode.viewfinder`, `plus`, `heart`, `ruler`, `scope`, `calendar`, `plus.square`, `person` |

## Caffeine model

The curve is computed, never drawn by hand. One-compartment Bateman model, summed over doses: A(t) = D·ka/(ka−ke)·(e^(−ke·t) − e^(−ka·t)), ke = ln2 / half-life (5 h by default, adjustable 3–10 h), ka = 6.0 h⁻¹ (peak about 39 min after a dose). Last call = bedtime − 8.8 h for coffee-sized doses (Gardiner et al. 2023).

## Exports

`docs/design/tokens.css` and `docs/design/base.css` in this project. The asset catalog is built from the table above.
