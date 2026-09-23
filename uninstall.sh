#!/bin/sh
# Removes everything install.sh put on this Mac: print queues that use brlaser, the filter, the PPDs.
# Usage:  sudo ./uninstall.sh
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo $0"; exit 1; }
FILTER=/Library/Printers/brlaser/rastertobrlaser
# 1. queues whose PPD points at our filter
for q in $(lpstat -p 2>/dev/null | awk '/^printer|^принтер/{print $2}'); do
  if grep -qs "$FILTER" "/etc/cups/ppd/$q.ppd"; then
    lpadmin -x "$q" && echo "removed print queue: $q"
  fi
done
# 2. PPDs
n=0
for f in /Library/Printers/PPDs/Contents/Resources/*.ppd; do
  if grep -qs "$FILTER" "$f"; then rm -f "$f"; n=$((n+1)); fi
done
echo "removed $n PPD file(s)"
# 3. filter
rm -rf /Library/Printers/brlaser && echo "removed /Library/Printers/brlaser"
echo "brlaser is fully removed. Rosetta 2 and any Brother-supplied software were not touched."
