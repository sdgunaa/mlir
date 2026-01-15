#!/usr/bin/env bash
# fetchMlir.sh - A friendly assistant to help you set up MLIR for Mojo.

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

# --- Humanised UI Helpers ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE} 📦 ${NC} $1"; }
action() { echo -e "${MAGENTA} 🚀 ${NC} $1"; }
done_msg() { echo -e "${GREEN} ✅ ${NC} $1"; }
warn() { echo -e "${YELLOW} ⚠️  ${NC} $1"; }
error() { echo -e "\033[0;31m ❌ ${NC} $1"; exit 1; }

# --- Header ---
clear
echo -e "${MAGENTA}==========================================${NC}"
echo -e "   🔥 MLIR Setup Assistant for Mojo 🔥"
echo -e "${MAGENTA}==========================================${NC}"
echo ""

# --- Environmental Checks ---
log "Checking your toolbox..."
for cmd in wget tar; do
    if ! command -v "$cmd" &> /dev/null; then
        error "I can't find '$cmd'! Please install it so I can help you."
    fi
done
done_msg "Toolbox looks good."

# --- Check Internet (Optional but nice) ---
log "Checking if I can reach GitHub..."
if ! wget -q --spider google.com; then
    error "I can't seem to reach the internet. Please check your connection."
fi
done_msg "Connection is live!"

# --- Execution ---
mkdir -p "$VENDOR_DIR"

if [ ! -d "$LLVM_DIR" ]; then
    action "I'm going to set up LLVM/MLIR ${LLVM_VERSION} for you."
    
    cd "$VENDOR_DIR"

    if [ ! -f "$ARCHIVE" ]; then
        log "Downloading the archive from GitHub (this might take a minute)..."
        echo -e "${BLUE}Link:${NC} ${URL}"
        wget --show-progress "$URL" || error "Something went wrong during the download. Check the link or version."
    else
        log "Found an existing archive in the vendors folder. Skipping download."
    fi

    action "Extracting the heavy lifting... please wait."
    mkdir -p "tmp_extract"
    tar -xf "$ARCHIVE" -C "tmp_extract" --strip-components=1
    mv "tmp_extract" "$LLVM_DIR"
    
    done_msg "Everything has been unpacked perfectly."
else
    log "Looks like LLVM/MLIR ${LLVM_VERSION} is already tucked away in 'vendors/'."
fi

# --- Cleanup & Finalize ---
cd "$ROOT_DIR"

log "Pointing 'llvm-current' to the new version..."
ln -sfn "llvm-${LLVM_VERSION}" "$CURRENT_LINK"

echo ""
echo -e "${GREEN}✨ Success! Your MLIR environment is ready for action. ✨${NC}"
echo -e "--------------------------------------------------------"
echo -e " 📂 ${BLUE}Location:${NC} ${LLVM_DIR}"
echo -e " 🔗 ${BLUE}Symlink:${NC}  ${CURRENT_LINK}"
echo -e " 🛠️  ${BLUE}Binaries:${NC} ${LLVM_DIR}/bin"
echo -e " 📚 ${BLUE}Library:${NC}  ${LLVM_DIR}/lib"
echo -e "--------------------------------------------------------"

# Verify MLIR libraries
if [ -d "$LLVM_DIR/lib" ]; then
    MLIR_LIBS=$(ls "$LLVM_DIR/lib" | grep -c "MLIR" || true)
    if [ "$MLIR_LIBS" -gt 0 ]; then
        done_msg "I verified ${MLIR_LIBS} MLIR libraries are standing by."
    else
        warn "I couldn't find any MLIR-specific libraries in the lib folder. You might want to double-check the archive!"
    fi
fi

echo -e "\n${MAGENTA}Happy coding! 🚀${NC}\n"

