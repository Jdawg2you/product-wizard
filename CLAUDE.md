# Insurance Product Wizard — project notes for Claude Code

Single-file web app (`index.html`, no build step, no dependencies) for Optimum's free agent tool suite.
Live at https://wizard.ffloptimum.com/ via GitHub Pages (CNAME file in repo root).

## What it does
An agent enters a client's age (or DOB), optional height/weight/sex/coverage amount, a living-benefits
preference, and the client's medical conditions (each with an optional "time since"). The tool returns
which carriers/products the client can buy, grouped IUL → Whole Life → Term, with a "Likely best fit"
call-out. Term is never the recommended product; it's listed as what's left. Below the results are the
full underwriting grids (browseable, tabbed) and product snapshots per carrier.

## File layout of index.html (top to bottom)
1. `<head>` — Google Fonts (Source Serif 4 + Inter), OG/Twitter meta, favicon links.
2. `<style>` — Optimum brand tokens (see OPTIMUM-BRAND-KIT.md; must stay in sync) + component CSS.
3. Header (brand-kit `.o-header` snippet, verbatim), GOAT pop-out `<dialog>`, "My carriers" drawer.
4. `<main>` — client panel, legend, `#verdict` results, `#suiteNext` card, browse grids, product snapshots, footer.
5. `<script>` main app:
   - `DATA = { wl, term, iul }` — each has `carriers[]`, `products[]` (snapshot cards), `rows[]`.
     A row is `[conditionName, cell1, cell2, ...]` with one cell per carrier, in carrier order.
     Cells are strings. Optional prefix forces status: `R|` decline, `A|` tier/window, `G|` allowed,
     `N|` not addressed. Without a prefix, `parse()` derives status from the wording.
     `term.orders` holds the two priority orders (with / without living benefits).
   - `BUILD` — height/weight tables, index 0 = 4'8" through 24 = 6'8", `[min,max]` at loosest class.
   - `ELIG` — per carrier id: `ages`, `face`, `faceAge` (age-stepped max face), `build` key or `bmi`/`bmiMin`.
   - `WL2T` — maps whole-life row names to their term/IUL equivalents for the unified condition list.
   - `RX` + `parse()` — status derivation from cell text (ok / tier / no / na).
   - `score()` — finer ranking within tier: unconditional class (2.8) > conditional (2.5) > windowed GI (2.2/2.3)
     > flat Graded/Modified/ROP/Basic (2.0) > flat Guaranteed Issue (1.8) > na (1) > no (0).
   - `clauseWindow / clauseAge / evalClause / resolveWindow` — evaluate a cell's `;`-separated clauses
     against years-since and client age ("within 2 yrs – Select; over 2 yrs – Premier",
     "diagnosed before age 50 – DECLINE", "46–59 – T4 to decline"). Returns the matching clause's
     outcome; leaves the cell alone when it can't decide.
   - `eligChecks()` — age / face / build knockouts per carrier.
   - `verdictsFor(key)` — filters (my carriers, underwriting type, IUL focus), applies checks + conditions,
     hides age-outs and declines, sorts by score then priority order.
   - `renderVerdict()` — best fit = highest score across IUL and WL only (ties: IUL first). Hides product
     types with nothing eligible. Shows/hides `#suiteNext`.
   - "My carriers" saved in `localStorage` key `ipw.myCarriers.v2` (set of unticked carrier *names*).
6. Suite block (brand kit) — `SUITE` config with tool URLs, header switcher, next-step card wiring.

## Carrier order (business rule from Jesse — pays better / prices better, top to bottom)
- WL: Americo, Mutual of Omaha, [Corebridge SIWL — not yet loaded], Chubb, InstaBrain, American Amicable,
  Transamerica, Foresters, Accendo (last; "only 6-month advance").
- Term with living benefits: NLG, Transamerica, Foresters SF, InstaBrain Term, Americo, MoO TLA, MoO TLE, AmAm.
  Term without: InstaBrain Pure Term, Transamerica, Foresters (rest trail).
- IUL: MoO IUL Express, NLG RapidProtect, TA FFIUL II Express, NLG FlexLife, Foresters SMART UL, TA FFIUL,
  Americo Instant Decision IUL (appended last — Jesse has not given it a priority position yet).
- Status beats priority: green > amber (by score) > gray. Priority only breaks ties.

## Adding carriers / guides
See `docs/ADDING-A-CARRIER.md`. Source PDFs go in `docs/guides/`; `tools/pdftext.py` extracts
their text (no pdftotext on this Mac). There is no database — all data is hand-curated arrays here.

## Conventions
- Never invent underwriting language. Every cell traces to a carrier guide (see SOURCES.md).
- Keep cells short; `;` separates clauses; use "within N yrs – X; over N yrs – Y" phrasing so
  `resolveWindow` can parse it. Age rules as "diagnosed before age N" / "after age N" / "N–M".
- Fully-underwritten products carry `tag:"Fully underwritten"`; instant/simplified carry their tag.
  The underwriting toggle keys off that tag.
- IUL carriers may carry `focus:"protection"|"cash"|"both"` (not yet set — Jesse will supply).
- Brand: follow OPTIMUM-BRAND-KIT.md exactly (header, footer, tokens, suite block). Do not restyle.
- No frameworks, no bundler, no external JS. Keep it one file so it deploys by copy.

## Testing before committing
`tools/check.sh` — parses every `<script>` block with JavaScriptCore (ships with macOS; there is no
node here) and verifies every grid row has one cell per carrier. A pre-commit hook runs it via
`git config core.hooksPath .githooks`. It exists because an unescaped `"` inside a double-quoted
string shipped to production, threw SyntaxError, and killed the entire app script — the live site
served a dead shell. Grepping the deployed HTML passed, because the text was there; the file just
did not parse. After the checks, load the preview and actually look at it.

## Open items
- Americo Eagle Select: FE column still uses 2022 Eagle Premier grid language; need the 3-tier guide.
- Americo term column uses 2020 HMS grid language; Instant Decision Term Series guide has no condition list.
- Corebridge SIWL: guide not yet received.
- Royal Neighbors SIWL/GDB: snapshot only; need the application's health questions.
- IUL focus tags: MoO IUL Express is `focus:"protection"` (hidden when Cash accumulation is picked).
  Americo Instant Decision IUL is `focus:"cash"` (hidden when Protection is picked). Remaining
  IUL carriers stay untagged, which means they always show.
- Planning Tools URL in SUITE config is still a placeholder.
