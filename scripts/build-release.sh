#!/usr/bin/env bash
# =============================================================================
# build-release.sh - Production LLVM+MLIR Release Build
# =============================================================================
# Builds LLVM+MLIR with C API enabled for FFI usage.
# Produces minimal runtime package (no tools, just shared libraries).
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
#   1 - Error (source not found, build failed, verification failed)
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
BUILD_DIR="${BUILD_DIR:-$PWD/build-llvm-mlir-${PLATFORM_TAG}}"
INSTALL_PREFIX="${INSTALL_PREFIX:-$PWD/llvm-mlir-${LLVM_VERSION}-${PLATFORM_TAG}}"
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
info "LLVM+MLIR Release Build (FFI Libraries)"
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

info "Configuring CMake..."

cmake -S "$LLVM_SRC/llvm" -B "$BUILD_DIR" -G "$GENERATOR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="X86;AArch64;RISCV;NVPTX;AMDGPU;SPIRV" \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON \
    -DMLIR_BUILD_MLIR_C_DYLIB=ON \
    -DLLVM_INCLUDE_TOOLS=ON \
    -DLLVM_BUILD_TOOLS=OFF \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DMLIR_INCLUDE_TESTS=OFF \
    -DMLIR_INCLUDE_INTEGRATION_TESTS=OFF \
    -DMLIR_ENABLE_EXECUTION_ENGINE=ON \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ASSERTIONS=OFF \
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
# Build - Stage 1: TableGen
# =============================================================================
info "Stage 1: Building TableGen generators..."

cd "$BUILD_DIR"

if [[ "$GENERATOR" == "Ninja" ]]; then
    ninja -j "$JOBS" llvm-tblgen mlir-tblgen
else
    cmake --build . --target llvm-tblgen --parallel "$JOBS"
    cmake --build . --target mlir-tblgen --parallel "$JOBS"
fi

# Verify TableGen bootstrap contract
if [[ ! -x "bin/llvm-tblgen" || ! -x "bin/mlir-tblgen" ]]; then
    error "TableGen bootstrap failed. Required binaries (llvm-tblgen, mlir-tblgen) not found in bin/"
fi

info "TableGen built and verified successfully"
echo ""

# =============================================================================
# Build - Stage 2: Libraries
# =============================================================================
info "Stage 2: Building LLVM + MLIR shared libraries..."
info "Estimated time: 30-60 minutes"
echo ""

if [[ "$GENERATOR" == "Ninja" ]]; then
    time ninja -j "$JOBS"
else
    time cmake --build . --parallel "$JOBS"
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
info "Verifying C API symbols..."
echo ""

cd "$INSTALL_PREFIX/lib"

# Platform-specific library names
if [[ "$PLATFORM" == "linux" ]]; then
    LLVM_LIB_PATTERN="libLLVM.so*"
    MLIR_LIB_PATTERN="libMLIR-C.so*"
    NM_FLAGS="-D"
else
    LLVM_LIB_PATTERN="libLLVM.dylib"
    MLIR_LIB_PATTERN="libMLIR-C.dylib"
    NM_FLAGS=""
fi

# Find and verify LLVM library
# shellcheck disable=SC2086
LLVM_LIB=$(find . -maxdepth 1 -name "$LLVM_LIB_PATTERN" -type f 2>/dev/null | head -1 || true)
if [[ -n "$LLVM_LIB" && -f "$LLVM_LIB" ]]; then
    if nm $NM_FLAGS "$LLVM_LIB" 2>/dev/null | grep -q "LLVMContextCreate"; then
        info "LLVM C API: LLVMContextCreate found in $LLVM_LIB"
    else
        if [[ "$PLATFORM" == "linux" ]]; then
            error "LLVMContextCreate not exported in $LLVM_LIB"
        else
            warn "LLVMContextCreate symbol check skipped on macOS"
        fi
    fi
else
    error "LLVM shared library not found (pattern: $LLVM_LIB_PATTERN)"
fi

# Find and verify MLIR C API library
# shellcheck disable=SC2086
MLIR_LIB=$(find . -maxdepth 1 -name "$MLIR_LIB_PATTERN" -type f 2>/dev/null | head -1 || true)
if [[ -n "$MLIR_LIB" && -f "$MLIR_LIB" ]]; then
    if nm $NM_FLAGS "$MLIR_LIB" 2>/dev/null | grep -q "mlirContextCreate"; then
        info "MLIR C API: mlirContextCreate found in $MLIR_LIB"
    else
        if [[ "$PLATFORM" == "linux" ]]; then
            warn "mlirContextCreate not exported in $MLIR_LIB"
        fi
    fi
else
    warn "MLIR C API library not found (pattern: $MLIR_LIB_PATTERN)"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Build Completed Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Installation: $INSTALL_PREFIX"
echo ""
echo "📚 Libraries:"
# Safe library listing with proper extension
find "$INSTALL_PREFIX/lib" -maxdepth 1 \( -name "libLLVM*.$LIB_EXT*" -o -name "libMLIR*.$LIB_EXT*" \) -type f 2>/dev/null | \
    while read -r lib; do
        size=$(du -h "$lib" | cut -f1)
        name=$(basename "$lib")
        printf "   %-40s %10s\n" "$name" "$size"
    done || echo "   (no libraries found)"
echo ""
echo "✅ Ready for FFI usage!"
echo ""

exit 0
