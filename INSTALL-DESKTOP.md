# Install as a desktop app on this computer

## Linux (copy/paste)

```bash
cd ~/Downloads
unzip -o drone-flight-test-reporter-desktop-1.0.2.zip
cd drone-flight-test-reporter-desktop-1.0.2
chmod +x install-desktop.sh
./install-desktop.sh
```

Then open **Drone Flight Test Reporter** from your app menu or Desktop.

> Important: use the **desktop** zip, not `...-web-...` or `...-ios-...`.
> `install-desktop.sh` only exists in the desktop package.

## Windows

1. Download `drone-flight-test-reporter-desktop-1.0.2.zip`
2. Unzip it
3. Open the folder `drone-flight-test-reporter-desktop-1.0.2`
4. Double-click `install-desktop.bat`
5. Open **Drone Flight Test Reporter** from the Start Menu or Desktop

## Chrome / Edge “Install app”

1. From the unzipped desktop folder run: `python3 -m http.server 8080`
2. Open http://localhost:8080 in Chrome/Edge
3. Click **Install** in the address bar (or the in-app **Install App** button)
