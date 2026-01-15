# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026, sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# See LICENSE file in the project root for full license information.
# ===----------------------------------------------------------------------=== #
"""MLIR Foreign Function Interface (FFI) module.

This module provides low-level bindings to the MLIR C API, enabling Mojo code
to interact with LLVM/MLIR infrastructure through a stable, type-safe interface.

The FFI layer handles:
- Dynamic library discovery and loading (system paths and vendored binaries)
- C type aliases for cross-platform compatibility
- Lazy global handles with RAII semantics
- Type-safe function pointer retrieval

Example usage:
```mojo
from mlir.ffi import get_mlir_function, c_int

# Get a function pointer from the MLIR C API
alias MlirContextCreate = fn() -> OpaquePointer
var create_ctx = get_mlir_function["mlirContextCreate", MlirContextCreate]()
var ctx = create_ctx()
```
"""

from collections.string.string_slice import get_static_string
from memory import UnsafePointer, OwnedPointer
from os import abort
from pathlib import Path
from sys._libc import dlclose, dlerror, dlopen, dlsym
from sys.info import is_64bit, is_32bit, os_is_linux, os_is_macos, os_is_windows

# ===-----------------------------------------------------------------------===#
# C Primitive Type Aliases
# ===-----------------------------------------------------------------------===#
# These aliases ensure correct sizes across platforms, matching the C ABI.

alias c_char = Int8
"""C `char` type."""

alias c_uchar = UInt8
"""C `unsigned char` type."""

alias c_int = Int32
"""C `int` type (typically 32-bit on all platforms)."""

alias c_uint = UInt32
"""C `unsigned int` type."""

alias c_short = Int16
"""C `short` type."""

alias c_ushort = UInt16
"""C `unsigned short` type."""

alias c_float = Float32
"""C `float` type."""

alias c_double = Float64
"""C `double` type."""

alias c_size_t = UInt
"""C `size_t` type (pointer-sized unsigned)."""

alias c_ssize_t = Int
"""C `ssize_t` type (pointer-sized signed)."""

alias c_void = NoneType
"""C `void` type."""

alias c_void_ptr = UnsafePointer[NoneType]
"""C `void*` type."""

alias c_char_ptr = UnsafePointer[c_char]
"""C `char*` type (C string pointer)."""


fn _c_long_dtype() -> DType:
    """Returns the appropriate DType for C `long` based on platform."""

    @parameter
    if is_64bit() and (os_is_macos() or os_is_linux()):
        # LP64: long is 64-bit on Unix-like 64-bit systems
        return DType.int64
    elif is_32bit() or os_is_windows():
        # ILP32 or LLP64 (Windows): long is 32-bit
        return DType.int32
    else:
        return DType.int64  # Safe default


alias c_long = Scalar[_c_long_dtype()]
"""C `long` type (64-bit on Unix, 32-bit on Windows)."""

alias c_ulong = Scalar[_c_long_dtype()]
"""C `unsigned long` type."""

alias c_long_long = Int64
"""C `long long` type (always 64-bit)."""

alias c_ulong_long = UInt64
"""C `unsigned long long` type."""


# ===-----------------------------------------------------------------------===#
# MLIR Opaque Handle Types
# ===-----------------------------------------------------------------------===#
# These represent opaque pointers to MLIR C API objects.

alias MlirContext = UnsafePointer[NoneType]
"""Opaque handle to an MLIR context."""

alias MlirDialect = UnsafePointer[NoneType]
"""Opaque handle to an MLIR dialect."""

alias MlirDialectRegistry = UnsafePointer[NoneType]
"""Opaque handle to an MLIR dialect registry."""

alias MlirOperation = UnsafePointer[NoneType]
"""Opaque handle to an MLIR operation."""

alias MlirBlock = UnsafePointer[NoneType]
"""Opaque handle to an MLIR block."""

alias MlirRegion = UnsafePointer[NoneType]
"""Opaque handle to an MLIR region."""

alias MlirValue = UnsafePointer[NoneType]
"""Opaque handle to an MLIR value (SSA value)."""

alias MlirType = UnsafePointer[NoneType]
"""Opaque handle to an MLIR type."""

alias MlirAttribute = UnsafePointer[NoneType]
"""Opaque handle to an MLIR attribute."""

