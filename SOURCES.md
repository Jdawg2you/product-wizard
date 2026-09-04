# Where every column comes from

| Tab | Carrier / product | Source document | Notes |
|---|---|---|---|
| WL | Americo Eagle Select | 2022 FFL Final Expense Grid Sheet (Eagle Premier column); Americo eApp UW reference (Apr 2026) for ages/faces/build | Tiers not in any guide yet |
| WL | Mutual of Omaha Living Promise | 2022 FE grid; MoO Simplified Issue guide (Apr 2026) for limits | |
| WL | Chubb/Combined Generational Life | Chubb Generational Life Underwriting Guide (medication + condition tables) | Translated to grid language |
| WL | InstaBrain / Fidelity RAPIDecision FE & GI | Fidelity Life FE Producer Guide (May 2026) | Any Yes → GI |
| WL | American Amicable Senior Choice | 2022 FE grid | |
| WL | Transamerica FE Express | FE Express Solution agent guide (Jul 2026) — adult + cancer decision charts, BMI bands | |
| WL | Foresters PlanRight | 2022 FE grid | |
| WL | Accendo | 2022 FE grid | |
| Term | Americo Instant Decision Term | 2020 FFL Term Grid (HMS column); Term Series agent guide (Sep 2025) for specs | |
| Term | MoO Term Life Express | 2020 term grid; MoO Simplified Issue guide (Apr 2026) | |
| Term | American Amicable Easy Term | 2020 term grid | |
| Term | Foresters Strong Foundation | 2020 term grid; Foresters UW guide (2020) | |
| Term | InstaBrain Term / Pure Term | Fidelity InstaBrain Term & Pure Term producer guides (May 2026) | |
| Term | MoO Term Life Answers | MoO Accelerated UW flyer (2023) + MoO Fully Underwritten guide (Sep 2025) | Cells show AU eligibility, then full-UW probable action |
| Term | NLG Term | NLG Underwriting Guide (Sep 2025) | |
| Term | Transamerica Trendsetter | Transamerica Field Guide to Underwriting (2021); Trendsetter guide (Dec 2025) for specs | |
| IUL | MoO IUL Express | Same as Term Life Express column | |
| IUL | NLG RapidProtect | NLG Underwriting Guide (Sep 2025) qualifying / non-qualifying lists | |
| IUL | Transamerica FFIUL II Express | FFIUL II Express agent guide (Sep 2026) adult decision chart | |
| IUL | NLG FlexLife/PeakLife | NLG Underwriting Guide (Sep 2025) | |
| IUL | Foresters SMART UL | Foresters UW guide (2020) — SF rules + SMART UL exceptions | |
| IUL | Transamerica FFIUL | Transamerica Field Guide (2021) | |
| IUL | Americo Instant Decision IUL | Instant Decision IUL Agent Guide 23-084-1 (10/25) — `docs/guides/` | Ages/face/build only; guide publishes no condition list, so every cell is "not addressed" |
| snapshot only | Royal Neighbors SIWL/GDB | Agent guide (2020) | Health questions not in guide |

The source PDFs live in Jesse's Google Drive "wizard" folder, and are readable through the Drive
connector — search by carrier name and read the file directly to check a cell against the guide
before changing it. Verified this way so far: Transamerica FFIUL II Express diabetes
("diagnosed prior to age 60 ... Ever / Decline", adult single condition decision chart, p.27).

The source PDFs live in Jesse's Google Drive "wizard" folder. Consider copying them into `docs/guides/` in this repo
so future updates can be diffed against the exact document that fed each column.

## Rules that are not from a carrier guide

One exception to "every cell traces to a document": where a carrier's guide is silent on blood
pressure medication count, the tool applies Jesse's rule — 4+ medications is not eligible for term
or IUL, and questionable for whole life. Carriers that state their own threshold (Americo term and
American Amicable term both decline at 3+) keep their guide language, which is stricter.
