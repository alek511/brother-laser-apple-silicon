---
name: Printing problem
about: The printer does not print, prints garbage, or the driver is not listed
---

**Printer model** (exactly as System Settings shows it):

**macOS version** (`sw_vers -productVersion`):

**Mac** (`uname -m` → arm64 / x86_64):

**How is the printer connected** (Wi‑Fi / Ethernet / USB):

**What happens** (nothing prints / printer clicks once / garbage / job stuck / driver not in list):

**Does a plain one‑line text file print?** (`echo hello | lp -d <queue>`):

**CUPS log for one failing job** — run once, print, then paste the output:

```sh
cupsctl --debug-logging; lp -d <queue> /path/to/file.pdf; sleep 20
grep "Job $(lpstat -W completed -o | head -1 | sed 's/.*-\([0-9]*\) .*/\1/')\]" /var/log/cups/error_log | grep -v envp
cupsctl --no-debug-logging
```