alias MlirLocation = UnsafePointer[NoneType]
"""Opaque handle to an MLIR location."""

alias MlirModule = UnsafePointer[NoneType]
"""Opaque handle to an MLIR module."""

alias MlirIdentifier = UnsafePointer[NoneType]
"""Opaque handle to an MLIR identifier."""

alias MlirSymbolTable = UnsafePointer[NoneType]
"""Opaque handle to an MLIR symbol table."""

alias MlirPassManager = UnsafePointer[NoneType]
"""Opaque handle to an MLIR pass manager."""

alias MlirExecutionEngine = UnsafePointer[NoneType]
"""Opaque handle to an MLIR execution engine."""

alias MlirLogicalResult = c_int
"""MLIR logical result (0 = failure, 1 = success)."""


# ===-----------------------------------------------------------------------===#
# RTLD Flags for Dynamic Library Loading
# ===-----------------------------------------------------------------------===#


struct RTLD:
    """Runtime linker flags for dynamic library loading."""

    alias LAZY = 1
    """Lazy binding: resolve symbols only when referenced."""

    alias NOW = 2
    """Immediate binding: resolve all symbols at load time."""

    alias LOCAL = 4
    """Symbols are not made available for subsequently loaded libraries."""

    alias GLOBAL = 256 if os_is_linux() else 8
    """Symbols are available for subsequently loaded libraries."""


alias DEFAULT_RTLD = RTLD.NOW | RTLD.GLOBAL
"""Default flags for loading dynamic libraries."""


# ===-----------------------------------------------------------------------===#
# Library Path Discovery
# ===-----------------------------------------------------------------------===#


fn _get_script_dir() -> Path:
    """Returns the directory containing this module."""
    # In a real implementation, this would use __file__ or similar
    # For now, we use a relative path from expected execution context
    return Path(".")


fn _get_vendor_lib_path() -> Path:
    """Returns the path to vendored LLVM/MLIR libraries."""
    return Path("vendors/llvm-current/lib")


fn _get_system_lib_paths() -> List[Path]:
    """Returns a list of system library paths to search."""
    var paths = List[Path]()

    @parameter
    if os_is_linux():
        # Check common LLVM installation paths on Linux
        paths.append(Path("/usr/lib/llvm-21/lib"))
        paths.append(Path("/usr/lib/llvm-20/lib"))
        paths.append(Path("/usr/lib/llvm-19/lib"))
        paths.append(Path("/usr/local/lib"))
        paths.append(Path("/usr/lib/x86_64-linux-gnu"))
        paths.append(Path("/usr/lib"))
    elif os_is_macos():
        paths.append(Path("/opt/homebrew/opt/llvm/lib"))
        paths.append(Path("/usr/local/opt/llvm/lib"))
        paths.append(Path("/usr/local/lib"))

    return paths


fn _find_library(name: String) -> Path:
    """Searches for a library in vendor and system paths.

    Args:
        name: The library name (e.g., "libMLIR-C.so" or "MLIR-C").

    Returns:
        The full path to the library if found.

    Raises:
        Aborts if library cannot be found.
    """
    # Build library filename based on platform
    var lib_name: String

    @parameter
    if os_is_linux():
        if name.startswith("lib") and name.endswith(".so"):
            lib_name = name
        else:
            lib_name = "lib" + name + ".so"
    elif os_is_macos():
        if name.startswith("lib") and name.endswith(".dylib"):
            lib_name = name
        else:
            lib_name = "lib" + name + ".dylib"
    else:
        lib_name = name + ".dll"

    # Check vendored libraries first
    var vendor_path = _get_vendor_lib_path() / lib_name
    if vendor_path.exists():
        return vendor_path

    # Check system paths
    var system_paths = _get_system_lib_paths()
    for i in range(len(system_paths)):
        var sys_path = system_paths[i] / lib_name
        if sys_path.exists():
            return sys_path

    # Return the name as-is and let dlopen handle it via LD_LIBRARY_PATH
    return Path(lib_name)


# ===-----------------------------------------------------------------------===#
# Dynamic Library Handle
# ===-----------------------------------------------------------------------===#


