#!/usr/bin/env bash
# Install Drone Flight Test Reporter as a desktop app on this computer.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
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

resolve_desktop_dir() {
  local dir=""
  if command -v xdg-user-dir >/dev/null 2>&1; then
    dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
  fi
  if [[ -n "$dir" && -d "$dir" ]]; then
    echo "$dir"
    return
  fi
  for candidate in "${HOME}/Desktop" "${HOME}/Bureaublad" "${HOME}/Escritorio" "${HOME}/Bureau" "${HOME}/Schreibtisch"; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  # Create a Desktop folder as a last resort so a shortcut always exists.
  mkdir -p "${HOME}/Desktop"
  echo "${HOME}/Desktop"
}

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

LAUNCHER="$INSTALL_DIR/scripts/launch-desktop.sh"
if [[ ! -f "$LAUNCHER" ]]; then
  LAUNCHER="$INSTALL_DIR/launch-desktop.sh"
fi
if [[ ! -f "$LAUNCHER" ]]; then
  echo "Missing launch-desktop.sh in package."
  exit 1
fi
chmod +x "$LAUNCHER"
chmod +x "$INSTALL_DIR/launch-desktop.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/launch-desktop.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/install-desktop.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/install-desktop.sh" 2>/dev/null || true

# Wrapper in PATH that always works, even if ~/.local/bin is missing from PATH later.
cat > "${BIN_DIR}/${APP_ID}" <<EOF
#!/usr/bin/env bash
exec "$LAUNCHER" "\$@"
EOF
chmod +x "${BIN_DIR}/${APP_ID}"

ICON_PATH="$INSTALL_DIR/icons/icon-512.png"
if [[ ! -f "$ICON_PATH" ]]; then
  ICON_PATH="$INSTALL_DIR/icons/icon-192.png"
fi

# Quote Exec path for desktop files.
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=${APP_NAME}
Comment=Professional multi-flight drone test reporting
Exec="${LAUNCHER}"
Icon=${ICON_PATH}
Terminal=false
Categories=Utility;Office;Development;
Keywords=drone;flight;test;report;
StartupNotify=true
StartupWMClass=drone-flight-test-reporter
EOF
chmod +x "$DESKTOP_FILE"

USER_DESKTOP_DIR="$(resolve_desktop_dir)"
USER_DESKTOP="${USER_DESKTOP_DIR}/${APP_NAME}.desktop"
cp "$DESKTOP_FILE" "$USER_DESKTOP"
chmod +x "$USER_DESKTOP"

# Mark shortcut as trusted/allowed on GNOME and similar desktops.
if command -v gio >/dev/null 2>&1; then
  gio set "$USER_DESKTOP" metadata::trusted true 2>/dev/null || true
  gio set "$DESKTOP_FILE" metadata::trusted true 2>/dev/null || true
fi
if command -v dbus-launch >/dev/null 2>&1; then
  true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

# Ensure ~/.local/bin is on PATH for future terminals.
PROFILE_SNIPPET='export PATH="$HOME/.local/bin:$PATH"'
for profile in "${HOME}/.profile" "${HOME}/.bashrc" "${HOME}/.zshrc"; do
  if [[ -f "$profile" ]] || [[ "$profile" == "${HOME}/.profile" ]]; then
    touch "$profile"
    if ! grep -Fq '.local/bin' "$profile" 2>/dev/null; then
      printf '\n# Added by Drone Flight Test Reporter installer\n%s\n' "$PROFILE_SNIPPET" >> "$profile"
    fi
  fi
done
export PATH="${BIN_DIR}:$PATH"

echo
echo "Installed successfully."
echo "Shortcut created at:"
echo "  ${USER_DESKTOP}"
echo "App menu entry:"
echo "  ${DESKTOP_FILE}"
echo
echo "You can also start it with:"
echo "  ${BIN_DIR}/${APP_ID}"
echo "  or:  ${LAUNCHER}"
echo

# Always offer an immediate launch; default yes.
if [[ -t 0 ]]; then
  read -r -p "Launch now? [Y/n] " answer || true
  answer="${answer:-Y}"
else
  answer="Y"
fi
if [[ "$answer" =~ ^[Yy]$ ]]; then
  nohup "$LAUNCHER" >/tmp/drone-flight-test-reporter-launch.log 2>&1 &
  echo "Launching... if no window opens, run:"
  echo "  ${LAUNCHER}"
  echo "and check /tmp/drone-flight-test-reporter-launch.log"
fi
