#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.22.3"

git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git flutter_sdk
export PATH="$PWD/flutter_sdk/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
