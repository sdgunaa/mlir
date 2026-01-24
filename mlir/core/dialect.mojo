from mlir.core import MlirStringRef
from mlir.core.context import MlirContext, Context
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.type import Type
from mlir.core.attribute import Attribute


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


fn mlirDialectHandleGetNamespace(
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


trait DialectType:
    fn __init__(out self, type: Type):
        ...

    fn to_mlir(self) -> Type:
        ...


trait DialectAttribute:
    fn __init__(out self, attribute: Attribute):
        ...

    fn to_mlir(self) -> Attribute:
        ...


@fieldwise_init("implicit")
struct DialectRegistry:
    comptime c_type = MlirDialectRegistry
    var _ptr: Self.c_type

    fn __init__(out self):
        self._ptr = mlirDialectRegistryCreate()

    fn register_all(self):
        mlirRegisterAllDialects(self._ptr)

    fn insert(mut self, handle: DialectHandle):
        mlirDialectHandleInsertDialect(handle._ptr, self._ptr)

    fn __del__(deinit self):
        # TODO: destroying the registry should be handled by the context
        pass


@fieldwise_init("implicit")
@register_passable("trivial")
struct Dialect(MlirWrapper):
    comptime c_type = MlirDialect
    var _ptr: Self.c_type

    fn __eq__(self, other: Self) -> Bool:
        return mlirDialectEqual(self._ptr, other._ptr)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn context(self) -> Context:
        return mlirDialectGetContext(self._ptr)

    fn namespace(self) -> StaticString:
        return mlirDialectGetNamespace(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

@fieldwise_init("implicit")
@register_passable("trivial")
struct DialectHandle(MlirWrapper):
    comptime c_type = MlirDialectHandle
    var _ptr: Self.c_type

    fn namespace(self) -> StaticString:
        return mlirDialectHandleGetNamespace(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr