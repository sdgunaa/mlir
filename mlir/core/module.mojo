from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, _static_from_str
from pathlib import Path
from mlir.core.block import MlirBlock, Block
from mlir.core.context import MlirContext, Context
from mlir.core.location import MlirLocation, Location
from mlir.core.operation import MlirOperation, Operation


@register_passable("trivial")
struct MlirModule:
    var ptr: ExternalPointer


fn mlirModuleCreateEmpty(location: MlirLocation) -> MlirModule:
    return mlirc_fn["mlirModuleCreateEmpty", MlirModule](location)


fn mlirModuleCreateParse(
    context: MlirContext, module: MlirStringRef
) -> MlirModule:
    return mlirc_fn["mlirModuleCreateParse", MlirModule](context, module)


fn mlirModuleCreateParseFromFile(
    context: MlirContext, filename: MlirStringRef
) -> MlirModule:
    return mlirc_fn["mlirModuleCreateParseFromFile", MlirModule](
        context, filename
    )


fn mlirModuleGetContext(module: MlirModule) -> MlirContext:
    return mlirc_fn["mlirModuleGetContext", MlirContext](module)


fn mlirModuleGetBody(module: MlirModule) -> MlirBlock:
    return mlirc_fn["mlirModuleGetBody", MlirBlock](module)


@always_inline("nodebug")
fn mlirModuleIsNull(module: MlirModule) -> Bool:
    return not Bool(module.ptr)


fn mlirModuleDestroy(module: MlirModule):
    mlirc_fn["mlirModuleDestroy", NoneType._mlir_type](module)


fn mlirModuleGetOperation(module: MlirModule) -> MlirOperation:
    return mlirc_fn["mlirModuleGetOperation", MlirOperation](module)


fn mlirModuleFromOperation(operation: MlirOperation) -> MlirModule:
    return mlirc_fn["mlirModuleFromOperation", MlirModule](operation)


@fieldwise_init("implicit")
@register_passable("trivial")
struct Module(MlirWrapper):
    comptime c_type = MlirModule
    var _ptr: Self.c_type

    fn __init__(
        out self,
    ):
        self._ptr = mlirModuleCreateEmpty(Location.unknown(Context())._ptr)

    fn __init__(out self, location: Location):
        self._ptr = mlirModuleCreateEmpty(location._ptr)

    fn __init__(out self, context: Context, /, module: String):
        self._ptr = mlirModuleCreateParse(
            context._ptr, _static_from_str(module)
        )

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

    fn __init__(out self, context: Context, *, filename: Path):
        self._ptr = mlirModuleCreateParseFromFile(
            context._ptr, _static_from_str(String(filename))
        )

    fn destroy(deinit self):
        mlirModuleDestroy(self._ptr)

    fn context(self) -> Context:
        return Context(mlirModuleGetContext(self._ptr))

    fn body(self) -> Block:
        return Block(mlirModuleGetBody(self._ptr))

    fn operation(self) -> Operation:
        return Operation(mlirModuleGetOperation(self._ptr))

    @staticmethod
    fn from_operation(operation: Operation) -> Self:
        return Module(mlirModuleFromOperation(operation._ptr))

    fn __bool__(self) -> Bool:
        return not mlirModuleIsNull(self._ptr)
