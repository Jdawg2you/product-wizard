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
7. Embedded-feed block — lets the Script Navigator drive this page. See "Embedded mode" below.

## Carrier order (business rule from Jesse — pays better / prices better, top to bottom)
- WL: Americo, Mutual of Omaha, [Corebridge SIWL — not yet loaded], Chubb, InstaBrain, American Amicable,
  Transamerica, Foresters, Accendo (last; "only 6-month advance").
- Term with living benefits: NLG, Transamerica, Foresters SF, InstaBrain Term, Americo, MoO TLA, MoO TLE, AmAm.
  Term without: InstaBrain Pure Term, Transamerica, Foresters (rest trail).
- IUL: MoO IUL Express, NLG RapidProtect, TA FFIUL II Express, NLG FlexLife, Foresters SMART UL, TA FFIUL,
  Americo Instant Decision IUL, then F&G Pathsetter and F&G Everlast (all appended last — Jesse
  has not given them priority positions yet).
- Status beats priority: green > amber (by score) > gray. Priority only breaks ties.

## Adding carriers / guides
See `docs/ADDING-A-CARRIER.md`. Source PDFs go in `docs/guides/`; `tools/pdftext.py` extracts
their text (no pdftotext on this Mac). There is no database — all data is hand-curated arrays here.

## Driven by the Script Navigator

The navigator opens this page **in its own window** (`window.open`, no `?embed=1`) from three places:
the Carriers button in its drawer bar, a block on its card 9.1, and the client-profile header. It
then posts the client record here. The agent gets the whole wizard - grids, snapshots, condition
search, and their own "My carriers" list - rather than a trimmed copy in a drawer.

Two things make that work, both in the feed block below: this page greets `window.opener` the way it
greets a frame parent, and it answers every applied record with `{type:"applied"}`. The navigator
retries for a few seconds until that lands, so without the acknowledgement it would keep re-posting
and overwrite anything the agent typed here.

An empty profile sends nothing at all, so the window opens blank and is typed into normally.

## Embedded mode (`?embed=1`)
Kept and working, but nothing currently uses it: it was built when the plan was to hold this page in
a panel inside the navigator. `?embed=1` adds
`body.embed`, which hides the header, footer, browse grids, product snapshots and **this page's own
client panel and condition chips** — the navigator owns the interview in that mode, and duplicating
the inputs would let the two drift apart on the next message. The underwriting-type and IUL-focus
segments stay live, because those are agent preferences rather than client facts.

`apply()` writes the incoming record into the same inputs a person would type into, calls
`readClient()`, rebuilds `picked`, and calls `render()`. There is deliberately no second eligibility
path: `verdictsFor` / `eligChecks` / `resolveWindow` / `clauseMeds` see exactly what they would see
if the agent had typed it. `report()` sends the counts and the best-fit line back, computed the same
way `renderVerdict` computes them.

```
navigator -> wizard   {source:"optimum-suite",  type:"client", v:1, client:{
                         age, sex, hin (total inches), wt, lb, conds:[{name, y}|{name, m}] }}
wizard -> navigator   {source:"optimum-wizard", type:"ready"|"summary", v:1,
                         total, byType:{iul,wl,term}, best, ready}
```

Conditions are addressed **by exact `COND` name**, which is a grid row name. Renaming a row in
`DATA.*.rows` silently breaks the matching chip in the navigator — nothing throws on either side.
The navigator has `tools/sync-conditions.sh` to regenerate its copy of the names and a check that
fails on drift; run it after any row rename.

The origin allowlist is in that block (`https://script.ffloptimum.com`), relaxed only when this page
is itself served from localhost or a file. Nothing crosses but `postMessage`: the two tools are
separate origins, so no storage is shared, and client health answers deliberately never touch a
cookie, a query string or a server.

## Conventions
- Conditions in `MEDS_CONDS` (high blood pressure) swap the "time since" dropdown for a medication
  count (`MEDOPTS`), stored on the chip as `p.m` rather than `p.y`. `clauseMeds()` reads carrier
  language like "3+ medications - DECLINE" or "one BP medication allowed for Preferred"; a
  medication threshold that definitely applies beats an earlier clause that can't be decided.
  Where a carrier's guide says nothing about medication count, Jesse's rule fills in: 4+ meds is
  not eligible for term or IUL, and questionable (amber) for whole life. That fallback is a
  business rule, not guide language — it is the one place a cell does not trace to a document.
- A condition with no row on a grid at all (blood pressure is absent from whole life, since FE
  carriers don't treat it as a factor) is marked `offGrid` and must not downgrade a card. A
  carrier-specific "not addressed" still does — Americo IUL is 107/107 unanswered, so ignoring
  those would show it as clean for a client with any condition at all.
- `WL_ALSO` maps a term/IUL condition onto a whole life row filed under a different name
  ("Irregular heartbeat / murmur" -> the WL row "AFib / irregular heartbeat"). Without it the card
  showed nothing for whole life while the grid held a real answer. Add an entry whenever the same
  impairment is named differently across grids.
- `#tally` under the chips shows the live match count and best fit, and scrolls to the results.
  It exists because on a narrow window the results render below the fold, so typing an age looked
  like the tool had done nothing.
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
- Cholesterol and Thyroid are on Jesse's paper client profile and the Script Navigator captures both,
  but neither is a row on any grid here, so they cannot affect a verdict. Adding them means real
  language per carrier from the guides in SOURCES.md — do not fill the cells in from general
  knowledge. Until then the navigator shows them with a "no grid" badge.
- Age: Jesse confirmed actual age (last birthday) is correct for quoting everything; age nearest
  birthday only matters for some IUL carriers. The DOB box is therefore right as written. A future
  refinement would flag an IUL carrier whose issue-age band the client clears on one basis but not
  the other.
- Americo Eagle Select: FE column still uses 2022 Eagle Premier grid language; need the 3-tier guide.
- Americo term column uses 2020 HMS grid language; Instant Decision Term Series guide has no condition list.
- Corebridge SIWL: guide not yet received.
- Royal Neighbors SIWL/GDB: snapshot only; need the application's health questions.
- IUL focus tags: MoO IUL Express and F&G Everlast are `focus:"protection"` (hidden when Cash
  accumulation is picked); Americo Instant Decision IUL and F&G Pathsetter are `focus:"cash"`
  (hidden when Protection is picked). Remaining IUL carriers stay untagged and always show.
  F&G Everlast sits directly after Transamerica FFIUL II Express in the protection order.
- F&G Everlast carries `tag:"Fast underwriting"` — close to instant, but not instant. Because the
  underwriting toggle treats anything other than the exact string "Fully underwritten" as
  simplified, Everlast now shows under Simplified issue while Pathsetter does not, even though the
  F&G guide gives both the same programme (exam-free to age 60 at $1M or less, full underwriting
  above that). Worth revisiting if that split is not what Jesse wants.
- `client.face` is read from no input and filtered on by nothing: `eligChecks` reports each
  carrier's face range as information only. A requested coverage amount is therefore not a
  filter today, which is why the navigator does not capture one.
- The `#uwSeg` click handler has a bad paste in it — it re-registers the `#focusSeg` handlers on
  every underwriting-segment click, so those listeners accumulate. Harmless in effect, wrong as
  written; worth collapsing back to the two separate handlers it was meant to be.
