from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback, _static_from_str
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.context import MlirContext, Context
from mlir.core.type import MlirType, MlirTypeID, Type
from mlir.core.dialect import MlirDialect, Dialect


@register_passable("trivial")
struct MlirNamedAttribute:
    var name: MlirIdentifier
    var attribute: MlirAttribute


@register_passable("trivial")
struct MlirIdentifier:
    var ptr: ExternalPointer


fn mlirIdentifierGet(
    context: MlirContext, string: MlirStringRef
) -> MlirIdentifier:
    return mlirc_fn["mlirIdentifierGet", MlirIdentifier](context, string)


fn mlirIdentifierGetContext(identifier: MlirIdentifier) -> MlirContext:
    return mlirc_fn["mlirIdentifierGetContext", MlirContext](identifier)


fn mlirIdentifierEqual(
    identifier1: MlirIdentifier, identifier2: MlirIdentifier
) -> Bool:
    return mlirc_fn["mlirIdentifierEqual", Bool](identifier1, identifier2)


fn mlirIdentifierStr(identifier: MlirIdentifier) -> MlirStringRef:
    return mlirc_fn["mlirIdentifierStr", MlirStringRef](identifier)


@register_passable("trivial")
struct MlirAttribute:
    var ptr: ExternalPointer


fn mlirAttributeParseGet(
    context: MlirContext, attr_str: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirAttributeParseGet", MlirAttribute](context, attr_str)


fn mlirAttributeGetContext(attribute: MlirAttribute) -> MlirContext:
    return mlirc_fn["mlirAttributeGetContext", MlirContext](attribute)


fn mlirAttributeGetType(attribute: MlirAttribute) -> MlirType:
    return mlirc_fn["mlirAttributeGetType", MlirType](attribute)


fn mlirAttributeGetTypeID(attribute: MlirAttribute) -> MlirTypeID:
    return mlirc_fn["mlirAttributeGetTypeID", MlirTypeID](attribute)


fn mlirAttributeGetDialect(attribute: MlirAttribute) -> MlirDialect:
    return mlirc_fn["mlirAttributeGetDialect", MlirDialect](attribute)


@always_inline("nodebug")
fn mlirAttributeIsNull(attribute: MlirAttribute) -> Bool:
    return not Bool(attribute.ptr)


fn mlirAttributeEqual(attribute: MlirAttribute, other: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeEqual", Bool](attribute, other)


fn mlirAttributePrint(attribute: MlirAttribute, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirAttributePrint", NoneType._mlir_type](
        attribute, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirAttributeDump(attribute: MlirAttribute):
    mlirc_fn["mlirAttributeDump", NoneType._mlir_type](attribute)


fn mlirNamedAttributeGet(
    name: MlirIdentifier, attribute: MlirAttribute
) -> MlirNamedAttribute:
    return mlirc_fn["mlirNamedAttributeGet", MlirNamedAttribute](
        name, attribute
    )


@fieldwise_init("implicit")
@register_passable("trivial")
struct Identifier(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirIdentifier
    var _ptr: Self.c_type

    fn __init__(out self, context: Context, identifier: String):
        self._ptr = mlirIdentifierGet(
            context._ptr, _static_from_str(identifier)
        )

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(mlirIdentifierStr(self._ptr))

    fn __str__(self) -> String:
        return String.write(self)


@fieldwise_init("implicit")
@register_passable("trivial")
struct Attribute(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirAttribute
    var _ptr: Self.c_type

    fn __init__(out self, context: Context, attribute: String):
        self = Self.parse(context, attribute)

    fn context(self) -> Context:
        return mlirAttributeGetContext(self._ptr)

    fn type(self) -> Type:
        return mlirAttributeGetType(self._ptr)

    fn dialect(self) -> Dialect:
        return mlirAttributeGetDialect(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr

    fn write_to(self, mut writer: Some[Writer]):
        mlirAttributePrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)

    @staticmethod
    fn parse(context: Context, attribute_string: String) -> Self:
        return mlirAttributeParseGet(
            context._ptr, _static_from_str(attribute_string)
        )


@fieldwise_init
@register_passable("trivial")
struct NamedAttribute(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirNamedAttribute
    var _name: Identifier
    var _attribute: Attribute

    fn __init__(out self, named_attribute: MlirNamedAttribute):
        self._name = Identifier(named_attribute.name)
        self._attribute = Attribute(named_attribute.attribute)

    fn name(self) -> Identifier:
        return self._name

    fn attribute(self) -> Attribute:
        return self._attribute

    fn _mlir_type(self) -> Self.c_type:
        return mlirNamedAttributeGet(self._name._ptr, self._attribute._ptr)

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.name())
        writer.write(":")
        writer.write(self.attribute())

    fn __str__(self) -> String:
        return String.write(self)
