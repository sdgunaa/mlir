# ===----------------------------------------------------------------------=== #
# MLIR Mojo Bindings - Foreign Function Interface (FFI)
#
# Copyright (c) 2026 sdgunaa
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""MLIR FFI module for loading and interfacing with MLIR/LLVM C libraries.

This module provides the low-level FFI infrastructure for loading MLIR and LLVM
shared libraries and accessing their C API functions. It uses Mojo's built-in
FFI capabilities to dynamically load libraries and resolve symbols.

The module automatically searches for libraries in the following order:
1. `vendors/mlir-capi/` (custom-built C API library)
2. `vendors/llvm-current/lib/` (project-local installation)
3. `/usr/lib/llvm-{21,20,19}/lib/` (system APT installation)
4. System library paths (via `LD_LIBRARY_PATH`)

NOTE: The MLIR C API is only distributed as static libraries by LLVM.
      Use scripts/buildMlirCApi.sh to build the shared library first.
"""

from pathlib import Path
from sys.ffi import OwnedDLHandle, _Global, _get_dylib_function, _find_dylib


# ===----------------------------------------------------------------------=== #
# Library Loading Functions
# ===----------------------------------------------------------------------=== #


fn _load_mlir_library() -> OwnedDLHandle:
    """Load the MLIR C API shared library.

    Searches for libMLIR-C.so in multiple locations. This library must be
    built using scripts/buildMlirCApi.sh as LLVM only distributes static libs.
    """
    # Priority order for finding the MLIR C API library
    var paths = List[Path]()
    paths.append(Path("vendors/mlir-capi/libMLIR-C.so"))
    paths.append(Path("vendors/llvm-current/lib/libMLIR-C.so"))
    paths.append(Path("/usr/lib/llvm-21/lib/libMLIR-C.so"))
    paths.append(Path("/usr/lib/llvm-20/lib/libMLIR-C.so"))
    paths.append(Path("/usr/lib/llvm-19/lib/libMLIR-C.so"))
    paths.append(Path("libMLIR-C.so"))
    return _find_dylib["MLIR C API"](paths)


fn _load_llvm_library() -> OwnedDLHandle:
    """Load the LLVM shared library."""
    var paths = List[Path]()
    paths.append(Path("vendors/llvm-current/lib/libLLVM.so"))
    paths.append(Path("/usr/lib/llvm-21/lib/libLLVM.so"))
    paths.append(Path("/usr/lib/llvm-20/lib/libLLVM.so"))
    paths.append(Path("/usr/lib/llvm-19/lib/libLLVM.so"))
    paths.append(Path("libLLVM.so"))
    return _find_dylib["LLVM"](paths)


# ===----------------------------------------------------------------------=== #
# Global Library Handles
# ===----------------------------------------------------------------------=== #

comptime MLIR_HANDLE = _Global["mlir.ffi.MLIR", _load_mlir_library]
"""Global handle to the MLIR C API library (lazily initialized)."""

comptime LLVM_HANDLE = _Global["mlir.ffi.LLVM", _load_llvm_library]
"""Global handle to the LLVM library (lazily initialized)."""


# ===----------------------------------------------------------------------=== #
# Function Accessors
# ===----------------------------------------------------------------------=== #


@always_inline
fn get_mlir_function[
    func_name: StaticString,
    result_type: AnyTrivialRegType,
]() raises -> result_type:
    """Get a function pointer from the MLIR C API library.

    Parameters:
        func_name: The C function name to look up (e.g., "mlirContextCreate").
        result_type: The function pointer type.

    Returns:
        A pointer to the requested function.

    Raises:
        If the library cannot be loaded or the symbol is not found.
    """
    return _get_dylib_function[MLIR_HANDLE(), func_name, result_type]()


@always_inline
fn get_llvm_function[
    func_name: StaticString,
    result_type: AnyTrivialRegType,
]() raises -> result_type:
    """Get a function pointer from the LLVM library.

    Parameters:
        func_name: The C function name to look up.
        result_type: The function pointer type.

    Returns:
        A pointer to the requested function.

    Raises:
        If the library cannot be loaded or the symbol is not found.
    """
    return _get_dylib_function[LLVM_HANDLE(), func_name, result_type]()


# ===----------------------------------------------------------------------=== #
# Library Status Utilities
# ===----------------------------------------------------------------------=== #


fn is_mlir_available() -> Bool:
    """Check if the MLIR library is available.

    Returns:
        True if the MLIR library can be loaded, False otherwise.
    """
    try:
        _ = MLIR_HANDLE.get_or_create_ptr()
        return True
    except:
        return False


fn is_llvm_available() -> Bool:
    """Check if the LLVM library is available.

    Returns:
        True if the LLVM library can be loaded, False otherwise.
    """
    try:
        _ = LLVM_HANDLE.get_or_create_ptr()
        return True
    except:
        return False


fn get_library_status() -> String:
    """Get a human-readable status of loaded libraries.

    Returns:
        A formatted string describing the library availability.
    """
    var mlir_status = "✓ Available" if is_mlir_available() else "✗ Not found"
    var llvm_status = "✓ Available" if is_llvm_available() else "✗ Not found"

    return String(
        "MLIR FFI Library Status:\n  MLIR C API: "
        + mlir_status
        + "\n  LLVM:       "
        + llvm_status
        + "\n"
    )
