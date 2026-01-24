from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.type import MlirType, Type
from mlir.core.location import MlirLocation, Location
from mlir.core.operation import MlirOperation, Operation
from mlir.core.region import MlirRegion, Region
from mlir.core.value import MlirValue, Value


@register_passable("trivial")
struct MlirBlock:
    var ptr: ExternalPointer


fn mlirBlockCreate(
    num_args: Int,
    args: UnsafePointer[MlirType, MutExternalOrigin],
    locations: UnsafePointer[MlirLocation, MutExternalOrigin],
) -> MlirBlock:
    return mlirc_fn["mlirBlockCreate", MlirBlock](num_args, args, locations)


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


@fieldwise_init("implicit")
@register_passable("trivial")
struct Block(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirBlock
    var _ptr: Self.c_type

    fn __init__(out self, var location: List[Location]):
        self._ptr = mlirBlockCreate(
            0,
            UnsafePointer[MlirType, MutExternalOrigin](),
            _InnerList(location^).unsafe_ptr(),
        )

    fn __init__(out self, var args: List[Type]):
        var locations = List[Location](capacity=len(args))
        for arg in args:
            locations.append(Location.unknown(arg.context()))

        self._ptr = mlirBlockCreate(
            len(args),
            _InnerList(args^).unsafe_ptr(),
            _InnerList(locations^).unsafe_ptr(),
        )

    fn __init__(out self, var args: List[Type], var locations: List[Location]):
        debug_assert(
            len(args) == len(locations), "Each arg must have a location"
        )
        self._ptr = mlirBlockCreate(
            len(args),
            _InnerList(args^).unsafe_ptr(),
            _InnerList(locations^).unsafe_ptr(),
        )

    fn destroy(deinit self):
        mlirBlockDestroy(self._ptr)

    fn parent_region(self) -> Region:
        return Region(mlirBlockGetParentRegion(self._ptr))

    fn next_in_region(self) -> Block:
        return Block(mlirBlockGetNextInRegion(self._ptr))

    fn parent_operation(self) -> Operation:
        return Operation(mlirBlockGetParentOperation(self._ptr))

    fn first_operation(self) -> Operation:
        return Operation(mlirBlockGetFirstOperation(self._ptr))

    fn num_arguments(self) -> Int:
        return mlirBlockGetNumArguments(self._ptr)

    fn argument(self, position: Int) -> Value:
        return Value(mlirBlockGetArgument(self._ptr, position))

    fn add_argument(self, type: Type, location: Location) -> Value:
        return Value(mlirBlockAddArgument(self._ptr, type._ptr, location._ptr))

    fn erase_argument(self, position: Int):
        mlirBlockEraseArgument(self._ptr, position)

    fn insert_argument(
        self, position: Int, type: Type, location: Location
    ) -> Value:
        return Value(
            mlirBlockInsertArgument(
                self._ptr, position, type._ptr, location._ptr
            )
        )

    fn num_successors(self) -> Int:
        return mlirBlockGetNumSuccessors(self._ptr)

    fn successor(self, position: Int) -> Block:
        return Block(mlirBlockGetSuccessor(self._ptr, position))

    fn num_predecessors(self) -> Int:
        return mlirBlockGetNumPredecessors(self._ptr)

    fn predecessor(self, position: Int) -> Block:
        return Block(mlirBlockGetPredecessor(self._ptr, position))

    fn append_operation(self, var operation: Operation):
        mlirBlockAppendOwnedOperation(self._ptr, operation._ptr)

    fn insert_operation(self, position: Int, var operation: Operation):
        mlirBlockInsertOwnedOperation(self._ptr, position, operation._ptr)

    fn insert_operation_after(self, after: Operation, var operation: Operation):
        mlirBlockInsertOwnedOperationAfter(
            self._ptr, after._ptr, operation._ptr
        )

    fn insert_operation_before(
        self, before: Operation, var operation: Operation
    ):
        mlirBlockInsertOwnedOperationBefore(
            self._ptr, before._ptr, operation._ptr
        )

    fn terminator(self) -> Operation:
        return Operation(mlirBlockGetTerminator(self._ptr))

    fn __eq__(self, other: Self) -> Bool:
        return mlirBlockEqual(self._ptr, other._ptr)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __bool__(self) -> Bool:
        return not mlirBlockIsNull(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

    fn write_to(self, mut writer: Some[Writer]):
        mlirBlockPrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)
