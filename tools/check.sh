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

echo
if [ "$FAIL" -eq 0 ]; then
  echo "PASS  $N script block(s) parse; all grid rows aligned."
  echo "      Still load the preview and look at it before pushing."
else
  echo "FAILED — do not push."
fi
exit $FAIL
