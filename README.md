# Drone Flight Test Reporter — Web, Desktop & iOS

Browser, desktop, and iOS Progressive Web App for professional multi-flight drone test reporting.

**Current version:** `1.0.3`

## Install as an app on this computer

```bash
cd ~
git clone https://github.com/TectiveJK/drone-flight-test-reporter-web.git
cd drone-flight-test-reporter-web
git pull
chmod +x scripts/install-desktop.sh scripts/launch-desktop.sh
./scripts/install-desktop.sh
```

Then start it with:

```bash
~/.local/bin/drone-flight-test-reporter
```

Or use the Desktop / `Bureaublad` shortcut **Drone Flight Test Reporter**.

Full steps: `INSTALL-DESKTOP.md`

## Features

- Multi-flight reports
- Evidence file attachments
- JSON save/open, Markdown export, Print / PDF export
- Desktop app window and iOS home-screen install

## Local development

```bash
python3 -m http.server 8080
```

Open http://localhost:8080
