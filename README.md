# Drone Flight Test Reporter — Web, Desktop & iOS

**Current version:** `1.0.4`

## Download packages (GitHub Releases)

https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/tag/v1.0.4

- **Desktop:** `drone-flight-test-reporter-desktop-1.0.4.zip`
- **Web:** `drone-flight-test-reporter-web-1.0.4.zip`
- **iOS:** `drone-flight-test-reporter-ios-1.0.4.zip`

## Uninstall the old version

```bash
chmod +x scripts/uninstall-desktop.sh
./scripts/uninstall-desktop.sh
```

Or one-liner:

```bash
rm -f ~/.local/bin/drone-flight-test-reporter ~/.local/share/applications/drone-flight-test-reporter.desktop ~/Desktop/"Drone Flight Test Reporter.desktop" ~/Bureaublad/"Drone Flight Test Reporter.desktop"
rm -rf ~/.local/share/drone-flight-test-reporter
```

See `UNINSTALL.md`.

## Install the desktop package

1. Download `drone-flight-test-reporter-desktop-1.0.4.zip` from Releases
2. Unzip and open the folder
3. Run:

```bash
chmod +x install-desktop.sh
./install-desktop.sh
```

4. Start:

```bash
~/.local/bin/drone-flight-test-reporter
```

See `INSTALL-DESKTOP.md`.
