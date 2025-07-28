#!/bin/bash

set -e

# Usage info
if [[ -z "$1" ]]; then
  echo "❌ Usage: $0 [release|debug]"
  exit 1
fi

# Build mode
BUILD_MODE=$1
if [[ "$BUILD_MODE" != "release" && "$BUILD_MODE" != "debug" ]]; then
  echo "❌ Invalid mode: $BUILD_MODE. Use 'release' or 'debug'."
  exit 1
fi

# Config
APP_NAME="wms-mobile"
OUTPUT_DIR="build-apks"

# Build the APK
flutter build apk --$BUILD_MODE

# Extract version info
VERSION_LINE=$(grep '^version:' pubspec.yaml)
VERSION_NAME=$(echo "$VERSION_LINE" | cut -d ':' -f2 | cut -d '+' -f1 | xargs)
VERSION_CODE=$(echo "$VERSION_LINE" | cut -d '+' -f2 | xargs)

# Timestamp
DATE=$(date +"%Y%m%d_%H%M")

# File names
SRC_APK="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
DEST_APK="$APP_NAME-v${VERSION_NAME}+${VERSION_CODE}-$BUILD_MODE-$DATE.apk"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy with new name
cp "$SRC_APK" "$OUTPUT_DIR/$DEST_APK"

echo "✅ APK saved as: $OUTPUT_DIR/$DEST_APK"
