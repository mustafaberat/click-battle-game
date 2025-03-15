#!/bin/bash

echo "🧹 Cleaning the project..."
flutter clean

echo "⚡ Getting dependencies..."
flutter pub get

echo "🏗️ Building release APK..."
flutter build apk --release -v --dart-define=Dart.vm.product=true --no-tree-shake-icons

echo "✨ Build completed!"
echo "📱 Your APK can be found at: build/app/outputs/flutter-apk/app-release.apk"

# Open Finder at the APK location
open "/Users/mustafaberataru/Projects/personal/mobile-apps/clickbattle/build/app/outputs/flutter-apk"