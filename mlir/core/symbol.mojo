from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef
from mlir.core.attribute import MlirAttribute
from mlir.core.operation import MlirOperation


@register_passable("trivial")
struct MlirSymbolTable:
    var ptr: ExternalPointer


fn mlirSymbolTableGetSymbolAttributeName() -> MlirStringRef:
    return mlirc_fn["mlirSymbolTableGetSymbolAttributeName", MlirStringRef]()


fn mlirSymbolTableGetVisibilityAttributeName() -> MlirStringRef:
    return mlirc_fn[
        "mlirSymbolTableGetVisibilityAttributeName", MlirStringRef
    ]()


fn mlirSymbolTableCreate(operation: MlirOperation) -> MlirSymbolTable:
    return mlirc_fn["mlirSymbolTableCreate", MlirSymbolTable](operation)


@always_inline("nodebug")
fn mlirSymbolTableIsNull(symbol_table: MlirSymbolTable) -> Bool:
    return not Bool(symbol_table.ptr)


fn mlirSymbolTableDestroy(symbol_table: MlirSymbolTable):
    return mlirc_fn["mlirSymbolTableDestroy", NoneType._mlir_type](symbol_table)


fn mlirSymbolTableLookup(
    symbol_table: MlirSymbolTable, name: MlirStringRef
) -> MlirOperation:
    return mlirc_fn["mlirSymbolTableLookup", MlirOperation](symbol_table, name)


fn mlirSymbolTableInsert(
    symbol_table: MlirSymbolTable, operation: MlirOperation
) -> MlirAttribute:
    return mlirc_fn["mlirSymbolTableInsert", MlirAttribute](
        symbol_table, operation
    )


fn mlirSymbolTableErase(
    symbol_table: MlirSymbolTable, operation: MlirOperation
):
    return mlirc_fn["mlirSymbolTableErase", NoneType._mlir_type](
        symbol_table, operation
    )


fn mlirSymbolTableReplaceAllSymbolUses(
    old_symbol: MlirStringRef, new_symbol: MlirStringRef, `from`: MlirOperation
):
    return mlirc_fn["mlirSymbolTableReplaceAllSymbolUses", NoneType._mlir_type](
        old_symbol, new_symbol, `from`
    )


fn mlirSymbolTableWalkSymbolTables(
    `from`: MlirOperation,
    allSymUsesVisible: Bool,
    callback: fn (MlirOperation, Bool, ExternalPointer) -> None,
    user_data: ExternalPointer,
):
    return mlirc_fn["mlirSymbolTableWalkSymbolTables", NoneType._mlir_type](
        `from`, allSymUsesVisible, callback, user_data
    )
