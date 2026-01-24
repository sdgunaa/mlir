from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.block import MlirBlock, Block
from mlir.core.operation import MlirOperation, Operation


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


fn mlirRegionGetNextInOperation(region: MlirRegion) -> MlirRegion:
    return mlirc_fn["mlirRegionGetNextInOperation", MlirRegion](region)


fn mlirRegionTakeBody(target: MlirRegion, source: MlirRegion):
    return mlirc_fn["mlirRegionTakeBody", NoneType._mlir_type](target, source)


@fieldwise_init("implicit")
@register_passable("trivial")
struct Region(MlirWrapper):
    comptime c_type = MlirRegion
    var _ptr: Self.c_type

    fn __init__(out self, ):
        self._ptr = mlirRegionCreate()
    
    fn get_first_block(self) -> Block:
        return Block(mlirRegionGetFirstBlock(self._ptr))
    
    fn append_block(self, block: Block):
        mlirRegionAppendOwnedBlock(self._ptr, block._ptr)
    
    fn insert_block(self, index: Int, block: Block):
        mlirRegionInsertOwnedBlock(self._ptr, index, block._ptr)
    
    fn insert_block_after(self, after: Block, block: Block):
        mlirRegionInsertOwnedBlockAfter(self._ptr, after._ptr, block._ptr)
    
    fn insert_block_before(self, before: Block, block: Block):
        mlirRegionInsertOwnedBlockBefore(self._ptr, before._ptr, block._ptr)
    
    fn get_next_in_operation(self) -> Region:
        return Region(mlirRegionGetNextInOperation(self._ptr))
    
    fn take_body(self, source: Region):
        mlirRegionTakeBody(self._ptr, source._ptr)
    
    fn destroy(deinit self):
        mlirRegionDestroy(self._ptr)
    
    fn __eq__(self, other: Self) -> Bool:
        return mlirRegionEqual(self._ptr, other._ptr)
    
    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)
    
    fn __bool__(self) -> Bool:
        return not mlirRegionIsNull(self._ptr)
    
    fn _mlir_type(self) -> Self.c_type:
        return self._ptr