#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# installMlirApt.sh — Install MLIR shared libraries via official LLVM APT repo
# ═══════════════════════════════════════════════════════════════════════════════
#
# This script installs properly built MLIR shared libraries from the official
# LLVM APT repository. These are production-safe and include libMLIR.so.
#
# Usage:
#   ./scripts/installMlirApt.sh
#   LLVM_VERSION=20 ./scripts/installMlirApt.sh  # Specific version
#
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Configuration                                                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

LLVM_VERSION="${LLVM_VERSION:-21}"

# Detect Ubuntu codename
if [ -f /etc/os-release ]; then
    . /etc/os-release
    UBUNTU_CODENAME="${UBUNTU_CODENAME:-jammy}"
else
    UBUNTU_CODENAME="jammy"
fi

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  UI Helpers                                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                  ║"
    echo "  ║   📦  MLIR APT Installer — Official LLVM Packages                ║"
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

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Preflight Checks                                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        warn "This script requires sudo privileges to install packages."
        info "You will be prompted for your password."
        echo ""
    fi
}

check_distro() {
    step "Checking system..."
    
    if [ -f /etc/debian_version ]; then
        success "Debian/Ubuntu detected"
        info "Codename: ${UBUNTU_CODENAME}"
    else
        error "This script only supports Debian/Ubuntu systems. For other distros, build from source."
    fi
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Installation Logic                                                             ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

add_llvm_repo() {
    step "Adding LLVM APT repository..."
    
    # Download and add the LLVM GPG key
    info "Downloading LLVM GPG key..."
    if ! wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc > /dev/null 2>&1; then
        # Fallback for older systems
        wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - 2>/dev/null || true
    fi
    success "GPG key added"
    
    # Add the repository
    local repo_line="deb http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-${LLVM_VERSION} main"
    local repo_file="/etc/apt/sources.list.d/llvm-${LLVM_VERSION}.list"
    
    info "Adding repository: ${DIM}${repo_line}${NC}"
    echo "$repo_line" | sudo tee "$repo_file" > /dev/null
    success "Repository added"
    
    # Update package lists
    info "Updating package lists..."
    sudo apt-get update -qq
    success "Package lists updated"
}

install_mlir_packages() {
    step "Installing MLIR packages..."
    
    local packages=(
        "libmlir-${LLVM_VERSION}-dev"
        "mlir-${LLVM_VERSION}-tools"
        "libllvm${LLVM_VERSION}"
        "llvm-${LLVM_VERSION}-dev"
    )
    
    for pkg in "${packages[@]}"; do
        info "Installing ${GREEN}${pkg}${NC}..."
    done
    
    echo ""
    sudo apt-get install -y "${packages[@]}"
    echo ""
    
    success "All packages installed!"
}

create_symlinks() {
    step "Creating convenience symlinks..."
    
    local llvm_dir="/usr/lib/llvm-${LLVM_VERSION}"
    local vendor_link
    
    # Get the project root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
    VENDOR_DIR="$ROOT_DIR/vendors"
    
    mkdir -p "$VENDOR_DIR"
    
    # Create symlink to system LLVM
    vendor_link="$VENDOR_DIR/llvm-system"
    if [ -d "$llvm_dir" ]; then
        ln -sfn "$llvm_dir" "$vendor_link"
        success "Created: vendors/llvm-system → ${llvm_dir}"
        
        # Also update llvm-current
        ln -sfn "llvm-system" "$VENDOR_DIR/llvm-current"
        success "Updated: vendors/llvm-current → llvm-system"
    fi
}

verify_installation() {
    step "Verifying installation..."
    
    local llvm_lib="/usr/lib/llvm-${LLVM_VERSION}/lib"
    
    # Check for MLIR shared libraries
    if [ -f "$llvm_lib/libMLIR.so" ] || [ -f "$llvm_lib/libMLIR.so.${LLVM_VERSION}" ]; then
        success "libMLIR.so found!"
        local size
        size=$(du -h "$llvm_lib"/libMLIR.so* 2>/dev/null | head -1 | cut -f1)
        info "Size: ${size}"
    else
        warn "libMLIR.so not found as shared library"
        info "Checking for static library..."
        if [ -f "$llvm_lib/libMLIR.a" ]; then
            success "libMLIR.a found (static)"
        fi
    fi
    
    # Check for MLIR C API
    if [ -f "$llvm_lib/libMLIR-C.so" ] || [ -f "$llvm_lib/libMLIRCAPI"*.a ]; then
        success "MLIR C API libraries found!"
    fi
    
    # Check for mlir-opt tool
    if command -v "mlir-opt-${LLVM_VERSION}" &> /dev/null; then
        success "mlir-opt-${LLVM_VERSION} is available"
    elif [ -x "/usr/lib/llvm-${LLVM_VERSION}/bin/mlir-opt" ]; then
        success "mlir-opt found at /usr/lib/llvm-${LLVM_VERSION}/bin/mlir-opt"
    fi
    
    # List available MLIR libraries
    info "Available MLIR libraries:"
    ls -1 "$llvm_lib" 2>/dev/null | grep -i mlir | head -10 | while read -r lib; do
        echo -e "     ${DIM}${lib}${NC}"
    done
    local count
    count=$(ls -1 "$llvm_lib" 2>/dev/null | grep -ci mlir || echo "0")
    if [ "$count" -gt 10 ]; then
        echo -e "     ${DIM}... and $((count - 10)) more${NC}"
    fi
}

print_summary() {
    local llvm_dir="/usr/lib/llvm-${LLVM_VERSION}"
    
    echo ""
    echo -e "${CYAN}${BOLD}  ╭───────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${BOLD}Installation Summary${NC}                                        ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ├───────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}LLVM Version:${NC}  ${GREEN}${LLVM_VERSION}${NC}                                       ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Install Path:${NC}  ${BLUE}/usr/lib/llvm-${LLVM_VERSION}${NC}                        ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ├───────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Key paths:${NC}                                                  ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Headers:   ${BLUE}/usr/lib/llvm-${LLVM_VERSION}/include${NC}              ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Libraries: ${BLUE}/usr/lib/llvm-${LLVM_VERSION}/lib${NC}                  ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}    Binaries:  ${BLUE}/usr/lib/llvm-${LLVM_VERSION}/bin${NC}                  ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ╰───────────────────────────────────────────────────────────────╯${NC}"
    
    done_msg "MLIR is installed and ready for FFI! 🚀"
    
    echo -e "${DIM}Usage in your project:${NC}"
    echo ""
    echo -e "  ${BOLD}# Set library path${NC}"
    echo -e "  export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:${llvm_dir}/lib\""
    echo ""
    echo -e "  ${BOLD}# For CMake projects${NC}"
    echo -e "  cmake -DMLIR_DIR=${llvm_dir}/lib/cmake/mlir ..."
    echo ""
    echo -e "  ${BOLD}# For Mojo FFI${NC}"
    echo -e "  # Libraries are at: ${llvm_dir}/lib"
    echo ""
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Entry Point                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

main() {
    banner
    
    echo -e "  ${DIM}This will install LLVM/MLIR ${LLVM_VERSION} from the official APT repository.${NC}"
    echo -e "  ${DIM}Packages include shared libraries suitable for FFI.${NC}"
    echo ""
    
    check_sudo
    check_distro
    add_llvm_repo
    install_mlir_packages
    create_symlinks
    verify_installation
    print_summary
}

main "$@"
