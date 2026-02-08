#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.38.9"

git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git
export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
