#!/bin/bash

# BrowserTerminal Xcode Build Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="BrowserTerminal"
BUNDLE_ID="com.lukekist.BrowserTerminal"

echo -e "${GREEN}Building BrowserTerminal as native macOS app...${NC}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create app bundle structure
echo -e "${YELLOW}Creating app bundle structure...${NC}"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Build the Swift executable
echo -e "${YELLOW}Building Swift executable...${NC}"
cd "$PROJECT_DIR"
swift build -c release --arch arm64 --arch x86_64

# Copy executable to app bundle
echo -e "${YELLOW}Assembling app bundle...${NC}"
cp ".build/apple/Products/Release/BrowserTerminal" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Copy Info.plist
cp "Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Update Info.plist with correct values
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $APP_NAME" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$APP_BUNDLE/Contents/Info.plist"

# Create PkgInfo file
echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Sign the app (ad-hoc signing for local use)
echo -e "${YELLOW}Signing app...${NC}"
codesign --force --deep --sign - "$APP_BUNDLE"

# Verify the app bundle
echo -e "${YELLOW}Verifying app bundle...${NC}"
codesign --verify --verbose "$APP_BUNDLE"

echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "${GREEN}App bundle created at: $APP_BUNDLE${NC}"

# Option to open the app
echo -e "\n${YELLOW}Would you like to open the app? (y/n)${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$APP_BUNDLE"
fi