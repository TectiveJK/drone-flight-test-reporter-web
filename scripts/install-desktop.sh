#!/usr/bin/env bash
# Install Drone Flight Test Reporter as a desktop app on this computer.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Support running from repo scripts/ or from an extracted desktop package root.
if [[ -f "$SCRIPT_DIR/../index.html" ]]; then
  SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ -f "$SCRIPT_DIR/index.html" ]]; then
  SOURCE_ROOT="$SCRIPT_DIR"
else
  echo "Could not find app files next to this installer."
  exit 1
fi

APP_ID="drone-flight-test-reporter"
APP_NAME="Drone Flight Test Reporter"
INSTALL_DIR="${HOME}/.local/share/${APP_ID}"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${DESKTOP_DIR}/${APP_ID}.desktop"
USER_DESKTOP="${HOME}/Desktop/${APP_ID}.desktop"

echo "Installing ${APP_NAME} to ${INSTALL_DIR}"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

# Copy app files
shopt -s dotglob nullglob
for item in "$SOURCE_ROOT"/*; do
  base="$(basename "$item")"
  case "$base" in
    dist|.git|node_modules) continue ;;
  esac
  cp -a "$item" "$INSTALL_DIR/"
done

chmod +x "$INSTALL_DIR/scripts/launch-desktop.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/launch-desktop.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/install-desktop.sh" 2>/dev/null || true

LAUNCHER="$INSTALL_DIR/scripts/launch-desktop.sh"
if [[ ! -x "$LAUNCHER" ]]; then
  LAUNCHER="$INSTALL_DIR/launch-desktop.sh"
fi
if [[ ! -f "$LAUNCHER" ]]; then
  echo "Missing launch-desktop.sh in package."
  exit 1
fi
chmod +x "$LAUNCHER"

ln -sfn "$LAUNCHER" "${BIN_DIR}/${APP_ID}"

ICON_PATH="$INSTALL_DIR/icons/icon-512.png"
if [[ ! -f "$ICON_PATH" ]]; then
  ICON_PATH="$INSTALL_DIR/icons/icon-192.png"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=${APP_NAME}
Comment=Professional multi-flight drone test reporting
Exec=${LAUNCHER}
Icon=${ICON_PATH}
Terminal=false
Categories=Utility;Office;
StartupNotify=true
StartupWMClass=Drone Flight Test Reporter
EOF
chmod +x "$DESKTOP_FILE"

# Also place a shortcut on the Desktop when possible.
if [[ -d "${HOME}/Desktop" ]]; then
  cp "$DESKTOP_FILE" "$USER_DESKTOP"
  chmod +x "$USER_DESKTOP"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo
echo "Installed successfully."
echo "Open it from your app menu as \"${APP_NAME}\","
echo "or run: ${APP_ID}"
echo
read -r -p "Launch now? [Y/n] " answer || true
answer="${answer:-Y}"
if [[ "$answer" =~ ^[Yy]$ ]]; then
  nohup "$LAUNCHER" >/dev/null 2>&1 &
  echo "Launching..."
fi
