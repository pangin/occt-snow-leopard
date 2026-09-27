#!/bin/bash
# Build OpenCASCADE (OCCT) 7.6.0 static for i386/10.6 — STEP import for libslic3r.
# Trimmed to DataExchange (+deps); no TK/TBB/FFMPEG/VTK/Draw/Viz.
. "$(dirname "$0")/common.sh"
VER=V7_6_0
URL="https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/${VER}.zip"
SRCDIR="$DEPS_BUILD/OCCT-7_6_0"          # GitHub strips the leading 'V'
mkdir -p "$DEPS_BUILD" "$DEPS_PREFIX"
if [ ! -d "$SRCDIR" ]; then
  cd "$DEPS_BUILD"
  [ -f "occt-${VER}.zip" ] || curl -fL -o "occt-${VER}.zip" "$URL"
  unzip -q "occt-${VER}.zip"
fi
if [ ! -f "$SRCDIR/.sl_patched" ]; then
  ( cd "$SRCDIR" && git apply --ignore-space-change --whitespace=fix \
      "$ROOT/0001-OCCT-fix.patch" ) \
    && touch "$SRCDIR/.sl_patched" || { echo "ERROR: OCCT patch failed"; exit 1; }
fi
# clang-16 / i386 source fixups (idempotent)
/usr/bin/python "$ROOT/occt_fixups.py" "$SRCDIR"
cmake -S "$SRCDIR" -B "$DEPS_BUILD/OCCT-build" \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DBUILD_LIBRARY_TYPE=Static \
  -DUSE_TK=OFF -DUSE_TBB=OFF -DUSE_FFMPEG=OFF -DUSE_VTK=OFF \
  -DBUILD_DOC_Overview=OFF \
  -DBUILD_MODULE_ApplicationFramework=OFF \
  -DBUILD_MODULE_Draw=OFF \
  -DBUILD_MODULE_FoundationClasses=OFF \
  -DBUILD_MODULE_ModelingAlgorithms=OFF \
  -DBUILD_MODULE_ModelingData=OFF \
  -DBUILD_MODULE_Visualization=OFF
set +e
cmake --build "$DEPS_BUILD/OCCT-build" -j2 && cmake --install "$DEPS_BUILD/OCCT-build"
rc=$?; set -e
echo "OCCT-DONE rc=$rc"
[ $rc -eq 0 ] && ls "$DEPS_PREFIX"/lib/libTKSTEP* 2>/dev/null
