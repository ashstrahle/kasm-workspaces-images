#!/usr/bin/env bash
set -ex

# Install Signal
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')
if [ "${ARCH}" == "arm64" ] ; then
    # GitHub repository details
    owner="dennisameling"
    repo="Signal-Desktop"

    # Fetch the latest release information using GitHub API
    latest_release=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

    # Check if the API request was successful
    if [[ "$latest_release" == *"Not Found"* ]]; then
        echo "Failed to fetch release information. Please check the repository details."
        exit 1
    fi

    # Extract the URL of the latest ARM64 .deb file
    deb_url=$(echo "$latest_release" | grep -Eo '"browser_download_url": *"[^"]+arm64\.deb"' | awk -F'"' '{print $4}')

    # Check if the .deb file URL was found
    if [ -z "$deb_url" ]; then
        echo "No ARM64 .deb file found in the latest release."
        exit 1
    fi

    # Output the latest version
    echo "Latest version: $latest_version"

    # Download the .deb file
    curl -L -o signal-desktop.deb "$deb_url"
    apt-get update
    apt-get install -y signal-desktop
    rm signal-desktop.deb
else
    # Signal only releases its desktop app under the xenial release, however it is compatible with all versions of Debian and Ubuntu that we support.
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
    echo "deb [arch=${ARCH}] https://updates.signal.org/desktop/apt xenial main" |  tee -a /etc/apt/sources.list.d/signal-xenial.list
    apt-get update
    apt-get install -y signal-desktop

    # Desktop icon
    cp /usr/share/applications/signal-desktop.desktop $HOME/Desktop/
    chmod +x $HOME/Desktop/signal-desktop.desktop
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi
