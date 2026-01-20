from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.block import MlirBlock
from mlir.core.operation import MlirOperation


@register_passable("trivial")
struct MlirRegion:
    var ptr: ExternalPointer


fn mlirRegionCreate() -> MlirRegion:
    return mlirc_fn["mlirRegionCreate", MlirRegion]()


fn mlirRegionDestroy(region: MlirRegion):
    return mlirc_fn["mlirRegionDestroy", NoneType._mlir_type](region)


@always_inline("nodebug")
fn mlirRegionIsNull(region: MlirRegion) -> Bool:
    return not Bool(region.ptr)


fn mlirRegionEqual(region: MlirRegion, other: MlirRegion) -> Bool:
    return mlirc_fn["mlirRegionEqual", Bool](region, other)


fn mlirRegionGetFirstBlock(region: MlirRegion) -> MlirBlock:
    return mlirc_fn["mlirRegionGetFirstBlock", MlirBlock](region)


fn mlirRegionAppendOwnedBlock(region: MlirRegion, block: MlirBlock):
    return mlirc_fn["mlirRegionAppendOwnedBlock", NoneType._mlir_type](
        region, block
    )


fn mlirRegionInsertOwnedBlock(region: MlirRegion, index: Int, block: MlirBlock):
    return mlirc_fn["mlirRegionInsertOwnedBlock", NoneType._mlir_type](
        region, index, block
    )


fn mlirRegionInsertOwnedBlockAfter(
    region: MlirRegion, after: MlirBlock, block: MlirBlock
):
    return mlirc_fn["mlirRegionInsertOwnedBlockAfter", NoneType._mlir_type](
        region, after, block
    )


fn mlirRegionInsertOwnedBlockBefore(
    region: MlirRegion, before: MlirBlock, block: MlirBlock
):
    return mlirc_fn["mlirRegionInsertOwnedBlockBefore", NoneType._mlir_type](
        region, before, block
    )


fn mlirOperationGetFirstRegion(operation: MlirOperation) -> MlirRegion:
    return mlirc_fn["mlirOperationGetFirstRegion", MlirRegion](operation)


fn mlirRegionGetNextInOperation(region: MlirRegion) -> MlirRegion:
    return mlirc_fn["mlirRegionGetNextInOperation", MlirRegion](region)


fn mlirRegionTakeBody(target: MlirRegion, source: MlirRegion):
    return mlirc_fn["mlirRegionTakeBody", NoneType._mlir_type](target, source)