@register_passable("trivial")
struct DLHandle:
    """A handle to a dynamically loaded library.

    This is a non-owning handle that can be freely copied. Use `OwnedDLHandle`
    for automatic resource management.
    """

    var _handle: UnsafePointer[NoneType]

    fn __init__(out self):
        """Creates a null handle."""
        self._handle = UnsafePointer[NoneType]()

    fn __init__(out self, handle: UnsafePointer[NoneType]):
        """Creates a handle from a raw pointer."""
        self._handle = handle

    fn __bool__(self) -> Bool:
        """Returns True if the handle is valid (non-null)."""
        return Bool(self._handle)

    fn get_function[T: AnyTrivialRegType](self, name: String) raises -> T:
        """Gets a function pointer from the library.

        Parameters:
            T: The function pointer type.

        Args:
            name: The symbol name to look up.

        Returns:
            A function pointer of type T.

        Raises:
            If the symbol is not found.
        """
        var sym = dlsym(self._handle, name.unsafe_cstr_ptr())
        if not sym:
            var err = dlerror()
            if err:
                raise Error(
                    "Symbol not found: "
                    + name
                    + " - "
                    + String(unsafe_from_utf8_ptr=err)
                )
            raise Error("Symbol not found: " + name)
        return sym.bitcast[T]()[]

    fn close(self):
        """Closes the library handle."""
        if self._handle:
            _ = dlclose(self._handle)


struct OwnedDLHandle(Movable):
    """An owned handle to a dynamically loaded library with RAII semantics.

    Automatically closes the library when destroyed.

    Example:
    ```mojo
    var lib = OwnedDLHandle("libMLIR-C.so")
    var func = lib.get_function[fn() -> c_int]("mlirContextCreate")
    # Library automatically closed when lib goes out of scope
    ```
    """

    var _handle: DLHandle
    var _path: String

    fn __init__(out self, path: Path, flags: Int = DEFAULT_RTLD) raises:
        """Loads a dynamic library from the given path.

        Args:
            path: Path to the library file.
            flags: RTLD flags for loading.

        Raises:
            If the library cannot be loaded.
        """
        self._path = String(path)
        var handle = dlopen(self._path.unsafe_cstr_ptr(), flags)
        if not handle:
            var err = dlerror()
            if err:
                raise Error(
                    "Failed to load library: "
                    + self._path
                    + " - "
                    + String(unsafe_from_utf8_ptr=err)
                )
            raise Error("Failed to load library: " + self._path)
        self._handle = DLHandle(handle)

    fn __init__(out self, name: String, flags: Int = DEFAULT_RTLD) raises:
        """Loads a dynamic library by name.

        The library is searched for in vendor paths and system paths.

        Args:
            name: Library name (e.g., "MLIR-C" or "libMLIR-C.so").
            flags: RTLD flags for loading.

        Raises:
            If the library cannot be found or loaded.
        """
        var lib_path = _find_library(name)
        self = Self(lib_path, flags)

    fn __moveinit__(out self, owned other: Self):
        """Move constructor."""
        self._handle = other._handle
        self._path = other._path^
        other._handle = DLHandle()

    fn __del__(owned self):
        """Closes the library."""
        self._handle.close()

    fn __bool__(self) -> Bool:
        """Returns True if the handle is valid."""
        return Bool(self._handle)

    fn borrow(self) -> DLHandle:
        """Returns a non-owning reference to the handle."""
        return self._handle

    fn get_function[T: AnyTrivialRegType](self, name: String) raises -> T:
        """Gets a function pointer from the library.

        Parameters:
            T: The function pointer type.

        Args:
            name: The symbol name to look up.

        Returns:
            A function pointer of type T.
        """
        return self._handle.get_function[T](name)

    fn check_symbol(self, name: String) -> Bool:
        """Checks if a symbol exists in the library.

        Args:
            name: The symbol name to check.

        Returns:
            True if the symbol exists.
        """
        var sym = dlsym(self._handle._handle, name.unsafe_cstr_ptr())
        return Bool(sym)


# ===-----------------------------------------------------------------------===#
# Global Library Handles
# ===-----------------------------------------------------------------------===#
# Lazy-initialized global handles for MLIR/LLVM libraries.

var _mlir_c_handle: OwnedDLHandle = OwnedDLHandle.__init__
var _mlir_c_loaded: Bool = False

