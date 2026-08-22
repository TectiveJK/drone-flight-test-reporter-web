#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
DIST="$ROOT/dist"
rm -rf "$DIST"
mkdir -p "$DIST/web" "$DIST/ios" "$DIST/desktop"

WEB_FILES=(
  index.html style.css renderer.js web-api.js
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-WEB.md
)
IOS_FILES=(
  index.html style.css renderer.js web-api.js
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-iOS.md
)
DESKTOP_FILES=(
  index.html style.css renderer.js web-api.js
  manifest.webmanifest sw.js VERSION RELEASES.md README.md
  INSTALL-WEB.md INSTALL-DESKTOP.md
)

copy_tree() {
  local dest="$1"; shift
  mkdir -p "$dest/icons" "$dest/scripts"
  for f in "$@"; do
    mkdir -p "$dest/$(dirname "$f")"
    cp "$ROOT/$f" "$dest/$f"
  done
  cp "$ROOT/icons/"*.png "$dest/icons/"
}

copy_tree "$DIST/web" "${WEB_FILES[@]}"
copy_tree "$DIST/ios" "${IOS_FILES[@]}"
copy_tree "$DIST/desktop" "${DESKTOP_FILES[@]}"

cp "$ROOT/scripts/launch-desktop.sh" "$DIST/desktop/scripts/launch-desktop.sh"
cp "$ROOT/scripts/install-desktop.sh" "$DIST/desktop/scripts/install-desktop.sh"
cp "$ROOT/scripts/install-desktop.bat" "$DIST/desktop/scripts/install-desktop.bat"
cp "$ROOT/scripts/launch-desktop.sh" "$DIST/desktop/launch-desktop.sh"
cp "$ROOT/scripts/install-desktop.sh" "$DIST/desktop/install-desktop.sh"
cp "$ROOT/scripts/install-desktop.bat" "$DIST/desktop/install-desktop.bat"
chmod +x "$DIST/desktop/launch-desktop.sh" "$DIST/desktop/install-desktop.sh" \
  "$DIST/desktop/scripts/launch-desktop.sh" "$DIST/desktop/scripts/install-desktop.sh"

cp "$ROOT/INSTALL-iOS.md" "$DIST/ios/README.md"
cp "$ROOT/INSTALL-WEB.md" "$DIST/web/README.md"
cp "$ROOT/INSTALL-DESKTOP.md" "$DIST/desktop/README.md"

(
  cd "$DIST/web"
  zip -qr "$DIST/drone-flight-test-reporter-web-${VERSION}.zip" .
)
(
  cd "$DIST/ios"
  zip -qr "$DIST/drone-flight-test-reporter-ios-${VERSION}.zip" .
)
(
  cd "$DIST/desktop"
  zip -qr "$DIST/drone-flight-test-reporter-desktop-${VERSION}.zip" .
)

echo "Built:"
ls -lh "$DIST"/*.zip
