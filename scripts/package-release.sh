#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
DIST="$ROOT/dist"
rm -rf "$DIST"
mkdir -p "$DIST/web" "$DIST/ios"

WEB_FILES=(
  index.html style.css renderer.js web-api.js
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-WEB.md
)
IOS_FILES=(
  index.html style.css renderer.js web-api.js
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-iOS.md
)

copy_tree() {
  local dest="$1"; shift
  mkdir -p "$dest/icons"
  for f in "$@"; do cp "$ROOT/$f" "$dest/$f"; done
  cp "$ROOT/icons/"*.png "$dest/icons/"
}

copy_tree "$DIST/web" "${WEB_FILES[@]}"
copy_tree "$DIST/ios" "${IOS_FILES[@]}"
cp "$ROOT/INSTALL-iOS.md" "$DIST/ios/README.md"
cp "$ROOT/INSTALL-WEB.md" "$DIST/web/README.md"

(
  cd "$DIST/web"
  zip -qr "$DIST/drone-flight-test-reporter-web-${VERSION}.zip" .
)
(
  cd "$DIST/ios"
  zip -qr "$DIST/drone-flight-test-reporter-ios-${VERSION}.zip" .
)

echo "Built:"
ls -lh "$DIST"/*.zip
