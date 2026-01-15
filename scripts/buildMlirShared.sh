#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# buildMlirShared.sh — Converts MLIR static libraries to shared libraries
# ═══════════════════════════════════════════════════════════════════════════════
#
# This script takes the static MLIR libraries (.a) from the LLVM distribution
# and links them into shared libraries (.so) for use with FFI.
#
# Usage:
#   ./scripts/buildMlirShared.sh
#
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Configuration                                                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendors"
LLVM_DIR="$VENDOR_DIR/llvm-current"
LIB_DIR="$LLVM_DIR/lib"
OUTPUT_DIR="$VENDOR_DIR/mlir-shared"

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
    echo "  ║   🔧  MLIR Static → Shared Library Converter                     ║"
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

preflight_check() {
    step "Checking requirements..."
    
    # Check for required tools
    for cmd in gcc ar; do
        if command -v "$cmd" &> /dev/null; then
            success "$cmd is available"
        else
            error "$cmd is required but not installed."
        fi
    done
    
    # Check LLVM installation
    if [ ! -d "$LLVM_DIR" ]; then
        error "LLVM not found at $LLVM_DIR. Run ./scripts/fetchMlir.sh first."
    fi
    success "LLVM found at $LLVM_DIR"
    
    # Check for MLIR static libraries
    local mlir_libs
    mlir_libs=$(find "$LIB_DIR" -name "libMLIR*.a" 2>/dev/null | wc -l)
    if [ "$mlir_libs" -eq 0 ]; then
        error "No MLIR static libraries found in $LIB_DIR"
    fi
    success "Found $mlir_libs MLIR static libraries"
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Build Logic                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

build_shared_lib() {
    local name="$1"
    shift
    local libs=("$@")
    
    local output_file="$OUTPUT_DIR/lib${name}.so"
    
    info "Building ${GREEN}lib${name}.so${NC}..."
    
    # Create a temporary directory for extraction
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    # Extract all object files from the static libraries
    for lib in "${libs[@]}"; do
        if [ -f "$LIB_DIR/$lib" ]; then
            (cd "$tmp_dir" && ar x "$LIB_DIR/$lib")
        else
            warn "Library $lib not found, skipping..."
        fi
    done
    
    # Count object files
    local obj_count
    obj_count=$(find "$tmp_dir" -name "*.o" | wc -l)
    
    if [ "$obj_count" -eq 0 ]; then
        warn "No object files extracted for $name"
        rm -rf "$tmp_dir"
        return 1
    fi
    
    info "Linking $obj_count object files..."
    
    # Link into shared library
    gcc -shared -fPIC -o "$output_file" "$tmp_dir"/*.o \
        -L"$LIB_DIR" \
        -lLLVM \
        -lstdc++ \
        -lm \
        -lpthread \
        -ldl \
        2>/dev/null || {
            warn "Failed to build lib${name}.so (may have unresolved dependencies)"
            rm -rf "$tmp_dir"
            return 1
        }
    
    # Cleanup
    rm -rf "$tmp_dir"
    
    local size
    size=$(du -h "$output_file" | cut -f1)
    success "Created lib${name}.so (${size})"
}

build_mlir_c_api() {
    step "Building MLIR C API shared library..."
    
    # The MLIR C API libraries (these are the FFI-friendly ones)
    local c_api_libs=(
        "libMLIRCAPIIR.a"
        "libMLIRCAPIInterfaces.a"
        "libMLIRCAPITransforms.a"
        "libMLIRCAPILinalg.a"
        "libMLIRCAPIFunc.a"
        "libMLIRCAPIArith.a"
        "libMLIRCAPITensor.a"
        "libMLIRCAPIMemRef.a"
        "libMLIRCAPISCF.a"
        "libMLIRCAPIGPU.a"
        "libMLIRCAPIAsync.a"
        "libMLIRCAPIControlFlow.a"
        "libMLIRCAPIConversion.a"
        "libMLIRCAPIExecutionEngine.a"
        "libMLIRCAPIRegisterEverything.a"
    )
    
    build_shared_lib "MLIRCAPI" "${c_api_libs[@]}"
}

build_mlir_execution_engine() {
    step "Building MLIR Execution Engine shared library..."
    
    local exec_libs=(
        "libMLIRExecutionEngine.a"
        "libMLIRExecutionEngineUtils.a"
        "libMLIRJitRunner.a"
    )
    
    build_shared_lib "MLIRExecutionEngine" "${exec_libs[@]}"
}

build_all_mlir() {
    step "Building combined MLIR shared library..."
    info "This will create a single libMLIR.so with all components"
    info "This may take a moment..."
    
    # Get all MLIR static libraries
    local all_libs=()
    while IFS= read -r -d '' lib; do
        all_libs+=("$(basename "$lib")")
    done < <(find "$LIB_DIR" -name "libMLIR*.a" -print0 | sort -z)
    
    info "Found ${#all_libs[@]} MLIR libraries to combine"
    
    build_shared_lib "MLIR" "${all_libs[@]}"
}

# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  Entry Point                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

main() {
    banner
    preflight_check
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    step "Output directory: ${BLUE}$OUTPUT_DIR${NC}"
    
    # Build the shared libraries
    build_mlir_c_api
    build_mlir_execution_engine
    build_all_mlir
    
    # Summary
    echo ""
    echo -e "${CYAN}${BOLD}  ╭───────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${BOLD}Build Summary${NC}                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ├───────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Output:${NC}  ${BLUE}$OUTPUT_DIR${NC}          ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    
    if [ -d "$OUTPUT_DIR" ]; then
        echo -e "${CYAN}${BOLD}  │${NC}  ${DIM}Libraries created:${NC}                                         ${CYAN}${BOLD}│${NC}"
        for so in "$OUTPUT_DIR"/*.so; do
            if [ -f "$so" ]; then
                local name size
                name=$(basename "$so")
                size=$(du -h "$so" | cut -f1)
                printf "${CYAN}${BOLD}  │${NC}    ${GREEN}%-30s${NC} %8s              ${CYAN}${BOLD}│${NC}\n" "$name" "$size"
            fi
        done
    fi
    
    echo -e "${CYAN}${BOLD}  │${NC}                                                               ${CYAN}${BOLD}│${NC}"
    echo -e "${CYAN}${BOLD}  ╰───────────────────────────────────────────────────────────────╯${NC}"
    
    done_msg "MLIR shared libraries are ready for FFI! 🚀"
    
    echo -e "${DIM}To use in your project:${NC}"
    echo -e "  export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$OUTPUT_DIR\""
    echo ""
}

main "$@"
