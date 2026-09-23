#!/bin/sh
# Rebuilds bin/rastertobrlaser and ppd/ from Owl-Maintain/brlaser (the maintained fork).
# Usage: ./build.sh [tag]   (default: v6.2.8; "master" builds the current branch)
# Needs Xcode Command Line Tools and cmake (brew install cmake).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REF=${1:-v6.2.8}
WORK="$(mktemp -d)"
if [ "$REF" = master ]; then URL="https://github.com/Owl-Maintain/brlaser/archive/refs/heads/master.tar.gz"; else URL="https://github.com/Owl-Maintain/brlaser/archive/refs/tags/$REF.tar.gz"; fi
curl -sL -o "$WORK/brlaser.tar.gz" "$URL"
mkdir "$WORK/src" && tar xzf "$WORK/brlaser.tar.gz" -C "$WORK/src" --strip-components 1
cd "$WORK/src"
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release >/dev/null
cmake --build build >/dev/null
(cd build && ctest >/dev/null)
mkdir -p build/ppd && ppdc build/brlaser.drv -d build/ppd >/dev/null
rm -rf "$HERE/ppd"; mkdir -p "$HERE/bin" "$HERE/ppd"
cp build/rastertobrlaser "$HERE/bin/"
codesign -s - -f "$HERE/bin/rastertobrlaser"
for f in build/ppd/*.ppd; do
  n=$(basename "$f")
  # absolute filter path (macOS has no filter search path for /Library/Printers) ...
  sed 's|\*cupsFilter: "application/vnd.cups-raster 33 rastertobrlaser"|*cupsFilter: "application/vnd.cups-raster 33 /Library/Printers/brlaser/rastertobrlaser"|' "$f" > "$HERE/ppd/$n"
  # ... and tell macOS that DCP/MFC queues have an ICA scanner (enables "Open Scanner")
  if grep -q -E '^\*ModelName: "Brother (DCP|MFC)' "$HERE/ppd/$n"; then
    sed -i '' 's|^\*cupsFilter:.*|&\
*APICADriver: True|' "$HERE/ppd/$n"
  fi
done
echo "Built brlaser $REF: $(file -b "$HERE/bin/rastertobrlaser" | cut -d, -f1-2), $(ls "$HERE/ppd" | wc -l | tr -d ' ') PPDs"
