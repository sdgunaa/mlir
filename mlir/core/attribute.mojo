from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.context import MlirContext
from mlir.core.type import MlirType, MlirTypeID
from mlir.core.dialect import MlirDialect


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
