# Install as a desktop/web app

## Desktop app on this computer (recommended)

1. Download [`drone-flight-test-reporter-desktop-1.0.1.zip`](https://github.com/TectiveJK/drone-flight-test-reporter-web/releases/download/v1.0.1/drone-flight-test-reporter-desktop-1.0.1.zip)
2. Unzip it
3. Install:
   - **Linux:** `chmod +x install-desktop.sh && ./install-desktop.sh`
   - **Windows:** double-click `install-desktop.bat`
4. Open **Drone Flight Test Reporter** from your app menu / Start Menu / Desktop

See `INSTALL-DESKTOP.md`.

## Browser-only

1. Unzip this package.
2. Open `index.html`, or serve locally:

```bash
python3 -m http.server 8080
```

Then open http://localhost:8080 and use Chrome/Edge **Install app** if offered.

## Included

- Multi-flight report editor
- Evidence file attachments
- JSON save/open
- Markdown export
- Print / PDF export
