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
1. `vendors/llvm-current/lib/` (project-local installation)
2. `/usr/lib/llvm-{21,20,19}/lib/` (system APT installation)
3. System library paths (via `LD_LIBRARY_PATH`)
"""

from pathlib import Path
from sys.ffi import OwnedDLHandle, _Global, _get_dylib_function, _find_dylib


# ===----------------------------------------------------------------------=== #
# Library Path Configuration
# ===----------------------------------------------------------------------=== #

comptime _VENDOR_LIB_PATH = "vendors/llvm-current/lib"
"""Project-local vendor library path (relative to project root)."""

comptime _SYSTEM_LIB_PATHS = [
    "/usr/lib/llvm-21/lib",
    "/usr/lib/llvm-20/lib",
    "/usr/lib/llvm-19/lib",
]
"""System installation paths for LLVM/MLIR (APT packages)."""

comptime _MLIR_C_LIB_NAMES = [
    "libMLIR-C.so",
    "libMLIRCAPI.so",
    "libMLIR.so",
]
"""Candidate filenames for the MLIR C API shared library."""

comptime _LLVM_LIB_NAMES = [
    "libLLVM.so",
    "libLLVM-21.so",
    "libLLVM-20.so",
    "libLLVM-19.so",
]
"""Candidate filenames for the LLVM shared library."""


# ===----------------------------------------------------------------------=== #
# Library Loading Infrastructure
# ===----------------------------------------------------------------------=== #


@parameter
fn _build_library_paths[lib_names: List[StaticString]]() -> List[Path]:
    """Build a prioritized list of candidate library paths.

    Searches in order: vendor directory, system paths, then bare names.
    """
    var paths = List[Path]()

    # 1. Project-local vendor paths (highest priority)
    @parameter
    for name in lib_names:
        paths.append(Path(_VENDOR_LIB_PATH) / name)

    # 2. System installation paths
    @parameter
    for sys_path in _SYSTEM_LIB_PATHS:

        @parameter
        for name in lib_names:
            paths.append(Path(sys_path) / name)

    # 3. Bare library names (uses LD_LIBRARY_PATH / system linker)
    @parameter
    for name in lib_names:
        paths.append(Path(name))

    return paths^


fn _load_mlir_library() -> OwnedDLHandle:
    """Load the MLIR C API shared library."""
    comptime paths = _build_library_paths[_MLIR_C_LIB_NAMES]()
    return _find_dylib["MLIR C API"](paths)


fn _load_llvm_library() -> OwnedDLHandle:
    """Load the LLVM shared library."""
    comptime paths = _build_library_paths[_LLVM_LIB_NAMES]()
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
