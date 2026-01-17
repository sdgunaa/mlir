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

The module automatically ensures the library is available by:
1. Checking for a cached build in `~/.cache/mlir-mojo/`
2. Detecting system MLIR/LLVM static libraries
3. Building a monolithic shared library from static archives if needed
"""

from pathlib import Path
from os import getenv
from sys.ffi import OwnedDLHandle, _Global, _get_dylib_function, _find_dylib
from .build import (
    ensure_mlir_c_library,
    get_platform,
    _get_lib_path,
    _is_cache_valid,
)


# ===----------------------------------------------------------------------=== #
# Library Loading Functions
# ===----------------------------------------------------------------------=== #


fn _load_mlir_library() -> OwnedDLHandle:
    """Load the MLIR C API shared library.

    This will automatically trigger the build system if the library is not found.
    """
    var paths = List[Path]()

    # Priority 1: Explicit path from environment
    var explicit = getenv("MLIR_LIB_PATH", "")
    if explicit:
        paths.append(Path(explicit))

    # Priority 2: Cache directory (ensured by the build system)
    paths.append(_get_lib_path())

    # Priority 3: System paths as fallback
    paths.append(Path("/usr/local/lib/libMLIR-C.so"))
    paths.append(Path("/usr/lib/libMLIR-C.so"))

    # If not found in cache, ensure it's built
    if not _is_cache_valid() and not explicit:
        try:
            _ = ensure_mlir_c_library()
        except e:
            # We continue anyway to let _find_dylib report the error if it still fails
            print("[mlir-ffi] Warning: Automated build failed:", e)

    return _find_dylib["MLIR C API"](paths)


fn _load_llvm_library() -> OwnedDLHandle:
    """Load the LLVM shared library."""
    var paths = List[Path]()

    # Try common system locations
    paths.append(Path("/usr/lib/llvm-21/lib/libLLVM.so"))
    paths.append(Path("/usr/lib/llvm-20/lib/libLLVM.so"))
    paths.append(Path("/usr/lib/llvm-19/lib/libLLVM.so"))
    paths.append(Path("/opt/homebrew/opt/llvm/lib/libLLVM.dylib"))
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
    var mlir_loaded = is_mlir_available()
    var llvm_loaded = is_llvm_available()

    var mlir_status = "✓ Available" if mlir_loaded else "✗ Not found"
    var llvm_status = "✓ Available" if llvm_loaded else "✗ Not found"

    var msg = String("MLIR FFI Status [") + get_platform() + "]:\n"
    msg += "  MLIR C API: " + mlir_status + "\n"
    if mlir_loaded:
        msg += "    Path:     " + String(_get_lib_path()) + "\n"
    msg += "  LLVM:       " + llvm_status + "\n"

    return msg


fn setup() raises:
    """Explicitly initialize the MLIR FFI system.

    This will ensure the library is built and loaded.
    """
    _ = ensure_mlir_c_library()
    print("[mlir-ffi] Setup complete!")
    print(get_library_status())
