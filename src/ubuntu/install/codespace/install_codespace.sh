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

# Extract the URL of the latest linux-arm64.tar.gz file
tar_url=$(echo "$latest_release" | grep -Eo '"browser_download_url": *"[^"]+linux-arm64\.tar\.gz"' | awk -F'"' '{print $4}')

# Check if the .tar.gz file URL was found
if [ -z "$tar_url" ]; then
    echo "No linux-arm64.tar.gz file found in the latest release."
    exit 1
fi

# Output the download URL for debugging
echo "Download URL: $tar_url"

# Download the .tar.gz file
curl -L -o powershell-latest-linux-arm64.tar.gz "$tar_url"

PSHome=/opt/microsoft/powershell
mkdir -p $PSHome
tar xzvf powershell-latest-linux-arm64.tar.gz -C $PSHome
ln -s $PSHome/pwsh /usr/bin/pwsh
echo /usr/bin/pwsh >> /etc/shells
rm ./powershell-latest-linux-arm64.tar.gz

# Install DotNet
RUN curl -s https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh | bash \
  && echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc \
  echo 'export PATH=$PATH:DOTNET_ROOT' >> ~/.bashrc