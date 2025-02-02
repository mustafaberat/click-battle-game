#!/bin/bash

# Function to show spinner while tasks are running
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Clean and get dependencies
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️  Building release versions..."
echo

# Build both formats in parallel
echo "📱 Building APK..."
flutter build apk --release > /dev/null 2>&1 & 
APK_PID=$!

echo "📦 Building App Bundle..."
flutter build appbundle --release > /dev/null 2>&1 &
BUNDLE_PID=$!

# Show spinners while building
echo -n "📱 APK Build Status: "
spinner $APK_PID
wait $APK_PID
APK_STATUS=$?

echo -n "📦 Bundle Build Status: "
spinner $BUNDLE_PID
wait $BUNDLE_PID
BUNDLE_STATUS=$?

echo
echo "Build Complete! 🎉"
echo

# Check and display results
if [ $APK_STATUS -eq 0 ]; then
    echo "✅ APK created at: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ APK build failed"
fi

if [ $BUNDLE_STATUS -eq 0 ]; then
    echo "✅ App Bundle created at: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ App Bundle build failed"
fi 