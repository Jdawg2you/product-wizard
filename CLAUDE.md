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
- WL: Americo, Mutual of Omaha, Corebridge SimpliNow Legacy (SIWL), Chubb, InstaBrain, American Amicable,
  Transamerica, Foresters, Accendo ("only 6-month advance"), then Corebridge GIWL - the guaranteed
  issue fallback, always last and always amber.
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
                         age, dob (ISO), sex, hin (total inches), wt, lb,
                         conds:[{name, yr, mo, d?:{followUpKey:answer}}|{name, m, mSet?}],
                         meds:[label], medSkip:["med|condition"] }}

  type and stage ride on Cancer / Active cancer (type is the navigator's free text, read by
  caType; stage is one of CA_STAGES); a1c (number) and tx (Pills | Insulin | Both) ride on
  Diabetes. All optional - see "Condition details".

  yr and mo are the year and month it happened - this page stores those on the chip and
  derives years-since itself, so a record that arrives and one that is typed cannot
  disagree. A legacy `y` (years-since as a decimal) still rides along and is used only
  when no yr is given. Names go through COND_ALIAS, so the navigator's "Active cancer"
  scores as Cancer.
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

## Kept in step with the Script Navigator
`tools/check.sh` step 3 fails the commit when this page and the navigator have drifted apart. It
reads the navigator from `~/script-navigator/index.html` (override with `NAV_FILE=`), falling back
to script.ffloptimum.com, and warns rather than fails if neither is reachable. It checks that:
- `MED_FOR` and `MEDS` match the navigator's exactly - they are a copy, and a stale copy asks
  about the wrong condition without any error;
- every condition name the navigator can send - its `PF_CONDS`, every `{{c:...}}` tick in its
  scripts, and every condition its `MED_FOR` points at - resolves to a `COND` entry here,
  directly or through `COND_ALIAS`.
When it fails, fix whichever side is wrong; do not bypass it.

## IUL contribution ($/m)
The contribution is IUL money, so it only moves the IUL list: $300 or more takes IUL to Both, ten
times the client's age takes IUL to Fully underwritten, a blank figure leaves it alone. That
override lives in `client.uwIul`, and `uwFor(key)` returns it for `iul` and the agent's own
`client.uw` for whole life and term. The IUL heading shows a badge while it applies. It used to
move the shared toggle, and because no whole life product is fully underwritten, 10x age wiped
all of whole life - the fallback the navigator's script leans on at 9.1.

