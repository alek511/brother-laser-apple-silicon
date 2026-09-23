#!/bin/sh
# Removes the brlaser filter and PPDs. Delete the printer in System Settings first.
# Usage:  sudo ./uninstall.sh
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0"; exit 1; }
rm -rf /Library/Printers/brlaser
for f in /Library/Printers/PPDs/Contents/Resources/*.ppd; do
  grep -q "/Library/Printers/brlaser/rastertobrlaser" "$f" 2>/dev/null && rm -f "$f"
done
echo "brlaser removed."
