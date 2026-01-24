from mlir.core.dialect import (
    MlirDialect,
    MlirDialectHandle,
    MlirDialectRegistry,
    Dialect,
    DialectHandle,
    DialectRegistry,
    mlirDialectHandleLoadDialect,
    mlirDialectHandleRegisterDialect,
    mlirDialectIsNull,
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


fn mlirContextCreateWithThreading(threading_enabled: Bool) -> MlirContext:
    return mlirc_fn["mlirContextCreateWithThreading", MlirContext](
        threading_enabled
    )


fn mlirContextCreateWithRegistry(registry: MlirDialectRegistry) -> MlirContext:
    return mlirc_fn["mlirContextCreateWithRegistry", MlirContext](registry)


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


@fieldwise_init("implicit")
@register_passable("trivial")
struct Context(MlirWrapper):
    comptime c_type = MlirContext
    var _ptr: Self.c_type

    fn __init__(
        out self,
    ):
        self._ptr = mlirContextCreate()

    fn __init__(out self, threading_enabled: Bool):
        self._ptr = mlirContextCreateWithThreading(threading_enabled)

    fn __init__(out self, var registry: DialectRegistry):
        self._ptr = mlirContextCreateWithRegistry(registry._ptr)

    fn __enter__(mut self) -> Self:
        return self

    fn __exit__(mut self):
        mlirContextDestroy(self._ptr)

    fn __eq__(self, other: Self) -> Bool:
        return mlirContextEqual(self._ptr, other._ptr)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

    fn append(mut self, var registry: DialectRegistry):
        mlirContextAppendDialectRegistry(self._ptr, registry._ptr)

    fn register(mut self, handle: DialectHandle):
        mlirDialectHandleRegisterDialect(handle._ptr, self._ptr)

    fn load_dialect(self, dialect_handle: DialectHandle) -> Dialect:
        return mlirDialectHandleLoadDialect(dialect_handle._ptr, self._ptr)

    fn get_or_load_dialect(self, dialect_namespace: StaticString) -> Dialect:
        var dialect = mlirContextGetOrLoadDialect(
            self._ptr, _static_from_str(dialect_namespace)
        )
        if mlirDialectIsNull(dialect):
            abort("Failed to load dialect: " + dialect_namespace)

        return dialect

    fn load_all_available_dialects(mut self):
        var registry = DialectRegistry()
        registry.register_all()
        self.append(registry^)
        mlirContextLoadAllAvailableDialects(self._ptr)

    fn allow_unregistered_dialects(mut self, allow: Bool):
        mlirContextSetAllowUnregisteredDialects(self._ptr, allow)

    fn allows_unregistered_dialects(self) -> Bool:
        return mlirContextGetAllowUnregisteredDialects(self._ptr)

    fn num_registered_dialects(self) -> Int:
        return mlirContextGetNumRegisteredDialects(self._ptr)

    fn num_loaded_dialects(self) -> Int:
        return mlirContextGetNumLoadedDialects(self._ptr)

    fn enable_multithreading(mut self, enable: Bool = True):
        mlirContextEnableMultithreading(self._ptr, enable)

    fn set_thread_pool(mut self, thread_pool: MlirLlvmThreadPool):
        mlirContextSetThreadPool(self._ptr, thread_pool)

    fn is_registered_operation(self, operation_name: StaticString) -> Bool:
        return mlirContextIsRegisteredOperation(
            self._ptr, _static_from_str(operation_name)
        )
