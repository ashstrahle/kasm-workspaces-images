#!/usr/bin/env bash
set -ex

ARMCORDVER=3.2.7
# Install Armcord
wget -qO armcord.tar.gz https://github.com/ArmCord/ArmCord/releases/download/v$ARMCORDVER/ArmCord-$ARMCORDVER-arm64.tar.gz
tar xzvf armcord.tar.gz
mv ArmCord-$ARMCORDVER-arm64 /opt/ArmCord
rm armcord.tar.gz

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
