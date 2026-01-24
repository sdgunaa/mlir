from format._utils import _WriteBufferStack
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback, _static_from_str
from mlir.core.context import Context, MlirContext
from mlir.core.dialect import MlirDialect, Dialect


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
        type, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirTypeDump(type: MlirType):
    mlirc_fn["mlirTypeDump", NoneType._mlir_type](type)


@fieldwise_init("implicit")
@register_passable("trivial")
struct Type(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirType
    var _ptr: Self.c_type

    @staticmethod
    fn parse(context: Context, type_string: String) raises -> Self:
        var type = mlirTypeParseGet(context._ptr, _static_from_str(type_string))
        if not type.ptr:
            raise Error("Failed to parse type")
        return Type(type)

    fn context(self) -> Context:
        return mlirTypeGetContext(self._ptr)

    fn dialect(self) -> Dialect:
        return mlirTypeGetDialect(self._ptr)

    fn __eq__(self, other: Self) -> Bool:
        return mlirTypeEqual(self._ptr, other._ptr)

    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    fn __bool__(self) -> Bool:
        return not mlirTypeIsNull(self._ptr)

    fn write_to(self, mut writer: Some[Writer]):
        mlirTypePrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr
