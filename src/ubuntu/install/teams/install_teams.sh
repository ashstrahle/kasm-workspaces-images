#!/usr/bin/env bash
set -ex
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

if [ "${ARCH}" == "arm64" ] ; then
    # GitHub repository details
    owner="IsmaelMartinez"
    repo="teams-for-linux"

    # Fetch the latest release information using GitHub API
    latest_release=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

    # Check if the API request was successful
    if [[ "$latest_release" == *"Not Found"* ]]; then
        echo "Failed to fetch release information. Please check the repository details."
        exit 1
    fi

    # Extract the latest version tag
    latest_version=$(echo "$latest_release" | grep -Eo '"tag_name": *"[^"]+"' | awk -F'"' '{print $4}')

    # Check if the version tag was found
    if [ -z "$latest_version" ]; then
        echo "Failed to extract the latest version tag."
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
    curl -L -o teams.deb "$deb_url"
else
    curl -L -o teams.deb  "https://go.microsoft.com/fwlink/p/?linkid=2112886&clcid=0x409&culture=en-us&country=us"
fi

apt-get update
apt-get install -y ./teams.deb
rm teams.deb
if [ "${ARCH}" != "arm64" ] ; then
    sed -i "s/Exec=teams/Exec=teams --no-sandbox/g" /usr/share/applications/teams.desktop
fi
cp /usr/share/applications/teams.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/teams.desktop