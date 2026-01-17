#!/usr/bin/env bash
# =============================================================================
# build-dev.sh - LLVM+MLIR Development Build
# =============================================================================
# Builds LLVM+MLIR with:
#   - All shared libraries (.so / .dylib)
#   - All command-line tools (mlir-opt, llc, opt, etc.)
#   - Headers and CMake config for downstream builds
#
# Environment Variables:
#   LLVM_VERSION  - LLVM major version (default: 21)
#   LLVM_SRC      - Path to llvm-project source
#   BUILD_DIR     - CMake build directory
#   INSTALL_PREFIX - Installation directory
#   JOBS          - Parallel build jobs
#
# Exit Codes:
#   0 - Success
#   1 - Error
# =============================================================================
set -euo pipefail

# =============================================================================
# Platform Detection
# =============================================================================
detect_platform() {
    local os arch
    os=$(uname -s)
    arch=$(uname -m)
    
    case "$os" in
        Linux)  os="linux" ;;
        Darwin) os="macos" ;;
        *)      echo "Unsupported OS: $os" >&2; exit 1 ;;
    esac
    
    case "$arch" in
        x86_64|amd64)  arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)             echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
    
    echo "${os}-${arch}"
}

PLATFORM_TAG=$(detect_platform)
PLATFORM="${PLATFORM_TAG%%-*}"
LLVM_VERSION="${LLVM_VERSION:-21}"

# Determine library extension for platform
case "$PLATFORM" in
    linux) LIB_EXT="so" ;;
    macos) LIB_EXT="dylib" ;;
esac

# =============================================================================
# Configuration
# =============================================================================
LLVM_SRC="${LLVM_SRC:-$PWD/llvm-project}"
BUILD_DIR="${BUILD_DIR:-$PWD/build-llvm-mlir-dev-${PLATFORM_TAG}}"
INSTALL_PREFIX="${INSTALL_PREFIX:-$PWD/llvm-mlir-dev-${LLVM_VERSION}-${PLATFORM_TAG}}"
GENERATOR="${GENERATOR:-Ninja}"

# Detect CPU cores
if command -v nproc >/dev/null 2>&1; then
    DEFAULT_JOBS=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    DEFAULT_JOBS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
else
    DEFAULT_JOBS=4
fi

JOBS="${JOBS:-$DEFAULT_JOBS}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

# =============================================================================
# Helper Functions
# =============================================================================
info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

# =============================================================================
# Build Summary
# =============================================================================
info "LLVM+MLIR Development Build (Full Toolchain)"
cat <<EOF
  Platform:       ${PLATFORM_TAG}
  LLVM Version:   ${LLVM_VERSION}
  Source:         ${LLVM_SRC}
  Build Dir:      ${BUILD_DIR}
  Install Prefix: ${INSTALL_PREFIX}
  Jobs:           ${JOBS}
  Build Type:     ${BUILD_TYPE}
  Lib Extension:  ${LIB_EXT}
EOF
echo ""

# =============================================================================
# Validation
# =============================================================================
if [[ ! -d "$LLVM_SRC/llvm" ]]; then
    error "LLVM source not found at: $LLVM_SRC/llvm"
fi

if [[ ! -d "$LLVM_SRC/mlir" ]]; then
    error "MLIR source not found at: $LLVM_SRC/mlir"
fi

# =============================================================================
# CMake Configuration
# =============================================================================
mkdir -p "$BUILD_DIR"

info "Configuring CMake (Development Build)..."

cmake -S "$LLVM_SRC/llvm" -B "$BUILD_DIR" -G "$GENERATOR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="X86;AArch64;RISCV;NVPTX;AMDGPU;SPIRV" \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON \
    -DMLIR_BUILD_MLIR_C_DYLIB=ON \
    -DLLVM_BUILD_TOOLS=ON \
    -DLLVM_BUILD_UTILS=ON \
    -DLLVM_INCLUDE_TOOLS=ON \
    -DLLVM_INCLUDE_UTILS=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DMLIR_INCLUDE_TESTS=OFF \
    -DMLIR_INCLUDE_INTEGRATION_TESTS=OFF \
    -DMLIR_ENABLE_EXECUTION_ENGINE=ON \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_EXPORT_SYMBOLS_FOR_PLUGINS=ON \
    -DCMAKE_CXX_VISIBILITY_PRESET=default \
    -DCMAKE_C_VISIBILITY_PRESET=default \
    -DCMAKE_VISIBILITY_INLINES_HIDDEN=OFF \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    -DCMAKE_MACOSX_RPATH=ON \
    -DLLVM_ENABLE_ZLIB=FORCE_ON \
    -DLLVM_ENABLE_ZSTD=OFF

info "CMake configuration complete"
echo ""

# =============================================================================
# Build
# =============================================================================
info "Building LLVM+MLIR (full toolchain)..."
info "Estimated time: 60-120 minutes"
echo ""

cd "$BUILD_DIR"

if [[ "$GENERATOR" == "Ninja" ]]; then
    time ninja -j "$JOBS"
else
    time cmake --build . --parallel "$JOBS"
fi

# Verify TableGen contract (Dev build builds tools, but explicit check is safe)
if [[ ! -x "bin/llvm-tblgen" || ! -x "bin/mlir-tblgen" ]]; then
    warn "TableGen binaries not found in bin/. This is unexpected for a dev build."
fi

# =============================================================================
# Install
# =============================================================================
info "Installing to $INSTALL_PREFIX..."

if [[ "$GENERATOR" == "Ninja" ]]; then
    ninja install
else
    cmake --install .
fi

# =============================================================================
# Verification
# =============================================================================
info "Verifying installation..."
echo ""

# Check critical tools exist
REQUIRED_TOOLS=("mlir-opt" "mlir-translate" "llc" "opt")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if [[ -x "$INSTALL_PREFIX/bin/$tool" ]]; then
        info "Tool verified: $tool"
    else
        MISSING_TOOLS+=("$tool")
        warn "Tool missing: $tool"
    fi
done

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
    warn "Some tools are missing, but build may still be usable"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Development Build Completed Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Installation: $INSTALL_PREFIX"
echo ""
echo "🔧 Tools (sample):"
find "$INSTALL_PREFIX/bin" -maxdepth 1 -type f -executable 2>/dev/null | head -10 | while read -r tool; do
    basename "$tool"
done || echo "   (no tools found)"
echo "   ... and more"
echo ""
echo "📚 Libraries:"
find "$INSTALL_PREFIX/lib" -maxdepth 1 \( -name "libLLVM*.$LIB_EXT*" -o -name "libMLIR*.$LIB_EXT*" \) -type f 2>/dev/null | \
    while read -r lib; do
        size=$(du -h "$lib" | cut -f1)
        name=$(basename "$lib")
        printf "   %-40s %10s\n" "$name" "$size"
    done | head -10 || echo "   (no libraries found)"
echo ""
echo "✅ Ready for development!"
echo ""

exit 0
