#!/usr/bin/env bash
set -ex

# Install Armcord from deb
owner="ArmCord"
repo="ArmCord"

# Fetch the latest release information using GitHub API
latest_release=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

# Check if the API request was successful
if [[ "$latest_release" == *"Not Found"* ]]; then
    echo "Failed to fetch release information. Please check the repository details."
    exit 1
fi

# Extract the URL of the latest ARM64 .deb file
deb_url=$(echo "$latest_release" | grep -Eo '"browser_download_url": *"[^"]+-arm64\.deb"' | grep -Eo 'http[^"]+')

# Check if the .deb file URL was found
if [ -z "$deb_url" ]; then
    echo "No ARM64 .deb file found in the latest release."
    exit 1
fi

# Download the .deb file
curl -L -o ArmCord-latest-arm64.deb "$deb_url"
apt-get update
apt-get install -y ./ArmCord-latest-arm64.deb
rm ArmCord-latest-arm64.deb

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
