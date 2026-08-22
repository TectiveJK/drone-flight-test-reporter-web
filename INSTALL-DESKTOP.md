# Install as a desktop app on this computer

## 1) Uninstall any old version

```bash
cd ~/drone-flight-test-reporter-web 2>/dev/null || true
chmod +x scripts/uninstall-desktop.sh 2>/dev/null || true
./scripts/uninstall-desktop.sh 2>/dev/null || rm -rf ~/.local/share/drone-flight-test-reporter
```

Manual cleanup:

```bash
rm -f ~/.local/bin/drone-flight-test-reporter \
  ~/.local/share/applications/drone-flight-test-reporter.desktop \
  ~/Desktop/"Drone Flight Test Reporter.desktop" \
  ~/Bureaublad/"Drone Flight Test Reporter.desktop"
rm -rf ~/.local/share/drone-flight-test-reporter
```

## 2) Download the desktop package from Releases

https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/download/v1.0.4/drone-flight-test-reporter-desktop-1.0.4.zip

## 3) Install

```bash
cd ~/Downloads
unzip -o drone-flight-test-reporter-desktop-1.0.4.zip
cd drone-flight-test-reporter-desktop-1.0.4
chmod +x install-desktop.sh uninstall-desktop.sh
./install-desktop.sh
```

## 4) Start

```bash
~/.local/bin/drone-flight-test-reporter
```
