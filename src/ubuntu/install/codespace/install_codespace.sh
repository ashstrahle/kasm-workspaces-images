#!/usr/bin/env bash
set -ex

# Install docker-compose
apt-get update
apt-get install -y docker-compose

# Install Powershell
# GitHub repository details
owner="PowerShell"
repo="PowerShell"

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

# Download the .deb file
curl -L -o powershell-latest-arm64.deb "$deb_url"

apt-get install -y ./powershell-latest-arm64.deb
rm ./powershell-latest-arm64.deb

# Install DotNet
RUN curl -s https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash \
  && echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc \
  echo 'export PATH=$PATH:DOTNET_ROOT' >> ~/.bashrc