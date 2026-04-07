#!/usr/bin/env bash
# Install the latest JDTLS into the path that nvim's stdpath("data") resolves to.
# Works on Linux and macOS.

set -e

# Detect platform
OS="$(uname -s)"
case "$OS" in
  Linux)
    DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    CONFIG_DIR_NAME="config_linux"
    ;;
  Darwin)
    DATA_DIR="$HOME/Library/Application Support/nvim"
    CONFIG_DIR_NAME="config_mac"
    # Prefer ARM config on Apple Silicon
    if [[ "$(uname -m)" == "arm64" ]]; then
      CONFIG_DIR_NAME="config_mac_arm64"
    fi
    ;;
  *)
    echo "Unsupported OS: $OS"
    echo "On Windows, use install_jdtls.ps1 instead."
    exit 1
    ;;
esac

JDTLS_DIR="$DATA_DIR/mason/packages/jdtls"

# Check Java
if ! command -v java &>/dev/null; then
  echo "Error: Java 17+ is required."
  echo "  Linux : sudo apt install openjdk-17-jdk"
  echo "  macOS : brew install openjdk@17"
  exit 1
fi

echo "Java  : $(java --version 2>&1 | head -1)"
echo "Target: $JDTLS_DIR"

# Fetch latest release tarball URL from GitHub
TARBALL_URL=$(curl -fsSL "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/releases/latest" \
  | grep '"browser_download_url"' \
  | grep '\.tar\.gz"' \
  | head -1 \
  | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')

if [[ -z "$TARBALL_URL" ]]; then
  echo "Error: Could not fetch latest JDTLS release from GitHub."
  exit 1
fi

echo "URL   : $TARBALL_URL"

mkdir -p "$JDTLS_DIR"
cd "$JDTLS_DIR"

# Clean existing install
rm -rf plugins config_* *.jar 2>/dev/null || true

echo "Downloading..."
curl -fsSL "$TARBALL_URL" -o jdtls.tar.gz

echo "Extracting..."
tar -xzf jdtls.tar.gz
rm jdtls.tar.gz

# Verify
LAUNCHER=$(find plugins -name "org.eclipse.equinox.launcher_*.jar" 2>/dev/null | head -1)
if [[ -z "$LAUNCHER" ]]; then
  echo "Error: Launcher jar not found after extraction."
  exit 1
fi

if [[ ! -d "$CONFIG_DIR_NAME" ]]; then
  echo "Warning: Expected config dir '$CONFIG_DIR_NAME' not found. Available:"
  ls -d config_* 2>/dev/null || echo "  (none)"
fi

echo ""
echo "JDTLS installed successfully."
echo "  Launcher : $JDTLS_DIR/$LAUNCHER"
echo "  Config   : $JDTLS_DIR/$CONFIG_DIR_NAME"
