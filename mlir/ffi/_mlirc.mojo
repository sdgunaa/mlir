from pathlib import Path
from sys.info import CompilationTarget
from os import abort
from subprocess import run
from sys.ffi import OwnedDLHandle, _Global, _get_dylib_function
from .build import (
    ensure_mlir,
    MLIR_SHARED_NAME,
    get_shared_lib_ext,
)


# ===----------------------------------------------------------------------=== #
# Global MLIR-C library handle (lazy, cached, RAII)
# ===----------------------------------------------------------------------=== #


fn _load_mlir_c() -> OwnedDLHandle:
    try:
        var mlir_path = ensure_mlir()
        var mlir_lib_path = mlir_path / "lib" / MLIR_SHARED_NAME
        return OwnedDLHandle(mlir_lib_path)
    except Err:
        if Bool(1):
            abort("Failed to load MLIR-C shared library: " + String(Err))
        return OwnedDLHandle(unsafe_uninitialized=True)


comptime MLIR_C_LIB = _Global[
    "mlir_c_dylib",
    _load_mlir_c,
]


fn has_symbol[Name: StaticString]() -> Bool:
    try:
        return MLIR_C_LIB.get_or_create_ptr()[].check_symbol(String(Name))
    except Err:
        return False


@always_inline
fn _mlir_symbol[
    FuncName: StaticString,
    RetType: AnyTrivialRegType,
]() -> RetType:
    try:
        return _get_dylib_function[
            MLIR_C_LIB(),
            FuncName,
            RetType,
        ]()
    except Err:
        abort(
            "Failed to load symbol "
            + FuncName
            + " from MLIR-C library; "
            + String(Err)
        )


fn mlirc_fn[
    FuncName: StaticString,
    RetType: AnyTrivialRegType,
    *types: AnyType,
](*args: *types) -> RetType:
    if not has_symbol[FuncName]():
        abort("MLIR C API symbol not found: " + FuncName)
    var loaded_pack = args.get_loaded_kgen_pack()
    return _mlir_symbol[FuncName, fn (type_of(loaded_pack)) -> RetType]()(
        loaded_pack
    )


# ===----------------------------------------------------------------------=== #
# Debug / Introspection
# ===----------------------------------------------------------------------=== #


fn list_available_symbols() raises -> List[String]:
    var mlir_path = ensure_mlir()
    var mlir_lib_path = mlir_path / "lib" / MLIR_SHARED_NAME

    var cmd: String
    var out: String
    if CompilationTarget.is_linux():
        cmd = "nm -D --defined-only " + String(mlir_lib_path)
    else:
        cmd = "nm -gU " + String(mlir_lib_path)
    cmd += " | awk '{print $3}' | grep '^mlir'"
    try:
        out = run(cmd)
    except Err:
        abort("Failed to enumerate MLIR C API symbols: " + String(Err))

    var symbols = List[String]()
    for line in out.split("\n"):
        if line and not line.startswith("_"):
            symbols.append(String(line))
    return symbols^
