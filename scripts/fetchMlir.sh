#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# fetchMlir.sh — MLIR/LLVM Binary Fetcher for Mojo MLIR Bindings
# ═══════════════════════════════════════════════════════════════════════════════
#
# A developer-friendly script that downloads and sets up MLIR/LLVM toolchain
# binaries from official GitHub releases.
#
# Usage:
#   ./scripts/fetchMlir.sh                  # Uses default version (21.1.8)
#   LLVM_VERSION=19.1.0 ./scripts/fetchMlir.sh  # Custom version
#
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Configuration                                                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

LLVM_VERSION="${LLVM_VERSION:-21.1.8}"
PLATFORM="${PLATFORM:-Linux-X64}"
ARCHIVE="LLVM-${LLVM_VERSION}-${PLATFORM}.tar.xz"
BASE_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}"
URL="${BASE_URL}/${ARCHIVE}"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendors"
LLVM_DIR="$VENDOR_DIR/llvm-${LLVM_VERSION}"
CURRENT_LINK="$VENDOR_DIR/llvm-current"

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  UI Helpers                                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

# Colors
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Message helpers with emojis
banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                  ║"
    echo "  ║   🦙  MLIR Mojo Bindings — Toolchain Fetcher                     ║"
    echo "  ║                                                                  ║"
    echo "  ╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

step() { echo -e "\n${BLUE}${BOLD}▶${NC} ${BOLD}$1${NC}"; }
info() { echo -e "  ${DIM}├─${NC} $1"; }
success() { echo -e "  ${GREEN}✔${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
error() { echo -e "\n${RED}${BOLD}✖ Error:${NC} $1\n"; exit 1; }
done_msg() { echo -e "\n${GREEN}${BOLD}🎉 All done!${NC} $1\n"; }

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p "$pid" > /dev/null 2>&1; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r  ${CYAN}%s${NC} %s" "${spinstr:$i:1}" "$2"
            sleep $delay
        done
    done
    printf "\r"
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Preflight Checks                                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

preflight_check() {
    step "Checking requirements..."
    
    local missing=()
    for cmd in tar xz; do
        if command -v "$cmd" &> /dev/null; then
            success "$cmd is available"
        else
            missing+=("$cmd")
        fi
    done
    
    # Check for download tools (aria2c preferred, wget as fallback)
    if command -v aria2c &> /dev/null; then
        DOWNLOADER="aria2c"
        success "aria2c is available ${GREEN}(turbo mode 🚀)${NC}"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
        success "wget is available"
        info "${DIM}Tip: Install aria2c for up to 16x faster downloads${NC}"
    elif command -v curl &> /dev/null; then
        DOWNLOADER="curl"
        success "curl is available"
        info "${DIM}Tip: Install aria2c for up to 16x faster downloads${NC}"
    else
        missing+=("wget or curl or aria2c")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required tools: ${missing[*]}. Please install them first."
    fi
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Main Logic                                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

download_llvm() {
    step "Downloading LLVM/MLIR ${LLVM_VERSION}..."
    info "Source: ${DIM}${URL}${NC}"
    
    local download_success=false
    
    case "$DOWNLOADER" in
        aria2c)
            # aria2c: Multi-connection download for maximum speed
            # -x16: 16 connections per server
            # -s16: Split file into 16 segments
            # -k1M: Minimum split size 1MB
            # --file-allocation=none: Don't pre-allocate (faster start)
            info "Using ${GREEN}aria2c turbo mode${NC} (16 parallel connections) 🚀"
            echo ""
            if aria2c \
                --max-connection-per-server=16 \
                --split=16 \
                --min-split-size=1M \
                --file-allocation=none \
                --continue=true \
                --auto-file-renaming=false \
                --console-log-level=notice \
                --summary-interval=1 \
                --out="$ARCHIVE" \
                "$URL"; then
                download_success=true
            fi
            ;;
        wget)
            # wget: Optimized single-connection download
            info "Using wget (single connection)"
            info "This may take a few minutes ☕"
            echo ""
            if wget \
                --progress=bar:force:noscroll \
                --tries=3 \
                --timeout=30 \
                --continue \
                -O "$ARCHIVE" \
                "$URL" 2>&1; then
                download_success=true
            fi
            ;;
        curl)
            # curl: Alternative single-connection download
            info "Using curl (single connection)"
            info "This may take a few minutes ☕"
            echo ""
            if curl \
                --progress-bar \
                --retry 3 \
                --retry-delay 5 \
                --connect-timeout 30 \
                --continue-at - \
                -L \
                -o "$ARCHIVE" \
                "$URL"; then
                download_success=true
            fi
            ;;
    esac
    
    echo ""
    if [ "$download_success" = true ] && [ -f "$ARCHIVE" ]; then
        local file_size
        file_size=$(du -h "$ARCHIVE" | cut -f1)
        success "Download complete! (${file_size})"
    else
        error "Download failed. Please check your internet connection or verify the version exists."
    fi
}

