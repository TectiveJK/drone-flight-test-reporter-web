# Install as a desktop app on this computer

## Fastest way (Linux)

1. Download `drone-flight-test-reporter-desktop-1.0.1.zip`
2. Unzip it
3. Run:

```bash
chmod +x install-desktop.sh
./install-desktop.sh
```

4. Open **Drone Flight Test Reporter** from your app menu or Desktop shortcut

## Windows

1. Download `drone-flight-test-reporter-desktop-1.0.1.zip`
2. Unzip it
3. Double-click `install-desktop.bat`
4. Open **Drone Flight Test Reporter** from the Start Menu or Desktop

## Chrome / Edge “Install app” (any OS)

1. Unzip the web or desktop package
2. In a terminal, from the unzipped folder:

```bash
python3 -m http.server 8080
```

3. Open Chrome or Edge at http://localhost:8080
4. Click the **Install** icon in the address bar (or menu → **Install Drone Flight Test Reporter… / Install app**)
5. Confirm Install

The app then opens in its own window and appears in your system app list.
