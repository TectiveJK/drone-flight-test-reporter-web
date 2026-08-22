#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
DIST="$ROOT/dist"
rm -rf "$DIST"
mkdir -p "$DIST"

package_variant() {
  local variant="$1"
  shift
  local staged="$DIST/staging/${variant}/drone-flight-test-reporter-${variant}-${VERSION}"
  mkdir -p "$staged/icons" "$staged/scripts"
  for f in "$@"; do
    mkdir -p "$staged/$(dirname "$f")"
    cp "$ROOT/$f" "$staged/$f"
  done
  cp "$ROOT/icons/"*.png "$staged/icons/"
  echo "$staged"
}

WEB_STAGED="$(package_variant web \
  index.html style.css renderer.js web-api.js \
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-WEB.md INSTALL.txt UNINSTALL.md
)"
cp "$ROOT/INSTALL-WEB.md" "$WEB_STAGED/README.md"

IOS_STAGED="$(package_variant ios \
  index.html style.css renderer.js web-api.js \
  manifest.webmanifest sw.js VERSION RELEASES.md README.md INSTALL-iOS.md INSTALL.txt UNINSTALL.md
)"
cp "$ROOT/INSTALL-iOS.md" "$IOS_STAGED/README.md"

DESKTOP_STAGED="$(package_variant desktop \
  index.html style.css renderer.js web-api.js \
  manifest.webmanifest sw.js VERSION RELEASES.md README.md \
  INSTALL-WEB.md INSTALL-DESKTOP.md INSTALL.txt UNINSTALL.md
)"
cp "$ROOT/scripts/launch-desktop.sh" "$DESKTOP_STAGED/scripts/launch-desktop.sh"
cp "$ROOT/scripts/install-desktop.sh" "$DESKTOP_STAGED/scripts/install-desktop.sh"
cp "$ROOT/scripts/uninstall-desktop.sh" "$DESKTOP_STAGED/scripts/uninstall-desktop.sh"
cp "$ROOT/scripts/install-desktop.bat" "$DESKTOP_STAGED/scripts/install-desktop.bat"
cp "$ROOT/scripts/uninstall-desktop.bat" "$DESKTOP_STAGED/scripts/uninstall-desktop.bat"
cp "$ROOT/scripts/launch-desktop.sh" "$DESKTOP_STAGED/launch-desktop.sh"
cp "$ROOT/scripts/install-desktop.sh" "$DESKTOP_STAGED/install-desktop.sh"
cp "$ROOT/scripts/uninstall-desktop.sh" "$DESKTOP_STAGED/uninstall-desktop.sh"
cp "$ROOT/scripts/install-desktop.bat" "$DESKTOP_STAGED/install-desktop.bat"
cp "$ROOT/scripts/uninstall-desktop.bat" "$DESKTOP_STAGED/uninstall-desktop.bat"
cp "$ROOT/INSTALL-DESKTOP.md" "$DESKTOP_STAGED/README.md"
chmod +x \
  "$DESKTOP_STAGED/launch-desktop.sh" \
  "$DESKTOP_STAGED/install-desktop.sh" \
  "$DESKTOP_STAGED/uninstall-desktop.sh" \
  "$DESKTOP_STAGED/scripts/launch-desktop.sh" \
  "$DESKTOP_STAGED/scripts/install-desktop.sh" \
  "$DESKTOP_STAGED/scripts/uninstall-desktop.sh"

(
  cd "$DIST/staging/web"
  zip -qr "$DIST/drone-flight-test-reporter-web-${VERSION}.zip" "drone-flight-test-reporter-web-${VERSION}"
)
(
  cd "$DIST/staging/ios"
  zip -qr "$DIST/drone-flight-test-reporter-ios-${VERSION}.zip" "drone-flight-test-reporter-ios-${VERSION}"
)
(
  cd "$DIST/staging/desktop"
  zip -qr "$DIST/drone-flight-test-reporter-desktop-${VERSION}.zip" "drone-flight-test-reporter-desktop-${VERSION}"
)

echo "Built:"
ls -lh "$DIST"/*.zip
echo
echo "Desktop package contains:"
unzip -l "$DIST/drone-flight-test-reporter-desktop-${VERSION}.zip" | grep -E 'install-desktop.sh|uninstall-desktop.sh|INSTALL.txt|UNINSTALL.md|/$' | head -30
