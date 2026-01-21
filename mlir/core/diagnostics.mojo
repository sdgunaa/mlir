from mlir.core.walk import MlirLogicalResult
from mlir.ffi import mlirc_fn, ExternalPointer
from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.location import MlirLocation
from mlir.core.context import MlirContext
from sys.ffi.cstring import CStringSlice


@register_passable("trivial")
struct MlirDiagnostic:
    var ptr: ExternalPointer


@fieldwise_init
@register_passable("trivial")
struct MlirDiagnosticSeverity:
    var value: Int8


comptime MlirDiagnosticError = MlirDiagnosticSeverity(0)
comptime MlirDiagnosticWarning = MlirDiagnosticSeverity(1)
comptime MlirDiagnosticNote = MlirDiagnosticSeverity(2)
comptime MlirDiagnosticRemark = MlirDiagnosticSeverity(3)

comptime MlirDiagnosticHandler = fn (
    MlirDiagnostic, ExternalPointer
) -> MlirLogicalResult

comptime MlirDiagnosticHandlerID = UInt64


fn mlirDiagnosticPrint(diagnostic: MlirDiagnostic, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirDiagnosticPrint", NoneType._mlir_type](
        diagnostic, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirDiagnosticGetLocation(diagnostic: MlirDiagnostic) -> MlirLocation:
    return mlirc_fn["mlirDiagnosticGetLocation", MlirLocation](diagnostic)


fn mlirDiagnosticGetSeverity(
    diagnostic: MlirDiagnostic,
) -> MlirDiagnosticSeverity:
    return mlirc_fn["mlirDiagnosticGetSeverity", MlirDiagnosticSeverity](
        diagnostic
    )


fn mlirDiagnosticGetNumNotes(diagnostic: MlirDiagnostic) -> Int:
    return mlirc_fn["mlirDiagnosticGetNumNotes", Int](diagnostic)


fn mlirDiagnosticGetNote(
    diagnostic: MlirDiagnostic, position: Int
) -> MlirDiagnostic:
    return mlirc_fn["mlirDiagnosticGetNote", MlirDiagnostic](
        diagnostic, position
    )


fn mlirContextAttachDiagnosticHandler(
    context: MlirContext,
    handler: MlirDiagnosticHandler,
    user_data: ExternalPointer,
    delete_user_data: fn (ExternalPointer) -> None,
) -> MlirDiagnosticHandlerID:
    return mlirc_fn[
        "mlirContextAttachDiagnosticHandler", MlirDiagnosticHandlerID
    ](context, handler, user_data, delete_user_data)


fn mlirContextDetachDiagnosticHandler(
    context: MlirContext,
    handler_id: MlirDiagnosticHandlerID,
) -> None:
    return mlirc_fn["mlirContextDetachDiagnosticHandler", NoneType._mlir_type](
        context, handler_id
    )


fn mlirEmitError(
    location: MlirLocation,
    message: CStringSlice,
) -> None:
    return mlirc_fn["mlirEmitError", NoneType._mlir_type](location, message)
