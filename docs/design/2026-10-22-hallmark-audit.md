# Hallmark audit: fueling app wireframes

Target: `docs/research/2026-10-22-wireframes.html` (7 phone screens, mid fidelity).
Run: Hallmark v2.0.0 `audit`, 2026-10-22. Scope: app screens (`flow.md` § App screens), genre modern-minimal.
Nothing in the target was changed.

## How this was checked

- `sloplint.mjs docs/research/2026-10-22-wireframes.html --genre modern-minimal --scope app --before`, **static tier only**. Puppeteer is not installed, so the render tier (`--render`) did not run, and no gate marked R or M/R was checked by the script.
- The judged gates (§ 4 and § 5) were walked from the source and from one macOS Quick Look render of the file (WebKit, top 1600 × 1600 px, system fonts). That render is not Hallmark's render tier.
- Contrast numbers below are WCAG 2 ratios computed from the file's own fallback colours.
- The page records 0 links, 0 fields, 0 handlers and 0 test hooks (`.hallmark/before.json`). It is a static picture with no wiring to keep.

## The read

1. **What it is for.** It shows how an endurance athlete (a 70 kg cyclist, Tue 22 Oct) sees what to eat before, during and after a ride, logs it fast, and trusts the numbers.
2. **What works and stays.** The content is strong and specific. Every target names the rule behind it ("1–2.5 h session: 30–60 g/h"). Logged meals lock and the plan says what changed ("ride moved from 18:00 to 17:30. Logged meals unchanged"). Calories are off by default. Each GREEN, AMBER and RED code carries its word. The screen set covers the whole loop: connect, plan, log, review.
3. **What reads as generated.** It is stock iOS dark mode: systemBlue, systemGreen, systemOrange and systemRed on #1c1c1e, set in the system face. Glyphs stand in for icons (♥ 🔒 ✓ ⚠ ⟳ ▸ ⌕ ▥ ◉ ▦ ＋ ○). Middle-dot strings join most meta lines. Everything sits at 11 to 13 px, so the day's one number (490 g) has the same weight as a caption.
4. **What is broken.** Opened on its own, the caption titles are near-white on a white page (1.12:1) and can't be read. Colours carry two meanings: green is the GREEN code, a switched-on toggle, "Connected ✓" and "on target"; amber is the AMBER code and also the sync warnings. Tap targets are 19 to 26 px tall, against 44 pt.

## Findings by tier

### Floor (never waivable)

| Gate | Where | Finding |
| --- | --- | --- |
| 40 | `:37-38` | Caption titles `figcaption b` use `--c-fg` #f2f2f7 with no page background, so they render on white at **1.12:1**. The note and caption body #98989f on white is 2.87:1. Judged from the Quick Look render. |
| 40 | `:54`, `:151` | The dimmed TrainingPeaks row (`.dim`, opacity .55) puts its small text at **2.72:1** on the card. |
| 40/41 | `:58` | White on the primary button #0a84ff is **3.65:1**, under 4.5:1 for 12 to 14 px labels. |
| 26a | `:1` (whole sheet) | No `:focus-visible` anywhere. |
| 30a | `:148`, `:300`, `:302`, `:307`, `:308` (linted); judged also `:178-179` (🔒 ✓), `:184` (⟳), `:258` (⌕ ▥), `:282-283` (🔒), tab bars `:186`, `:247`, `:270`, `:312`, every status bar | Emoji and Unicode glyphs used as icons: ♥, 🔒, ✓, ⚠, ⟳, ▸, ⌕, ▥, ◉ ▦ ＋ ○, ▮▮▮ ◠ ▭. |
| 34 | `:1` | No `overflow-x: clip` on `html` and `body`. |
| 48 | `:9-22` | 14 colour literals: the `var(--x, #hex)` fallbacks are the real palette and sit outside any token block. |
| 54 | `:196`, `:280`, `:297` | Linted as eyebrows: the "‹ Today" and "‹ Profile" back links. **Dismissed**: these are navigation, a legal label. Judged instead: the uppercase "Next up" (`:173`) and "Needs a look" (`:305`) labels act as eyebrows over the card and list they introduce. |
| 63 | `:137`, `:174`, `:178-181`, `:197`, `:243`, `:283-285` | Middle-dot meta strings ("80 g carbs · 15 g protein", "17:30 · 1 h 45 · planned 1,250 kJ · Intervals.icu"). Judged as well: arrows glued to link text: "Ideas ▸", "Add workouts by hand instead ▸", "Why GREEN today ▸", "Review ▸", "Confirm or delete ▸", "Ride: Threshold 3×12 ▸". |
| 67 | `:41`, `:90` | Status bar glyphs tracked 1 px; `.lbl` set uppercase and tracked .04em at 11 px. |
| 19 | `:202` and every range | En dashes in copy ("1–4 g/kg", "17:30–19:15"). These are the engine's own ranges, so a redesign carries them verbatim (`copy: verbatim`) and the gate reports as a note. |
| 20 | `:1` | No Hallmark stamp. This is expected for a page Hallmark did not build. |
| F21 / F23 | `:1` | Only `h3` is used, with no `h1` or `h2`. There is no meta description. |

