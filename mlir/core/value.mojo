from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.block import MlirBlock
from mlir.core.context import MlirContext
from mlir.core.operation import MlirOperation, MlirOpOperand
from mlir.core.type import MlirType
from mlir.core.location import MlirLocation


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
