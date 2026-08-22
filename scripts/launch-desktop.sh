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

find_browser() {
  local c
  for c in google-chrome-stable google-chrome chromium chromium-browser microsoft-edge brave-browser firefox; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

BROWSER="$(find_browser || true)"
if [[ -z "${BROWSER}" ]]; then
  echo "No browser found. Install Google Chrome or Chromium, then try again."
  exit 1
fi

PORT="$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(('127.0.0.1', 0))
print(s.getsockname()[1])
s.close()
PY
)"
echo "$PORT" > "$PORT_FILE"

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
echo "Opening ${URL} with ${BROWSER}"

if [[ "$BROWSER" == "firefox" ]]; then
  "$BROWSER" --new-window "$URL" >/dev/null 2>&1 || "$BROWSER" "$URL" || true
else
  "$BROWSER" --new-window --app="$URL" >/dev/null 2>&1 || "$BROWSER" --new-window "$URL" >/dev/null 2>&1 || true
fi

# Keep serving until this process is stopped.
wait "$SERVER_PID" || true
