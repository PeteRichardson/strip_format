#!/bin/bash
set -euo pipefail

APP_NAME="StripFormat"
BUNDLE="$APP_NAME.app"
DEST="/Applications/$BUNDLE"

swift build -c release

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
cp ".build/release/$APP_NAME" "$BUNDLE/Contents/MacOS/"
cp "Info.plist" "$BUNDLE/Contents/Info.plist"

rm -rf "$DEST"
cp -R "$BUNDLE" "$DEST"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST"

echo "Installed to $DEST — check Keyboard Shortcuts > Services to bind a key."
