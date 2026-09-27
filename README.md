# occt-snow-leopard

Build **OpenCASCADE (OCCT) 7.6.0** static for **Mac OS X 10.6.8 / i386**
(the DataExchange/STEP toolkits, as used by Bambu Studio).

```sh
./build.sh      # -> prefix/lib/libTK*.a (i386, incl. TKSTEP*)
```

Key 10.6/i386 fixes:
- clang/`ld64-274` toolchain (stock `ld64-127` fails on i386 unwind atoms).
- `occt_fixups.py`: `StdPrs_BRepFont.cxx` `const char*` cast (clang-16 rejects
  the implicit `unsigned char* -> const char*`).
- Upstream `0001-OCCT-fix.patch`; static, no TK/TBB/FFMPEG/VTK/Draw/Viz.
