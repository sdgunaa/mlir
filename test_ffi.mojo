# ===----------------------------------------------------------------------=== #
# MLIR FFI Module Test
# ===----------------------------------------------------------------------=== #
"""Simple test to verify the FFI module can load MLIR/LLVM libraries."""

from memory import UnsafePointer
from mlir.ffi import (
    is_mlir_available,
    is_llvm_available,
    get_library_status,
    get_mlir_function,
)

# Opaque pointer type for MLIR context (C API uses opaque handles)
comptime MlirContext = UnsafePointer[NoneType, MutExternalOrigin]

# Function pointer types
comptime ContextCreateFn = fn () -> MlirContext
comptime ContextDestroyFn = fn (MlirContext) -> None


fn main() raises:
    print("=" * 60)
    print("MLIR FFI Module Test")
    print("=" * 60)
    print()

    # Test 1: Library status
    print(get_library_status())

    # Test 2: Check availability
    if not is_mlir_available():
        print("⚠ MLIR library not found!")
        print("  Run: ./scripts/installMlirApt.sh")
        print("  Or:  ./scripts/fetchMlir.sh")
        return

    print("✓ MLIR library loaded successfully!")
    print()

    # Test 3: Try to get a function pointer
    print("Testing function lookup...")

    var ctx_create = get_mlir_function["mlirContextCreate", ContextCreateFn]()
    print("  ✓ mlirContextCreate found")

    var ctx_destroy = get_mlir_function[
        "mlirContextDestroy", ContextDestroyFn
    ]()
    print("  ✓ mlirContextDestroy found")

    # Test 4: Actually create and destroy a context
    print()
    print("Testing MLIR context creation...")
    var ctx = ctx_create()
    if ctx:
        print("  ✓ mlirContextCreate() called")
    ctx_destroy(ctx)
    print("  ✓ mlirContextDestroy() completed")

    print()
    print("=" * 60)
    print("All tests passed! ✓")
    print("=" * 60)
