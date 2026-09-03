# Optimum Tool Suite — Brand Kit

Paste this whole file into any thread that builds or edits an Optimum tool or site.
It is the single source of truth for the suite's look and wording. Follow it exactly;
do not invent a different palette, font, header, or credit line.

## What this is
A suite of free tools for insurance agents. Every tool must look like it came from
the same family and point back to Optimum (optimumprotects.com).
Reference implementations: `Insurance-Agent-Planning-Tools.html` and
`insurance-script-navigator.html`. Match them.

## Wording (fixed)
- Suite tagline, under every tool's title in the header: **Tools built for agents, by agents**
- Credit line in the header: **Brought to you by Optimum** (Optimum links to https://optimumprotects.com/)
- Footer credit on every page: **Built for insurance agents by Optimum.**
- Credit Optimum, not Jesse by name.
- Sentence case everywhere. No all-caps tracked-out labels in new work.

## Header (copy exactly, change only the tool name)
```html
<header class="o-header">
  <div>
    <div class="o-title">NAME OF THIS TOOL</div>
    <div class="o-sub">Tools built for agents, by agents <span class="o-sep">&middot;</span>
      Brought to you by <a href="https://optimumprotects.com/" target="_blank" rel="noopener">Optimum</a></div>
  </div>
  <a class="o-pill" href="https://goatleads.com/registration/new?affiliate_id=66c4aa379e0123651ad2f0e6"
     target="_blank" rel="noopener">&#9733; FREE Agent Website, Digital Business Card &amp; Booking Calendar</a>
</header>
```
The pill is solid gold with navy text and turns blue with white text on hover. It always sits top-right.

## Footer (copy exactly)
```html
<p class="o-footer">Built for insurance agents by
  <a href="https://optimumprotects.com/" target="_blank" rel="noopener">Optimum</a>.</p>
```

## Rules of the look
- Cream page (`--cream`), white cards with a 1px `--rule` border. No gradients, no grey drop-shadow kit.
- Navy is the only dark surface: the header band, primary buttons, headings.
- Gold is an accent, not a fill: wordmark, active-tab underline, big step numerals, hover borders, the header pill.
  Use `--golddk` for gold text on cream (contrast); `--gold` for gold on navy.
- Headings and the wordmark are Source Serif 4. Everything else is Inter. Mono only for code.
- Rust (`--rust`) is reserved for real user-facing warnings (e.g. chargeback warnings). Green for good/positive.
  Nothing else gets a colour.
- Do NOT reuse the "Rates not verified" build-note style (dashed grey box, mono label) anywhere — it is a
  one-off in the Commission Calculator that Jesse styles himself.

## Fonts
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,400&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

## Theme CSS (paste into a `<style>` block or save as optimum-theme.css)
```css
/* ==========================================================================
   Optimum — shared theme tokens
   Drop this file into any tool or site in the suite, or paste the :root block
   into a <style>. Every Optimum tool uses these names so a colour change here
   propagates everywhere.
   Fonts: <link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,400&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
   ========================================================================== */
:root{
  /* surfaces */
  --cream:#F5F1E8;      /* page background */
  --card:#FFFFFF;       /* cards, sheets, inputs */
  --fill:#FAF8F2;       /* subtle panel fill inside cards */
  --rule:#E3DFD4;       /* borders and dividers */
  --rule-soft:#EDE9DF;

  /* text */
  --ink:#1B1B1B;        /* body text */
  --slate:#4A4A44;      /* secondary text */
  --muted:#8B8A82;      /* captions, hints */

  /* brand */
  --navy:#16203C;       /* header band, primary buttons, headings */
  --navy-deep:#101832;
  --blue:#2C4A7C;       /* links, secondary emphasis */
  --bluesoft:#EDF1F8;
  --gold:#C9A24E;       /* wordmark, accents on navy */
  --golddk:#A8853A;     /* gold used as text on cream (better contrast) */
  --goldsoft:#F4EBD5;   /* gold tint backgrounds */
  --goldline:#E6D6AE;   /* gold tint borders */

  /* status */
  --green:#3F7A56;  --greensoft:#EDF4EF;
  --rust:#A8452F;   --rustsoft:#F8EEEB;

  /* type */
  --serif:'Source Serif 4',Georgia,'Times New Roman',serif;   /* headings, wordmark */
  --sans:'Inter',-apple-system,'Segoe UI',Roboto,sans-serif;  /* everything else */
  --mono:ui-monospace,Menlo,Consolas,monospace;

  /* shape */
  --radius:12px; --radius-sm:8px; --radius-pill:999px;
  --shadow:0 1px 2px rgba(22,32,60,.06);
  --shadow-lift:0 10px 24px rgba(22,32,60,.12);
}

/* ---- Base ---- */
body{background:var(--cream);color:var(--ink);font-family:var(--sans);margin:0;
     -webkit-font-smoothing:antialiased}
h1,h2,h3,.serif{font-family:var(--serif);color:var(--navy);font-weight:700;letter-spacing:-.015em;line-height:1.15}
a{color:var(--blue)}

/* ---- Brand band: same on every tool ---- */
.o-header{background:var(--navy);color:#fff;padding:13px 20px;display:flex;align-items:center;gap:14px}
.o-brand{font-family:var(--serif);font-weight:700;font-size:20px;color:var(--gold);text-decoration:none;white-space:nowrap}
.o-brand small{display:block;font-family:var(--sans);font-weight:500;font-size:11px;color:rgba(255,255,255,.65);letter-spacing:.01em;margin-top:1px}
.o-pill{font-family:var(--sans);font-size:12px;font-weight:600;color:#fff;border:1px solid rgba(255,255,255,.3);
        background:transparent;border-radius:var(--radius-pill);padding:7px 14px;text-decoration:none;cursor:pointer}
.o-pill:hover{background:var(--gold);border-color:var(--gold);color:var(--navy)}
.o-pill.solid{background:var(--gold);border-color:var(--gold);color:var(--navy)}

/* ---- Common pieces ---- */
.o-card{background:var(--card);border:1px solid var(--rule);border-radius:var(--radius);box-shadow:var(--shadow)}
.o-btn{font-family:var(--sans);font-weight:600;font-size:14px;background:var(--navy);color:#fff;border:0;
       border-radius:var(--radius-sm);padding:12px 18px;cursor:pointer}
.o-btn:hover{background:var(--blue)}
.o-btn.ghost{background:transparent;color:var(--navy);border:1px solid var(--rule)}
.o-footer{font-size:12px;color:var(--muted);text-align:center;padding:24px 16px;line-height:1.7}
.o-footer a{color:var(--golddk);font-weight:600;text-decoration:none}
.o-footer a:hover{text-decoration:underline}
:focus-visible{outline:2px solid var(--gold);outline-offset:2px}

/* header pieces used by the snippet above */
.o-title{font-family:var(--serif);font-weight:700;font-size:20px;color:#fff;letter-spacing:-.01em;white-space:nowrap}
.o-sub{font-size:12px;font-weight:500;color:rgba(255,255,255,.62);margin-top:3px}
.o-sub .o-sep{color:rgba(255,255,255,.35);margin:0 4px}
.o-sub a{color:var(--gold);font-family:var(--serif);font-weight:700;font-size:13.5px;text-decoration:none}
.o-sub a:hover{color:#fff}
.o-pill{margin-left:auto;background:var(--gold);color:var(--navy);border:1px solid var(--gold);font-weight:700;font-size:12.5px;padding:8px 16px}
.o-pill:hover{background:var(--blue);border-color:var(--blue);color:#fff}
@media(max-width:640px){.o-header{flex-wrap:wrap} .o-pill{width:100%;justify-content:center;margin:6px 0 0}}
```

## Cross-linking the suite (every tool carries this)
Two pieces, identical on every tool:

1. **Header switcher** — an outlined "More free tools ▾" button next to the gold pill. Its menu lists all tools
   (current one greyed with "you're here") plus the free website/card offer. Markup, placed after the gold pill:
   ```html
   <div class="o-suite"><button type="button">More free tools &#9662;</button><div class="o-suite-menu"></div></div>
   ```
2. **One contextual "next step" card** per tool, dashed gold border, placed at the moment the other tool becomes useful
   (e.g. under results, under the home cards). Links use `data-suite="wizard|navigator|planning"` and get their URL
   from the config automatically:
   ```html
   <div class="o-next">
     <div class="k">Next step</div>
     <a data-suite="navigator" href="#"><span class="n">&rarr;</span><div><b>Run the call</b><span>One line on why.</span></div></a>
   </div>
   ```

Paste the block below before `</body>` of every tool (before the LAST `</body>` if the file has print templates),
and set `SUITE_CURRENT` to the tool's key. **URLs live only in the `SUITE` config** — when a tool's domain changes,
update that one object in each file. Tool cross-links are cream/navy (helping); the GOAT offer stays gold (selling).

```html
<!-- ===== OPTIMUM SUITE: cross-links to the other free tools (shared across all tools) ===== -->
<style>
.o-suite{position:relative;margin-left:8px;font-family:'Inter',-apple-system,'Segoe UI',Roboto,sans-serif}
.o-suite>button{font:inherit;font-size:12px;font-weight:600;color:#fff;background:transparent;border:1px solid rgba(255,255,255,.3);border-radius:999px;padding:7px 14px;cursor:pointer;white-space:nowrap}
.o-suite>button:hover,.o-suite>button[aria-expanded="true"]{border-color:#fff}
.o-suite-menu{display:none;position:absolute;right:0;top:calc(100% + 8px);width:340px;max-width:calc(100vw - 24px);background:#fff;border:1px solid #E3DFD4;border-radius:12px;box-shadow:0 14px 34px rgba(22,32,60,.18);padding:8px;z-index:200;text-align:left}
.o-suite.open .o-suite-menu{display:block}
.o-suite-menu .k{font-size:11px;font-weight:600;color:#8B8A82;padding:8px 10px 4px}
.o-suite-menu a{display:block;text-decoration:none;color:#1B1B1B;padding:9px 10px;border-radius:8px}
.o-suite-menu a:hover{background:#FAF8F2}
.o-suite-menu a b{display:block;font-family:'Source Serif 4',Georgia,serif;font-size:15px;color:#16203C;font-weight:700}
.o-suite-menu a span{font-size:12px;color:#4A4A44;line-height:1.45}
.o-suite-menu a.cur{opacity:.5;pointer-events:none}
.o-suite-menu a.cur b::after{content:" · you're here";font-family:'Inter',sans-serif;font-size:11px;font-weight:500;color:#8B8A82}
.o-suite-menu .sgoat{margin:6px 4px 2px;border-top:1px solid #EDE9DF;padding-top:10px}
.o-suite-menu .sgoat a{color:#A8853A;font-weight:600;font-size:12.5px;padding:4px 6px}
.o-suite-menu .sgoat a:hover{background:transparent;text-decoration:underline}
.o-next{background:#fff;border:1px dashed #C9A24E;border-radius:12px;padding:16px 20px;display:flex;gap:18px;align-items:center;flex-wrap:wrap;font-family:'Inter',-apple-system,'Segoe UI',Roboto,sans-serif}
.o-next[hidden]{display:none}
.o-next .k{font-size:12px;font-weight:600;color:#8B8A82;flex:0 0 100%}
.o-next a{flex:1 1 220px;text-decoration:none;color:#1B1B1B;display:flex;gap:10px;align-items:flex-start}
.o-next a .n{font-family:'Source Serif 4',Georgia,serif;font-size:30px;line-height:1;color:#C9A24E;flex:0 0 auto;min-width:22px}
.o-next a b{display:block;font-family:'Source Serif 4',Georgia,serif;font-size:16px;color:#16203C;font-weight:700}
.o-next a span{font-size:12.5px;color:#4A4A44;line-height:1.45}
.o-next a:hover b{color:#2C4A7C;text-decoration:underline}
@media(max-width:640px){.o-suite{margin-left:0}.o-suite-menu{right:auto;left:0}}
</style>
<script>
/* ---- SUITE CONFIG: edit URLs here only. Same block lives in every tool. ---- */
var SUITE = {
  wizard:    { name:'Insurance Product Wizard',  url:'https://REPLACE-ME-wizard.example.com/',
               blurb:'Enter age and conditions — see which IUL, term and final expense products a client can buy.' },
  navigator: { name:'Insurance Script Navigator', url:'https://REPLACE-ME-navigator.example.com/',
               blurb:'Card-by-card call scripts for veteran life, IUL and mortgage protection.' },
  planning:  { name:'Agent Planning Tools',       url:'https://REPLACE-ME-planning.example.com/',
               blurb:'Income, activity, agency and commission calculators that pass numbers to each other.' },
  goat:      { name:'Free agent website, digital card & booking calendar',
               url:'https://goatleads.com/registration/new?affiliate_id=66c4aa379e0123651ad2f0e6' }
};
var SUITE_CURRENT = 'wizard';
(function(){
  function menuHTML(){
    var h='<div class="k">Free tools from Optimum</div>';
    ['wizard','navigator','planning'].forEach(function(k){
      var t=SUITE[k], cur=(k===SUITE_CURRENT);
      h+='<a href="'+t.url+'" class="'+(cur?'cur':'')+'"'+(cur?' aria-current="page"':' target="_blank" rel="noopener"')+'><b>'+t.name+'</b><span>'+t.blurb+'</span></a>';
    });
    h+='<div class="sgoat"><a href="'+SUITE.goat.url+'" target="_blank" rel="noopener">&#9733; '+SUITE.goat.name+' &rarr;</a></div>';
    return h;
  }
  function init(){
    document.querySelectorAll('.o-suite').forEach(function(s){
      var btn=s.querySelector('button'), menu=s.querySelector('.o-suite-menu');
      if(!btn||!menu) return;
      menu.innerHTML=menuHTML();
      btn.setAttribute('aria-haspopup','true'); btn.setAttribute('aria-expanded','false');
      btn.addEventListener('click',function(e){e.stopPropagation();var o=!s.classList.contains('open');
        document.querySelectorAll('.o-suite.open').forEach(function(x){x.classList.remove('open');x.querySelector('button').setAttribute('aria-expanded','false');});
        s.classList.toggle('open',o); btn.setAttribute('aria-expanded',o?'true':'false');});
    });
    document.addEventListener('click',function(){document.querySelectorAll('.o-suite.open').forEach(function(x){x.classList.remove('open');x.querySelector('button').setAttribute('aria-expanded','false');});});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.o-suite.open').forEach(function(x){x.classList.remove('open');x.querySelector('button').setAttribute('aria-expanded','false');});});
    // contextual cards: <a data-suite="navigator"> gets its href from SUITE
    document.querySelectorAll('[data-suite]').forEach(function(a){var t=SUITE[a.getAttribute('data-suite')]; if(t){a.href=t.url; a.target='_blank'; a.rel='noopener';}});
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',init); else init();
})();
</script>
<!-- ===== /OPTIMUM SUITE ===== -->

```
