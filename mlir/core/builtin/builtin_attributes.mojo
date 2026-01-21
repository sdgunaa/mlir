from mlir.ffi import mlirc_fn
from mlir.core.affine.affine_map import MlirAffineMap
from mlir.core.affine.integer_set import MlirIntegerSet
from mlir.core.type import MlirType, MlirTypeID
from mlir.core.attribute import MlirAttribute, MlirNamedAttribute
from mlir.core.context import MlirContext
from mlir.core.location import MlirLocation
from mlir.core import MlirStringRef
from sys.ffi import CStringSlice

comptime ExternalPointer[Type: AnyType] = UnsafePointer[Type, MutExternalOrigin]


fn mlirAttributeGetNull() -> MlirAttribute:
    return mlirc_fn["mlirAttributeGetNull", MlirAttribute]()


# ===----------------------------------------------------------------------===//
#  Location attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsALocation(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsALocation", Bool](attribute)


# ===----------------------------------------------------------------------===//
#  Affine map attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAAffineMap(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAAffineMap", Bool](attribute)


fn mlirAffineMapAttrGet(affine_map: MlirAffineMap) -> MlirAttribute:
    return mlirc_fn["mlirAffineMapAttrGet", MlirAttribute](affine_map)


fn mlirAffineMapAttrGetValue(attribute: MlirAttribute) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapAttrGetValue", MlirAffineMap](attribute)


