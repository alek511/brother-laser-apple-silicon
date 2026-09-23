# Brother laser printers on Apple Silicon — native driver, no Rosetta

Fixes **"The printer software is not compatible with this device"** for older Brother
mono laser printers on macOS 27 / Apple Silicon.

Brother's own macOS driver (`rastertobrother*`, last built in 2019) is Intel‑only. If your
Mac has no Rosetta 2 — or once Apple limits it — macOS refuses the driver. Most of these
printers have no AirPrint either (they only speak Brother's HBP raster), so a driver is
required. This repository ships **[brlaser](https://github.com/pdewacht/brlaser)**, the
open‑source CUPS driver that has supported these printers on Linux for a decade, **prebuilt
for arm64** together with its PPDs and a one‑command installer.

> **Built from brlaser `master` (2a49e328, 2023‑02‑20), not the v6 release — on purpose.**
> v6 splits the raster into 64‑line blocks, and the HL‑1110/1210W/DCP‑1610W engine silently
> drops complex pages encoded that way (the printer clicks once, nothing comes out, CUPS
> reports success — [issue #40](https://github.com/pdewacht/brlaser/issues/40),
> [PR #68](https://github.com/pdewacht/brlaser/pull/68)). `master` uses 128‑line bands like
> Brother's own driver and prints everything. Verified on a DCP‑1610W: v6 → 0 pages,
> master → prints.

Also read this if you want the **"Open Scanner…"** button to survive on an all‑in‑one
(DCP/MFC): see [Scanner](#scanner-dcpmfc-models).

## Supported printers

Everything brlaser supports:

DCP‑1510, DCP‑1600 series (1600/1602/1610W/1612W/1617NW/1618W), DCP‑7030, DCP‑7040,
DCP‑7055, DCP‑7055W, DCP‑7060D, DCP‑7065DN, DCP‑7080, DCP‑7080D, DCP‑L2500D, DCP‑L2520D,
DCP‑L2540DW, HL‑1110, HL‑1200, HL‑2030 series, HL‑2140 series, HL‑2220 series,
HL‑2270DW series, HL‑5030 series, HL‑L2300D, HL‑L2320D, HL‑L2340D, HL‑L2360D,
MFC‑1910W, MFC‑7240, MFC‑7360N, MFC‑7365DN, MFC‑L2710DW series.

If your model is not listed, try the closest one — brlaser's README says most of the
family works with any entry marked "brlaser".

## Install

Download the [latest release](https://github.com/alek511/brother-laser-apple-silicon/releases/latest) and unpack it, or:

```sh
git clone https://github.com/alek511/brother-laser-apple-silicon.git
cd brother-laser-apple-silicon
sudo ./install.sh
```

Then add the printer **through System Settings** (not `lpadmin`, see below):

1. System Settings → Printers & Scanners → **Add Printer, Scanner, or Fax…**
2. Select your Brother printer in the list (network or USB).
3. Open the **Use** menu → **Select Software…** → search `brlaser` → pick your model → **Add**.

That's it. Print a test page.

What the installer puts on disk:

- `/Library/Printers/brlaser/rastertobrlaser` — the filter, arm64, ad‑hoc signed (62 KB)
- `/Library/Printers/PPDs/Contents/Resources/*.ppd` — one PPD per model

It also strips the `com.apple.quarantine` flag that a GitHub download carries; without
that, `cupsd` refuses to execute the filter.

## Scanner (DCP/MFC models)

brlaser is a print driver only. Scanning keeps working through Brother's ICA scanner
package (`Brother Scanner.app`), which — unlike the printer driver — is a universal
binary and runs natively. Install it from Brother's site if you don't have it.

The **"Open Scanner…"** button in the printer's card in System Settings appears only when
*all three* hold:

1. the PPD contains `*APICADriver: True` (all DCP/MFC PPDs here do);
2. the PPD's `*ModelName` equals the scanner's Bonjour name (e.g. `Brother DCP-1610W series`);
3. the queue was created **through System Settings**, not `lpadmin` — the link is made by
   the Settings app at add time.

`ppd-tuned/` contains PPDs already tuned for point 2. For another model, copy the stock
PPD, set `*ModelName` / `*ShortNickName` / `*Product` to the exact name the printer
advertises (`dns-sd -B _scanner._tcp local` shows it), and install it alongside.

Without the button the scanner is still available from Image Capture and every app's
"Import from scanner".

## Troubleshooting

Everything below was hit while getting a DCP‑1610W to print on macOS 27. Each entry is
*symptom → cause → fix*.

**"The printer software is not compatible with this device."**
Brother's driver is Intel‑only and your Mac has no Rosetta 2. Either install this driver,
or `sudo softwareupdate --install-rosetta --agree-to-license` to keep using Brother's.

**The printer clicks once, nothing comes out, CUPS says "completed".**
The classic brlaser **v6** failure on the 1110/1210W/1610W engine: simple text prints,
anything denser is dropped. You are running a v6 build — install this one (built from
`master`, 128‑line bands). If it still happens, capture the job and open an issue
(template included).

**Job says "Sending" / "Connecting to printer" and never prints.**
Check the printer itself first: `nc -z <printer-ip> 9100` must succeed, and the printer's
web page (its IP in a browser) should say Ready or Sleep, not an error. Power‑cycle it once —
a run of broken jobs (e.g. from the Intel driver failing mid‑send) can wedge the engine.

**No "Open Scanner…" button on a DCP/MFC.**
Three conditions (see [Scanner](#scanner-dcpmfc-models)): `*APICADriver: True` in the
PPD, `*ModelName` equal to the scanner's Bonjour name, and the queue added **through
System Settings**. Replacing the PPD with `lpadmin` never creates the button — delete the
queue and add it again in Settings.

**Driver not in the "Select Software…" list.**
`lpinfo -m | grep brlaser` should list 30 entries. If it is empty, the PPDs still carry
the quarantine flag (installer skipped?) — re‑run `sudo ./install.sh`.

**"Printer drivers are deprecated" warning from `lpadmin`.**
Informational. Apple deprecated PPD drivers; they work on macOS 27. Brother's own driver
gets the same warning.

**"Use generic printer features" toggle in the printer's options.**
Leave it off. On, macOS ignores the PPD's options.

**Wrong or generic icon.**
Expected: Brother's icons are Brother's artwork and are not shipped here. If Brother's
package is installed, add `*APPrinterIconPath: "/Library/Printers/Brother/Icons/<model>.icns"`
to your PPD.

**1200 dpi prints nothing.**
Known on some 1600‑series units (brlaser #173). Use 600 dpi.

## How the v6 problem was found

Worth recording, because the symptom points everywhere except the real cause. Text pages
printed; a PDF from Preview did not, yet CUPS reported success and the printer accepted every
byte on port 9100. Sending the same bytes straight to the port with `nc` printed — so the
transport was innocent. Capturing the job with a local `socket://127.0.0.1` queue showed
CUPS emitted exactly the bytes that printed raw. What differed was the *page*: Preview's
raster is denser than a fresh render of the same file. Capturing Preview's raster
(`cupsFilter … rastertopwg` to a local socket), encoding it with three builds and sending
each with a different copy count (1 / 2 / 4) gave 0 + 2 + 4 sheets: v6 fails, 32‑line
blocks work, `master` works.

## Uninstall

`sudo ./uninstall.sh` — removes the print queues that use brlaser, the PPDs and the filter. Nothing else is touched.

## Rebuild from source

```sh
brew install cmake
./build.sh        # downloads brlaser master (or ./build.sh 6 for a tag), builds, regenerates bin/ and ppd/
```

Works on Intel Macs too (it just builds x86_64).

## Notes

- Apple has deprecated PPD‑based drivers (`lpadmin` prints a warning). They still work on
  macOS 27. The long‑term escape hatch for these printers is a Raspberry Pi / any Linux box
  running CUPS + brlaser, sharing the printer as AirPrint.
- Rosetta 2 remains installable on macOS 27 (`softwareupdate --install-rosetta`) and
  makes Brother's driver work again — but Apple has announced it will be limited in
  macOS 28. This driver does not depend on it.
- Print quality: 600 dpi is the safe default; 1200 dpi is exposed but not guaranteed on
  every model.
- Not affiliated with Brother. Brother's icons are not included (they are Brother's
  artwork); printers get the generic macOS icon.

## Credits and license

The driver is [brlaser](https://github.com/pdewacht/brlaser) by Peter De Wachter,
GPL‑2.0‑or‑later. This repository only builds it for macOS/arm64 and adds the PPD tweaks,
scripts and documentation. Same license — see `LICENSE`.

Русская версия: [README.ru.md](README.ru.md).
