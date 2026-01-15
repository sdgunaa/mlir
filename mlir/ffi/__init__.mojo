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

Example usage:
    ```mojo
    from mlir.ffi import get_mlir_context_create

    fn main() raises:
        var ctx = get_mlir_context_create()()
        # Use the MLIR context...
    ```

The module automatically searches for libraries in the following order:
1. `vendors/llvm-current/lib/` (project-local installation)
2. `/usr/lib/llvm-21/lib/` (system APT installation)
3. System library paths (via `LD_LIBRARY_PATH`)
"""

from pathlib import Path
from os import abort
from sys.ffi import (
    OwnedDLHandle,
    _DLHandle,
    _Global,
    _get_dylib_function,
    _find_dylib,
    _try_find_dylib,
    c_char,
    c_int,
    c_uint,
    c_size_t,
    c_ssize_t,
    c_void = NoneType,
)
from memory import UnsafePointer


# ===-----------------------------------------------------------------------===#
# Library Path Configuration
# ===-----------------------------------------------------------------------===#

# Project-local paths (relative to project root)
comptime _VENDOR_LIB_PATH = "vendors/llvm-current/lib"

# System installation paths (APT packages)
comptime _SYSTEM_LIB_PATHS = List[String](
    "/usr/lib/llvm-21/lib",
    "/usr/lib/llvm-20/lib",
    "/usr/lib/llvm-19/lib",
)

# Library filenames
comptime _MLIR_C_LIB_NAMES = List[String](
    "libMLIR-C.so",
    "libMLIRCAPI.so",
    "libMLIR.so",
)

comptime _LLVM_LIB_NAMES = List[String](
    "libLLVM.so",
    "libLLVM-21.so",
    "libLLVM-20.so",
    "libLLVM-19.so",
)


# ===-----------------------------------------------------------------------===#
# MLIR C API Opaque Types
# ===-----------------------------------------------------------------------===#
# These are opaque pointer types that correspond to the MLIR C API types.
# They wrap raw pointers and provide type safety at the Mojo level.


@value
@register_passable("trivial")
struct MlirContext:
    """Opaque handle to an MLIR context (MlirContext in C API)."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirDialect:
    """Opaque handle to an MLIR dialect (MlirDialect in C API)."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirDialectRegistry:
    """Opaque handle to an MLIR dialect registry."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirOperation:
    """Opaque handle to an MLIR operation."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirBlock:
    """Opaque handle to an MLIR block."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirRegion:
    """Opaque handle to an MLIR region."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirValue:
    """Opaque handle to an MLIR value (SSA value)."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirType:
    """Opaque handle to an MLIR type."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirAttribute:
    """Opaque handle to an MLIR attribute."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirLocation:
    """Opaque handle to an MLIR location."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirModule:
    """Opaque handle to an MLIR module."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirIdentifier:
    """Opaque handle to an MLIR identifier (interned string)."""

    var ptr: UnsafePointer[NoneType]

    fn __init__(out self):
        self.ptr = UnsafePointer[NoneType]()

    fn __bool__(self) -> Bool:
        return Bool(self.ptr)


@value
@register_passable("trivial")
struct MlirStringRef:
    """MLIR string reference (non-owning view into a string).
    
    This corresponds to `MlirStringRef` in the C API:
    ```c
    struct MlirStringRef {
        const char *data;
        size_t length;
    };
    ```
    """

    var data: UnsafePointer[c_char]
    var length: c_size_t

    fn __init__(out self):
        self.data = UnsafePointer[c_char]()
        self.length = 0

    fn __init__(out self, s: StringSlice):
        """Create an MlirStringRef from a Mojo StringSlice."""
        self.data = s.unsafe_ptr().bitcast[c_char]()
        self.length = len(s)

    fn __init__(out self, s: String):
        """Create an MlirStringRef from a Mojo String."""
        self.data = s.unsafe_ptr().bitcast[c_char]()
        self.length = len(s)

    fn to_string(self) -> String:
        """Convert to a Mojo String (copies the data)."""
        if self.length == 0:
            return String()
        return String(
            StringSlice(unsafe_from_utf8_ptr=self.data, len=Int(self.length))
        )


@value
@register_passable("trivial")
struct MlirLogicalResult:
    """MLIR logical result (success/failure indicator).
    
    This corresponds to `MlirLogicalResult` in the C API.
    """

    var value: Int8

    fn __init__(out self):
        self.value = 0

    fn succeeded(self) -> Bool:
        """Returns True if the operation succeeded."""
        return self.value != 0

    fn failed(self) -> Bool:
        """Returns True if the operation failed."""
        return self.value == 0


