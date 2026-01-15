#!/usr/bin/env bash
# fetchMlir.sh - Downloads and sets up MLIR/LLVM binaries for the project.

set -euo pipefail

# --- Configuration ---
LLVM_VERSION=${LLVM_VERSION:-"21.1.8"}
PLATFORM=${PLATFORM:-"Linux-X64"}
ARCHIVE="LLVM-${LLVM_VERSION}-${PLATFORM}.tar.xz"
BASE_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}"
URL="${BASE_URL}/${ARCHIVE}"

# Infrastructure paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendors"
LLVM_DIR="$VENDOR_DIR/llvm-${LLVM_VERSION}"
CURRENT_LINK="$VENDOR_DIR/llvm-current"

# --- UI Helpers ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "\033[0;31m[ERROR]${NC} $1"; exit 1; }

# --- Requirements Check ---
for cmd in wget tar; do
    if ! command -v "$cmd" &> /dev/null; then
        error "$cmd is required but not installed."
    fi
done

# --- Execution ---
mkdir -p "$VENDOR_DIR"

if [ ! -d "$LLVM_DIR" ]; then
    info "Preparing to install LLVM/MLIR ${LLVM_VERSION}..."
    
    cd "$VENDOR_DIR"

    if [ ! -f "$ARCHIVE" ]; then
        info "Downloading from: ${URL}"
        wget --show-progress "$URL" || error "Failed to download LLVM archive. Please check the version/URL."
    fi

    info "Extracting ${ARCHIVE}..."
    # Create a temp dir for extraction to handle inconsistent archive root names
    mkdir -p "tmp_extract"
    tar -xf "$ARCHIVE" -C "tmp_extract" --strip-components=1
    mv "tmp_extract" "$LLVM_DIR"
    
    success "Extraction complete."
else
    info "LLVM/MLIR ${LLVM_VERSION} is already installed in ${LLVM_DIR}"
fi

# --- Cleanup & Finalize ---
cd "$ROOT_DIR"

# Create/Update symlink to current version
info "Updating 'llvm-current' symlink..."
ln -sfn "llvm-${LLVM_VERSION}" "$CURRENT_LINK"

success "Setup finished!"
echo -e "\n${BLUE}Installation Summary:${NC}"
echo -e "  Location: ${LLVM_DIR}"
echo -e "  Symlink:  ${CURRENT_LINK}"
echo -e "  Binaries: ${LLVM_DIR}/bin"
echo -e "  Libs:     ${LLVM_DIR}/lib"

# Verify MLIR libraries
if [ -d "$LLVM_DIR/lib" ]; then
    MLIR_LIBS=$(ls "$LLVM_DIR/lib" | grep -c "MLIR" || true)
    if [ "$MLIR_LIBS" -gt 0 ]; then
        info "Found ${MLIR_LIBS} MLIR-related libraries."
    else
        warn "No libraries containing 'MLIR' found in ${LLVM_DIR}/lib. Check the archive content."
    fi
fi

