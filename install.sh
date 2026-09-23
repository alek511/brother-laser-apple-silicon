#!/bin/sh
# Installs the native arm64 brlaser CUPS filter and PPDs on macOS (Apple Silicon).
# Usage:  sudo ./install.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST=/Library/Printers/brlaser
PPDDIR=/Library/Printers/PPDs/Contents/Resources
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0"; exit 1; }
[ "$(uname -m)" = arm64 ] || echo "Warning: this binary is arm64-only; on an Intel Mac build from source with ./build.sh"
mkdir -p "$DEST" "$PPDDIR"
cp "$HERE/bin/rastertobrlaser" "$DEST/"
chmod 755 "$DEST/rastertobrlaser"
# files downloaded from GitHub carry a quarantine flag that keeps cupsd from executing the filter
xattr -d com.apple.quarantine "$DEST/rastertobrlaser" 2>/dev/null || true
for f in "$HERE"/ppd/*.ppd "$HERE"/ppd-tuned/*.ppd; do
  cp "$f" "$PPDDIR/"
  xattr -d com.apple.quarantine "$PPDDIR/$(basename "$f")" 2>/dev/null || true
done
chown -R root:wheel "$DEST"
echo "Installed. Now add the printer in System Settings > Printers & Scanners > Add Printer,"
echo "open the 'Use' menu, pick 'Select Software...', search 'brlaser' and choose your model."
