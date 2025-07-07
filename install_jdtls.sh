#!/bin/bash
# Fixed JDTLS setup for macOS

echo "Setting up Java Language Server (JDTLS) for macOS..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java not found. Please install Java 17+ first:"
    echo "brew install openjdk@17"
    exit 1
fi

echo "Java version:"
java --version

# Create necessary directories
mkdir -p ~/.local/share/nvim/mason/packages/jdtls
mkdir -p ~/.cache/jdtls-workspace

# Download JDTLS
cd ~/.local/share/nvim/mason/packages/jdtls

# Clean any existing installation
rm -rf plugins config_* *.jar 2>/dev/null

# Get the latest stable version
JDTLS_VERSION="1.9.0"
JDTLS_TIMESTAMP="202203031534"
JDTLS_URL="https://download.eclipse.org/jdtls/milestones/${JDTLS_VERSION}/jdt-language-server-${JDTLS_VERSION}-${JDTLS_TIMESTAMP}.tar.gz"

echo "Downloading JDTLS from: $JDTLS_URL"
curl -L "$JDTLS_URL" -o jdtls.tar.gz

if [ ! -f jdtls.tar.gz ]; then
    echo "Error: Failed to download JDTLS"
    exit 1
fi

echo "Extracting JDTLS..."
tar -xzf jdtls.tar.gz
rm jdtls.tar.gz

# Verify the jar file exists and get its exact name
LAUNCHER_JAR=$(find plugins -name "org.eclipse.equinox.launcher_*.jar" | head -1)
if [ -z "$LAUNCHER_JAR" ]; then
    echo "Error: Could not find launcher jar file"
    echo "Contents of plugins directory:"
    ls -la plugins/
    exit 1
fi

echo "Found launcher jar: $LAUNCHER_JAR"

# Check for config directory
CONFIG_DIR=""
if [ -d "config_mac" ]; then
    CONFIG_DIR="config_mac"
elif [ -d "config_mac_arm64" ]; then
    CONFIG_DIR="config_mac_arm64"
elif [ -d "config_linux" ]; then
    CONFIG_DIR="config_linux"  # fallback
    echo "Warning: Using Linux config as fallback"
else
    echo "Error: No config directory found"
    echo "Available directories:"
    ls -la
    exit 1
fi

echo "Using config directory: $CONFIG_DIR"

# Create a helper script to get the exact paths
cat > ~/.local/bin/jdtls-paths.sh << 'EOF'
#!/bin/bash
JDTLS_HOME="$HOME/.local/share/nvim/mason/packages/jdtls"
LAUNCHER_JAR=$(find "$JDTLS_HOME/plugins" -name "org.eclipse.equinox.launcher_*.jar" | head -1)
CONFIG_DIR=$(find "$JDTLS_HOME" -name "config_*" -type d | head -1)

echo "LAUNCHER_JAR=$LAUNCHER_JAR"
echo "CONFIG_DIR=$CONFIG_DIR"
EOF

chmod +x ~/.local/bin/jdtls-paths.sh

echo ""
echo "JDTLS installed successfully!"
echo "Launcher jar: $(pwd)/$LAUNCHER_JAR"
echo "Config dir: $(pwd)/$CONFIG_DIR"
echo ""
echo "Now update your Neovim config with the corrected paths..."
