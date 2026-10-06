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
# Printers added with an older version keep their old PPD in /etc/cups/ppd. brlaser 6.2.x reads the
# toner density from the new PPD; with a v6-era PPD it sends density -100 and prints lighter.
stale=""
for f in /etc/cups/ppd/*.ppd; do
  [ -f "$f" ] || continue
  grep -qs "$DEST/rastertobrlaser" "$f" || continue
  grep -qs "brlaserDensityAdjust" "$f" && continue
  stale="$stale $(basename "$f" .ppd)"
done
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
if [ -n "$stale" ]; then
  echo
  echo "NOTE: these printers still use a PPD from an older version:$stale"
  echo "  They print lighter than they should. In System Settings > Printers & Scanners, remove each"
  echo "  one and add it again with the brlaser driver. (Replacing the PPD with lpadmin -P also fixes"
  echo "  printing, but removes the 'Open Scanner' button on DCP/MFC models.)"
fi
