# ===----------------------------------------------------------------------=== #
# MLIR Mojo Bindings - Foreign Function Interface (FFI)
#
# Copyright (c) 2026 sdgunaa
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #

"""MLIR FFI module for loading and interfacing with MLIR/LLVM C libraries.

This module provides the low-level FFI infrastructure for loading MLIR and LLVM
shared libraries and accessing their C API functions.

The runtime is automatically provisioned by:
1. Checking for a cached build in ~/.cache/mlir-mojo/
2. Downloading a prebuilt package from:
   https://github.com/sdgunaa/mlir/releases

Supported variants:
  - release : Optimized MLIR/LLVM build
  - dev     : Developer build (currently disabled)

Artifacts are cached under ~/.cache/mlir-mojo/<variant>-<platform>.
"""

from pathlib import Path
from os import getenv, mkdir, abort, listdir, rmdir, unlink
from sys.info import CompilationTarget
from subprocess import run

# ===----------------------------------------------------------------------=== #
# Platform Detection
# ===----------------------------------------------------------------------=== #


@parameter
fn get_platform() -> StaticString:
    if CompilationTarget.is_linux() and CompilationTarget.is_x86():
        return "linux-x86_64"
    elif CompilationTarget.is_macos() and CompilationTarget.is_apple_silicon():
        return "macos-arm64"
    else:
        return "unknown"


@parameter
fn get_shared_lib_ext() -> StaticString:
    if CompilationTarget.is_linux():
        return ".so"
    elif CompilationTarget.is_macos():
        return ".dylib"
    else:
        return ""


comptime LLVM_VERSION = "21.1.8"
comptime CACHE_DIR_NAME = "mlir-mojo"
comptime PLATFORM = get_platform()

comptime RELEASE_FILENAME = "llvm+mlir-v" + LLVM_VERSION + "-" + PLATFORM + ".tar.gz"
comptime DEV_FILENAME = "llvm+mlir-v" + LLVM_VERSION + "-dev-" + PLATFORM + ".tar.gz"

comptime RELEASE_URL = "https://github.com/sdgunaa/mlir/releases/download/v" + LLVM_VERSION + "/" + RELEASE_FILENAME
comptime DEV_URL = "https://github.com/sdgunaa/mlir/releases/download/v" + LLVM_VERSION + "/" + DEV_FILENAME

comptime LLVM_SHARED_NAME = "libLLVM" + get_shared_lib_ext()
comptime MLIR_SHARED_NAME = "libMLIR-C" + get_shared_lib_ext()


# ===----------------------------------------------------------------------=== #
# Cache Helpers
# ===----------------------------------------------------------------------=== #


fn _get_cache_dir() -> Path:
    home = getenv("HOME", "/tmp")
    return Path(home) / ".cache" / CACHE_DIR_NAME


fn _get_version_file() -> Path:
    return Path(String(_get_cache_dir(), "/version.txt"))


fn _archive_path(filename: String) -> Path:
    return String(_get_cache_dir(), "/", filename)


fn _extract_dir(variant: String) -> Path:
    return String(_get_cache_dir(), "/", variant, "-", PLATFORM)


fn _ensure_cache_dir():
    var dir = _get_cache_dir()
    if not dir.exists():
        try:
            _ = run("mkdir -p " + String(dir))
        except Err:
            abort("Failed to create cache directory: " + String(dir))


# ===----------------------------------------------------------------------=== #
# Download / Extract
# ===----------------------------------------------------------------------=== #


fn download(url: String, archive: Path):
    print("Downloading:", url)
    try:
        _ = run(
            "curl -L --fail --progress-bar --retry 3 -o "
            + String(archive)
            + " "
            + url
        )
    except Err:
        abort("Failed to download MLIR/LLVM package: " + String(Err))


fn extract(archive: Path, target: Path):
    print("Extracting:", archive, "->", target)

    var tmp = Path(String(target) + ".tmp")
    if tmp.exists():
        remove_tree(tmp)

    try:
        mkdir(tmp)
        _ = run(
            "tar -xzf "
            + String(archive)
            + " --strip-components=1 -C "
            + String(tmp)
        )
        verify_layout(tmp)

        if target.exists():
            remove_tree(target)

        _ = run("mv " + String(tmp) + " " + String(target))
    except Err:
        abort("Failed to extract MLIR/LLVM package: " + String(Err))


# ===----------------------------------------------------------------------=== #
# Verification
# ===----------------------------------------------------------------------=== #


fn verify_layout(root: Path) raises:
    lib_dir = root / "lib"
    include_dir = root / "include"

    if not lib_dir.exists():
        abort("Invalid package: missing lib/ directory " + String(lib_dir))
    if not include_dir.exists():
        abort(
            "Invalid package: missing include/ directory " + String(include_dir)
        )

    var llvm_ok = False
    var mlir_ok = False

    for name in listdir(lib_dir):
        if name == LLVM_SHARED_NAME:
            llvm_ok = True
        if name == MLIR_SHARED_NAME:
            mlir_ok = True

    if not llvm_ok or not mlir_ok:
        abort("Required MLIR/LLVM shared libraries not found")


# ===----------------------------------------------------------------------=== #
# Version Tracking
# ===----------------------------------------------------------------------=== #


fn _read_installed_version() -> Optional[String]:
    var vf = _get_version_file()
    if not vf.exists():
        return None
    try:
        return String(vf.read_text().strip())
    except Err:
        abort("Failed to read installed version file: " + String(Err))


fn _write_installed_version(variant: String):
    var vf = _get_version_file()
    try:
        vf.write_text("v" + LLVM_VERSION + ":" + variant + ":" + PLATFORM)
    except Err:
        abort("Failed to write installed version file: " + String(Err))


fn set_variant(variant: String):
    if variant != "release" and variant != "dev":
        abort("Invalid MLIR variant: " + variant)
    _write_installed_version(variant)


fn get_variant() -> String:
    var installed = _read_installed_version()
    if installed:
        # format: v<ver>:<variant>:<platform>
        var parts = installed.value().split(":")
        if len(parts) >= 2:
            return String(parts[1])
    return "release"  # default


# ===----------------------------------------------------------------------=== #
# Utilities
# ===----------------------------------------------------------------------=== #


fn remove_tree(path: Path):
    try:
        if not path.exists():
            return

        for entry in listdir(path):
            var p = path / entry
            if p.is_dir():
                remove_tree(p)
            else:
                unlink(p)

        rmdir(path)
    except Err:
        abort("Failed to remove directory tree: " + String(Err))


# ===----------------------------------------------------------------------=== #
# Public API
# ===----------------------------------------------------------------------=== #


fn ensure_mlir() raises -> Path:
    if PLATFORM == "unknown":
        abort(
            "Unsupported platform. Only linux-x86_64 and macos-arm64 are"
            " supported."
        )

    _ensure_cache_dir()

    var url: String
    var filename: String
    variant: String = get_variant()

    if variant == "release":
        url = RELEASE_URL
        filename = RELEASE_FILENAME
    elif variant == "dev":
        abort("Developer variant is currently disabled.")
    else:
        abort("Invalid MLIR variant: " + variant)

    var archive = _archive_path(filename)
    var target = _extract_dir(variant)

    var expected = "v" + LLVM_VERSION + ":" + variant + ":" + PLATFORM
    var installed = _read_installed_version()

    if target.exists() and installed and installed.value() == expected:
        verify_layout(target)
        return target

    if not archive.exists():
        download(url, archive)

    extract(archive, target)
    _write_installed_version(variant)

    return target
