#!/usr/bin/env bash
# Uninstall Drone Flight Test Reporter from this computer.
set -euo pipefail

APP_ID="drone-flight-test-reporter"
APP_NAME="Drone Flight Test Reporter"
INSTALL_DIR="${HOME}/.local/share/${APP_ID}"
BIN_PATH="${HOME}/.local/bin/${APP_ID}"
APP_MENU="${HOME}/.local/share/applications/${APP_ID}.desktop"

resolve_desktop_dirs() {
  local dirs=()
  if command -v xdg-user-dir >/dev/null 2>&1; then
    local xdg
    xdg="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
    [[ -n "$xdg" ]] && dirs+=("$xdg")
  fi
  dirs+=("${HOME}/Desktop" "${HOME}/Bureaublad" "${HOME}/Escritorio" "${HOME}/Bureau" "${HOME}/Schreibtisch")
  printf '%s\n' "${dirs[@]}" | awk 'NF && !seen[$0]++'
}

echo "Uninstalling ${APP_NAME}..."

# Stop a running local server if present.
if [[ -f "${XDG_RUNTIME_DIR:-/tmp}/${APP_ID}.port" ]]; then
  PORT="$(cat "${XDG_RUNTIME_DIR:-/tmp}/${APP_ID}.port" 2>/dev/null || true)"
  if [[ -n "${PORT:-}" ]]; then
    pkill -f "python3 -m http.server ${PORT}" >/dev/null 2>&1 || true
  fi
fi
pkill -f "${INSTALL_DIR}/scripts/launch-desktop.sh" >/dev/null 2>&1 || true

rm -f "$BIN_PATH"
rm -f "$APP_MENU"

while IFS= read -r desk; do
  [[ -z "$desk" || ! -d "$desk" ]] && continue
  rm -f "${desk}/${APP_ID}.desktop"
  rm -f "${desk}/${APP_NAME}.desktop"
done < <(resolve_desktop_dirs)

if [[ -d "$INSTALL_DIR" ]]; then
  rm -rf "$INSTALL_DIR"
  echo "Removed app files: ${INSTALL_DIR}"
else
  echo "No installed app files found at: ${INSTALL_DIR}"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${HOME}/.local/share/applications" >/dev/null 2>&1 || true
fi

echo
echo "Uninstall complete."
echo "Removed launcher, app menu entry, Desktop/Bureaublad shortcuts, and installed files."
echo
echo "Optional cleanup (cloned source folder, if you still have it):"
echo "  rm -rf ~/drone-flight-test-reporter-web"
echo
echo "Optional cleanup (downloaded zip folders):"
echo "  rm -rf ~/Downloads/drone-flight-test-reporter-desktop-*"