var _llvm_handle: OwnedDLHandle = OwnedDLHandle.__init__
var _llvm_loaded: Bool = False


fn _ensure_mlir_c_loaded() raises:
    """Ensures the MLIR C API library is loaded."""
    if _mlir_c_loaded:
        return

    # Try different library names in order of preference
    var lib_names = List[String]()
    lib_names.append("MLIR-C")
    lib_names.append("libMLIR-C.so")
    lib_names.append("libMLIR-C.so.21")
    lib_names.append("libMLIRCAPI.so")
    lib_names.append("MLIR")

    var last_error: String = ""
    for i in range(len(lib_names)):
        try:
            _mlir_c_handle = OwnedDLHandle(lib_names[i])
            _mlir_c_loaded = True
            return
        except e:
            last_error = String(e)

    raise Error(
        "Failed to load MLIR C API library. Tried: "
        + ", ".join(lib_names)
        + ". Last error: "
        + last_error
    )


fn _ensure_llvm_loaded() raises:
    """Ensures the LLVM library is loaded."""
    if _llvm_loaded:
        return

    var lib_names = List[String]()
    lib_names.append("LLVM")
    lib_names.append("libLLVM.so")
    lib_names.append("libLLVM.so.21")
    lib_names.append("libLLVM-21.so")

    var last_error: String = ""
    for i in range(len(lib_names)):
        try:
            _llvm_handle = OwnedDLHandle(lib_names[i])
            _llvm_loaded = True
            return
        except e:
            last_error = String(e)

    raise Error(
        "Failed to load LLVM library. Tried: "
        + ", ".join(lib_names)
        + ". Last error: "
        + last_error
    )


# ===-----------------------------------------------------------------------===#
# Public API for Getting Function Pointers
# ===-----------------------------------------------------------------------===#


fn get_mlir_function[
    name: StringLiteral,
    T: AnyTrivialRegType,
]() raises -> T:
    """Gets a function pointer from the MLIR C API library.

    Parameters:
        name: The C function name (e.g., "mlirContextCreate").
        T: The function pointer type.

    Returns:
        A function pointer of type T.

    Raises:
        If the MLIR library cannot be loaded or the symbol is not found.

    Example:
    ```mojo
    alias CreateCtxFn = fn() -> MlirContext
    var create = get_mlir_function["mlirContextCreate", CreateCtxFn]()
    var ctx = create()
    ```
    """
    _ensure_mlir_c_loaded()
    return _mlir_c_handle.get_function[T](String(name))


fn get_llvm_function[
    name: StringLiteral,
    T: AnyTrivialRegType,
]() raises -> T:
    """Gets a function pointer from the LLVM library.

    Parameters:
        name: The C function name.
        T: The function pointer type.

    Returns:
        A function pointer of type T.

    Raises:
        If the LLVM library cannot be loaded or the symbol is not found.
    """
    _ensure_llvm_loaded()
    return _llvm_handle.get_function[T](String(name))


fn mlir_library_loaded() -> Bool:
    """Returns True if the MLIR C API library is loaded."""
    return _mlir_c_loaded


fn llvm_library_loaded() -> Bool:
    """Returns True if the LLVM library is loaded."""
    return _llvm_loaded


# ===-----------------------------------------------------------------------===#
# Utility Functions
# ===-----------------------------------------------------------------------===#


fn c_str(s: String) -> c_char_ptr:
    """Converts a Mojo String to a C string pointer.

    Note: The returned pointer is only valid while the String is alive.

    Args:
        s: The Mojo string.

    Returns:
        A pointer to the null-terminated string data.
    """
    return s.unsafe_cstr_ptr().bitcast[c_char]()


@always_inline
fn mlir_succeeded(result: MlirLogicalResult) -> Bool:
    """Checks if an MLIR logical result indicates success.

    Args:
        result: The logical result from an MLIR C API call.

    Returns:
        True if the operation succeeded.
    """
    return result != 0


@always_inline
fn mlir_failed(result: MlirLogicalResult) -> Bool:
    """Checks if an MLIR logical result indicates failure.

    Args:
        result: The logical result from an MLIR C API call.

    Returns:
        True if the operation failed.
    """
    return result == 0
