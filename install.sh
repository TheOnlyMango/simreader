#!/bin/bash
# Installation script for simreader

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for user installation"
   print_error "Run without sudo for user installation or with sudo for system installation"
   exit 1
fi

# Installation paths
PREFIX=${PREFIX:-/usr/local}
if [[ $EUID -eq 0 ]]; then
    PREFIX=/usr/local
    INSTALL_DIR="$PREFIX/bin"
    MAN_DIR="$PREFIX/share/man/man1"
    DOC_DIR="$PREFIX/share/doc/simreader"
else
    INSTALL_DIR="$HOME/.local/bin"
    MAN_DIR="$HOME/.local/share/man/man1"
    DOC_DIR="$HOME/.local/share/doc/simreader"
fi

print_status "Installing simreader to $INSTALL_DIR"

# Check dependencies
print_status "Checking dependencies..."

# Check for pcsc-lite
if ! pkg-config --exists libpcsclite; then
    print_warning "pcsc-lite development libraries not found"
    print_status "Installing dependencies..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y libpcsclite-dev libccid pcscd
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y pcsc-lite-devel pcsc-lite-ccid pcsc-lite
    elif command -v pacman &> /dev/null; then
        sudo pacman -S pcsclite ccid
    else
        print_error "Cannot install dependencies automatically"
        print_error "Please install pcscite development libraries manually"
        exit 1
    fi
fi

# Build the project
print_status "Building simreader..."
make clean
make

# Create directories
print_status "Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$MAN_DIR"
mkdir -p "$DOC_DIR"

# Install files
print_status "Installing binary..."
install -m 755 build/simreader "$INSTALL_DIR/simreader"

print_status "Installing man page..."
install -m 644 man/simreader.1 "$MAN_DIR/simreader.1"

print_status "Installing documentation..."
install -m 644 README.md LICENSE "$DOC_DIR/"

# Update man database
if command -v mandb &> /dev/null; then
    print_status "Updating man database..."
    mandb -q "$MAN_DIR" 2>/dev/null || true
fi

# Add to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_warning "$INSTALL_DIR is not in your PATH"
    print_status "Adding to ~/.bashrc..."
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> ~/.bashrc
    print_status "Please run: source ~/.bashrc or restart your terminal"
fi

# Check PC/SC service
print_status "Checking PC/SC service..."
if ! systemctl is-active --quiet pcscd 2>/dev/null; then
    print_warning "PC/SC service is not running"
    print_status "Starting and enabling PC/SC service..."
    sudo systemctl enable --now pcscd || print_warning "Could not start pcscd service"
fi

print_status "Installation completed successfully!"
echo
print_status "Usage:"
echo "  simreader                    # Basic SIM information"
echo "  simreader -a                # Complete analysis"
echo "  simreader -e -v             # Explore files with verbose output"
echo "  simreader -j                # JSON output"
echo "  man simreader               # View manual page"
echo
print_status "For more information, see: man simreader"