extract_llvm() {
    step "Extracting archive..."
    info "Unpacking ${ARCHIVE}..."
    
    mkdir -p "tmp_extract"
    
    # Run extraction with spinner
    tar -xf "$ARCHIVE" -C "tmp_extract" --strip-components=1 &
    local tar_pid=$!
    spinner $tar_pid "Extracting files..."
    wait $tar_pid
    
    mv "tmp_extract" "$LLVM_DIR"
    success "Extracted to ${LLVM_DIR}"
    
    # Clean up archive to save space
    info "Cleaning up downloaded archive..."
    rm -f "$ARCHIVE"
    success "Archive removed to save disk space"
}

create_symlink() {
    step "Creating version symlink..."
    ln -sfn "llvm-${LLVM_VERSION}" "$CURRENT_LINK"
    success "llvm-current → llvm-${LLVM_VERSION}"
}

verify_installation() {
    step "Verifying installation..."
    
    if [ -d "$LLVM_DIR/bin" ]; then
        local bin_count
        bin_count=$(find "$LLVM_DIR/bin" -type f -executable | wc -l)
        success "Found ${bin_count} executables in bin/"
    fi
    
    if [ -d "$LLVM_DIR/lib" ]; then
        local mlir_libs
        mlir_libs=$(find "$LLVM_DIR/lib" -name "*MLIR*" 2>/dev/null | wc -l)
        if [ "$mlir_libs" -gt 0 ]; then
            success "Found ${mlir_libs} MLIR-related libraries"
        else
            warn "No MLIR libraries found. This release may not include MLIR."
        fi
    fi
}

print_summary() {
    echo ""
    echo -e "${CYAN}${BOLD}  ╭───────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${BOLD}Installation Summary${NC}                                        ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ├───────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Version:${NC}   ${GREEN}${LLVM_VERSION}${NC}                                         ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Platform:${NC}  ${PLATFORM}                                       ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Location:${NC}  ${BLUE}vendors/llvm-${LLVM_VERSION}${NC}                         ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Symlink:${NC}   ${BLUE}vendors/llvm-current${NC}                            ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ├───────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Quick access paths:${NC}                                        ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Binaries:  ${MAGENTA}vendors/llvm-current/bin${NC}                     ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Libraries: ${MAGENTA}vendors/llvm-current/lib${NC}                     ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Headers:   ${MAGENTA}vendors/llvm-current/include${NC}                 ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ╰───────────────────────────────────────────────────────────────╯${NC}"
    
    done_msg "LLVM/MLIR is ready to use. Happy compiling! 🚀"
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Entry Point                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

main() {
    banner
    preflight_check
    
    mkdir -p "$VENDOR_DIR"
    cd "$VENDOR_DIR"
    
    if [ -d "$LLVM_DIR" ]; then
        echo ""
        success "LLVM/MLIR ${LLVM_VERSION} is already installed!"
        info "Location: ${LLVM_DIR}"
        info "To reinstall, remove the directory first:"
        echo -e "     ${DIM}rm -rf vendors/llvm-${LLVM_VERSION}${NC}"
        create_symlink
    else
        download_llvm
        extract_llvm
        create_symlink
        verify_installation
    fi
    
    cd "$ROOT_DIR"
    print_summary
}

main "$@"

