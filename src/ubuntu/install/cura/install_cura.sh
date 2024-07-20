#!/usr/bin/env bash
set -ex

# Install Armcord from deb
# GitHub repository details
owner="smartavionics"
repo="Cura"

# Fetch the latest release information using GitHub API
latest_release=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

# Check if the API request was successful
if [[ "$latest_release" == *"Not Found"* ]]; then
    echo "Failed to fetch release information. Please check the repository details."
    exit 1
fi

# Extract the URL of the latest mb-aarch64.AppImage file
appimage_url=$(echo "$latest_release" | grep -Eo '"browser_download_url": *"[^"]+mb-aarch64\.AppImage"' | awk -F'"' '{print $4}')

# Check if the .AppImage file URL was found
if [ -z "$appimage_url" ]; then
    echo "No mb-aarch64.AppImage file found in the latest release."
    exit 1
fi

# Output the download URL for debugging
echo "Download URL: $appimage_url"

# Download the .AppImage file
wget -O /opt/Cura.AppImage "$appimage_url"
sudo chmod +x /opt/Cura.AppImage

apt-get update
apt-get install -y fuse mesa-utils libgles-dev zlib1g-dev libxss1 libxkbcommon-x11-0 libxcb*

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
