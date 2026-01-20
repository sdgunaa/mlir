from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.context import MlirContext
from mlir.core.dialect import MlirDialect


@register_passable("trivial")
struct MlirType:
    var ptr: ExternalPointer


@register_passable("trivial")
struct MlirTypeID:
    var ptr: ExternalPointer


fn mlirTypeParseGet(context: MlirContext, type_str: MlirStringRef) -> MlirType:
    return mlirc_fn["mlirTypeParseGet", MlirType](context, type_str)


fn mlirTypeGetContext(type: MlirType) -> MlirContext:
    return mlirc_fn["mlirTypeGetContext", MlirContext](type)


fn mlirTypeGetTypeID(type: MlirType) -> MlirTypeID:
    return mlirc_fn["mlirTypeGetTypeID", MlirTypeID](type)


fn mlirTypeGetDialect(type: MlirType) -> MlirDialect:
    return mlirc_fn["mlirTypeGetDialect", MlirDialect](type)


@always_inline("nodebug")
fn mlirTypeIsNull(type: MlirType) -> Bool:
    return not Bool(type.ptr)


fn mlirTypeEqual(type: MlirType, other: MlirType) -> Bool:
    return mlirc_fn["mlirTypeEqual", Bool](type, other)


fn mlirTypePrint(type: MlirType, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirTypePrint", NoneType._mlir_type](
        type, UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirTypeDump(type: MlirType):
    mlirc_fn["mlirTypeDump", NoneType._mlir_type](type)
