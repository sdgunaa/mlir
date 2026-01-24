from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.block import MlirBlock, Block
from mlir.core.context import MlirContext, Context
from mlir.core.operation import (
    MlirOperation,
    MlirOpOperand,
    Operation,
    OpOperand,
)
from mlir.core.type import MlirType, Type
from mlir.core.location import MlirLocation, Location


@register_passable("trivial")
struct MlirValue:
    var ptr: ExternalPointer


fn mlirValueIsNull(value: MlirValue) -> Bool:
    return not Bool(value.ptr)


fn mlirValueEqual(value: MlirValue, other: MlirValue) -> Bool:
    return mlirc_fn["mlirValueEqual", Bool](value, other)


fn mlirValueIsABlockArgument(value: MlirValue) -> Bool:
    return mlirc_fn["mlirValueIsABlockArgument", Bool](value)


fn mlirValueIsAOpResult(value: MlirValue) -> Bool:
    return mlirc_fn["mlirValueIsAOpResult", Bool](value)


fn mlirBlockArgumentGetOwner(value: MlirValue) -> MlirBlock:
    return mlirc_fn["mlirBlockArgumentGetOwner", MlirBlock](value)


fn mlirBlockArgumentGetArgNumber(value: MlirValue) -> Int:
    return mlirc_fn["mlirBlockArgumentGetArgNumber", Int](value)


fn mlirBlockArgumentSetType(value: MlirValue, type: MlirType):
    return mlirc_fn["mlirBlockArgumentSetType", NoneType._mlir_type](
        value, type
    )


fn mlirOpResultGetOwner(value: MlirValue) -> MlirOperation:
    return mlirc_fn["mlirOpResultGetOwner", MlirOperation](value)


fn mlirOpResultGetResultNumber(value: MlirValue) -> Int:
    return mlirc_fn["mlirOpResultGetResultNumber", Int](value)


fn mlirValueGetType(value: MlirValue) -> MlirType:
    return mlirc_fn["mlirValueGetType", MlirType](value)


fn mlirValueSetType(value: MlirValue, type: MlirType):
    return mlirc_fn["mlirValueSetType", NoneType._mlir_type](value, type)


fn mlirValueDump(value: MlirValue):
    return mlirc_fn["mlirValueDump", NoneType._mlir_type](value)


fn mlirValuePrint(value: MlirValue, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirValuePrint", NoneType._mlir_type](
        value, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirValuePrintAsOperand(value: MlirValue, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirValuePrintAsOperand", NoneType._mlir_type](
        value, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirValueGetFirstUse(value: MlirValue) -> MlirOpOperand:
    return mlirc_fn["mlirValueGetFirstUse", MlirOpOperand](value)


fn mlirValueReplaceAllUsesOfWith(of: MlirValue, `with`: MlirValue):
    return mlirc_fn["mlirValueReplaceAllUsesOfWith", NoneType._mlir_type](
        of, `with`
    )


fn mlirValueReplaceAllUsesExcept(
    of: MlirValue,
    `with`: MlirValue,
    num_exceptions: Int,
    exceptions: UnsafePointer[MlirOperation, MutExternalOrigin],
):
    return mlirc_fn["mlirValueReplaceAllUsesExcept", NoneType._mlir_type](
        of, `with`, num_exceptions, exceptions
    )


fn mlirValueGetLocation(value: MlirValue) -> MlirLocation:
    return mlirc_fn["mlirValueGetLocation", MlirLocation](value)


fn mlirValueGetContext(value: MlirValue) -> MlirContext:
    return mlirc_fn["mlirValueGetContext", MlirContext](value)


@fieldwise_init("implicit")
@register_passable("trivial")
struct Value(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirValue
    var _ptr: Self.c_type

    fn type(self) -> Type:
        return Type(mlirValueGetType(self._ptr))

    fn location(self) -> Location:
        return Location(mlirValueGetLocation(self._ptr))

    fn context(self) -> Context:
        return Context(mlirValueGetContext(self._ptr))

    fn replace_all_uses_with(self, other: Self):
        mlirValueReplaceAllUsesOfWith(self._ptr, other._ptr)

    fn replace_all_uses_except(
        self, other: Self, num_exceptions: Int, var exceptions: List[Operation]
    ):
        mlirValueReplaceAllUsesExcept(
            self._ptr,
            other._ptr,
            num_exceptions,
            _InnerList(exceptions^).unsafe_ptr(),
        )

    fn is_block_argument(self) -> Bool:
        return mlirValueIsABlockArgument(self._ptr)

    fn is_op_result(self) -> Bool:
        return mlirValueIsAOpResult(self._ptr)

    fn get_owner(self) -> Block:
        return Block(mlirBlockArgumentGetOwner(self._ptr))

    fn get_arg_number(self) -> Int:
        return mlirBlockArgumentGetArgNumber(self._ptr)

    fn set_arg_type(self, type: Type):
        mlirBlockArgumentSetType(self._ptr, type._ptr)

    fn set_type(self, type: Type):
        mlirValueSetType(self._ptr, type._ptr)

    fn get_first_use(self) -> OpOperand:
        return OpOperand(mlirValueGetFirstUse(self._ptr))
    
    fn defining_op(self) -> Operation:
        return Operation(mlirOpResultGetOwner(self._ptr))
    
    fn result_number(self) -> Int:
        return mlirOpResultGetResultNumber(self._ptr)

    fn __eq__(self, other: Self) -> Bool:
        return mlirValueEqual(self._ptr, other._ptr)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __bool__(self) -> Bool:
        return not mlirValueIsNull(self._ptr)

    fn write_to(self, mut writer: Some[Writer]):
        mlirValuePrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr
