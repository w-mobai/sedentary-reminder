#!/bin/zsh
set -euo pipefail

ROOT_DIR="${0:A:h:h}"
APP_NAME="Move Ease"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"

if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
elif [[ -d "$HOME/Downloads/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="$HOME/Downloads/Xcode.app/Contents/Developer"
elif ! xcodebuild -version >/dev/null 2>&1; then
  echo "需要完整安装 Xcode 16，并用 xcode-select 切换到 Xcode Developer 目录。" >&2
  exit 1
fi

cd "$ROOT_DIR"
mkdir -p "$BUILD_DIR"
xcrun swiftc -O -parse-as-library \
  -target arm64-apple-macosx14.0 \
  "$ROOT_DIR"/Sources/MoveEase/*.swift \
  -o "$BUILD_DIR/MoveEase"

mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"
cp "$BUILD_DIR/MoveEase" "$CONTENTS_DIR/MacOS/MoveEase"

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
  <key>CFBundleExecutable</key><string>MoveEase</string>
  <key>CFBundleIdentifier</key><string>com.moveease.reminder</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>Move Ease</string>
  <key>CFBundleDisplayName</key><string>Move Ease</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>CFBundleIconFile</key><string>AppIcon</string>
</dict>
</plist>
PLIST

ICONSET="$BUILD_DIR/AppIcon.iconset"
mkdir -p "$ICONSET"
sips -s format png "$ROOT_DIR/Assets/AppIcon.svg" --out "$BUILD_DIR/icon-1024.png" >/dev/null
for spec in "16 16x16" "32 16x16@2x" "32 32x32" "64 32x32@2x" "128 128x128" "256 128x128@2x" "256 256x256" "512 256x256@2x" "512 512x512" "1024 512x512@2x"; do
  set -- $=spec
  sips -z "$1" "$1" "$BUILD_DIR/icon-1024.png" --out "$ICONSET/icon_$2.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$CONTENTS_DIR/Resources/AppIcon.icns"
codesign --force --deep --sign - "$APP_DIR"

echo "$APP_DIR"
