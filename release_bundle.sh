#!/bin/bash

# Clean and get dependencies
echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

# Build app bundle
echo "Building Android App Bundle..."
flutter build appbundle --release

echo "App Bundle created at: build/app/outputs/bundle/release/app-release.aab" 