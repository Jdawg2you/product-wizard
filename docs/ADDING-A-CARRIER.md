# Adding a carrier, product or guide

There is no database. Every underwriting fact lives in hand-curated JavaScript arrays inside
`index.html`. That is deliberate — the tool is one file with no build step, so it deploys by copy.
Adding a carrier means editing those arrays, not importing anything.

## Drop a guide in

Put the PDF in `docs/guides/` and name it so the carrier, product and revision are obvious:

```
docs/guides/Americo_Instant_Decision_IUL_Agent_Guide_2025-10.pdf
```

Committing the guide is the point: when a cell is questioned later, the exact document that
produced it is sitting next to the code and can be diffed against a newer revision.

Guides are also in Jesse's Google Drive "wizard" folder and readable through the Drive connector —
useful for checking a carrier whose PDF has not been copied here yet.

## Read it

This Mac has no `pdftotext`, so use the extractor in `tools/`:

```bash
python3 tools/pdftext.py docs/guides/<file>.pdf > /tmp/guide.txt
```

Output can contain NUL bytes from two-byte font encodings, which makes `grep` treat the file as
binary and silently match nothing. Strip them before searching:

```bash
python3 -c "import sys;sys.stdout.write(open(sys.argv[1],encoding='latin-1').read().replace(chr(0),''))" /tmp/guide.txt > /tmp/clean.txt
```

## What to pull out of the guide

| Need | Goes in | Notes |
|---|---|---|
| Issue ages | `ELIG[type][id].ages` | `[min, max]` |
| Face min/max | `ELIG[type][id].face` | `[min, max]` |
| Age-stepped max face | `ELIG[type][id].faceAge` | `[[thruAge, max], ...]`, ascending |
| Build chart | `BUILD` key, then `ELIG[...].build` | index 0 = 4'8" … 24 = 6'8"; `null` for uncovered heights |
| BMI limit | `ELIG[...].bmi` / `.bmiMin` | use instead of `build` when the guide gives BMI |
| Condition rules | one cell per row in `DATA[type].rows` | see below |

Check whether the build chart already exists before adding a new one. Americo's Instant Decision
IUL chart turned out to be byte-identical to the existing `AM` table.

## Adding the carrier column

1. Add to `DATA[type].carriers`: `{id, name, prod, tag, src}`. `tag:"Fully underwritten"` drives the
   underwriting toggle; instant/simplified products carry their own tag. IUL carriers may carry
   `focus:"protection"|"cash"|"both"`.
2. Add the `ELIG[type][id]` entry.
3. **Add one cell to every row in that grid.** A row is `[conditionName, cell1, cell2, ...]` with one
   cell per carrier in carrier order. Miss a row and the grid silently misaligns — every cell after
   it belongs to the wrong carrier.
4. Add a snapshot card to `DATA[type].products`, titled `"Carrier — Product"`. The carrier half is
   matched against "My carriers", ignoring any parenthetical.
5. Add the row to `SOURCES.md` naming the exact document.
6. Update the carrier order list in `CLAUDE.md` — order is Jesse's business rule (pays better /
   prices better), not alphabetical.

### Verify before committing

```bash
tools/check.sh
```

It parses every `<script>` block with JavaScriptCore and checks that no row's cell count differs
from its grid's carrier count. A pre-commit hook runs it automatically (`git config core.hooksPath
.githooks`); `git commit --no-verify` bypasses it, which should be a deliberate act.

**Then load the preview and look at the page.** The checks catch dead code and misaligned grids;
they cannot tell you a carrier landed in the wrong order or a cell reads wrong. Grepping deployed
HTML for expected text is not verification — text can be present in a file that does not parse.

## Writing cells

Never invent underwriting language — every cell traces to a guide. Keep cells short, `;` separates
clauses, and phrase windows as "within N yrs – X; over N yrs – Y" so `resolveWindow` can parse them.
Age rules go as "diagnosed before age N" / "after age N" / "N–M".

Optional prefixes force a status: `R|` decline, `A|` tier/window, `G|` allowed, `N|` not addressed.
Without a prefix, `parse()` derives status from the wording.

**When the guide has no condition list**, use `N|` cells saying so rather than guessing. The carrier
still gets its age, face and build knockouts, and shows gray ("not addressed — check meds / call
underwriting") for conditions. Americo's Instant Decision IUL is the worked example: its guide states
that all application health questions are knockouts but never publishes them.