## Rating classes (business rule from Jesse)
Everyone is run at Standard, so any class a carrier will issue is a go: Preferred, Standard, Select,
Premier, "no rating", "all classes" all parse green. Classes that change the benefit stay amber:
Basic, Graded, Modified, ROP, guaranteed issue, table or sub-standard. A class inside a time window
("within 1 yr - Basic; within 2 yrs - Standard") stays amber until a date resolves it; resolveWindow
parses only the outcome it lands on, so it goes green once the date puts the client in a go class.
Transamerica FE Express "Select" and Foresters PlanRight / Accendo "Standard" are full coverage from
day one, which is why they are not a lower tier.
The test is `goClass()` and it runs in `parse()` both on plain cells and on flat cells forced amber
with an `A|` prefix, so the prefix does not override this rule. Anything rated case by case ("rate
for cause", "depending on") stays amber.

Guaranteed issue: Corebridge GIWL takes anyone within its age limits (50-80) regardless of health, so
a client every simplified-issue carrier declines still has that option. Its carrier carries `gi:true`
and its ELIG entry a `gi` message: `eligChecks` always adds that message as an amber check, and
`verdictsFor` answers every condition with "no health questions" (marked `minor`, so conditions never
move it, including the 4+ blood pressure rule). Its grid cells all read "Guaranteed Issue".

## Corebridge SimpliNow Legacy (SIWL)
One application, two outcomes: Level (SimpliNow Legacy Max, full benefit day one) or Graded
(SimpliNow Legacy). Cells use "Allowed (Level)" for the full benefit so it parses green, "Graded" for
amber, and DECLINE for the knockout steps. Windows follow the question sheet: Section A ever, B 48
months, C 24 months, D and knockout steps 3-4 12 months, step 5 36 months. Rows the application does
not ask read "Not asked - Allowed"; Crohn's, ulcerative colitis and Down syndrome are `N|` because the
autoimmune / mental incapacity questions may or may not catch them.
Two build charts: `CB` (Graded, the looser, used for the knockout) and `CBL` (Level). ELIG's
`buildLevel` adds an amber "Graded only" check between the two. Level face steps up with age
(`faceAge`); smokers 71-80 get Graded only, which the tool cannot tell because it does not ask
tobacco. Known conservative spots: a TIA 6-12 months ago reads as the stroke-within-1-year decline,
and cancer type-specific rules show as text for the agent rather than resolving.

## Blood pressure (business rule from Jesse)
Rated on how many medications it takes to control, never on when it started, so the chip asks
for a count and no date - and the navigator's script asks only the count too.
- 1-2 medications: controlled. Changes nothing, and a hospitalisation clause is not held against it.
- 3: questionable. Where a carrier states its own count (Americo term, American Amicable decline at
  3+) its language decides; where it is silent the card shows amber, "verify with underwriting".
- 4+: not well controlled - not eligible for simplified issue with any carrier, whole life included,
  whatever the guide says. Guaranteed issue (Corebridge GIWL) still takes them within its age limits.
- A carrier's own medication count only declines when its text says decline. National Life Group's
  "one BP medication allowed for Preferred" is a rating-class rule: on two medications that shows
  green ("controlled, Standard") - see Rating classes - never not-eligible.
Deliberately not asked, to keep the most common and least important condition to one question: the
guides' diagnosis-within-4-months, hospitalised-within-10-years, dosage-change-within-12-months and
abnormal-EKG rules. Those cells stay as the guide wrote them for the agent to read.

## One set of questions (business rule from Jesse)
Whatever the navigator's script asks, this page asks, and the other way round - the navigator is built
off the same underwriting guides. `DETAILS` here mirrors the navigator's `PF_FOLLOW` key for key and
answer for answer, and `LIFT` mirrors its `COND_FROM_FOLLOW` (answers that add a condition: neuropathy
Yes, on oxygen, on dialysis, cirrhosis, stent or bypass since). `tools/check.sh` step 3 fails the commit
if a question, an answer list or a lift differs. Dates (`dx_*`) are the chip's year box.
An answer works on the carrier cells three ways: `keep` narrows a cell to the clauses that name it,
`drop` removes a clause it rules out (only clauses about nothing else), and `detailCell` answers
outright where a carrier's rule is written against the answer. Cancer counts from the more recent of
diagnosis and last treatment. Every follow-up rides the handoff under `d:{key:value}`.

Blood pressure count follows the medication list in both tools: every entered drug tagged "High blood
pressure" in `MED_FOR` counts, unless it was answered No for blood pressure. A count the agent picks
wins (`mSet`); "not sure" (or clicking the pick off, in the navigator) hands it back. The list rides
the handoff as `meds` / `medSkip`. Metoprolol, diltiazem, spironolactone and furosemide count though
they have other uses - the agent can override.

## Condition details (cancer type / stage, diabetes A1C / treatment)
Optional dropdowns on the Cancer and Diabetes chips, also filled from the navigator. Blank leaves the
grid cell in charge. `detailCell(car,name,p)` answers for the carriers whose rules turn on them,
before `resolveWindow`:
- Corebridge SimpliNow Legacy cancer: Stage III/IV or lymphoma - decline; 13 types within 12 months -
  decline; within 4 yrs breast, prostate, colon, melanoma, thyroid, kidney, cervical, uterine,
  testicular are Level unless Stage II, everything else Graded; after 4 yrs the grid cell applies.
  Stage I of a Level type is green whatever the date, since it is Level either side of 4 yrs.
- SimpliNow Legacy diabetes: A1C 10+ decline; insulin Graded; pills Level (an unknown A1C still
  goes on to the insulin question, per the sheet).
- Chubb: insulin or A1C over 7 - Graded. American Amicable: pills Immediate, insulin before 50 ROP.
  Transamerica FE Express: insulin - Select (green).

## Borrowed build chart (business rule from Jesse, 14 Sep 2026)
F&G publishes no build chart, so Everlast uses National Life Group's RapidProtect chart (`NLGP1`), set
with `ELIG.iul.fgever.buildBorrowed`. Outside it Everlast is removed like any carrier over its limit
(Jesse chose this over keeping it amber), and `BORROWED_OUT` puts a line under that product type's
heading - or in the best-fit call-out when the whole type is empty - naming the carrier and the
borrowed chart. Every build line, "Build OK" included, also names the chart. Pathsetter still has no build check.

## Reading a cell for this client (fixed 14 Sep 2026 from Jesse's screenshot)
A breast cancer four months old, in remission, showed Transamerica FFIUL II Express and Foresters SMART
UL green for IUL. Three separate reading errors, all fixed in resolveWindow / preferClauses / cancerCell:
- Fallback: when no dated clause fits, only a clause about everyone left over may answer ("otherwise -
  Graded", a bare "Standard"). A clause naming its own case ("basal cell - OK", "Raynaud's - Standard",
  "injury - allowed") no longer answers for the client; the cell stays amber for the agent to read.
  Checked against every cell at six dates and two ages: 47 cells changed, all from green to amber or
  from a wrong case to the full text.
- Clean periods: "no treatment / recurrence / attacks / seizures / episodes / symptoms / use within N
  yrs - OK" applies after N years, not inside them. The wording list is deliberate - "(no
  complications) within 1 yr - Decline" and "No heart attack, no surgery, within 5 yrs" still read as
  within.
- Cancer by type (`cancerCell`): with the type known, only clauses about that type or about every type
  are read, and undated declines ("metastatic, recurrent or multi-site") don't stop the type's own
  dated rule from settling. With the type unknown, a clause about one type never decides; the cell
  resolves on the rest or stays amber.
- "In remission" only removes a carrier's "current - DECLINE" once the latest diagnosis or treatment is
  a year or more back.

## Condition chip year input
A year is only committed once the box holds four digits (or on blur, when anything left over is
settled). Committing each keystroke rebuilt the chip empty, since every partial year is below 1900,
so a year could not be typed at all. Do not call `setSelectionRange` on these - number inputs throw.
`needsOf()` resolves aliases, so an aliased chip gets the year box its real row needs.

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
- Corebridge guides are not in `docs/guides/`: every page is marked not for public distribution and
  this repo is public. Ask Jesse before committing them.
- Corebridge aggregate: the April 2025 question sheet says $25K total across SIWL and GIWL; the May
  2025 agent guide says $35K if approved Level. The snapshot uses the newer guide and says so.
- Royal Neighbors SIWL/GDB: snapshot only; need the application's health questions.
- IUL focus tags: MoO IUL Express and F&G Everlast are `focus:"protection"` (hidden when Cash
  accumulation is picked); Americo Instant Decision IUL and F&G Pathsetter are `focus:"cash"`
  (hidden when Protection is picked). Remaining IUL carriers stay untagged and always show.
  F&G Everlast sits directly after Transamerica FFIUL II Express in the protection order.
- F&G Everlast carries `tag:"Fast underwriting"` — close to instant, but not instant — and
  Pathsetter is `tag:"Fully underwritten"`. Confirmed by Jesse 8 Sep 2026: the two products are
  not the same speed, whatever the shared exam-free programme in the guide suggests. The split is
  deliberate, so Everlast appears on the Simplified issue default and Pathsetter only once the
  toggle opens to Both or Fully underwritten.
- `client.face` is read from no input and filtered on by nothing: `eligChecks` reports each
  carrier's face range as information only. A requested coverage amount is therefore not a
  filter today, which is why the navigator does not capture one.
- The `#uwSeg` click handler has a bad paste in it — it re-registers the `#focusSeg` handlers on
  every underwriting-segment click, so those listeners accumulate. Harmless in effect, wrong as
  written; worth collapsing back to the two separate handlers it was meant to be.
