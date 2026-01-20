from mlir.core.dialect import (
    MlirDialect,
    MlirDialectHandle,
    MlirDialectRegistry,
)
from mlir.core import MlirStringRef
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.runtime.thread_pool import MlirLlvmThreadPool


@register_passable("trivial")
struct MlirContext:
    var ptr: ExternalPointer


# lifecycle management
fn mlirContextCreate() -> MlirContext:
    return mlirc_fn["mlirContextCreate", MlirContext]()


fn mlirContextDestroy(context: MlirContext):
    return mlirc_fn["mlirContextDestroy", NoneType._mlir_type](context)


@always_inline("nodebug")
fn mlirContextIsNull(context: MlirContext) -> Bool:
    return not Bool(context.ptr)


fn mlirContextEqual(ctx1: MlirContext, ctx2: MlirContext) -> Bool:
    return mlirc_fn["mlirContextEqual", Bool](ctx1, ctx2)


# dialect management
fn mlirContextSetAllowUnregisteredDialects(
    context: MlirContext, allow: Bool
) -> None:
    return mlirc_fn[
        "mlirContextSetAllowUnregisteredDialects", NoneType._mlir_type
    ](context, allow)


fn mlirContextGetAllowUnregisteredDialects(context: MlirContext) -> Bool:
    return mlirc_fn["mlirContextGetAllowUnregisteredDialects", Bool](context)


fn mlirContextGetNumRegisteredDialects(context: MlirContext) -> Int:
    return mlirc_fn["mlirContextGetNumRegisteredDialects", Int](context)


fn mlirContextAppendDialectRegistry(
    context: MlirContext, registry: MlirDialectRegistry
) -> None:
    return mlirc_fn["mlirContextAppendDialectRegistry", NoneType._mlir_type](
        context, registry
    )


fn mlirContextGetNumLoadedDialects(context: MlirContext) -> Int:
    return mlirc_fn["mlirContextGetNumLoadedDialects", Int](context)


fn mlirContextGetOrLoadDialect(
    context: MlirContext, dialect_namespace: MlirStringRef
) -> MlirDialect:
    return mlirc_fn["mlirContextGetOrLoadDialect", MlirDialect](
        context, dialect_namespace
    )


fn mlirContextLoadAllAvailableDialects(context: MlirContext) -> None:
    return mlirc_fn["mlirContextLoadAllAvailableDialects", NoneType._mlir_type](
        context
    )


# threading and parallelism
fn mlirContextEnableMultithreading(context: MlirContext, enable: Bool) -> None:
    return mlirc_fn["mlirContextEnableMultithreading", NoneType._mlir_type](
        context, enable
    )


fn mlirContextSetThreadPool(
    context: MlirContext, thread_pool: MlirLlvmThreadPool
) -> None:
    return mlirc_fn["mlirContextSetThreadPool", NoneType._mlir_type](
        context, thread_pool
    )


# operation registration
fn mlirContextIsRegisteredOperation(
    context: MlirContext, operation_name: MlirStringRef
) -> Bool:
    return mlirc_fn["mlirContextIsRegisteredOperation", Bool](
        context, operation_name
    )
