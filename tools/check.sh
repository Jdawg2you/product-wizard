#!/bin/bash
# Pre-push checks for index.html. Run from the repo root: tools/check.sh
#
# Exists because a stray pair of double quotes inside a double-quoted string once
# shipped to production: it threw SyntaxError, which kills the ENTIRE main script,
# so the live site rendered a dead shell. Grepping the deployed HTML for expected
# text passed happily — text was present, the file just didn't parse.
#
# Uses JavaScriptCore, which ships with macOS. No node, no install.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

JSC="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Helpers/jsc"
FILE="index.html"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAIL=0

if [ ! -x "$JSC" ]; then
  echo "FAIL  JavaScriptCore not found at $JSC"
  exit 2
fi

# ---- split out every <script> block -------------------------------------------------
python3 - "$FILE" "$TMP" <<'PY'
import re, sys, io, os
src = io.open(sys.argv[1], encoding='utf-8').read()
blocks = re.findall(r'<script>(.*?)</script>', src, re.S)
for i, b in enumerate(blocks):
    io.open(os.path.join(sys.argv[2], 'block%d.js' % i), 'w', encoding='utf-8').write(b)
PY
N=$(ls "$TMP"/block*.js 2>/dev/null | wc -l | tr -d ' ')

# ---- 1. does every block parse? -----------------------------------------------------
for f in "$TMP"/block*.js; do
  OUT=$("$JSC" -e "
    var src = readFile('$f');
    try { new Function(src); print('OK'); }
    catch (e) { print('SYNTAX ERROR: ' + e.message); }
  " 2>&1)
  if [ "$OUT" = "OK" ]; then
    echo "ok    $(basename "$f") parses"
  else
    echo "FAIL  $(basename "$f"): $OUT"
    FAIL=1
  fi
done

# ---- 2. does the app run, and is every grid row aligned? ----------------------------
# A row is [conditionName, cell1, ...] with one cell per carrier. Miss one and every
# cell after it silently belongs to the wrong carrier — wrong underwriting, no error.
if [ "$FAIL" -eq 0 ] && [ -f "$TMP/block0.js" ]; then
  OUT=$("$JSC" -e "
    var mk = function(id){ return {id:id, innerHTML:'', textContent:'', hidden:false, value:'',
      classList:{add:function(){},remove:function(){},toggle:function(){},contains:function(){return false}},
      setAttribute:function(){}, getAttribute:function(){return null}, addEventListener:function(){},
      querySelectorAll:function(){return []}, querySelector:function(){return mk()},
      dataset:{}, showModal:function(){}, options:[], focus:function(){}, scrollIntoView:function(){} }; };
    var els = {};
    globalThis.document = { querySelector:function(s){ return els[s] || (els[s]=mk(s)); },
      querySelectorAll:function(){ return []; }, createElement:function(){ return mk(); },
      addEventListener:function(){}, getElementById:function(s){ return els[s] || (els[s]=mk(s)); },
      readyState:'complete', head:mk('head'), body:mk('body') };
    globalThis.window = globalThis;
    globalThis.localStorage = { _:{}, getItem:function(k){ return this._[k]||null; },
      setItem:function(k,v){ this._[k]=v; }, removeItem:function(k){ delete this._[k]; } };
    globalThis.MutationObserver = function(){ return {observe:function(){}}; };
    var src = readFile('$TMP/block0.js');
    try {
      var run = new Function(src + ';return {DATA:DATA, COND:COND, render:render};');
      var app = run();
      var bad = [];
      ['wl','term','iul'].forEach(function(k){
        var n = app.DATA[k].carriers.length;
        app.DATA[k].rows.forEach(function(r){
          if (r.cells.length !== n) bad.push(k + ' \"' + r.name + '\" has ' + r.cells.length + ' cells, expected ' + n);
        });
      });
      if (bad.length) { print('MISALIGNED:'); bad.slice(0,10).forEach(print); }
      else print('ALIGNED ' + ['wl','term','iul'].map(function(k){
        return k + '=' + app.DATA[k].carriers.length + 'x' + app.DATA[k].rows.length; }).join(' '));
    } catch (e) { print('RUNTIME ERROR: ' + e.message); }
  " 2>&1)
  case "$OUT" in
    ALIGNED*) echo "ok    $OUT" ;;
    *)        echo "FAIL  $OUT"; FAIL=1 ;;
  esac
fi

# ---- 3. still in step with the Script Navigator? -----------------------------------
# The navigator hands this page its conditions by name, and the medication tables here are a
# copy of its own. Either can drift without an error on either side: a renamed row silently
# stops matching, and a stale medication table quietly asks about the wrong condition. This
# is the check that would have caught "Active cancer" before anyone noticed it by hand.
NAV_SRC="${NAV_FILE:-$HOME/script-navigator/index.html}"
NAV="$TMP/navigator.html"
if [ -f "$NAV_SRC" ]; then cp "$NAV_SRC" "$NAV"; NAVFROM="$NAV_SRC"
elif curl -fs --max-time 20 https://script.ffloptimum.com/ -o "$NAV"; then NAVFROM="script.ffloptimum.com"
else NAV=""; fi