### Reflex (fix or waive)

| Gate | Where | Finding |
| --- | --- | --- |
| 24b | 24 places, `:40` to `:122` | Off-scale spacing (6, 7, 9, 10 px …). |
| 26b | `:1` | No `:active` state. |
| 39b | `:57`, `:63`, `:66`, `:186` | Controls are 19 to 26 px tall (Connect pill, chips, toggles 32 × 19, tab items) with no hit-target expansion. iOS wants 44 pt. |
| 74 (judged) | `:15-21` | Stock swatch: Apple's dark system colours used as the brand. The brief asks for a custom look. |
| 75 (judged) | `:45-46` | Multi-line running text at 11 px (`small`, `.mut`): the Apple Health description, timeline lines, the "Why GREEN" body. At the real 402 pt width these map to Caption 2, iOS's smallest style. |
| 47b | 7 frames | Phone frames. A screen sheet needs them, so this is waivable on the record. |

### Finish (answered, never blocking)

- **F1** Straight apostrophes in prose (`:159` and 7 more).
- **F6** Figures that compare (210 / 490 g, the week's grams column) don't use tabular numerals.
- **F12** The Week rows (`.wrow`, `:107`) align to the top, so the 490 g on Tuesday floats above its wrapped workout name.
- **F5-like** Letter monograms ("i", "W", "TP") sit in grey coins. They are stand-ins for brand marks the project doesn't have yet.

### Not gated, but the main design problems

- **Colour semantics collide.** The three carb codes share their hues with system status: the green toggle, "Connected ✓" and the "on target" total, plus the amber "Reconnect" and "⚠". A GREEN day and a working toggle look the same. The fix is a brand accent off the code hues, and status shown with a glyph and ink.
- **Colour blindness.** GREEN #30d158 and RED #ff453a pills differ only in hue. Each one carries its word, so WCAG 1.4.1 passes, but someone with deuteranopia can't scan the Week column by colour.
- **No signature.** The product's argument is "every gram explained", yet the rule lines are 11 px grey mono under the target. Nothing on Today says how much is left of the day's 490 g.
- **States.** Only two sync errors are drawn (WHOOP sign-in expired, Needs a look). No region shows loading or empty.

## Depth that settles it

- **Polish** fixes the Floor list: tokens, focus rings, `overflow-x`, icons from one set, untracked labels, middle dots and arrows replaced by layout, contrast, hit targets.
- **Restyle** is the lightest depth that gives the custom brand look and pulls the code colours apart from status and accent.
- **Full** is needed for the rest: what leads on Today (the day's target and the ride), the rule line as the product's signature, and the loading, empty and error states. That is the depth the redesign takes (`docs/design/mockups.html`).

## Material to verify (carried over as found, never invented)

Every number on the screens is engine output for the example athlete and stays word for word. Product claims to confirm before launch: "Takes about 60 seconds" (onboarding), "updates within minutes" (Intervals.icu), "Runna, Zwift, a group ride: 10 seconds" (Week), "Source: ACSM 2016" (Ride plan).
