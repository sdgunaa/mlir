from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.operation import MlirOperation


@fieldwise_init
@register_passable("trivial")
struct MlirWalkResult:
    var value: Int8


comptime MlirWalkResultAdvance = MlirWalkResult(0)
comptime MlirWalkResultInterrupt = MlirWalkResult(1)
comptime MlirWalkResultSkip = MlirWalkResult(2)


@fieldwise_init
@register_passable("trivial")
struct MlirWalkOrder:
    var value: Int8


comptime MlirWalkPreOrder = MlirWalkOrder(0)
comptime MlirWalkPostOrder = MlirWalkOrder(1)


comptime MlirOperationWalkCallback = fn (
    MlirOperation, ExternalPointer
) -> MlirWalkResult


fn mlirOperationWalk(
    op: MlirOperation,
    callback: MlirOperationWalkCallback,
    user_data: ExternalPointer,
    walk_order: MlirWalkOrder,
):
    return mlirc_fn["mlirOperationWalk", NoneType._mlir_type](
        op, callback, user_data, walk_order
    )
