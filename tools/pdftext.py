import re, zlib, sys

def extract(path):
    raw = open(path,'rb').read()
    out = []
    for m in re.finditer(rb'stream\r?\n(.*?)endstream', raw, re.S):
        data = m.group(1)
        try: data = zlib.decompress(data)
        except Exception:
            try: data = zlib.decompressobj().decompress(data)
            except Exception: continue
        if b'Tj' not in data and b'TJ' not in data: continue
        txt = []
        for tm in re.finditer(rb'\((?:\\.|[^\\()])*\)|TJ|Tj|T\*|Td|TD', data, re.S):
            tok = tm.group(0)
            if tok in (b'T*', b'Td', b'TD'): txt.append('\n')
            elif tok in (b'TJ', b'Tj'): pass
            else:
                s = tok[1:-1]
                s = re.sub(rb'\\([()\\])', rb'\1', s)
                s = s.replace(b'\\n', b' ').replace(b'\\r', b' ').replace(b'\\t',b' ')
                s = re.sub(rb'\\[0-7]{1,3}', b'', s)
                txt.append(s.decode('latin-1'))
        page = ''.join(txt)
        page = re.sub(r'\n{2,}', '\n', page)
        if page.strip(): out.append(page)
    return out

if __name__ == '__main__':
    pages = extract(sys.argv[1])
    print(f"### {len(pages)} text streams extracted", file=sys.stderr)
    for i,p in enumerate(pages,1):
        print(f"\n===== STREAM {i} =====")
        print(p)

# Usage: python3 tools/pdftext.py docs/guides/<file>.pdf > out.txt
# Written because this Mac has no poppler/pdftotext. Output can contain NUL bytes
# from two-byte font encodings, which makes grep treat it as binary — strip them:
#   python3 -c "import sys;sys.stdout.write(open(sys.argv[1],encoding='latin-1').read().replace(chr(0),''))" out.txt > clean.txt
