#!/bin/bash

# Click Battle - Release APK Builder
# ================================
# This script builds and installs a release APK for Click Battle.
# It handles the build process, installation, and launching of the app.
#
# Usage:
#   ./release_apk.sh [options]
#
# Options:
#   -c    Clean build (performs a full rebuild with cleaning)
#         This removes all build artifacts and starts fresh.
#         Use this when you want to ensure a completely clean build.
#
#   -h    Show this help message
#
# Examples:
#   ./release_apk.sh          # Normal build (incremental)
#   ./release_apk.sh -c       # Clean build
#
# Notes:
#   - Requires Flutter SDK to be installed and in PATH
#   - Requires Android device to be connected via USB with USB debugging enabled
#   - Build logs are saved to logs/apk_build.log
#   - The script will automatically install and launch the app on the connected device

# Get the script's directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Create logs directory and file
LOG_FILE="$PROJECT_ROOT/logs/apk_build.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Function to show a spinner animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\r${spin:$i:1}"
            sleep $delay
        done
    done
    echo -ne "\r"
}

# Parse command line arguments
CLEAN_BUILD=false
while getopts "ch" opt; do
  case $opt in
    c) CLEAN_BUILD=true ;;
    h) 
      echo "Click Battle - Release APK Builder"
      echo "================================="
      echo "Usage: $0 [options]"
      echo
      echo "Options:"
      echo "  -c    Clean build (performs a full rebuild with cleaning)"
      echo "        This removes all build artifacts and starts fresh."
      echo "        Use this when you want to ensure a completely clean build."
      echo
      echo "  -h    Show this help message"
      echo
      echo "Examples:"
      echo "  $0          # Normal build (incremental)"
      echo "  $0 -c       # Clean build"
      echo
      echo "Notes:"
      echo "  - Requires Flutter SDK to be installed and in PATH"
      echo "  - Requires Android device to be connected via USB with USB debugging enabled"
      echo "  - Build logs are saved to logs/apk_build.log"
      echo "  - The script will automatically install and launch the app on the connected device"
      exit 0
      ;;
    *) echo "Usage: $0 [-c] [-h]" >&2
       echo "Try '$0 -h' for more information." >&2
       exit 1 ;;
  esac
done

# Change to project root directory
cd "$PROJECT_ROOT" || exit 1

# Build process
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 Cleaning the project..."
    flutter clean > "$LOG_FILE" 2>&1
else
    echo "🔄 Performing incremental build..."
    echo "   Only recent changes will be included..." > "$LOG_FILE" 2>&1
fi

echo "⚡ Getting dependencies..."
flutter pub get >> "$LOG_FILE" 2>&1

echo -n "🏗️ Building release APK... "
flutter build apk --release --dart-define=Dart.vm.product=true --no-tree-shake-icons >> "$LOG_FILE" 2>&1 &
BUILD_PID=$!
show_spinner $BUILD_PID

APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo "✨ Your APK can be found at: build/app/outputs/flutter-apk/app-release.apk"
    
    echo -n "📲 Installing APK on connected device... "
    adb install -r "$APK_PATH" >> "$LOG_FILE" 2>&1 &
    INSTALL_PID=$!
    show_spinner $INSTALL_PID
    echo "✅"

    echo "🚀 Launching the app..."
    PACKAGE_NAME="com.arusoft.clickbattle"
    adb shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 >> "$LOG_FILE" 2>&1

    echo "📝 App logs are being saved to: $LOG_FILE"
    flutter logs --verbose >> "$LOG_FILE" 2>&1
else
    RED='\033[0;31m'
    echo -e "${RED}❌ Build failed! Check logs at: $LOG_FILE"
    echo "Last 20 lines of build log:"
    tail -n 20 "$LOG_FILE"
fi
