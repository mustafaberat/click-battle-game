#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is not installed. Please install it first:${NC}"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu/Debian: sudo apt-get install imagemagick"
    exit 1
fi

# Source icon path
ICON_PATH="lib/assets/app-icon.jpeg"

# Check if source icon exists
if [ ! -f "$ICON_PATH" ]; then
    echo -e "${RED}❌ Source icon not found at: $ICON_PATH${NC}"
    exit 1
fi

# Define mipmap directories and sizes
declare -A MIPMAP_SIZES=(
    ["mipmap-mdpi"]=48
    ["mipmap-hdpi"]=72
    ["mipmap-xhdpi"]=96
    ["mipmap-xxhdpi"]=144
    ["mipmap-xxxhdpi"]=192
)

echo -e "${YELLOW}🔍 Updating Android app icons...${NC}"

# Update existing ic_launcher.png files
for dir in "${!MIPMAP_SIZES[@]}"; do
    size="${MIPMAP_SIZES[$dir]}"
    target_dir="android/app/src/main/res/$dir"
    target_file="$target_dir/ic_launcher.png"
    
    # Check if target file exists
    if [ -f "$target_file" ]; then
        # Backup original icon
        cp "$target_file" "$target_file.backup"
        
        # Convert and resize icon
        convert "$ICON_PATH" -resize "${size}x${size}" "$target_file"
        
        echo -e "${GREEN}✅ Updated ${size}x${size} icon in $dir${NC}"
    else
        echo -e "${YELLOW}⚠️  Skipping $dir - ic_launcher.png not found${NC}"
    fi
done

echo -e "\n${GREEN}✅ App icons updated!${NC}"
echo -e "${YELLOW}ℹ️  Note: You may need to clean and rebuild your app:${NC}"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter build apk --release"
echo -e "\n${YELLOW}ℹ️  Backup files were created with .backup extension${NC}" 