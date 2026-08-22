#!/usr/bin/env bash
# Launch Drone Flight Test Reporter as a desktop app window.
set -euo pipefail

APP_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# If launched from scripts/, app root is parent.
if [[ ! -f "$APP_ROOT/index.html" && -f "$APP_ROOT/../index.html" ]]; then
  APP_ROOT="$(cd "$APP_ROOT/.." && pwd)"
fi

PORT_FILE="${XDG_RUNTIME_DIR:-/tmp}/drone-flight-test-reporter.port"
LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/drone-flight-test-reporter-server.log"
PROFILE_DIR="${HOME}/.local/share/drone-flight-test-reporter/browser-profile"
BROWSER_LOG="${XDG_RUNTIME_DIR:-/tmp}/drone-flight-test-reporter-browser.log"

find_browser() {
  local c
  # Prefer Chrome/Chromium for reliable --app windows; Brave is supported with a dedicated profile.
  for c in google-chrome-stable google-chrome chromium chromium-browser microsoft-edge brave-browser brave firefox; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

open_in_browser() {
  local url="$1"
  local browser="$2"
  mkdir -p "$PROFILE_DIR"

  case "$browser" in
    firefox)
      "$browser" --new-window "$url" >>"$BROWSER_LOG" 2>&1 &
      return 0
      ;;
    brave-browser|brave)
      # Brave often ignores one-shot --app launches against an existing profile.
      # Use a dedicated profile so a real window always opens.
      "$browser" \
        --user-data-dir="$PROFILE_DIR" \
        --no-first-run \
        --no-default-browser-check \
        --disable-features=Translate \
        --new-window \
        --app="$url" >>"$BROWSER_LOG" 2>&1 &
      sleep 1
      # Fallback: normal window if app mode still fails silently.
      if ! pgrep -f "$PROFILE_DIR" >/dev/null 2>&1; then
        "$browser" --user-data-dir="$PROFILE_DIR" --new-window "$url" >>"$BROWSER_LOG" 2>&1 &
      fi
      return 0
      ;;
    *)
      "$browser" \
        --user-data-dir="$PROFILE_DIR" \
        --no-first-run \
        --no-default-browser-check \
        --new-window \
        --app="$url" >>"$BROWSER_LOG" 2>&1 &
      return 0
      ;;
  esac
}

BROWSER="$(find_browser || true)"
PORT="$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(('127.0.0.1', 0))
print(s.getsockname()[1])
s.close()
PY
)"
echo "$PORT" > "$PORT_FILE"
: > "$BROWSER_LOG"

cd "$APP_ROOT"
python3 -m http.server "$PORT" --bind 127.0.0.1 >"$LOG_FILE" 2>&1 &
SERVER_PID=$!

cleanup() {
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

python3 - <<PY
import socket, time
port = int("$PORT")
for _ in range(50):
    s = socket.socket()
    s.settimeout(0.2)
    try:
        s.connect(('127.0.0.1', port))
        s.close()
        break
    except Exception:
        time.sleep(0.1)
else:
    raise SystemExit('Local app server failed to start. See: '"$LOG_FILE")
PY

URL="http://127.0.0.1:${PORT}/index.html"
echo "App server is running."
echo "URL: ${URL}"

if [[ -n "${BROWSER}" ]]; then
  echo "Opening with ${BROWSER}..."
  open_in_browser "$URL" "$BROWSER" || true
else
  echo "No Chrome/Brave/Firefox binary found."
fi

# Always try the desktop opener as a reliable fallback.
if command -v xdg-open >/dev/null 2>&1; then
  echo "Also opening with xdg-open (default browser)..."
  xdg-open "$URL" >/dev/null 2>&1 || true
fi

echo
echo "If no window appeared, open this URL manually in Brave/Chrome:"
echo "  ${URL}"
echo
echo "Keep this terminal open while using the app."
echo "Press Ctrl+C to stop the app server."
echo

wait "$SERVER_PID" || true
