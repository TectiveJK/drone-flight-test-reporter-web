# Release Notes — Drone Flight Test Reporter (Web / iOS / Desktop)

## v1.0.2

Clearer desktop install packaging.

### Fixes
- Desktop zip now unpacks into a named folder containing `install-desktop.sh`
- Added `INSTALL.txt` with exact install commands
- Avoids “No such file or directory” when the wrong zip or folder is used

### Downloads
- `drone-flight-test-reporter-desktop-1.0.2.zip` — install as an app on this computer
- `drone-flight-test-reporter-web-1.0.2.zip` — browser package
- `drone-flight-test-reporter-ios-1.0.2.zip` — iPhone/iPad home-screen package

## v1.0.1

Desktop app install support for the web build.

### Highlights
- Linux/Windows desktop installer packages
- App menu / Desktop shortcut launch in a dedicated Chrome/Edge app window
- In-app **Install App** button when the browser supports PWA install

## v1.0.0

First public installable release of the browser and iOS PWA builds.

### Highlights
- Remove Mission ID field from the flight editor and generated reports
- Fix **Add Files** so evidence attachments upload reliably
- Store attachment contents in saved reports; embed images in preview/PDF
- Add Progressive Web App support for iOS “Add to Home Screen” install
- Ship downloadable Web and iOS packages
