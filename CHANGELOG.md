# Changelog

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
