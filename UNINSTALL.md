# Uninstall Drone Flight Test Reporter

## Linux (copy/paste)

```bash
# If you still have the repo:
cd ~/drone-flight-test-reporter-web
git pull
chmod +x scripts/uninstall-desktop.sh
./scripts/uninstall-desktop.sh
```

Or run this one-liner without the repo:

```bash
rm -f ~/.local/bin/drone-flight-test-reporter \
  ~/.local/share/applications/drone-flight-test-reporter.desktop \
  ~/Desktop/drone-flight-test-reporter.desktop \
  ~/Desktop/"Drone Flight Test Reporter.desktop" \
  ~/Bureaublad/drone-flight-test-reporter.desktop \
  ~/Bureaublad/"Drone Flight Test Reporter.desktop"
rm -rf ~/.local/share/drone-flight-test-reporter
```

Optional: remove the cloned project / unzipped packages too:

```bash
rm -rf ~/drone-flight-test-reporter-web
rm -rf ~/Downloads/drone-flight-test-reporter-desktop-*
```

## Windows

1. Download/unzip the desktop package (or use your clone)
2. Double-click `uninstall-desktop.bat`

Or delete manually:
- `%LOCALAPPDATA%\drone-flight-test-reporter`
- Start Menu shortcut `Drone Flight Test Reporter`
- Desktop shortcut `Drone Flight Test Reporter`
