#!/usr/bin/env bash
# ===----------------------------------------------------------------------=== #
# buildMlirCApi.sh — Build MLIR C API shared library from static libs
# ===----------------------------------------------------------------------=== #
#
# The MLIR C API is only distributed as static libraries (.a) by LLVM.
# This script links them into a single shared library (.so) for FFI use.
#
# ===----------------------------------------------------------------------=== #

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendors"
LLVM_DIR="$VENDOR_DIR/llvm-current"
LIB_DIR="$LLVM_DIR/lib"
OUTPUT_DIR="$VENDOR_DIR/mlir-capi"
OUTPUT_LIB="$OUTPUT_DIR/libMLIR-C.so"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}▶${NC} $1"; }
success() { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "\033[0;31m✖${NC} $1"; exit 1; }

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  Building MLIR C API Shared Library"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Check prerequisites
if [ ! -d "$LLVM_DIR" ]; then
    error "LLVM not found at $LLVM_DIR. Run ./scripts/fetchMlir.sh first."
fi

for cmd in gcc ar; do
    if ! command -v "$cmd" &> /dev/null; then
        error "$cmd is required but not installed."
    fi
done

# Core C API libraries (order matters for linking)
CAPI_LIBS=(
    "libMLIRCAPIIR.a"
    "libMLIRCAPIInterfaces.a"
    "libMLIRCAPIFunc.a"
    "libMLIRCAPIArith.a"
    "libMLIRCAPITransforms.a"
    "libMLIRCAPIConversion.a"
    "libMLIRCAPIRegisterEverything.a"
    "libMLIRCAPILLVM.a"
    "libMLIRCAPIDebug.a"
)

# Create output directory
mkdir -p "$OUTPUT_DIR"

info "Extracting object files from C API static libraries..."

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

for lib in "${CAPI_LIBS[@]}"; do
    lib_path="$LIB_DIR/$lib"
    if [ -f "$lib_path" ]; then
        echo "  - $lib"
        (cd "$TMP_DIR" && ar x "$lib_path")
    else
        warn "Library not found: $lib"
    fi
done

OBJ_COUNT=$(find "$TMP_DIR" -name "*.o" | wc -l)
info "Found $OBJ_COUNT object files"

if [ "$OBJ_COUNT" -eq 0 ]; then
    error "No object files extracted!"
fi

info "Linking into shared library..."

# Link with libMLIR.so which contains all the C++ implementations
gcc -shared -fPIC \
    -o "$OUTPUT_LIB" \
    "$TMP_DIR"/*.o \
    -L"$LIB_DIR" \
    -Wl,-rpath,"$LIB_DIR" \
    -lMLIR \
    -lLLVM \
    -lstdc++ \
    -lm \
    -lpthread \
    -ldl \
    2>&1 || error "Linking failed!"

# Verify the library
info "Verifying exported symbols..."
if nm -D "$OUTPUT_LIB" 2>/dev/null | grep -q "mlirContextCreate"; then
    success "mlirContextCreate symbol found!"
else
    error "mlirContextCreate symbol NOT found in output library"
fi

SYMBOL_COUNT=$(nm -D "$OUTPUT_LIB" 2>/dev/null | grep -c "^[0-9a-f]* T mlir" || echo 0)
SIZE=$(du -h "$OUTPUT_LIB" | cut -f1)

echo ""
echo "═══════════════════════════════════════════════════════════════════"
success "Build complete!"
echo ""
echo "  Output:  $OUTPUT_LIB"
echo "  Size:    $SIZE"
echo "  Symbols: $SYMBOL_COUNT mlir* functions exported"
echo ""
echo "  To use:"
echo "    export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$OUTPUT_DIR:$LIB_DIR\""
echo "═══════════════════════════════════════════════════════════════════"
