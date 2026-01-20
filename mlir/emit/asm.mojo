from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.operation import MlirOperation
from mlir.core.value import MlirValue
from mlir.emit.printing_flags import MlirOpPrintingFlags


@register_passable("trivial")
struct MlirAsmState:
    var ptr: ExternalPointer


fn mlirAsmStateCreateForOperation(
    operation: MlirOperation, flags: MlirOpPrintingFlags
) -> MlirAsmState:
    return mlirc_fn["mlirAsmStateCreateForOperation", MlirAsmState](
        operation, flags
    )


fn mlirAsmStateCreateForValue(
    value: MlirValue, flags: MlirOpPrintingFlags
) -> MlirAsmState:
    return mlirc_fn["mlirAsmStateCreateForValue", MlirAsmState](value, flags)


fn mlirAsmStateDestroy(state: MlirAsmState):
    return mlirc_fn["mlirAsmStateDestroy", NoneType._mlir_type](state)
