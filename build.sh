#!/bin/bash
set -e

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# CONFIG
ISO_LABEL="ArchLinux-Kiosk"
CONFIG_DIR="./"
ISO1_EXEC='ExecStart=/usr/bin/cage -s -- /usr/bin/firefox --kiosk --no-remote --private --start-fullscreen --disable-popup-blocking --no-proxy-server --private-window "https://google.com"'
TARGET_FILE="${CONFIG_DIR}/airootfs/etc/systemd/system/cage@.service"

# Save original line
ORIGINAL_LINE=$(grep '^ExecStart=' "$TARGET_FILE")
echo "✅ Original line backed up: $ORIGINAL_LINE"

# Replace line
echo "🔧 Patching line for ISO 1..."
sed -i "s|^ExecStart=.*|$ISO1_EXEC|" "$TARGET_FILE"

# Build first ISO
echo "▶️ Building first ISO..."
mkarchiso -v -w ../work-iso1 -o ../out-iso1 "$CONFIG_DIR"

# Restore original line
echo "♻️ Restoring original config..."
sed -i "s|^ExecStart=.*|$ORIGINAL_LINE|" "$TARGET_FILE"

echo "🔧 Moving ISO"
# Get current build date in YYYY-MM-DD format
ISO_BUILD_DATE=$(date +%F)
mkdir -p ./build
mv ../out-iso1/ArchLinux-Kiosk*.iso "./build/ArchLinux-Kiosk-${ISO_BUILD_DATE}.iso"
rmdir ../out-iso*

echo "✅ Done! ISO built."