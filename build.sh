#!/usr/bin/env bash
# build.sh - Multi-platform LLVM+MLIR build script for Mojo FFI
# Builds LLVM+MLIR with C API enabled for all supported platforms
set -euo pipefail

# ----------------------
# Platform Detection
# ----------------------
detect_platform() {
  local OS=$(uname -s)
  local ARCH=$(uname -m)
  
  case "$OS" in
    Linux)
      PLATFORM="linux"
      ;;
    Darwin)
      PLATFORM="macos"
      ;;
    *)
      echo "Unsupported OS: $OS"
      exit 1
      ;;
  esac
  
  case "$ARCH" in
    x86_64|amd64)
      ARCH="x64"
      ;;
    aarch64|arm64)
      ARCH="arm64"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac
  
  echo "${PLATFORM}-${ARCH}"
}

PLATFORM_TAG=$(detect_platform)
PLATFORM=${PLATFORM_TAG%%-*}  # Extract 'linux' or 'macos' from 'linux-x64'
LLVM_VERSION="${LLVM_VERSION:-21}"

# ----------------------
# Configuration
# ----------------------
LLVM_SRC="${LLVM_SRC:-$PWD/llvm-project}"
BUILD_DIR="${BUILD_DIR:-$PWD/build-llvm-mlir-${PLATFORM_TAG}}"
INSTALL_PREFIX="${INSTALL_PREFIX:-$PWD/llvm-mlir-${LLVM_VERSION}-${PLATFORM_TAG}}"
GENERATOR="${GENERATOR:-Ninja}"

# Detect number of cores
if command -v nproc >/dev/null 2>&1; then
  DEFAULT_JOBS=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
  DEFAULT_JOBS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
else
  DEFAULT_JOBS=4
fi

JOBS="${JOBS:-$DEFAULT_JOBS}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

# ----------------------
# Helper functions
# ----------------------
info() { echo -e "\e[1;34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $*"; }
err()  { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; exit 1; }

# ----------------------
# Build Summary
# ----------------------
info "LLVM+MLIR Multi-Platform Build for Mojo FFI"
echo "  Platform:      $PLATFORM_TAG"
echo "  LLVM version:  $LLVM_VERSION"
echo "  Source:        $LLVM_SRC"
echo "  Build dir:     $BUILD_DIR"
echo "  Install dir:   $INSTALL_PREFIX"
echo "  Jobs:          $JOBS"
echo ""

# ----------------------
# Validation
# ----------------------
if [ ! -d "$LLVM_SRC/llvm" ]; then
  err "LLVM source not found at: $LLVM_SRC
Please clone with: git clone --depth=1 --branch=release/${LLVM_VERSION}.x https://github.com/llvm/llvm-project.git"
fi

if [ ! -d "$LLVM_SRC/mlir" ]; then
  err "MLIR source not found at: $LLVM_SRC/mlir"
fi

# ----------------------
# CMake Configuration
# ----------------------
mkdir -p "$BUILD_DIR"

info "Configuring with CMake..."

cmake -S "$LLVM_SRC/llvm" -B "$BUILD_DIR" -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  \
  `# Enable MLIR project` \
  -DLLVM_ENABLE_PROJECTS="mlir" \
  \
  `# Target architectures - including RISC-V for future compatibility` \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64;RISCV;NVPTX;AMDGPU;SPIRV" \
  \
  `# Build monolithic shared libraries with C API` \
  -DBUILD_SHARED_LIBS=OFF \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DMLIR_BUILD_MLIR_C_DYLIB=ON \
  \
  `# MLIR Feature Flags` \
  -DMLIR_ENABLE_EXECUTION_ENGINE=ON \
  -DMLIR_ENABLE_PDL=ON \
  -DMLIR_ENABLE_IRDL=ON \
  -DMLIR_ENABLE_TRANSFORM_DIALECT=ON \
  \
  `# Build optimizations` \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_OPTIMIZED_TABLEGEN=ON \
  \
  `# Symbol visibility control (smaller binaries, faster linking)` \
  -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
  -DCMAKE_C_VISIBILITY_PRESET=hidden \
  -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
  \
  `# Runtime path handling` \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
  \
  `# Compression` \
  -DLLVM_ENABLE_ZLIB=FORCE_ON \
  -DLLVM_ENABLE_ZSTD=OFF



# ----------------------
# Build
# ----------------------
info "Building LLVM+MLIR..."
info "This will take 40-90 minutes depending on your CPU"
echo ""

cd "$BUILD_DIR"

if [ "$GENERATOR" = "Ninja" ]; then
  time ninja -j "$JOBS"
else
  time cmake --build . --parallel "$JOBS"
fi



# ----------------------
# Install
# ----------------------
info "Installing to $INSTALL_PREFIX..."

if [ "$GENERATOR" = "Ninja" ]; then
  ninja install
else
  cmake --install .
fi



# ----------------------
# Verification
# ----------------------
info "Verifying C API symbols..."
echo ""

cd "$INSTALL_PREFIX/lib"

# Detect library extension based on platform
if [ "$PLATFORM" = "macos" ]; then
  LIB_EXT="dylib"
  NM_CMD="nm"
else
  LIB_EXT="so"
  NM_CMD="nm -D"
fi

# Find LLVM library
LLVM_LIB=$(ls -1 libLLVM.${LIB_EXT}* 2>/dev/null | head -1)
if [ -f "$LLVM_LIB" ]; then
  LLVM_API_COUNT=$($NM_CMD "$LLVM_LIB" | grep -c " T LLVM" || echo "0")
  echo "  ✅ LLVM C API: $LLVM_API_COUNT exported functions in $LLVM_LIB"
  
  # Test for key function
  if $NM_CMD "$LLVM_LIB" | grep -q "LLVMContextCreate"; then
    echo "     ✓ LLVMContextCreate found"
  else
    err "LLVMContextCreate not found in $LLVM_LIB"
  fi
else
  err "libLLVM.$LIB_EXT not found!"
fi

# Find MLIR library
MLIR_C_LIB=$(ls -1 libMLIR-C.${LIB_EXT}* 2>/dev/null | head -1)
if [ -f "$MLIR_C_LIB" ]; then
  MLIR_API_COUNT=$($NM_CMD "$MLIR_C_LIB" | grep -c " T mlir" || echo "0")
  echo ""
  echo "  ✅ MLIR C API: $MLIR_API_COUNT exported functions in $MLIR_C_LIB"
  
  # Test for key function
  if $NM_CMD "$MLIR_C_LIB" | grep -q "mlirContextCreate"; then
    echo "     ✓ mlirContextCreate found"
  else
    warn "mlirContextCreate not found in $MLIR_C_LIB"
  fi
else
  warn "libMLIR-C.$LIB_EXT not found (may be embedded in libLLVM)"
fi

# ----------------------
# Summary
# ----------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Build Completed Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Installation: $INSTALL_PREFIX"
echo ""
echo "📚 Libraries:"
ls -lh libLLVM*.${LIB_EXT}* libMLIR*.${LIB_EXT}* 2>/dev/null | awk '{printf "   %-30s %10s\n", $9, $5}'
echo ""
echo "🔧 For Mojo FFI usage:"
echo "   The mlir/ffi/build.mojo module will automatically locate these libraries"
echo ""
echo "✅ Ready for use!"
echo ""

exit 0
