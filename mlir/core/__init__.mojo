from mlir.ffi import mlirc_fn, ExternalPointer
from sys.ffi import CStringSlice
from format._utils import _WriteBufferStack
from os import abort
from pathlib import Path

comptime DevDoc1 = """
For Developer:
    See https://mlir.llvm.org/docs/Bindings/Python/#ownership-in-the-core-ir
    for more details on ownership semantics.

    - Context owns most things, we don't need to memory manage them.
    - Most things are passed by value, and are actually mutable references with same lifetime as the context.
    - Context Ownership is therefore important that people must be aware of it.
    - while there are some exceptions, like 
        - when objects are created by the user, they are owned by the user until they are passed to the context.
"""


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


fn _static_from_str(string: String) -> StaticString:
    return StaticString(
        ptr=string.unsafe_ptr().unsafe_origin_cast[StaticConstantOrigin](),
        length=len(string),
    )


comptime __TypeOfAllTypes = __mlir_type.`!kgen.type`


@register_passable("trivial")
trait MlirWrapper(Copyable):
    comptime c_type: __TypeOfAllTypes

    fn _mlir_type(self) -> Self.c_type:
        ...


@fieldwise_init("implicit")
struct _InnerList[T: MlirWrapper](Boolable, Sized):
    comptime _list_type = Self.T.c_type
    var _list: List[Self._list_type]

    fn __init__(out self):
        self._list = List[Self._list_type]()

    fn __init__(out self, var args: List[Self.T]):
        self._list = List[Self._list_type](capacity=len(args))
        for arg in args:
            self._list.append(arg._mlir_type())

    fn __init__(out self, var *values: Self.T, __list_literal__: ()):
        var length = len(values)
        self._list = type_of(self._list)(capacity=length)

        @parameter
        fn init_elt(idx: Int, var elt: Self.T):
            (self._list._data + idx).init_pointee_move(elt._mlir_type())

        values^.consume_elements[init_elt]()
        self._list._len = length

    fn list(ref self) -> ref [self._list] List[Self.T.c_type]:
        return self._list

    fn unsafe_ptr(
        self,
    ) -> UnsafePointer[Self._list_type, MutExternalOrigin]:
        return rebind[UnsafePointer[Self._list_type, MutExternalOrigin]](
            self._list.unsafe_ptr().unsafe_origin_cast[MutExternalOrigin]()
        )

    fn __bool__(self) -> Bool:
        return Bool(self._list)

    fn __len__(self) -> Int:
        return len(self._list)
