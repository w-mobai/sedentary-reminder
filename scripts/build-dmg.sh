#!/bin/zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
BUILD_DIR="$ROOT_DIR/build"
APP_PATH="$BUILD_DIR/Move Ease.app"
DMG_PATH="$BUILD_DIR/Move-Ease-macOS-arm64.dmg"
STAGE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/moveease-dmg.XXXXXX")

cleanup() {
  rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

"$ROOT_DIR/scripts/build-app.sh"

ditto "$APP_PATH" "$STAGE_DIR/Move Ease.app"
ln -s /Applications "$STAGE_DIR/Applications"

hdiutil create \
  -volname "Move Ease" \
  -srcfolder "$STAGE_DIR" \
  -format UDZO \
  -ov \
  "$DMG_PATH"

echo "$DMG_PATH"
