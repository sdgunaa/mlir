from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.type import MlirType
from mlir.core.location import MlirLocation
from mlir.core.operation import MlirOperation
from mlir.core.region import MlirRegion
from mlir.core.value import MlirValue


@register_passable("trivial")
struct MlirBlock:
    var ptr: ExternalPointer


fn mlirBlockCreate(
    num_args: Int,
    args: UnsafePointer[MlirType, MutExternalOrigin],
    location: MlirLocation,
) -> MlirBlock:
    return mlirc_fn["mlirBlockCreate", MlirBlock](num_args, args, location)


fn mlirBlockDestroy(block: MlirBlock):
    return mlirc_fn["mlirBlockDestroy", NoneType._mlir_type](block)


fn mlirBlockDetach(block: MlirBlock):
    return mlirc_fn["mlirBlockDetach", NoneType._mlir_type](block)


@always_inline("nodebug")
fn mlirBlockIsNull(block: MlirBlock) -> Bool:
    return not Bool(block.ptr)


fn mlirBlockEqual(block: MlirBlock, other: MlirBlock) -> Bool:
    return mlirc_fn["mlirBlockEqual", Bool](block, other)


fn mlirBlockGetParentOperation(block: MlirBlock) -> MlirOperation:
    return mlirc_fn["mlirBlockGetParentOperation", MlirOperation](block)


fn mlirBlockGetParentRegion(block: MlirBlock) -> MlirRegion:
    return mlirc_fn["mlirBlockGetParentRegion", MlirRegion](block)


fn mlirBlockGetNextInRegion(block: MlirBlock) -> MlirBlock:
    return mlirc_fn["mlirBlockGetNextInRegion", MlirBlock](block)


fn mlirBlockGetFirstOperation(block: MlirBlock) -> MlirOperation:
    return mlirc_fn["mlirBlockGetFirstOperation", MlirOperation](block)


fn mlirBlockGetTerminator(block: MlirBlock) -> MlirOperation:
    return mlirc_fn["mlirBlockGetTerminator", MlirOperation](block)


fn mlirBlockAppendOwnedOperation(block: MlirBlock, operation: MlirOperation):
    return mlirc_fn["mlirBlockAppendOwnedOperation", NoneType._mlir_type](
        block, operation
    )


fn mlirBlockInsertOwnedOperation(
    block: MlirBlock, position: Int, operation: MlirOperation
):
    return mlirc_fn["mlirBlockInsertOwnedOperation", NoneType._mlir_type](
        block, position, operation
    )


fn mlirBlockInsertOwnedOperationAfter(
    block: MlirBlock, after: MlirOperation, operation: MlirOperation
):
    return mlirc_fn["mlirBlockInsertOwnedOperationAfter", NoneType._mlir_type](
        block, after, operation
    )


fn mlirBlockInsertOwnedOperationBefore(
    block: MlirBlock, before: MlirOperation, operation: MlirOperation
):
    return mlirc_fn["mlirBlockInsertOwnedOperationBefore", NoneType._mlir_type](
        block, before, operation
    )


fn mlirBlockGetNumArguments(block: MlirBlock) -> Int:
    return mlirc_fn["mlirBlockGetNumArguments", Int](block)


fn mlirBlockAddArgument(
    block: MlirBlock, type: MlirType, location: MlirLocation
) -> MlirValue:
    return mlirc_fn["mlirBlockAddArgument", MlirValue](block, type, location)


fn mlirBlockEraseArgument(block: MlirBlock, position: UInt32):
    return mlirc_fn["mlirBlockEraseArgument", NoneType._mlir_type](
        block, position
    )


fn mlirBlockInsertArgument(
    block: MlirBlock, position: Int, type: MlirType, location: MlirLocation
) -> MlirValue:
    return mlirc_fn["mlirBlockInsertArgument", MlirValue](
        block, position, type, location
    )


fn mlirBlockGetArgument(block: MlirBlock, position: Int) -> MlirValue:
    return mlirc_fn["mlirBlockGetArgument", MlirValue](block, position)


fn mlirBlockPrint(block: MlirBlock, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirBlockPrint", NoneType._mlir_type](
        block, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirBlockGetNumSuccessors(block: MlirBlock) -> Int:
    return mlirc_fn["mlirBlockGetNumSuccessors", Int](block)


fn mlirBlockGetSuccessor(block: MlirBlock, position: Int) -> MlirBlock:
    return mlirc_fn["mlirBlockGetSuccessor", MlirBlock](block, position)


fn mlirBlockGetNumPredecessors(block: MlirBlock) -> Int:
    return mlirc_fn["mlirBlockGetNumPredecessors", Int](block)


fn mlirBlockGetPredecessor(block: MlirBlock, position: Int) -> MlirBlock:
    return mlirc_fn["mlirBlockGetPredecessor", MlirBlock](block, position)
