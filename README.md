# Drone Flight Test Reporter — Web, Desktop & iOS

Browser, desktop, and iOS Progressive Web App for professional multi-flight drone test reporting.

**Current version:** `1.0.2`

## Install as an app on this computer

Download the **desktop** package (name must include `desktop`):

https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/download/v1.0.2/drone-flight-test-reporter-desktop-1.0.2.zip

Then:

```bash
cd ~/Downloads
unzip -o drone-flight-test-reporter-desktop-1.0.2.zip
cd drone-flight-test-reporter-desktop-1.0.2
chmod +x install-desktop.sh
./install-desktop.sh
```

Full steps: `INSTALL-DESKTOP.md`

## iOS / iPadOS

Download the iOS zip from [Releases](https://github.com/TectiveJK/drone-flight-test-reporter-web/releases), host/open in Safari, then **Share → Add to Home Screen**.

See `INSTALL-iOS.md`.

## Features

- Multi-flight reports
- Evidence file attachments (images embedded in reports)
- JSON save/open, Markdown export, Print / PDF export
- Voice notes where supported
- Desktop app window and iOS home-screen install

## Local development

```bash
python3 -m http.server 8080
```

Open http://localhost:8080
