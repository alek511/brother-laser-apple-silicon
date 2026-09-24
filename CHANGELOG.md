# Changelog

## 1.1.1 — 2026-09-25

- **Fix:** `install.sh` always ended with "ERROR: the filter does not run on this Mac" after a
  successful install. Its self-check looked for "Need arguments" — a message from Brother's own
  filter that brlaser never prints (present since 1.0.0). It now checks for brlaser's real usage
  line and reports when macOS kills the filter.
- **Docs corrected:** CUPS does not check code signatures or quarantine. What actually happens,
  tested on macOS 27 with a DCP‑1610W: a quarantined filter is killed by macOS (Gatekeeper) when
  CUPS starts it — the job reports *completed* and nothing prints; a filter not owned by root is
  refused by CUPS ("insecure permissions"). The installer handles both; troubleshooting updated.

## 1.1.0 — 2026-09-24

- Switched to the maintained fork **Owl-Maintain/brlaser v6.2.8**: 102 PPDs (was 29), real
  1200 dpi modes, per‑model `1284DeviceID` so System Settings picks the right driver itself,
  and model names that already match the scanner's Bonjour name (no more `ppd-tuned/`).
  Same 128‑line band encoding as before; verified on a DCP‑1610W with the captured raster.
- `build.sh` now builds the fork (`./build.sh master` for the branch tip).

## 1.0.0 — 2026-09-23

- brlaser built from `master` (2a49e328, 2023‑02‑20) for macOS/arm64, ad‑hoc signed.
  Not the v6 release: its 64‑line blocks are silently dropped by the HL‑1110/1210W/DCP‑1610W
  engine on complex pages (pdewacht/brlaser#40, #68).
- 29 PPDs from `brlaser.drv` with an absolute filter path; `*APICADriver: True` on DCP/MFC.
- `ppd-tuned/`: DCP‑1610W PPD whose model name matches the Bonjour scanner name, so the
  "Open Scanner…" button appears when the queue is added through System Settings.
- `install.sh` strips the download quarantine flag and verifies the filter runs;
  `uninstall.sh` removes queues, PPDs and the filter; `build.sh` rebuilds from source.
