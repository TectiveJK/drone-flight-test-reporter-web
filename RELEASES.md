# Release Notes — Drone Flight Test Reporter (Web / iOS / Desktop)

## v1.0.3

More reliable desktop shortcuts.

### Fixes
- Detect Dutch/localized Desktop folders (e.g. `Bureaublad`) via `xdg-user-dir`
- Create a trusted Desktop shortcut named **Drone Flight Test Reporter**
- Print exact shortcut paths after install
- Launch command works even when `~/.local/bin` was not on PATH

### Downloads
- `drone-flight-test-reporter-desktop-1.0.3.zip`
- `drone-flight-test-reporter-web-1.0.3.zip`
- `drone-flight-test-reporter-ios-1.0.3.zip`

## v1.0.2

Clearer desktop install packaging.

### Fixes
- Desktop zip now unpacks into a named folder containing `install-desktop.sh`
- Added `INSTALL.txt` with exact install commands

## v1.0.1

Desktop app install support for the web build.

## v1.0.0

First public installable release of the browser and iOS PWA builds.
