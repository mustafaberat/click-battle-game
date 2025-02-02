#!/bin/bash

# Clean and get dependencies
echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

# Build APK
echo "Building APK..."
flutter build apk --release

echo "APK created at: build/app/outputs/flutter-apk/app-release.apk" 