if [ "$FAIL" -eq 0 ] && [ -n "$NAV" ]; then
  cat > "$TMP/stub.js" <<'JS'
var mk = function(id){ return {id:id, innerHTML:'', textContent:'', hidden:false, value:'',
  classList:{add:function(){},remove:function(){},toggle:function(){},contains:function(){return false}},
  setAttribute:function(){}, getAttribute:function(){return null}, addEventListener:function(){},
  querySelectorAll:function(){return []}, querySelector:function(){return mk()},
  dataset:{}, showModal:function(){}, options:[], focus:function(){}, scrollIntoView:function(){} }; };
var els = {};
globalThis.document = { querySelector:function(s){ return els[s] || (els[s]=mk(s)); },
  querySelectorAll:function(){ return []; }, createElement:function(){ return mk(); },
  addEventListener:function(){}, getElementById:function(s){ return els[s] || (els[s]=mk(s)); },
  readyState:'complete', head:mk('head'), body:mk('body') };
globalThis.window = globalThis;
globalThis.localStorage = { _:{}, getItem:function(k){ return this._[k]||null; },
  setItem:function(k,v){ this._[k]=v; }, removeItem:function(k){ delete this._[k]; } };
globalThis.MutationObserver = function(){ return {observe:function(){}}; };
JS
  "$JSC" -e "
    eval(readFile('$TMP/stub.js'));
    try { var names = new Function(readFile('$TMP/block0.js') + ';return COND.map(function(c){return c.name});')();
          print(JSON.stringify(names)); }
    catch (e) { print('ERR ' + e.message); }
  " > "$TMP/wiz_conds.json" 2>&1

  cat > "$TMP/sync.py" <<'PY2'
import io, re, sys, json
nav = io.open(sys.argv[1], encoding='utf-8').read()
wiz = io.open(sys.argv[2], encoding='utf-8').read()
raw = io.open(sys.argv[3], encoding='utf-8').read().strip()
if raw.startswith('ERR'): print('could not load the conditions on this page: ' + raw); sys.exit()
have = set(json.loads(raw))
def span(src, pat, o, c):
    m = re.search(pat, src)
    if not m: return None
    i = src.index(o, m.start()); d = 0
    for k in range(i, len(src)):
        if src[k] == o: d += 1
        elif src[k] == c:
            d -= 1
            if d == 0: return src[i:k+1]
def medfor(src):
    b = span(src, r'(?:var|const|let)\s+MED_FOR\s*=', '{', '}') or ''
    return {k.strip(): tuple(sorted(re.findall(r'"([^"]+)"', v)))
            for k, v in re.findall(r'["\']?([^"\':,{}\[\]]+?)["\']?\s*:\s*\[([^\]]*)\]', b)}
problems = []
nm, wm = medfor(nav), medfor(wiz)
if not nm: problems.append('could not read MED_FOR from the navigator')
elif nm != wm:
    extra = sorted(set(nm) ^ set(wm)); moved = sorted(k for k in set(nm) & set(wm) if nm[k] != wm[k])
    problems.append('MED_FOR differs from the navigator - drugs on one side only: %s; mapped differently: %s'
                    % (extra[:8] or 'none', moved[:8] or 'none'))
norm = lambda b: re.sub(r'\s+', '', b or '')
if norm(span(nav, r'(?:var|const|let)\s+MEDS\s*=', '[', ']')) != norm(span(wiz, r'(?:var|const|let)\s+MEDS\s*=', '[', ']')):
    problems.append('MEDS differs from the navigator')
pc = span(nav, r'var\s+PF_CONDS\s*=', '[', ']') or ''
names = set(re.findall(r'"([^"]+)"', pc)) | set(re.findall(r'\{\{c:([^}]+)\}\}', nav))
names |= set(c for v in nm.values() for c in v)
missing = sorted(n for n in names if n not in have)
if missing: problems.append('navigator conditions with no match here: ' + ', '.join(missing))
if problems: print(' | '.join(problems))
else: print('SYNCED %d medications, %d condition names' % (len(nm), len(names)))
PY2
  OUT=$(python3 "$TMP/sync.py" "$NAV" "$FILE" "$TMP/wiz_conds.json")
  case "$OUT" in
    SYNCED*) echo "ok    $OUT (against $NAVFROM)" ;;
    *)       echo "FAIL  $OUT"; echo "      against $NAVFROM"; FAIL=1 ;;
  esac
elif [ -z "$NAV" ]; then
  echo "warn  navigator not found locally or online - sync with it was not checked"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "PASS  $N script block(s) parse; all grid rows aligned; in step with the navigator."
  echo "      Still load the preview and look at it before pushing."
else
  echo "FAILED — do not push."
fi
exit $FAIL