fn mlirAffineMapAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirAffineMapAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Array attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAArray(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAArray", Bool](attribute)


fn mlirArrayAttrGet(
    context: MlirContext,
    num_elements: Int,
    elements: UnsafePointer[MlirAttribute, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirArrayAttrGet", MlirAttribute](
        context, num_elements, elements
    )


fn mlirArrayAttrGetNumElements(attribute: MlirAttribute) -> Int:
    return mlirc_fn["mlirArrayAttrGetNumElements", Int](attribute)


fn mlirArrayAttrGetElement(
    attribute: MlirAttribute, position: Int
) -> MlirAttribute:
    return mlirc_fn["mlirArrayAttrGetElement", MlirAttribute](
        attribute, position
    )


fn mlirArrayAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirArrayAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Dictionary attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsADictionary(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADictionary", Bool](attribute)


fn mlirDictionaryAttrGet(
    context: MlirContext,
    num_elements: Int,
    elements: UnsafePointer[MlirNamedAttribute, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDictionaryAttrGet", MlirAttribute](
        context, num_elements, elements
    )


fn mlirDictionaryAttrGetNumElements(attribute: MlirAttribute) -> Int:
    return mlirc_fn["mlirDictionaryAttrGetNumElements", Int](attribute)


fn mlirDictionaryAttrGetElement(
    attribute: MlirAttribute, position: Int
) -> MlirNamedAttribute:
    return mlirc_fn["mlirDictionaryAttrGetElement", MlirNamedAttribute](
        attribute, position
    )


fn mlirDictionaryAttrGetElementByName(
    attribute: MlirAttribute, name: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirDictionaryAttrGetElementByName", MlirAttribute](
        attribute, name
    )


fn mlirDictionaryAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirDictionaryAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Floating point attribute.
# ===----------------------------------------------------------------------===//

#  TODO: add support for APFloat and APInt to LLVM IR C API, then expose the
#  relevant functions here.


fn mlirAttributeIsAFloat(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAFloat", Bool](attribute)


fn mlirFloatAttrDoubleGet(
    context: MlirContext, type: MlirType, value: Float64
) -> MlirAttribute:
    return mlirc_fn["mlirFloatAttrDoubleGet", MlirAttribute](
        context, type, value
    )


fn mlirFloatAttrDoubleGetChecked(
    location: MlirLocation, type: MlirType, value: Float64
) -> MlirAttribute:
    return mlirc_fn["mlirFloatAttrDoubleGetChecked", MlirAttribute](
        location, type, value
    )


fn mlirFloatAttrGetValueDouble(attribute: MlirAttribute) -> Float64:
    return mlirc_fn["mlirFloatAttrGetValueDouble", Float64](attribute)


fn mlirFloatAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloatAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Integer attribute.
# ===----------------------------------------------------------------------===//

#  TODO: add support for APFloat and APInt to LLVM IR C API, then expose the
#  relevant functions here.


fn mlirAttributeIsAInteger(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAInteger", Bool](attribute)


fn mlirIntegerAttrGet(type: MlirType, value: Int64) -> MlirAttribute:
    return mlirc_fn["mlirIntegerAttrGet", MlirAttribute](type, value)


fn mlirIntegerAttrGetValueInt(attribute: MlirAttribute) -> Int64:
    return mlirc_fn["mlirIntegerAttrGetValueInt", Int64](attribute)


fn mlirIntegerAttrGetValueSInt(attribute: MlirAttribute) -> Int64:
    return mlirc_fn["mlirIntegerAttrGetValueSInt", Int64](attribute)


fn mlirIntegerAttrGetValueUInt(attribute: MlirAttribute) -> UInt64:
    return mlirc_fn["mlirIntegerAttrGetValueUInt", UInt64](attribute)


fn mlirIntegerAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirIntegerAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Bool attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsABool(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsABool", Bool](attribute)


fn mlirBoolAttrGet(context: MlirContext, value: Int16) -> MlirAttribute:
    return mlirc_fn["mlirBoolAttrGet", MlirAttribute](context, value)


fn mlirBoolAttrGetValue(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirBoolAttrGetValue", Bool](attribute)


# ===----------------------------------------------------------------------===//
#  Integer set attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAIntegerSet(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAIntegerSet", Bool](attribute)


fn mlirIntegerSetAttrGet(integer_set: MlirIntegerSet) -> MlirAttribute:
    return mlirc_fn["mlirIntegerSetAttrGet", MlirAttribute](integer_set)


fn mlirIntegerSetAttrGetValue(attribute: MlirAttribute) -> MlirIntegerSet:
    return mlirc_fn["mlirIntegerSetAttrGetValue", MlirIntegerSet](attribute)


fn mlirIntegerSetAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirIntegerSetAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Opaque attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAOpaque(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAOpaque", Bool](attribute)


fn mlirOpaqueAttrGet(
    context: MlirContext,
    dialect_namespace: MlirStringRef,
    data_length: Int,
    data: CStringSlice,
    type: MlirType,
) -> MlirAttribute:
    return mlirc_fn["mlirOpaqueAttrGet", MlirAttribute](
        context, dialect_namespace, data_length, data, type
    )


fn mlirOpaqueAttrGetDialectNamespace(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirOpaqueAttrGetDialectNamespace", MlirStringRef](
        attribute
    )


fn mlirOpaqueAttrGetData(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirOpaqueAttrGetData", MlirStringRef](attribute)


fn mlirOpaqueAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirOpaqueAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  String attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAString(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAString", Bool](attribute)


fn mlirStringAttrGet(
    context: MlirContext, string: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirStringAttrGet", MlirAttribute](context, string)


fn mlirStringAttrTypedGet(
    type: MlirType, string: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirStringAttrTypedGet", MlirAttribute](type, string)


fn mlirStringAttrGetValue(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirStringAttrGetValue", MlirStringRef](attribute)


fn mlirStringAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirStringAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  SymbolRef attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsASymbolRef(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsASymbolRef", Bool](attribute)


fn mlirSymbolRefAttrGet(
    context: MlirContext,
    symbol: MlirStringRef,
    num_references: Int,
    references: UnsafePointer[MlirAttribute, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirSymbolRefAttrGet", MlirAttribute](
        context, symbol, num_references, references
    )


fn mlirSymbolRefAttrGetRootReference(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirSymbolRefAttrGetRootReference", MlirStringRef](
        attribute
    )


fn mlirSymbolRefAttrGetLeafReference(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirSymbolRefAttrGetLeafReference", MlirStringRef](
        attribute
    )


fn mlirSymbolRefAttrGetNumNestedReferences(attribute: MlirAttribute) -> Int:
    return mlirc_fn["mlirSymbolRefAttrGetNumNestedReferences", Int](attribute)


fn mlirSymbolRefAttrGetNestedReference(
    attribute: MlirAttribute, position: Int
) -> MlirAttribute:
    return mlirc_fn["mlirSymbolRefAttrGetNestedReference", MlirAttribute](
        attribute, position
    )


fn mlirSymbolRefAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirSymbolRefAttrGetTypeID", MlirTypeID]()


fn mlirDisctinctAttrCreate(
    referenced_attribute: MlirAttribute,
) -> MlirAttribute:
    return mlirc_fn["mlirDisctinctAttrCreate", MlirAttribute](
        referenced_attribute
    )


# ===----------------------------------------------------------------------===//
#  Flat SymbolRef attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAFlatSymbolRef(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAFlatSymbolRef", Bool](attribute)


fn mlirFlatSymbolRefAttrGet(
    context: MlirContext, symbol: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirFlatSymbolRefAttrGet", MlirAttribute](context, symbol)


fn mlirFlatSymbolRefAttrGetValue(attribute: MlirAttribute) -> MlirStringRef:
    return mlirc_fn["mlirFlatSymbolRefAttrGetValue", MlirStringRef](attribute)


# ===----------------------------------------------------------------------===//
#  Type attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAType(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAType", Bool](attribute)


fn mlirTypeAttrGet(type: MlirType) -> MlirAttribute:
    return mlirc_fn["mlirTypeAttrGet", MlirAttribute](type)


fn mlirTypeAttrGetValue(attribute: MlirAttribute) -> MlirType:
    return mlirc_fn["mlirTypeAttrGetValue", MlirType](attribute)


fn mlirTypeAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirTypeAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Unit attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAUnit(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAUnit", Bool](attribute)


fn mlirUnitAttrGet(context: MlirContext) -> MlirAttribute:
    return mlirc_fn["mlirUnitAttrGet", MlirAttribute](context)


fn mlirUnitAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirUnitAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Elements attributes.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAElements", Bool](attribute)


fn mlirElementsAttrGetValue(
    attribute: MlirAttribute,
    rank: Int,
    idxs: UnsafePointer[UInt64, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirElementsAttrGetValue", MlirAttribute](
        attribute, rank, idxs
    )


fn mlirElementsAttrIsValidIndex(
    attribute: MlirAttribute,
    rank: Int,
    idxs: UnsafePointer[UInt64, MutExternalOrigin],
) -> Bool:
    return mlirc_fn["mlirElementsAttrIsValidIndex", Bool](attribute, rank, idxs)


fn mlirElementsAttrGetNumElements(attribute: MlirAttribute) -> Int64:
    return mlirc_fn["mlirElementsAttrGetNumElements", Int64](attribute)


# ===----------------------------------------------------------------------===//
#  Dense array attribute.
# ===----------------------------------------------------------------------===//


fn mlirDenseArrayAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirDenseArrayAttrGetTypeID", MlirTypeID]()


fn mlirAttributeIsADenseBoolArray(attribute: MlirAttribute) -> Bool:
    """Checks whether the given attribute is a dense array attribute."""
    return mlirc_fn["mlirAttributeIsADenseBoolArray", Bool](attribute)


fn mlirAttributeIsADenseI8Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseI8Array", Bool](attribute)


fn mlirAttributeIsADenseI16Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseI16Array", Bool](attribute)


fn mlirAttributeIsADenseI32Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseI32Array", Bool](attribute)


fn mlirAttributeIsADenseI64Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseI64Array", Bool](attribute)


fn mlirAttributeIsADenseF32Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseF32Array", Bool](attribute)


fn mlirAttributeIsADenseF64Array(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseF64Array", Bool](attribute)


fn mlirDenseBoolArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Int16, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseBoolArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseI8ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Int8, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseI8ArrayGet", MlirAttribute](context, size, values)


fn mlirDenseI16ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Int16, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseI16ArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseI32ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Int32, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseI32ArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseI64ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Int64, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseI64ArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseF32ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Float32, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseF32ArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseF64ArrayGet(
    context: MlirContext,
    size: Int,
    values: UnsafePointer[Float64, MutExternalOrigin],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseF64ArrayGet", MlirAttribute](
        context, size, values
    )


fn mlirDenseArrayGetNumElements(attribute: MlirAttribute) -> Int:
    return mlirc_fn["mlirDenseArrayGetNumElements", Int](attribute)


fn mlirDenseBoolArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Bool:
    return mlirc_fn["mlirDenseBoolArrayGetElement", Bool](attribute, position)


fn mlirDenseI8ArrayGetElement(attribute: MlirAttribute, position: Int) -> Int8:
    return mlirc_fn["mlirDenseI8ArrayGetElement", Int8](attribute, position)


fn mlirDenseI16ArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Int16:
    return mlirc_fn["mlirDenseI16ArrayGetElement", Int16](attribute, position)


fn mlirDenseI32ArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Int32:
    return mlirc_fn["mlirDenseI32ArrayGetElement", Int32](attribute, position)


fn mlirDenseI64ArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Int64:
    return mlirc_fn["mlirDenseI64ArrayGetElement", Int64](attribute, position)


fn mlirDenseF32ArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Float32:
    return mlirc_fn["mlirDenseF32ArrayGetElement", Float32](attribute, position)


fn mlirDenseF64ArrayGetElement(
    attribute: MlirAttribute, position: Int
) -> Float64:
    return mlirc_fn["mlirDenseF64ArrayGetElement", Float64](attribute, position)


# ===----------------------------------------------------------------------===//
#  Dense elements attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsADenseElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseElements", Bool](attribute)


fn mlirAttributeIsADenseIntElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseIntElements", Bool](attribute)


fn mlirAttributeIsADenseFPElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseFPElements", Bool](attribute)


fn mlirDenseIntOrFPElementsAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirDenseIntOrFPElementsAttrGetTypeID", MlirTypeID]()


fn mlirDenseElementsAttrGet(
    shaped_type: MlirType,
    num_elements: Int,
    elements: ExternalPointer[MlirAttribute],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrGet", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrRawBufferGet(
    shaped_type: MlirType,
    raw_buffer_size: Int,
    raw_buffer: ExternalPointer,
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrRawBufferGet", MlirAttribute](
        shaped_type, raw_buffer_size, raw_buffer
    )


fn mlirDenseElementsAttrSplatGet(
    shaped_type: MlirType, element: MlirAttribute
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrSplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrBoolSplatGet(
    shaped_type: MlirType, element: Bool
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrBoolSplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrUInt8SplatGet(
    shaped_type: MlirType, element: UInt8
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt8SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrInt8SplatGet(
    shaped_type: MlirType, element: Int8
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt8SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrUInt32SplatGet(
    shaped_type: MlirType, element: UInt32
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt32SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrInt32SplatGet(
    shaped_type: MlirType, element: Int32
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt32SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrUInt64SplatGet(
    shaped_type: MlirType, element: UInt64
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt64SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrInt64SplatGet(
    shaped_type: MlirType, element: Int64
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt64SplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrFloatSplatGet(
    shaped_type: MlirType, element: Float32
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrFloatSplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrDoubleSplatGet(
    shaped_type: MlirType, element: Float64
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrDoubleSplatGet", MlirAttribute](
        shaped_type, element
    )


fn mlirDenseElementsAttrBoolGet(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Int16]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrBoolGet", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrUInt8Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt8]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt8Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrInt8Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Int8]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt8Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrUInt16Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt16]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt16Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrInt16Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Int16]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt16Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrUInt32Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt32]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt32Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrInt32Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Int32]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt32Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrUInt64Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt64]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrUInt64Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrInt64Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Int64]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrInt64Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrFloatGet(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Float32]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrFloatGet", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrDoubleGet(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[Float64]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrDoubleGet", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrBFloat16Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt16]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrBFloat16Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrFloat16Get(
    shaped_type: MlirType, num_elements: Int, elements: ExternalPointer[UInt16]
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrFloat16Get", MlirAttribute](
        shaped_type, num_elements, elements
    )


fn mlirDenseElementsAttrStringGet(
    shaped_type: MlirType,
    num_elements: Int,
    strings: ExternalPointer[MlirStringRef],
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrStringGet", MlirAttribute](
        shaped_type, num_elements, strings
    )


fn mlirDenseElementsAttrReshapeGet(
    attribute: MlirAttribute, shaped_type: MlirType
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrReshapeGet", MlirAttribute](
        attribute, shaped_type
    )


fn mlirDenseElementsAttrIsSplat(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirDenseElementsAttrIsSplat", Bool](attribute)


fn mlirDenseElementsAttrGetSplatValue(
    attribute: MlirAttribute,
) -> MlirAttribute:
    return mlirc_fn["mlirDenseElementsAttrGetSplatValue", MlirAttribute](
        attribute
    )


fn mlirDenseElementsAttrGetBoolSplatValue(attribute: MlirAttribute) -> Int16:
    return mlirc_fn["mlirDenseElementsAttrGetBoolSplatValue", Int16](attribute)


fn mlirDenseElementsAttrGetInt8SplatValue(attribute: MlirAttribute) -> Int8:
    return mlirc_fn["mlirDenseElementsAttrGetInt8SplatValue", Int8](attribute)


fn mlirDenseElementsAttrGetUInt8SplatValue(attribute: MlirAttribute) -> UInt8:
    return mlirc_fn["mlirDenseElementsAttrGetUInt8SplatValue", UInt8](attribute)


fn mlirDenseElementsAttrGetInt32SplatValue(attribute: MlirAttribute) -> Int32:
    return mlirc_fn["mlirDenseElementsAttrGetInt32SplatValue", Int32](attribute)


fn mlirDenseElementsAttrGetUInt32SplatValue(attribute: MlirAttribute) -> UInt32:
    return mlirc_fn["mlirDenseElementsAttrGetUInt32SplatValue", UInt32](
        attribute
    )


fn mlirDenseElementsAttrGetInt64SplatValue(attribute: MlirAttribute) -> Int64:
    return mlirc_fn["mlirDenseElementsAttrGetInt64SplatValue", Int64](attribute)


fn mlirDenseElementsAttrGetUInt64SplatValue(attribute: MlirAttribute) -> UInt64:
    return mlirc_fn["mlirDenseElementsAttrGetUInt64SplatValue", UInt64](
        attribute
    )


fn mlirDenseElementsAttrGetFloatSplatValue(attribute: MlirAttribute) -> Float32:
    return mlirc_fn["mlirDenseElementsAttrGetFloatSplatValue", Float32](
        attribute
    )


fn mlirDenseElementsAttrGetDoubleSplatValue(
    attribute: MlirAttribute,
) -> Float64:
    return mlirc_fn["mlirDenseElementsAttrGetDoubleSplatValue", Float64](
        attribute
    )


fn mlirDenseElementsAttrGetStringSplatValue(
    attribute: MlirAttribute,
) -> MlirStringRef:
    return mlirc_fn["mlirDenseElementsAttrGetStringSplatValue", MlirStringRef](
        attribute
    )


fn mlirDenseElementsAttrGetBoolValue(
    attribute: MlirAttribute, position: Int
) -> Bool:
    return mlirc_fn["mlirDenseElementsAttrGetBoolValue", Bool](
        attribute, position
    )


fn mlirDenseElementsAttrGetInt8Value(
    attribute: MlirAttribute, position: Int
) -> Int8:
    return mlirc_fn["mlirDenseElementsAttrGetInt8Value", Int8](
        attribute, position
    )


fn mlirDenseElementsAttrGetUInt8Value(
    attribute: MlirAttribute, position: Int
) -> UInt8:
    return mlirc_fn["mlirDenseElementsAttrGetUInt8Value", UInt8](
        attribute, position
    )


fn mlirDenseElementsAttrGetInt16Value(
    attribute: MlirAttribute, position: Int
) -> Int16:
    return mlirc_fn["mlirDenseElementsAttrGetInt16Value", Int16](
        attribute, position
    )


fn mlirDenseElementsAttrGetUInt16Value(
    attribute: MlirAttribute, position: Int
) -> UInt16:
    return mlirc_fn["mlirDenseElementsAttrGetUInt16Value", UInt16](
        attribute, position
    )


fn mlirDenseElementsAttrGetInt32Value(
    attribute: MlirAttribute, position: Int
) -> Int32:
    return mlirc_fn["mlirDenseElementsAttrGetInt32Value", Int32](
        attribute, position
    )


fn mlirDenseElementsAttrGetUInt32Value(
    attribute: MlirAttribute, position: Int
) -> UInt32:
    return mlirc_fn["mlirDenseElementsAttrGetUInt32Value", UInt32](
        attribute, position
    )


fn mlirDenseElementsAttrGetInt64Value(
    attribute: MlirAttribute, position: Int
) -> Int64:
    return mlirc_fn["mlirDenseElementsAttrGetInt64Value", Int64](
        attribute, position
    )


fn mlirDenseElementsAttrGetUInt64Value(
    attribute: MlirAttribute, position: Int
) -> UInt64:
    return mlirc_fn["mlirDenseElementsAttrGetUInt64Value", UInt64](
        attribute, position
    )


fn mlirDenseElementsAttrGetIndexValue(
    attribute: MlirAttribute, position: Int
) -> Int:
    return mlirc_fn["mlirDenseElementsAttrGetIndexValue", Int](
        attribute, position
    )


fn mlirDenseElementsAttrGetFloatValue(
    attribute: MlirAttribute, position: Int
) -> Float32:
    return mlirc_fn["mlirDenseElementsAttrGetFloatValue", Float32](
        attribute, position
    )


fn mlirDenseElementsAttrGetDoubleValue(
    attribute: MlirAttribute, position: Int
) -> Float64:
    return mlirc_fn["mlirDenseElementsAttrGetDoubleValue", Float64](
        attribute, position
    )


fn mlirDenseElementsAttrGetStringValue(
    attribute: MlirAttribute, position: Int
) -> MlirStringRef:
    return mlirc_fn["mlirDenseElementsAttrGetStringValue", MlirStringRef](
        attribute, position
    )


fn mlirDenseElementsAttrGetRawData(
    attribute: MlirAttribute,
) -> ExternalPointer[NoneType]:
    return mlirc_fn[
        "mlirDenseElementsAttrGetRawData", ExternalPointer[NoneType]
    ](attribute)


# ===----------------------------------------------------------------------===//
#  Resource blob attributes.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsADenseResourceElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsADenseResourceElements", Bool](attribute)


fn mlirUnmanagedDenseResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    data: ExternalPointer[NoneType],
    data_length: Int,
    data_alignment: Int,
    data_is_mutable: Bool,
    deleter: fn (
        ExternalPointer[NoneType], ExternalPointer[NoneType], Int32, Int32
    ) -> None,
    user_data: ExternalPointer[NoneType],
) -> MlirAttribute:
    return mlirc_fn["mlirUnmanagedDenseResourceElementsAttrGet", MlirAttribute](
        shaped_type,
        name,
        data,
        data_length,
        data_alignment,
        data_is_mutable,
        deleter,
        user_data,
    )


fn mlirUnmanagedDenseBoolResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Int16],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseBoolResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseUInt8ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[UInt8],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseUInt8ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseInt8ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Int8],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseInt8ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseUInt16ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[UInt16],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseUInt16ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseInt16ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Int16],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseInt16ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseUInt32ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[UInt32],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseUInt32ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseInt32ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Int32],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseInt32ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseUInt64ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[UInt64],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseUInt64ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseInt64ResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Int64],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseInt64ResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseFloatResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Float32],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseFloatResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirUnmanagedDenseDoubleResourceElementsAttrGet(
    shaped_type: MlirType,
    name: MlirStringRef,
    num_elements: Int,
    elements: ExternalPointer[Float64],
) -> MlirAttribute:
    return mlirc_fn[
        "mlirUnmanagedDenseDoubleResourceElementsAttrGet", MlirAttribute
    ](shaped_type, name, num_elements, elements)


fn mlirDenseBoolResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Bool:
    return mlirc_fn["mlirDenseBoolResourceElementsAttrGetValue", Bool](
        attribute, position
    )


fn mlirDenseInt8ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Int8:
    return mlirc_fn["mlirDenseInt8ResourceElementsAttrGetValue", Int8](
        attribute, position
    )


fn mlirDenseUInt8ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> UInt8:
    return mlirc_fn["mlirDenseUInt8ResourceElementsAttrGetValue", UInt8](
        attribute, position
    )


fn mlirDenseInt16ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Int16:
    return mlirc_fn["mlirDenseInt16ResourceElementsAttrGetValue", Int16](
        attribute, position
    )


fn mlirDenseUInt16ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> UInt16:
    return mlirc_fn["mlirDenseUInt16ResourceElementsAttrGetValue", UInt16](
        attribute, position
    )


fn mlirDenseInt32ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Int32:
    return mlirc_fn["mlirDenseInt32ResourceElementsAttrGetValue", Int32](
        attribute, position
    )


fn mlirDenseUInt32ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> UInt32:
    return mlirc_fn["mlirDenseUInt32ResourceElementsAttrGetValue", UInt32](
        attribute, position
    )


fn mlirDenseInt64ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Int64:
    return mlirc_fn["mlirDenseInt64ResourceElementsAttrGetValue", Int64](
        attribute, position
    )


fn mlirDenseUInt64ResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> UInt64:
    return mlirc_fn["mlirDenseUInt64ResourceElementsAttrGetValue", UInt64](
        attribute, position
    )


fn mlirDenseFloatResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Float32:
    return mlirc_fn["mlirDenseFloatResourceElementsAttrGetValue", Float32](
        attribute, position
    )


fn mlirDenseDoubleResourceElementsAttrGetValue(
    attribute: MlirAttribute, position: Int
) -> Float64:
    return mlirc_fn["mlirDenseDoubleResourceElementsAttrGetValue", Float64](
        attribute, position
    )


# ===----------------------------------------------------------------------===//
#  Sparse elements attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsASparseElements(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsASparseElements", Bool](attribute)


fn mlirSparseElementsAttribute(
    shaped_type: MlirType,
    dense_indices: MlirAttribute,
    dense_values: MlirAttribute,
) -> MlirAttribute:
    return mlirc_fn["mlirSparseElementsAttribute", MlirAttribute](
        shaped_type, dense_indices, dense_values
    )


fn mlirSparseElementsAttrGetIndices(attribute: MlirAttribute) -> MlirAttribute:
    return mlirc_fn["mlirSparseElementsAttrGetIndices", MlirAttribute](
        attribute
    )


fn mlirSparseElementsAttrGetValues(attribute: MlirAttribute) -> MlirAttribute:
    return mlirc_fn["mlirSparseElementsAttrGetValues", MlirAttribute](attribute)


fn mlirSparseElementsAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirSparseElementsAttrGetTypeID", MlirTypeID]()


# ===----------------------------------------------------------------------===//
#  Strided layout attribute.
# ===----------------------------------------------------------------------===//


fn mlirAttributeIsAStridedLayout(attribute: MlirAttribute) -> Bool:
    return mlirc_fn["mlirAttributeIsAStridedLayout", Bool](attribute)


fn mlirStridedLayoutAttrGet(
    context: MlirContext,
    offset: Int64,
    num_strides: Int,
    strides: ExternalPointer[Int64],
) -> MlirAttribute:
    return mlirc_fn["mlirStridedLayoutAttrGet", MlirAttribute](
        context, offset, num_strides, strides
    )


fn mlirStridedLayoutAttrGetOffset(attribute: MlirAttribute) -> Int64:
    return mlirc_fn["mlirStridedLayoutAttrGetOffset", Int64](attribute)


fn mlirStridedLayoutAttrGetNumStrides(attribute: MlirAttribute) -> Int:
    return mlirc_fn["mlirStridedLayoutAttrGetNumStrides", Int](attribute)


fn mlirStridedLayoutAttrGetStride(
    attribute: MlirAttribute, position: Int
) -> Int64:
    return mlirc_fn["mlirStridedLayoutAttrGetStride", Int64](
        attribute, position
    )


fn mlirStridedLayoutAttrGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirStridedLayoutAttrGetTypeID", MlirTypeID]()
