#!/bin/sh
# Installs the native arm64 brlaser CUPS filter and PPDs on macOS (Apple Silicon).
# Usage:  sudo ./install.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST=/Library/Printers/brlaser
PPDDIR=/Library/Printers/PPDs/Contents/Resources
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0"; exit 1; }
if [ "$(uname -m)" != arm64 ]; then
  echo "This binary is arm64-only. On an Intel Mac run ./build.sh first (needs cmake), then re-run install."; exit 1
fi
mkdir -p "$DEST" "$PPDDIR"
cp "$HERE/bin/rastertobrlaser" "$DEST/"
chmod 755 "$DEST/rastertobrlaser"
# a GitHub download carries a quarantine flag that keeps cupsd from executing the filter
xattr -d com.apple.quarantine "$DEST/rastertobrlaser" 2>/dev/null || true
n=0
for f in "$HERE"/ppd/*.ppd; do
  cp "$f" "$PPDDIR/"; xattr -d com.apple.quarantine "$PPDDIR/$(basename "$f")" 2>/dev/null || true; n=$((n+1))
done
chown -R root:wheel "$DEST"
# verify
# verify the filter actually runs here (it prints its usage and exits 1; exit 137 = killed by the OS)
rc=0; out=$("$DEST/rastertobrlaser" 2>&1) || rc=$?
case "$out" in
  *"rastertobrlaser job-id"*) ;;
  *) echo "ERROR: the filter does not run on this Mac (exit $rc)"; [ "$rc" = 137 ] && echo "It was killed by macOS; check: xattr -l $DEST/rastertobrlaser"; exit 1 ;;
esac
seen=$(lpinfo -m 2>/dev/null | grep -c brlaser || true)
echo "Installed: filter OK, $n PPDs copied, $seen brlaser drivers visible to macOS."
echo
echo "Next: System Settings > Printers & Scanners > Add Printer, Scanner, or Fax..."
echo "  select your Brother > Use: 'Select Software...' > search 'brlaser' > pick your model > Add."
echo "  (Add it through System Settings, not lpadmin, or the 'Open Scanner' button will be missing on DCP/MFC.)"
