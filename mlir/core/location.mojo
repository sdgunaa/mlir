from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback, _static_from_str
from mlir.core.attribute import (
    MlirAttribute,
    MlirIdentifier,
    Attribute,
    Identifier,
)
from mlir.core.context import MlirContext, Context
from mlir.core.type import MlirTypeID
from format._utils import _WriteBufferStack


@register_passable("trivial")
struct MlirLocation:
    var ptr: ExternalPointer


fn mlirLocationGetAttribute(location: MlirLocation) -> MlirAttribute:
    return mlirc_fn["mlirLocationGetAttribute", MlirAttribute](location)


fn mlirLocationFromAttribute(attribute: MlirAttribute) -> MlirLocation:
    return mlirc_fn["mlirLocationFromAttribute", MlirLocation](attribute)


fn mlirLocationFileLineColGet(
    context: MlirContext, filename: MlirStringRef, line: UInt32, col: UInt32
) -> MlirLocation:
    return mlirc_fn["mlirLocationFileLineColGet", MlirLocation](
        context, filename, line, col
    )


fn mlirLocationFileLineColRangeGet(
    context: MlirContext,
    filename: MlirStringRef,
    start_line: UInt32,
    start_col: UInt32,
    end_line: UInt32,
    end_col: UInt32,
) -> MlirLocation:
    return mlirc_fn["mlirLocationFileLineColRangeGet", MlirLocation](
        context, filename, start_line, start_col, end_line, end_col
    )


fn mlirLocationFileLineColRangeGetFilename(
    loaction: MlirLocation,
) -> MlirIdentifier:
    return mlirc_fn["mlirLocationFileLineColRangeGetFilename", MlirIdentifier](
        loaction
    )


fn mlirLocationFileLineColRangeGetStartLine(location: MlirLocation) -> Int32:
    return mlirc_fn["mlirLocationFileLineColRangeGetStartLine", Int32](location)


fn mlirLocationFileLineColRangeGetStartColumn(location: MlirLocation) -> Int32:
    return mlirc_fn["mlirLocationFileLineColRangeGetStartColumn", Int32](
        location
    )


fn mlirLocationFileLineColRangeGetEndLine(location: MlirLocation) -> Int32:
    return mlirc_fn["mlirLocationFileLineColRangeGetEndLine", Int32](location)


fn mlirLocationFileLineColRangeGetEndColumn(location: MlirLocation) -> Int32:
    return mlirc_fn["mlirLocationFileLineColRangeGetEndColumn", Int32](location)


fn mlirLocationFileLineColRangeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirLocationFileLineColRangeGetTypeID", MlirTypeID]()


fn mlirLocationIsAFileLineColRange(location: MlirLocation) -> Bool:
    return mlirc_fn["mlirLocationIsAFileLineColRange", Bool](location)


fn mlirLocationCallSiteGet(
    callee: MlirLocation, caller: MlirLocation
) -> MlirLocation:
    return mlirc_fn["mlirLocationCallSiteGet", MlirLocation](callee, caller)


fn mlirLocationCallSiteGetCallee(location: MlirLocation) -> MlirLocation:
    return mlirc_fn["mlirLocationCallSiteGetCallee", MlirLocation](location)


fn mlirLocationCallSiteGetCaller(location: MlirLocation) -> MlirLocation:
    return mlirc_fn["mlirLocationCallSiteGetCaller", MlirLocation](location)


fn mlirLocationCallSiteGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirLocationCallSiteGetTypeID", MlirTypeID]()


fn mlirLocationIsACallSite(location: MlirLocation) -> Bool:
    return mlirc_fn["mlirLocationIsACallSite", Bool](location)


fn mlirLocationFusedGet(
    ctx: MlirContext,
    num_locations: Int,
    locations: UnsafePointer[MlirLocation, MutExternalOrigin],
    metadata: MlirAttribute,
) -> MlirLocation:
    return mlirc_fn["mlirLocationFusedGet", MlirLocation](
        ctx, num_locations, locations, metadata
    )


fn mlirLocationFusedGetNumLocations(location: MlirLocation) -> UInt32:
    return mlirc_fn["mlirLocationFusedGetNumLocations", UInt32](location)


fn mlirLocationFusedGetLocations(
    location: MlirLocation,
) -> UnsafePointer[MlirLocation, MutExternalOrigin]:
    return mlirc_fn[
        "mlirLocationFusedGetLocations",
        UnsafePointer[MlirLocation, MutExternalOrigin],
    ](location)