# ===-----------------------------------------------------------------------===#
# Library Loading Infrastructure
# ===-----------------------------------------------------------------------===#


fn _build_library_paths(lib_names: List[String]) -> List[Path]:
    """Build a list of candidate library paths to try loading.
    
    Args:
        lib_names: List of library filenames to search for.
        
    Returns:
        List of full paths to try loading.
    """
    var paths = List[Path]()
    
    # Add project-local vendor paths
    for name in lib_names:
        paths.append(Path(_VENDOR_LIB_PATH) / name[])
    
    # Add system installation paths
    for sys_path in _SYSTEM_LIB_PATHS:
        for name in lib_names:
            paths.append(Path(sys_path[]) / name[])
    
    # Add bare library names (will use LD_LIBRARY_PATH)
    for name in lib_names:
        paths.append(Path(name[]))
    
    return paths


fn _load_mlir_library() -> OwnedDLHandle:
    """Load the MLIR C API shared library.
    
    Returns:
        Handle to the loaded MLIR library.
    """
    var paths = _build_library_paths(_MLIR_C_LIB_NAMES)
    return _find_dylib["MLIR C API library"](paths)


fn _load_llvm_library() -> OwnedDLHandle:
    """Load the LLVM shared library.
    
    Returns:
        Handle to the loaded LLVM library.
    """
    var paths = _build_library_paths(_LLVM_LIB_NAMES)
    return _find_dylib["LLVM library"](paths)


# ===-----------------------------------------------------------------------===#
# Global Library Handles
# ===-----------------------------------------------------------------------===#
# These globals lazily initialize the library handles on first use.

comptime MLIR_HANDLE = _Global[
    OwnedDLHandle,
    name = "mlir.ffi.MLIR",
    init_fn = _load_mlir_library,
]

comptime LLVM_HANDLE = _Global[
    OwnedDLHandle,
    name = "mlir.ffi.LLVM", 
    init_fn = _load_llvm_library,
]


# ===-----------------------------------------------------------------------===#
# Function Accessors
# ===-----------------------------------------------------------------------===#


fn get_mlir_function[
    func_name: StaticString,
    result_type: AnyTrivialRegType,
]() raises -> result_type:
    """Get a function pointer from the MLIR C API library.
    
    Parameters:
        func_name: The name of the C function to look up.
        result_type: The function pointer type.
        
    Returns:
        A pointer to the requested function.
        
    Raises:
        If the library cannot be loaded or the symbol is not found.
        
    Example:
        ```mojo
        alias MlirContextCreateFn = fn() -> MlirContext
        var create_ctx = get_mlir_function["mlirContextCreate", MlirContextCreateFn]()
        var ctx = create_ctx()
        ```
    """
    return _get_dylib_function[MLIR_HANDLE, func_name, result_type]()


fn get_llvm_function[
    func_name: StaticString,
    result_type: AnyTrivialRegType,
]() raises -> result_type:
    """Get a function pointer from the LLVM library.
    
    Parameters:
        func_name: The name of the C function to look up.
        result_type: The function pointer type.
        
    Returns:
        A pointer to the requested function.
        
    Raises:
        If the library cannot be loaded or the symbol is not found.
    """
    return _get_dylib_function[LLVM_HANDLE, func_name, result_type]()


# ===-----------------------------------------------------------------------===#
# MLIR C API Function Type Aliases
# ===-----------------------------------------------------------------------===#
# These are the function pointer types for common MLIR C API functions.

# Context management
alias MlirContextCreateFn = fn () -> MlirContext
alias MlirContextDestroyFn = fn (MlirContext) -> None
alias MlirContextIsNullFn = fn (MlirContext) -> Bool
alias MlirContextGetNumLoadedDialectsFn = fn (MlirContext) -> c_int
alias MlirContextEnableMultithreadingFn = fn (MlirContext, Bool) -> None

# Dialect registry
alias MlirDialectRegistryCreateFn = fn () -> MlirDialectRegistry
alias MlirDialectRegistryDestroyFn = fn (MlirDialectRegistry) -> None

# Location
alias MlirLocationUnknownGetFn = fn (MlirContext) -> MlirLocation
alias MlirLocationFileLineColGetFn = fn (
    MlirContext, MlirStringRef, c_uint, c_uint
) -> MlirLocation

# Module
alias MlirModuleCreateEmptyFn = fn (MlirLocation) -> MlirModule
alias MlirModuleDestroyFn = fn (MlirModule) -> None
alias MlirModuleGetBodyFn = fn (MlirModule) -> MlirBlock
alias MlirModuleGetOperationFn = fn (MlirModule) -> MlirOperation

