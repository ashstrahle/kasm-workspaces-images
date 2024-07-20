#!/usr/bin/env bash
set -ex

# Install Armcord from deb
OWNER="ArmCord"
REPO="ArmCord"

# Fetch the latest release information using GitHub API
LATEST_RELEASE=$(curl -s "https://api.github.com/REPOs/$OWNER/$REPO/releases/latest")

# Extract the URL of the latest ARM64 .deb file
DEB_URL=$(echo "$LATEST_RELEASE" | grep -Eo '"browser_download_url": *"[^"]+_arm64\.deb"' | grep -Eo 'http[^"]+')

# Check if the .deb file URL was found
if [ -z "$DEB_URL" ]; then
    echo "No ARM64 .deb file found in the latest release."
    exit 1
fi
curl -L -o ArmCord-latest-arm64.deb "$DEB_URL"
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
