from mlir.ffi import mlirc_fn, ExternalPointer
from sys.ffi import CStringSlice
from format._utils import _WriteBufferStack


comptime MlirStringRef = StaticString


fn mlirStringRefCreateFromCString(str: CStringSlice) -> MlirStringRef:
    """Constructs a string reference from a null-terminated C string. Prefer
    mlirStringRefCreate if the length of the string is known."""
    return mlirc_fn["mlirStringRefCreateFromCString", MlirStringRef](str)


fn mlirStringRefEqual(string: MlirStringRef, other: MlirStringRef) -> Bool:
    """Returns true if two string references are equal, false otherwise."""
    return mlirc_fn["mlirStringRefEqual", Bool](string, other)


fn mlirStringCallback[
    writer: Writer
](string: MlirStringRef, user_data: ExternalPointer):
    """Callback function for printing strings."""
    var buffer = user_data.bitcast[
        _WriteBufferStack[origin=MutAnyOrigin, W=writer]
    ]()
    buffer[].write_string(string)
