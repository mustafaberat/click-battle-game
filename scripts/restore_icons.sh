#!/bin/bash

# Exit on error
set -e

echo "🔄 Restoring original icons..."

# Define mipmap directories
MIPMAP_DIRS=(
    "android/app/src/main/res/mipmap-mdpi"
    "android/app/src/main/res/mipmap-hdpi"
    "android/app/src/main/res/mipmap-xhdpi"
    "android/app/src/main/res/mipmap-xxhdpi"
    "android/app/src/main/res/mipmap-xxxhdpi"
)

# Restore backup files
for dir in "${MIPMAP_DIRS[@]}"; do
    if [ -f "$dir/ic_launcher.png.backup" ]; then
        mv "$dir/ic_launcher.png.backup" "$dir/ic_launcher.png"
        echo "✅ Restored icon in $dir"
    fi
done

echo "✅ Original icons restored!" 