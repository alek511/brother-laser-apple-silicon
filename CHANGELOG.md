# Changelog

## 1.0.0 — 2026-09-23

- brlaser built from `master` (2a49e328, 2023‑02‑20) for macOS/arm64, ad‑hoc signed.
  Not the v6 release: its 64‑line blocks are silently dropped by the HL‑1110/1210W/DCP‑1610W
  engine on complex pages (pdewacht/brlaser#40, #68).
- 29 PPDs from `brlaser.drv` with an absolute filter path; `*APICADriver: True` on DCP/MFC.
- `ppd-tuned/`: DCP‑1610W PPD whose model name matches the Bonjour scanner name, so the
  "Open Scanner…" button appears when the queue is added through System Settings.
- `install.sh` strips the download quarantine flag and verifies the filter runs;
  `uninstall.sh` removes queues, PPDs and the filter; `build.sh` rebuilds from source.
