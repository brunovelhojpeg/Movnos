#!/bin/bash
echo "🔨 Building..."
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -sdk iphonesimulator \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="-" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  build -quiet
cd ..

if [ $? -eq 0 ]; then
  echo "✅ Build OK. Installing..."
  APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Runner.app" -path "*Debug-iphonesimulator*" -maxdepth 10 2>/dev/null | sort -r | head -1)
  xcrun simctl install booted "$APP_PATH"
  BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Info.plist")
  xcrun simctl launch booted "$BUNDLE_ID"
  echo "🚀 App launched!"
else
  echo "❌ Build failed"
fi