fn mlirLocationFusedGetMetadata(location: MlirLocation) -> MlirAttribute:
    return mlirc_fn["mlirLocationFusedGetMetadata", MlirAttribute](location)


fn mlirLocationFusedGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirLocationFusedGetTypeID", MlirTypeID]()


fn mlirLocationIsAFused(location: MlirLocation) -> Bool:
    return mlirc_fn["mlirLocationIsAFused", Bool](location)


fn mlirLocationNameGet(
    context: MlirContext, name: MlirStringRef, child_location: MlirLocation
) -> MlirLocation:
    return mlirc_fn["mlirLocationNameGet", MlirLocation](
        context, name, child_location
    )


fn mlirLocationNameGetName(location: MlirLocation) -> MlirIdentifier:
    return mlirc_fn["mlirLocationNameGetName", MlirIdentifier](location)


fn mlirLocationNameGetChildLoc(location: MlirLocation) -> MlirLocation:
    return mlirc_fn["mlirLocationNameGetChildLoc", MlirLocation](location)


fn mlirLocationNameGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirLocationNameGetTypeID", MlirTypeID]()


fn mlirLocationIsAName(location: MlirLocation) -> Bool:
    return mlirc_fn["mlirLocationIsAName", Bool](location)


fn mlirLocationUnknownGet(context: MlirContext) -> MlirLocation:
    return mlirc_fn["mlirLocationUnknownGet", MlirLocation](context)


fn mlirLocationEqual(location1: MlirLocation, location2: MlirLocation) -> Bool:
    return mlirc_fn["mlirLocationEqual", Bool](location1, location2)


fn mlirLocationGetContext(location: MlirLocation) -> MlirContext:
    return mlirc_fn["mlirLocationGetContext", MlirContext](location)


@always_inline("nodebug")
fn mlirLocationIsNull(location: MlirLocation) -> Bool:
    return not Bool(location.ptr)


fn mlirLocationPrint(location: MlirLocation, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirLocationPrint", NoneType._mlir_type](
        location, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


@fieldwise_init("implicit")
@register_passable("trivial")
struct Location(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirLocation
    var _ptr: Self.c_type

    fn __init__(out self, context: Context):
        self._ptr = mlirLocationUnknownGet(context._ptr)

    fn __init__(out self, attribute: Attribute):
        self._ptr = mlirLocationFromAttribute(attribute._ptr)

    fn __init__(
        out self, context: Context, filename: String, line: Int, col: Int
    ):
        self._ptr = mlirLocationFileLineColGet(
            context._ptr, _static_from_str(filename), line, col
        )

    fn __init__(
        out self,
        context: Context,
        filename: String,
        line: Int,
        col: Int,
        end_line: Int,
        end_col: Int,
    ):
        self._ptr = mlirLocationFileLineColRangeGet(
            context._ptr,
            _static_from_str(filename),
            line,
            col,
            end_line,
            end_col,
        )

    fn __init__(
        out self,
        context: Context,
        filename: String,
        child_location: Location,
    ):
        self._ptr = mlirLocationNameGet(
            context._ptr,
            _static_from_str(filename),
            child_location._ptr,
        )

    fn is_name(self) -> Bool:
        return mlirLocationIsAName(self._ptr)

    fn name(self) -> Identifier:
        return Identifier(mlirLocationNameGetName(self._ptr))

    fn child_location(self) -> Location:
        return Location(mlirLocationNameGetChildLoc(self._ptr))

    @staticmethod
    fn call_site(callee: Self, caller: Self) -> Self:
        return Self(mlirLocationCallSiteGet(callee._ptr, caller._ptr))

    @staticmethod
    fn fused(
        context: Context, var locations: List[MlirLocation], metadata: Attribute
    ) -> Self:
        return Self(
            mlirLocationFusedGet(
                context._ptr,
                locations._len,
                locations.steal_data(),
                metadata._ptr,
            )
        )

    @staticmethod
    fn unknown(context: Context) -> Self:
        return Self(mlirLocationUnknownGet(context._ptr))

    fn __eq__(self, other: Self) -> Bool:
        return mlirLocationEqual(self._ptr, other._ptr)

    fn context(self) -> Context:
        return Context(mlirLocationGetContext(self._ptr))

    fn attribute(self) -> Attribute:
        return Attribute(mlirLocationGetAttribute(self._ptr))

    fn file_line_col_range_get_filename(self) -> Identifier:
        return Identifier(mlirLocationFileLineColRangeGetFilename(self._ptr))

    fn write_to(self, mut writer: Some[Writer]):
        mlirLocationPrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)

    fn __bool__(self) -> Bool:
        return not mlirLocationIsNull(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr
