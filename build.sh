#!/bin/sh
# Rebuilds bin/rastertobrlaser and ppd/ from brlaser source (https://github.com/pdewacht/brlaser).
# Needs Xcode Command Line Tools and cmake (brew install cmake).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
REF=${1:-master}
WORK="$(mktemp -d)"
curl -sL -o "$WORK/brlaser.tar.gz" "https://github.com/pdewacht/brlaser/archive/$( [ "$REF" = master ] && echo refs/heads/master.tar.gz || echo refs/tags/v$REF.tar.gz )"
tar xzf "$WORK/brlaser.tar.gz" -C "$WORK"
cd "$WORK"/brlaser-*
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 >/dev/null
cmake --build build >/dev/null
mkdir -p build/ppd && ppdc build/brlaser.drv -d build/ppd >/dev/null
mkdir -p "$HERE/bin" "$HERE/ppd"
cp build/rastertobrlaser "$HERE/bin/"
codesign -s - -f "$HERE/bin/rastertobrlaser"
for f in build/ppd/*.ppd; do
  n=$(basename "$f")
  sed 's|\*cupsFilter: "application/vnd.cups-raster 33 rastertobrlaser"|*cupsFilter: "application/vnd.cups-raster 33 /Library/Printers/brlaser/rastertobrlaser"|' "$f" > "$HERE/ppd/$n"
  if grep -q -E '^\*ModelName: "Brother (DCP|MFC)' "$HERE/ppd/$n"; then
    sed -i '' 's|^\*cupsFilter:.*|&\
*APICADriver: True|' "$HERE/ppd/$n"
  fi
done
echo "Built brlaser $REF: $(file -b "$HERE/bin/rastertobrlaser" | cut -d, -f1-2), $(ls "$HERE/ppd" | wc -l | tr -d ' ') PPDs"
