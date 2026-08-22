# Install as a desktop app on this computer

## Recommended (from git)

```bash
cd ~
git clone https://github.com/TectiveJK/drone-flight-test-reporter-web.git
cd drone-flight-test-reporter-web
git pull
chmod +x scripts/install-desktop.sh scripts/launch-desktop.sh
./scripts/install-desktop.sh
```

## Start the app

Use any of these:

```bash
~/.local/bin/drone-flight-test-reporter
```

```bash
~/.local/share/drone-flight-test-reporter/scripts/launch-desktop.sh
```

Or open the Desktop shortcut **Drone Flight Test Reporter**  
(on Dutch Ubuntu this may be in `~/Bureaublad`).

## If the shortcut is missing

```bash
ls -la ~/Desktop ~/Bureaublad ~/.local/share/applications | grep -i drone || true
```

Then reinstall with the commands above, or launch with the `~/.local/bin/...` command.
