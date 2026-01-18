from pathlib import Path
from os import abort
from subprocess import run
from sys.info import CompilationTarget
from sys.ffi import OwnedDLHandle, _Global, _get_dylib_function
from .build import (
    ensure_mlir,
    LLVM_SHARED_NAME,
)

# ===----------------------------------------------------------------------=== #
# Global LLVM-C library handle (lazy, cached, RAII)
# ===----------------------------------------------------------------------=== #


fn _load_llvm_c() -> OwnedDLHandle:
    try:
        var llvm_root = ensure_mlir()
        var llvm_lib = llvm_root / "lib" / LLVM_SHARED_NAME
        return OwnedDLHandle(llvm_lib)
    except Err:
        if Bool(1):
            abort("Failed to load LLVM-C shared library: " + String(Err))
        return OwnedDLHandle(unsafe_uninitialized=True)


comptime LLVM_C_LIB = _Global[
    "llvm_c_dylib",
    _load_llvm_c,
]


fn has_symbol[Name: StaticString]() -> Bool:
    try:
        return LLVM_C_LIB.get_or_create_ptr()[].check_symbol(String(Name))
    except Err:
        return False


@always_inline
fn _llvmc_symbol[
    FuncName: StaticString,
    RetType: AnyTrivialRegType,
]() -> RetType:
    try:
        return _get_dylib_function[
            LLVM_C_LIB(),
            FuncName,
            RetType,
        ]()
    except Err:
        abort(
            "Failed to load symbol "
            + FuncName
            + " from LLVM-C library;"
            + String(Err)
        )


fn _llvmc_fn[
    FuncName: StaticString,
    RetType: AnyTrivialRegType,
    *types: AnyType,
](*args: *types) -> RetType:
    if not has_symbol[FuncName]():
        abort("LLVM C API symbol not found: " + FuncName)
    var loaded_pack = args.get_loaded_kgen_pack()
    return _llvmc_symbol[FuncName, fn (type_of(loaded_pack)) -> RetType]()(
        loaded_pack
    )


# ===----------------------------------------------------------------------=== #
# Debug / Introspection
# ===----------------------------------------------------------------------=== #


fn list_available_symbols() raises -> List[String]:
    var root = ensure_mlir()
    var lib = root / "lib" / LLVM_SHARED_NAME

    var cmd: String
    if CompilationTarget.is_linux():
        cmd = "nm -D --defined-only " + String(lib)
    else:
        cmd = "nm -gU " + String(lib)

    cmd += " | awk '{print $3}' | grep '^LLVM'"

    var out = run(cmd)
    var syms = List[String]()
    for line in out.split("\n"):
        if line:
            # Strip @@LLVM_XX version suffix
            var name = line.split("@")[0]
            syms.append(String(name))
    return syms^
