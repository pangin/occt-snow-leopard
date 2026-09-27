#!/usr/bin/env python
# Idempotent clang-16 / i386 source fixups for OCCT 7.6.0, applied after the
# upstream deps/OCCT/0001-OCCT-fix.patch. Add entries here as errors surface.
# Usage: /usr/bin/python occt_fixups.py <OCCT source root>
import sys, os

root = sys.argv[1]

FIXUPS = [
    # clang-16 rejects const char* <- unsigned char* (FreeType tags array).
    ("src/StdPrs/StdPrs_BRepFont.cxx",
     "= &anOutline->tags[aStartIndex];",
     "= (const char* )&anOutline->tags[aStartIndex];"),
]

for rel, old, new in FIXUPS:
    p = os.path.join(root, rel)
    try:
        s = open(p).read()
    except IOError:
        print("MISS %s (file not found)" % rel); continue
    if new in s:
        print("skip %s" % rel)
    elif old in s:
        open(p, "w").write(s.replace(old, new, 1))
        print("fix  %s" % rel)
    else:
        print("MISS %s (pattern not found)" % rel)
