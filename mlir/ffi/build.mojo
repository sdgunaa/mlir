# ===----------------------------------------------------------------------=== #
# MLIR Mojo Bindings - Build System
#
# Copyright (c) 2026 sdgunaa
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Build system for MLIR C API shared library.

This module handles automatic detection and building of the libMLIR-C.so
shared library from static libraries installed via system package manager.

The build process:
1. Check if cached libMLIR-C.so exists and is valid
2. Look for system-installed LLVM with MLIR static libraries
3. If not found, prompt user to install via package manager
4. Build shared library from static libs (monolithic build)
5. Cache the result in ~/.cache/mlir-mojo/
"""

from pathlib import Path
from os import getenv
from sys.info import CompilationTarget

# ===----------------------------------------------------------------------=== #
# Constants
# ===----------------------------------------------------------------------=== #

comptime MLIR_VERSION = "21"
"""Target MLIR/LLVM major version."""

comptime CACHE_DIR_NAME = "mlir-mojo"
"""Name of the cache directory."""


# ===----------------------------------------------------------------------=== #
# Platform Detection
# ===----------------------------------------------------------------------=== #


fn get_platform() -> String:
    """Detect the current platform.

    Returns:
        Platform string like "Linux-X64", "Darwin-ARM64", etc.
    """
    var os_name: String

    @parameter
    if CompilationTarget.is_linux():
        os_name = "Linux"
    elif CompilationTarget.is_macos():
        os_name = "Darwin"
    else:
        os_name = "Unknown"

    var arch: String

    @parameter
    if CompilationTarget.is_x86():
        arch = "X64"
    elif CompilationTarget.is_apple_silicon():
        arch = "ARM64"
    else:
        arch = "Unknown"

    return os_name + "-" + arch


fn _get_cache_dir() -> Path:
    """Get the MLIR cache directory path."""
    var home = getenv("HOME", "/tmp")
    return Path(home) / ".cache" / CACHE_DIR_NAME


fn _get_lib_path() -> Path:
    """Get the path to the cached libMLIR-C.so."""
    return _get_cache_dir() / "libMLIR-C.so"


fn _get_version_file() -> Path:
    """Get the path to the .version file."""
    return _get_cache_dir() / ".version"


# ===----------------------------------------------------------------------=== #
# Cache Validation
# ===----------------------------------------------------------------------=== #


fn _is_cache_valid() -> Bool:
    """Check if the cached library is valid.

    Returns:
        True if cache exists and version matches.
    """
    var lib_path = _get_lib_path()
    var version_file = _get_version_file()

    # Check if library exists
    if not lib_path.exists():
        return False

    # Check if version file exists
    if not version_file.exists():
        return False

    # TODO: Check version matches when Path.read_text is stable
    return True


# ===----------------------------------------------------------------------=== #
# System LLVM Detection
# ===----------------------------------------------------------------------=== #


fn _find_system_llvm() -> Optional[Path]:
    """Search for system-installed LLVM with MLIR C API static libraries.

    Returns:
        Path to the lib directory if found, None otherwise.
    """
    # Define search paths based on platform
    var search_paths = List[Path]()

    @parameter
    if CompilationTarget.is_linux():
        search_paths.append(Path("/usr/lib/llvm-21/lib"))
        search_paths.append(Path("/usr/lib/llvm-20/lib"))
        search_paths.append(Path("/usr/lib/llvm-19/lib"))
        search_paths.append(Path("/usr/local/lib"))
    elif CompilationTarget.is_macos():
        search_paths.append(Path("/opt/homebrew/opt/llvm/lib"))
        search_paths.append(Path("/usr/local/opt/llvm/lib"))
        search_paths.append(Path("/usr/local/lib"))

    # Look for libMLIRCAPIIR.a as indicator
    for i in range(len(search_paths)):
        var lib_dir = search_paths[i]
        var indicator = lib_dir / "libMLIRCAPIIR.a"
        if indicator.exists():
            print("[mlir-ffi] Found system LLVM at:", String(lib_dir))
            return lib_dir

    return None


fn _get_install_instructions() -> String:
    """Get platform-specific installation instructions."""

    @parameter
    if CompilationTarget.is_linux():
        return String(
            "Install LLVM/MLIR development packages:\n"
            "  Ubuntu/Debian:\n"
            "    sudo apt install llvm-21-dev libmlir-21-dev\n"
            "  Fedora:\n"
            "    sudo dnf install llvm-devel mlir-devel\n"
            "  Arch:\n"
            "    sudo pacman -S llvm mlir\n"
        )
    elif CompilationTarget.is_macos():
        return String(
            "Install LLVM via Homebrew:\n"
            "  brew install llvm\n"
            '  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"\n'
        )
    else:
        return (
            "Please install LLVM with MLIR development libraries for your"
            " platform.\n"
        )


# ===----------------------------------------------------------------------=== #
# Build Shared Library
# ===----------------------------------------------------------------------=== #


fn _build_shared_library(llvm_lib_dir: Path, output: Path) raises:
    """Build libMLIR-C.so from static libraries.

    Args:
        llvm_lib_dir: Path to LLVM lib directory containing static libs.
        output: Output path for the shared library.

    Raises:
        If build fails.
    """
    from subprocess import run

    print("[mlir-ffi] Building libMLIR-C.so from static libraries...")

    # Create cache directory
    var cache_dir = _get_cache_dir()
    _ = run("mkdir -p '" + String(cache_dir) + "'")

    # Build a shell script that extracts ALL MLIR static libs and links them
    var lib_dir_str = String(llvm_lib_dir)
    var output_str = String(output)

    var script = String(
        "#!/bin/bash\n"
        "set -e\n"
        "TMP_DIR=$(mktemp -d)\n"
        "trap 'rm -rf $TMP_DIR' EXIT\n"
        "\n"
    )

    # Extract objects from ALL MLIR and LLVM static libraries into unique subdirectories
    # We include everything (except thin archives and LTO) to ensure all symbols are present
    script += (
        "echo '[mlir-ffi] Extracting objects from static libraries (this may"
        " take a while)...'\n"
    )
    script += (
        "find '"
        + lib_dir_str
        + "' \\( -name 'libMLIR*.a' -o -name 'libLLVM*.a' \\) ! -name"
        " 'libMLIR.a' ! -name 'libLLVM.a' ! -name 'libLTO.a' | while read"
        " lib; do\n"
    )
    script += '  name=$(basename "$lib" .a)\n'
    script += '  mkdir -p "$TMP_DIR/$name"\n'
    script += '  (cd "$TMP_DIR/$name" && ar x "$lib")\n'
    script += "done\n"

    # Determine compiler
    var compiler = "gcc"

    @parameter
    if CompilationTarget.is_macos():
        compiler = "clang"

    script += "\n# Link into monolithic shared library\n"
    script += "echo '[mlir-ffi] Linking monolithic libMLIR-C.so...'\n"

    # Link all objects. Use find to get all .o files recursively.
    script += (
        compiler
        + " -shared -fPIC -o '"
        + output_str
        + "' $(find $TMP_DIR -name '*.o') \\\n"
    )
    script += "  -L'" + lib_dir_str + "' \\\n"
    script += "  -lstdc++ -lm -lpthread -ldl\n"

    # Verify build
    script += "\n# Verify\n"
    script += (
        "nm '"
        + output_str
        + "' | grep -q mlirContextCreate || { echo 'Build verification failed';"
        " exit 1; }\n"
    )
    script += "echo '[mlir-ffi] Build successful!'\n"

    # Write and execute script
    var script_path = "/tmp/mlir_build.sh"
    Path(script_path).write_text(script)

    try:
        var result = run("bash " + script_path)
        # run() returns output string on success, raises on failure
        print(result)
    except e:
        raise Error(
            "Build failed! Check if gcc/clang is installed. Error: " + String(e)
        )

    # Write version file
    var version_file = _get_version_file()
    version_file.write_text(MLIR_VERSION)

    print("[mlir-ffi] Successfully built:", output_str)


# ===----------------------------------------------------------------------=== #
# Main Entry Point
# ===----------------------------------------------------------------------=== #


fn ensure_mlir_c_library() raises -> Path:
    """Ensure libMLIR-C.so exists, building if needed.

    This is the main entry point called by the FFI module.

    Returns:
        Path to the libMLIR-C.so file.

    Raises:
        If the library cannot be found or built.
    """
    # Fast path: check cache
    if _is_cache_valid():
        print("[mlir-ffi] Using cached libMLIR-C.so")
        return _get_lib_path()

    # Try to find system LLVM
    var llvm_lib = _find_system_llvm()

    if not llvm_lib:
        # No system LLVM found - show installation instructions
        print("\n" + "=" * 60)
        print("[mlir-ffi] MLIR C API libraries not found!")
        print("=" * 60 + "\n")
        print(_get_install_instructions())
        raise Error(
            "Please install LLVM/MLIR development packages and try again."
        )

    # Build the shared library
    var output = _get_lib_path()
    _build_shared_library(llvm_lib.value(), output)

    return output


fn cleanup_old_caches():
    """Remove old LLVM versions from cache."""
    # TODO: Implement cache cleanup
    pass
