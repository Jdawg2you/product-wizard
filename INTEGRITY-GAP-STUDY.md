# Integrity Connect vs the Product Wizard — gap study

Jesse, 2026-09-26: *"come up with like 30 scenarios... see what they recommend versus what
you would recommend in our product wizard... where we may have gaps."*

**Sourcing rule for this whole study.** Integrity's output is a POINTER, never a source.
`SOURCES.md` says every cell in the wizard traces to a carrier document, and that does not
change here. A finding below means "go read that carrier's guide", not "copy their answer".
Same call Jesse made on the outside veteran script: reviewed, nothing borrowed.

Access: Claude in Chrome, Jesse's logged-in session. Synthetic clients only — no real
client details entered into a third-party tool.

---

## Session 1 — mechanics proven, three findings before a single quote ran

### Finding 1 — State is a REQUIRED field for them
Their intake asks, in this order: **State\*, Gender\*, Height, Weight, Tobacco Use\*,
Date of Birth\* or Age.** Three of those are starred as required, and state is one.

Our wizard had no state field at all until today, and the version I built treats it as
optional. Worth deciding whether it should be required for us too — a final expense quote
without a state is arguably not a quote.

### Finding 2 — Tobacco is a first-class required input for them; we have no tobacco input
Ours captures smoking in the *profile* on the navigator side, but the Product Wizard itself
has no tobacco control. Smoker status moves both price and eligibility on nearly every final
expense product. **This looks like a real gap in our wizard, independent of anything Integrity
does.** Verify against the guides we already hold — several of our own product notes reference
smoker rules (Transamerica "any asthma + tobacco - DECLINE", Corebridge "not offered to smokers
71-80").

### Finding 3 — Their prescription→condition map is far finer than ours
Typing **Eliquis** offers seven conditions to attach:

- Atrial Fibrillation / Irregular Heartbeat (AFIB)
- Deep Venous Thrombosis (dvt)
- **Deep Venous Thrombosis (dvt) Prophylaxis**
- Pulmonary Embolism
- **Pulmonary Embolism Prophylaxis**
- Stroke And Systemic Embolism Prophylaxis In Nonvalvular Atrial Fibrillation
- **Thrombosis Prophylaxis**

Ours (`MED_FOR`) offers two: *Arrhythmia / AFib* and *Blood clots / DVT*.

The interesting part is not the count, it is **prophylaxis**. Someone on Eliquis to *prevent*
a clot after surgery is a different risk from someone with active AFib, and our tool cannot
currently tell those apart — it would flag both the same way. Whether the carriers actually
underwrite that distinction is the question to take to the guides.

### Structural note — their product taxonomy vs ours
They split by underwriting as separate product types:
Final Expense · Fully Underwritten IUL · Fully Underwritten Term · Simplified IUL · Simplified Term

We carry one "Show: Simplified issue / Both / Fully underwritten" toggle across three tabs.
Same concept, different shape. No action — ours is fine — but it explains why their product
counts will not line up with ours when comparing.

---

## Scenario matrix (to run)

Baseline used so far: OH · male · 5'10" · 232 lbs · non-tobacco · age 73.

| # | Scenario | Purpose |
|---|---|---|
| 1 | Clean 45, average build | floor — everyone should take them |
| 2 | Clean 72 | age bands |
| 3 | Clean 84 | top of the age range |
| 4 | Diabetic, pills, controlled | our most common real case |
| 5 | Diabetic on insulin, dx before 30 | Corebridge's own decline rule |
| 6 | Heart attack within 1 yr | recency windows |
| 7 | Heart attack 5 yrs ago | the other side of the window |
| 8 | COPD on oxygen | hard knockout |
| 9 | Cancer in remission 3 yrs | staging / recency |
| 10 | Heavy build, 5'9" 290 | build charts |
| 11 | Tobacco + asthma | comorbidity stacking |
| 12 | 4+ BP medications | Jesse's own rule — do they agree? |
| 13 | Eliquis, prophylaxis only | Finding 3 |
| 14 | Eliquis, active AFib | Finding 3, the other side |
| 15 | New York | the only state rule we hold |
| ... | (15 more to design once the first pass shows what moves) | |

Recorded per scenario: which carriers and products they surface, what questions they asked
to get there, and what our wizard says on identical inputs.

---

## SCOPE NARROWED — Jesse, 2026-09-26

*"I really like the simplicity of it. So I don't want to overcomplicate it... in the integrity
tool it's very confusing and it's too much. And then it gives all these products that nobody
even uses... return of premium products and stuff that it's confusing on."*

So this study is **not** a shopping list of their products. It is three questions only:

1. On a carrier we BOTH carry, do we ever disagree on a real condition case?
2. Which of their questions actually change an answer — neuropathy, gabapentin, heart
   surgery, time windows — versus which are noise?
3. Is there a product we are missing that is *writable*, i.e. that a guide exists for?

Anything else they show is theirs to show. We are not chasing row count.

---

## Scenario 1 — clean 73yo male, OH, 5'10" 232, non-tobacco, $15k

**Their result: 35 rows. Ours: 12 products.** That gap is almost entirely *granularity,
not coverage*, and it is the clearest argument for leaving our design alone.

They give every rate class its own row:

| Their rows | What it is |
|---|---|
| Eagle Select **1 / 2 / 3** | one Americo product, three rate classes |
| Living Promise **Level / Graded** | one MoO product, two outcomes |
| Senior Choice **Immediate / Graded / ROP** | one American Amicable product, three |
| PlanRight **Preferred / Standard / ROP** | one Foresters product, three |
| Express **Premier / Select / Graded** | one Transamerica product, three |
| SimpliNow **Level / Graded** | one Corebridge product, two |

**6 of their 35 rows are Return of Premium. 8 more are Graded variants.** Fourteen rows —
40% of the page — are the noise Jesse is describing. We carry the same carriers and explain
Level vs Graded *inside the cell*, which is one row instead of three and says more.

**Conclusion: do not add rows. The granularity difference is a feature of ours, not a gap.**

### They show, we do not carry
- **Aflac** (Preferred / Standard / Graded) — Jesse's standing note says no Aflac
- **Golden Solution** (Immediate / Graded / ROP) — American Amicable
- **Platinum Solution** (Immediate / Graded / ROP) — American Amicable
- **TruStage Advantage Whole Life $5k–$25k**
- **Primary Plan ROP**

Only worth chasing where a guide exists AND Jesse can write it. Golden Solution and Platinum
Solution are the two to ask about — we already carry American Amicable's Senior Choice, so an
appointment likely already covers them.

### We carry, they did not show
- Chubb / Combined Generational Life
- InstaBrain / Fidelity RAPIDecision FE + GI
- Accendo (Aetna/CVS) Final Expense
- Royal Neighbors Jet Whole Life

**The reverse gap is real and worth understanding** — four products we quote that their tool
did not surface for this client. Either Jesse is not appointed in their system, or they do not
carry them. If it is the former, their results will always look different and that is fine.

---

## Next: the cases that actually matter

Per Jesse's steer, the remaining runs are condition-driven, on carriers we both carry:

| # | Case | Why |
|---|---|---|
| A | Diabetes, pills, controlled | the everyday case |
| B | Diabetes + **neuropathy** | Jesse named it — does it move anyone? |
| C | **Gabapentin** with no stated condition | a drug that implies several things |
| D | Heart surgery **within 1 yr** vs **5 yrs** | the window, both sides |
| E | Eliquis **prophylaxis** vs **active AFib** | Finding 3 |
| F | 4+ BP medications | Jesse's own rule — do they agree? |

Recorded only where we disagree on a shared carrier.

---

## Scenario 2 (partial) — diabetes + Simplified IUL, 55yo male OH, 5'10" 200, non-tobacco

Did not reach a quote — their condition entry needs a "Date of Last Treatment" and my entry
did not stick, so it sat at *Incomplete*. Two findings landed on the way in regardless.

### Finding 4 — they let the agent pick the TYPE of diabetes, we do not
Typing "Diabetes" in their condition search offers nine:

Diabetes · Diabetes When Coadministered With Certain Medications · Diabetes Mellitus ·
Diabetes Insipidus · **Prediabetes** · **Type 2 Diabetes Mellitus** · **Type 1 Diabetes
Mellitus** · Neonatal Diabetes Mellitus · Gestational Diabetes

We have one condition, "Diabetes", with follow-ups underneath it.

**This is the false-negative risk Jesse is worried about, and it is real.** Our own
InstaBrain cell already reads *"Type I - DECLINE; Type II - DECLINE"* and Corebridge's reads
*"Insulin prior to age 50 - ROP; otherwise Immediate"*. So the guides DO underwrite the
distinction — we hold it in cell text but give the agent no way to select it, which means a
Type 2 client can only ever be shown the worst case across both types.

**Worth checking against the guides**: is there a carrier that takes Type 2 and declines
Type 1? If so, our tool is currently hiding a writable carrier from a Type 2 client.
Prediabetes is the same question in milder form — several of our cells mention it separately
("Pre-diabetes diagnosed after 40 - Standard Extra").

### Finding 5 — on diabetes, OUR follow-ups are richer than theirs
They ask one thing: **Date of Last Treatment**.
We ask four: diagnosed when · last A1C · pills or insulin · neuropathy.

Worth recording because it cuts against the assumption that their tool is always deeper. On
this condition we collect more of what the carriers actually rate on. No change needed.

---

## Practical note on running the remaining scenarios

Each scenario is roughly 15 browser actions: Quick Quote -> Life -> product type -> state,
gender, height, weight, tobacco, age -> continue -> condition search -> pick condition ->
answer its follow-up -> continue -> set page size -> extract. Their condition follow-ups are
modal dialogs that reject programmatic typing, so they need real clicks.

Thirty full scenarios is therefore a long grind rather than a quick sweep. Recommend running
Jesse's specific combinations rather than a broad matrix - they are the ones with a decision
attached:

- diabetes + IUL (does an IUL exist for a diabetic at all?)
- cancer 1 yr / 2 yrs / 5 yrs + IUL
- heart attack 6 mos / 12 mos / 2 yrs
- diabetes + heart attack 2 yrs ago
- diabetes on insulin vs on pills

---

## Scenario 2 COMPLETE — diabetes + Simplified IUL
55yo male · OH · 5'10" · 200 lbs · non-tobacco · Type 2, pills, no complications, A1C under 8.6

| | Result |
|---|---|
| **Integrity** | **2** Simplified IUL policies |
| **Ours** | **5** IUL products |

**Integrity:** IUL Express Easy Solve (= MoO IUL Express) · Intelligent Choice IUL Target

**Ours:** Foresters SMART UL · **MoO IUL Express** · NLG RapidProtect IUL ·
**Americo Instant Decision IUL** · F&G Everlast
*(ruled out: Transamerica FFIUL II Express on its diabetes rule, InstaBrain)*

### The answer to Jesse's worry, on this case: we show MORE, not fewer
We surfaced five where they surfaced two, and both of theirs appear to be in our five. **On
this scenario our tool is not hiding a writable carrier — it is more generous.**

Which raises the opposite question, and it is the one worth chasing: are Foresters, NLG and
F&G genuinely available to a diabetic here, or is our grid too loose on them? Two innocent
explanations first — their catalogue may not carry those three, or Jesse may not be appointed
with them in their system. ("My Appointed Products" was unchecked, so it should have shown
everything they carry.)

### Finding 6 — CORRECTION to Finding 5, and the real gap
Finding 5 said they ask one question about diabetes. **That was wrong** — I had only seen the
first dialog. The full chain is **thirteen** follow-ups:

date of last treatment · tobacco use within · 3+ medications · age of diagnosis ·
insulin dependent · treated for uncontrolled diabetes · most recent A1C ·
**complications (coma / insulin shock / retinopathy / neuropathy / nephropathy / amputation)** ·
comorbidities (heart disease / stroke / PVD) · medication changes in the past year ·
last hospitalization due to diabetes · **do you take insulin, and at what age did it start** ·
when did you last use insulin

Ours asks four: diagnosed when · last A1C · pills or insulin · neuropathy.

**Two of theirs are worth having, because our own guides already turn on them:**

1. **Insulin onset age.** They band it before 31 / 31-40 / 41-50 / after 50. Our Corebridge
   cell reads *"Insulin prior to age 50 - ROP; otherwise Immediate"* - the same line. We ask
   "pills or insulin" and never ask WHEN, so we cannot apply a rule our own guide states.
2. **Complications beyond neuropathy.** We ask neuropathy only. Retinopathy, nephropathy and
   amputation are severity markers carriers rate on, and we have no way to record them.

The other nine are the "too much" Jesse is describing. Thirteen dialogs to add one condition
is why agents call their tool confusing.

**Recommended: add two fields to our Diabetes follow-ups, not thirteen.**
`insulin onset age` and `complications (multi-select)`. Verify both against the guides first.

---

## Finding 7 — LEVOTHYROXINE IS MAPPED TO "AUTOIMMUNE DISORDER". Fix this one first.

Found by auditing our own condition list against what ordinary clients actually have — no
Integrity involved.

`MED_FOR["Levothyroxine"] = ["Autoimmune disorder"]`

Levothyroxine is one of the most prescribed drugs in the United States, and for the large
majority of people on it the condition is plain hypothyroidism: benign, Standard rates,
nobody blinks. Hashimoto's is one cause among several, and even Hashimoto's is usually a mild
rating rather than a decline.

**Measured impact.** 62-year-old woman, 5'6", 165 lbs:

| | matches | ruled out |
|---|---|---|
| clean | 20 | 3 |
| after accepting what the tool suggests | **17** | **4** |

Three products lost. And look at what the decline text actually says:

> **DECLINE (Sjogren's, Raynaud's, Guillain-Barre, myasthenia gravis, lupus)**

The guide is declining *those* diseases. Hypothyroidism is not among them. We are taking a
thyroid patient and routing them into a decline written for lupus and myasthenia gravis.

**Mitigating:** the agent is asked "Levothyroxine is usually for Autoimmune disorder — is
that why?" and can say No. So it is a prompt, not automatic. But the prompt is wrong, and an
agent who does not know better will say yes. That is the whole point of the prompt.

**Also note there is no "Thyroid" condition in our 110 at all**, so even an agent who
correctly rejects "Autoimmune disorder" has nowhere to record the thyroid. It vanishes.

**Recommended fix (verify against guides first):**
1. Add a **Thyroid / hypothyroidism** condition.
2. Re-point `MED_FOR["Levothyroxine"]` at it.
3. Keep Autoimmune disorder for the drugs that genuinely imply it (Humira, Enbrel, Plaquenil,
   Imuran, methotrexate — all already mapped).

Of everything in this study so far, this is the one most likely to have already cost a case.

### Condition-list audit, the rest
Our 110 conditions cover 17 of the 20 commonest client presentations. Genuinely missing:
- **Thyroid** — see above
- **Obesity** — correctly absent; it is the build chart, not a condition
- **Acid reflux / GERD** — ubiquitous but rarely underwritten; low priority

Medication table is internally sound otherwise: 106 medications, 122 mappings, **zero orphans**
(no medication points at a condition that does not exist).

---

## The 20 combinations to run

Chosen for what ordinary clients actually present with, weighted toward cases where our tool
and theirs could plausibly disagree.

| # | Combination | Why this one |
|---|---|---|
| 1 | High blood pressure alone, 2 meds | the single commonest case in the book |
| 2 | HBP + high cholesterol | near-universal pairing |
| 3 | HBP on 4+ medications | Jesse's own rule — do they agree? |
| 4 | Type 2 diabetes, pills | DONE — ours 5, theirs 2 |
| 5 | Type 2 diabetes + HBP | the commonest real combination |
| 6 | Diabetes on insulin, onset after 50 | the Corebridge ROP line |
| 7 | Diabetes on insulin, onset before 31 | the other side of it |
| 8 | Diabetes + neuropathy | Jesse named it |
| 9 | **Levothyroxine only** | Finding 7 — does their tool flag it benign? |
| 10 | Anxiety or depression, one medication | very common; are we too strict? |
| 11 | Sleep apnea + CPAP, BMI 38 | common, and build interacts |
| 12 | Heart attack 6 months ago | inside every window |
| 13 | Heart attack 24 months ago | outside most windows |
| 14 | Heart attack 3 yrs + stent + diabetes | the stacked case Jesse described |
| 15 | AFib on Eliquis | Finding 3 — prophylaxis vs active |
| 16 | Cancer, remission 1 yr | inside every window |
| 17 | Cancer, remission 5 yrs | should reopen most carriers |
| 18 | Stroke 4 yrs ago, no deficit | common at 65+ |
| 19 | COPD, non-smoker, no oxygen | mild end |
| 20 | Arthritis on prednisone | steroid rule |

Recorded only where the two tools disagree on a carrier both carry.

---

## Finding 8 — the medication list is not thin, it is targeted

Jesse: *"my Product Wizard doesn't have a lot of the medications that are listed in the
integrity quick quote. But is that because we don't need them?"*

**Mostly yes.** Two different jobs:

- **Theirs** is a drug lookup feeding a priced quote, so breadth is the point.
- **Ours** is a lie detector. Per the navigator's own comment: *"The med list is your lie
  detector. They'll say no heart problems while you're looking at Eliquis on your notepad."*
  A drug earns its place here only if it **implies a condition that is on our grids**. A drug
  that implies nothing underwritten is noise on the card and costs the agent attention.

So the test for adding a medication is not "does Integrity list it". It is: *does this drug
point at a condition we actually underwrite, and would we otherwise miss it?*

### Audited against that test — we are in good shape
**266 medication names** (106 base drugs plus brand aliases), and **every knockout class is
covered**:

| Class | Condition it implies | On our grids? | Covered? |
|---|---|---|---|
| Suboxone / buprenorphine / methadone / naltrexone | opioid dependence | yes | **yes** |
| Oxycodone, OxyContin, Hydrocodone, Norco, Percocet, Morphine, Fentanyl, Tramadol | major pain | yes | **yes** |
| Keppra, Dilantin, Lamictal, Depakote, Topamax | epilepsy / seizures | yes | **yes** |
| Abilify, Seroquel, Risperdal, Zyprexa, Lithium, Haldol | bipolar / schizophrenia | yes | **yes** |
| Aricept, Donepezil, Namenda, Memantine | Alzheimer's / dementia | yes | **yes** |
| Biktarvy, Truvada, Descovy | HIV | yes | **yes** |
| Tacrolimus, Prograf, Cyclosporine, CellCept | transplant | yes | **yes** |
| Tamoxifen, Arimidex, Femara, Gleevec | cancer history | yes | **yes** |
| Sevelamer, Renvela, Epogen | kidney failure / dialysis | yes | **yes** |
| Entresto, Digoxin, Lasix, Jardiance | heart failure | yes | **yes** |
| Spiriva, Trelegy, Breo, Symbicort, Advair | COPD | yes | **yes** |

### The real gaps are secondary brand names, not classes
Eleven, all inside classes we already cover. A client who says the brand we do not carry is
currently unrecognised, and the drug silently flags nothing:

`Tivicay` · `Genvoya` · `Atripla` (HIV) · `Latuda` (bipolar) · `Exelon` / `Rivastigmine`
(dementia) · `Carbamazepine` / Tegretol (seizure) · `Dilaudid` (opioid) · `Vivitrol`
(naltrexone depot) · `Sirolimus` (transplant) · `Calcitriol` · `Aranesp` (renal)

Cheap to add - they are alias rows pointing at conditions and MED_FOR entries that already
exist. No new conditions, no grid changes. **Do this; it is the whole medication gap.**

Remember the port rule in SOURCES.md: MEDS and MED_FOR are ported from the navigator and
guarded by check.sh in both the wizard and POP Pro. **Edit the navigator, then re-port.**

### Diseases we may want, from the guides rather than from Integrity
Only one so far, and it is Finding 7: **Thyroid / hypothyroidism**. It is absent from our 110,
and levothyroxine is currently mis-pointed at Autoimmune disorder because of it.

---

## Finding 9 — CORRECTION to Finding 8. Several drugs are recognised but inert.

Finding 8 checked whether a drug **name** was in the list and called the class "covered".
That was the wrong test. A name only does something if `MED_FOR` points it at a condition.
Checking the mappings instead:

### Drugs we recognise that derive NOTHING, where the grid row already exists

| Drug | Should imply | Grid row exists? | Today |
|---|---|---|---|
| **Suboxone, Methadone, Buprenorphine, Naltrexone** | Alcohol / drug abuse or treatment | **yes** | nothing |
| **Aricept, Namenda** | Alzheimer's / dementia | **yes** | nothing |
| **Abilify, Seroquel, Haloperidol** | Bipolar / Schizophrenia | **yes** | nothing |
| **Valproate** | Epilepsy / seizures (or Bipolar) | **yes** | nothing |
| **Imuran** | Autoimmune disorder | **yes** | nothing |
| **Methimazole** | Thyroid | no - see Finding 7 | nothing |

The first two are the serious ones.

**Suboxone** is named as a knockout in our own Transamerica notes ("Rx list also knocks out
... Suboxone-class"), and Jesse's veteran script explicitly coaches the agent toward it:
*"If he's on those, ask about Suboxone."* An agent types it in and the tool says nothing.

**Aricept and Namenda** are dementia drugs. Dementia is a hard decline on most of this book.
We recognise both names and derive nothing.

### Correctly silent - leave these alone
These are the non-starters Jesse described, and the design is working as intended:

Aspirin · Vitamin D · Potassium · Amoxicillin · Azithromycin · Doxycycline · Ibuprofen ·
Naproxen · Meloxicam · Celecoxib · Omeprazole · Pantoprazole · Famotidine · Alendronate ·
Tamsulosin · Finasteride · Sildenafil · Tadalafil · Colchicine

Major opioids (Oxycodone, Hydrocodone, Morphine, Fentanyl, Tramadol) are a judgement call:
they imply "major pain", which is not a grid row. Recommend leaving them silent as conditions
but they are worth a **prompt** rather than a condition - the script already coaches the agent
to ask about Suboxone when they appear.

### Two duplicate rows in MEDS
`Furosemide` and `Eliquis` each appear as a canonical row twice. Harmless today but it means
one copy carries aliases and the other does not, which is how an alias silently stops working.

### Revised work list
1. **Fix `MED_FOR`**: Suboxone-class -> drug abuse row; Aricept/Namenda -> dementia;
   Abilify/Seroquel/Haloperidol -> bipolar / schizophrenia; Valproate -> seizures; Imuran ->
   autoimmune.
2. **Add the Thyroid condition**, re-point Levothyroxine, map Methimazole to it.
3. **Add the eleven missing aliases** (Tivicay, Genvoya, Atripla, Latuda, Exelon, Carbamazepine,
   Dilaudid, Vivitrol, Sirolimus, Calcitriol, Aranesp).
4. **De-duplicate** the Furosemide and Eliquis rows.

All four are edits to the NAVIGATOR, then a re-port to the wizard and POP Pro, per SOURCES.md.
Every mapping verified against the guides before it ships.