# Types
alias MlirIntegerTypeGetFn = fn (MlirContext, c_uint) -> MlirType
alias MlirF32TypeGetFn = fn (MlirContext) -> MlirType
alias MlirF64TypeGetFn = fn (MlirContext) -> MlirType
alias MlirIndexTypeGetFn = fn (MlirContext) -> MlirType
alias MlirNoneTypeGetFn = fn (MlirContext) -> MlirType

# Attributes  
alias MlirIntegerAttrGetFn = fn (MlirType, Int64) -> MlirAttribute
alias MlirFloatAttrDoubleGetFn = fn (MlirContext, MlirType, Float64) -> MlirAttribute
alias MlirStringAttrGetFn = fn (MlirContext, MlirStringRef) -> MlirAttribute
alias MlirUnitAttrGetFn = fn (MlirContext) -> MlirAttribute

# Identifiers
alias MlirIdentifierGetFn = fn (MlirContext, MlirStringRef) -> MlirIdentifier

# Parsing/Printing
alias MlirOperationPrintFn = fn (
    MlirOperation, 
    fn (MlirStringRef, UnsafePointer[NoneType]) -> None,
    UnsafePointer[NoneType]
) -> None


# ===-----------------------------------------------------------------------===#
# Convenience Function Getters
# ===-----------------------------------------------------------------------===#
# These provide easy access to commonly used MLIR C API functions.


fn get_mlir_context_create() raises -> MlirContextCreateFn:
    """Get the mlirContextCreate function."""
    return get_mlir_function["mlirContextCreate", MlirContextCreateFn]()


fn get_mlir_context_destroy() raises -> MlirContextDestroyFn:
    """Get the mlirContextDestroy function."""
    return get_mlir_function["mlirContextDestroy", MlirContextDestroyFn]()


fn get_mlir_location_unknown_get() raises -> MlirLocationUnknownGetFn:
    """Get the mlirLocationUnknownGet function."""
    return get_mlir_function["mlirLocationUnknownGet", MlirLocationUnknownGetFn]()


fn get_mlir_module_create_empty() raises -> MlirModuleCreateEmptyFn:
    """Get the mlirModuleCreateEmpty function."""
    return get_mlir_function["mlirModuleCreateEmpty", MlirModuleCreateEmptyFn]()


fn get_mlir_module_destroy() raises -> MlirModuleDestroyFn:
    """Get the mlirModuleDestroy function."""
    return get_mlir_function["mlirModuleDestroy", MlirModuleDestroyFn]()


fn get_mlir_f32_type_get() raises -> MlirF32TypeGetFn:
    """Get the mlirF32TypeGet function."""
    return get_mlir_function["mlirF32TypeGet", MlirF32TypeGetFn]()


fn get_mlir_f64_type_get() raises -> MlirF64TypeGetFn:
    """Get the mlirF64TypeGet function."""
    return get_mlir_function["mlirF64TypeGet", MlirF64TypeGetFn]()


fn get_mlir_integer_type_get() raises -> MlirIntegerTypeGetFn:
    """Get the mlirIntegerTypeGet function."""
    return get_mlir_function["mlirIntegerTypeGet", MlirIntegerTypeGetFn]()


fn get_mlir_index_type_get() raises -> MlirIndexTypeGetFn:
    """Get the mlirIndexTypeGet function."""
    return get_mlir_function["mlirIndexTypeGet", MlirIndexTypeGetFn]()


# ===-----------------------------------------------------------------------===#
# Library Status
# ===-----------------------------------------------------------------------===#


fn is_mlir_available() -> Bool:
    """Check if the MLIR library is available.
    
    Returns:
        True if the MLIR library can be loaded.
    """
    try:
        _ = MLIR_HANDLE.get_or_create_ptr()
        return True
    except:
        return False


fn is_llvm_available() -> Bool:
    """Check if the LLVM library is available.
    
    Returns:
        True if the LLVM library can be loaded.
    """
    try:
        _ = LLVM_HANDLE.get_or_create_ptr()
        return True
    except:
        return False


fn get_library_info() raises -> String:
    """Get information about loaded libraries.
    
    Returns:
        A string describing the loaded library status.
    """
    var info = String("MLIR FFI Library Status:\n")
    info += "  MLIR: " + ("Available ✓" if is_mlir_available() else "Not found ✗") + "\n"
    info += "  LLVM: " + ("Available ✓" if is_llvm_available() else "Not found ✗") + "\n"
    return info
