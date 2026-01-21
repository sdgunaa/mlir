from mlir.core import MlirStringRef
from mlir.core.context import MlirContext
from mlir.ffi import mlirc_fn, ExternalPointer


@register_passable("trivial")
struct MlirDialect:
    var ptr: ExternalPointer


@register_passable("trivial")
struct MlirDialectHandle:
    var ptr: ExternalPointer


@register_passable("trivial")
struct MlirDialectRegistry:
    var ptr: ExternalPointer


fn mlirDialectGetNamespace(dialect: MlirDialect) -> MlirStringRef:
    return mlirc_fn["mlirDialectGetNamespace", MlirStringRef](dialect)


fn mlirDialectGetContext(dialect: MlirDialect) -> MlirContext:
    return mlirc_fn["mlirDialectGetContext", MlirContext](dialect)


fn mlirDialectEqual(dialect1: MlirDialect, dialect2: MlirDialect) -> Bool:
    return mlirc_fn["mlirDialectEqual", Bool](dialect1, dialect2)


@always_inline("nodebug")
fn mlirDialectIsNull(dialect: MlirDialect) -> Bool:
    return not Bool(dialect.ptr)


fn MlirDialectHandleGetNamespace(
    dialect_handle: MlirDialectHandle,
) -> MlirStringRef:
    return mlirc_fn["mlirDialectHandleGetNamespace", MlirStringRef](
        dialect_handle
    )


fn mlirDialectHandleInsertDialect(
    dialect_handle: MlirDialectHandle, registry: MlirDialectRegistry
) -> None:
    return mlirc_fn["mlirDialectHandleInsertDialect", NoneType._mlir_type](
        dialect_handle, registry
    )


fn mlirDialectHandleRegisterDialect(
    dialect_handle: MlirDialectHandle, context: MlirContext
) -> None:
    return mlirc_fn["mlirDialectHandleRegisterDialect", NoneType._mlir_type](
        dialect_handle, context
    )


fn mlirDialectHandleLoadDialect(
    dialect_handle: MlirDialectHandle, context: MlirContext
) -> MlirDialect:
    return mlirc_fn["mlirDialectHandleLoadDialect", MlirDialect](
        dialect_handle, context
    )


fn mlirDialectRegistryCreate() -> MlirDialectRegistry:
    return mlirc_fn["mlirDialectRegistryCreate", MlirDialectRegistry]()


@always_inline("nodebug")
fn mlirDialectRegistryIsNull(registry: MlirDialectRegistry) -> Bool:
    return not Bool(registry.ptr)


fn mlirDialectRegistryDestroy(registry: MlirDialectRegistry) -> None:
    return mlirc_fn["mlirDialectRegistryDestroy", NoneType._mlir_type](registry)


fn mlirRegisterAllDialects(registry: MlirDialectRegistry) -> None:
    return mlirc_fn["mlirRegisterAllDialects", NoneType._mlir_type](registry)
