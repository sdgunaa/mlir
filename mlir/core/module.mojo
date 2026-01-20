from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef
from mlir.core.block import MlirBlock
from mlir.core.context import MlirContext
from mlir.core.location import MlirLocation
from mlir.core.operation import MlirOperation


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
