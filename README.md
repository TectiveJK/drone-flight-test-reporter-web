# Drone Flight Test Reporter — Web, Desktop & iOS

Browser, desktop, and iOS Progressive Web App for professional multi-flight drone test reporting.

**Current version:** `1.0.1`

## Install as an app on this computer

1. Download [`drone-flight-test-reporter-desktop-1.0.1.zip`](https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/download/v1.0.1/drone-flight-test-reporter-desktop-1.0.1.zip)
2. Unzip
3. Run `install-desktop.sh` (Linux) or `install-desktop.bat` (Windows)
4. Launch **Drone Flight Test Reporter** from your app menu / Desktop

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
