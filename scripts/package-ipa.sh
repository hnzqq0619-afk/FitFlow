#!/bin/bash
set -euo pipefail

# This packages the iphoneos build, never the iphonesimulator product.
APP="build/DeviceData/Build/Products/Release-iphoneos/FitFlow.app"
test -d "$APP"
test -f "$APP/Info.plist"
PLATFORM=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleSupportedPlatforms:0' "$APP/Info.plist")
test "$PLATFORM" = "iPhoneOS"

mkdir -p build/ipa/Payload
ditto "$APP" build/ipa/Payload/FitFlow.app
(
  cd build/ipa
  /usr/bin/zip -qry ../FitFlow-unsigned.ipa Payload
)
echo "Packaged build/FitFlow-unsigned.ipa; re-sign with your own certificate before installing."
