# Drone Flight Test Reporter — Web, Desktop & iOS

**Current version:** `1.0.5`

## Download packages (GitHub Releases)

https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/tag/v1.0.5

- **Desktop:** `drone-flight-test-reporter-desktop-1.0.5.zip`
- **Web:** `drone-flight-test-reporter-web-1.0.5.zip`
- **iOS:** `drone-flight-test-reporter-ios-1.0.5.zip`

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

## Install / update from git (recommended)

```bash
cd ~/drone-flight-test-reporter-web
git pull
./scripts/uninstall-desktop.sh
chmod +x scripts/*.sh
./scripts/install-desktop.sh
~/.local/bin/drone-flight-test-reporter
```

If Brave shows “Opening …” but no window appears, copy the printed `http://127.0.0.1:…. /index.html` URL into Brave manually and keep the terminal open.
