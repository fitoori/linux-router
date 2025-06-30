#!/bin/bash

set -e

REPO_URL="https://github.com/garywill/linux-router.git"
SCRIPT_NAME="linux-router.sh"
INSTALL_PATH="/usr/local/bin/linux-router"

# Full dependency list (core + wifi/hotspot + optional)
REQUIRED_PACKAGES=(
    bash
    procps
    iproute2
    dnsmasq
    iptables
    hostapd
    iw
    wireless-tools
    haveged
    qrencode
    network-manager
    firewalld
    git
)

echo "Checking for required packages..."

MISSING_PKGS=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -ne 0 ]; then
    echo "The following packages are missing: ${MISSING_PKGS[*]}"
    echo "Installing missing packages..."
    apt update
    apt install -y "${MISSING_PKGS[@]}"
else
    echo "All required packages are already installed."
fi

TMPDIR=$(mktemp -d)
echo "Cloning linux-router repository..."
git clone --depth 1 "$REPO_URL" "$TMPDIR"

# If the script is renamed in the repo, adjust this section.
if [ -f "$TMPDIR/$SCRIPT_NAME" ]; then
    echo "Copying $SCRIPT_NAME to $INSTALL_PATH..."
    cp "$TMPDIR/$SCRIPT_NAME" "$INSTALL_PATH"
elif [ -f "$TMPDIR/linux-router" ]; then
    echo "Copying linux-router to $INSTALL_PATH..."
    cp "$TMPDIR/linux-router" "$INSTALL_PATH"
else
    echo "ERROR: Script not found in repository."
    exit 1
fi

chmod +x "$INSTALL_PATH"
rm -rf "$TMPDIR"
echo "Installation complete."
echo "Run with: sudo linux-router"
