from mlir.ffi import mlirc_fn
from mlir.core.affine.affine_map import MlirAffineMap
from mlir.core.type import MlirType, MlirTypeID
from mlir.core.attribute import MlirAttribute
from mlir.core.context import MlirContext
from mlir.core.location import MlirLocation
from mlir.core.walk import MlirLogicalResult
from mlir.core import MlirStringRef

comptime ExternalPointer[Type: AnyType] = UnsafePointer[Type, MutExternalOrigin]

# ===----------------------------------------------------------------------===
#  Integer types.
# ===----------------------------------------------------------------------===


fn mlirIntegerTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirIntegerTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAInteger(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAInteger", Bool](type)


fn mlirIntegerTypeGet(context: MlirContext, bitwidth: Int) -> MlirType:
    return mlirc_fn["mlirIntegerTypeGet", MlirType](context, bitwidth)


fn mlirIntegerTypeSignedGet(context: MlirContext, bitwidth: Int) -> MlirType:
    return mlirc_fn["mlirIntegerTypeSignedGet", MlirType](context, bitwidth)


fn mlirIntegerTypeUnsignedGet(context: MlirContext, bitwidth: Int) -> MlirType:
    return mlirc_fn["mlirIntegerTypeUnsignedGet", MlirType](context, bitwidth)


fn mlirIntegerTypeGetWidth(type: MlirType) -> Int:
    return mlirc_fn["mlirIntegerTypeGetWidth", Int](type)


fn mlirIntegerTypeIsSignless(type: MlirType) -> Bool:
    return mlirc_fn["mlirIntegerTypeIsSignless", Bool](type)


fn mlirIntegerTypeIsSigned(type: MlirType) -> Bool:
    return mlirc_fn["mlirIntegerTypeIsSigned", Bool](type)


fn mlirIntegerTypeIsUnsigned(type: MlirType) -> Bool:
    return mlirc_fn["mlirIntegerTypeIsUnsigned", Bool](type)


# ===----------------------------------------------------------------------===
#  Index type.
# ===----------------------------------------------------------------------===


fn mlirIndexTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirIndexTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAIndex(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAIndex", Bool](type)


fn mlirIndexTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirIndexTypeGet", MlirType](context)


# ===----------------------------------------------------------------------===
#  Floating-point types.
# ===----------------------------------------------------------------------===


fn mlirTypeIsAFloat(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat", Bool](type)


fn mlirFloatTypeGetWidth(type: MlirType) -> Int:
    return mlirc_fn["mlirFloatTypeGetWidth", Int](type)


fn mlirFloat4E2M1FNTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat4E2M1FNTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat4E2M1FN(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat4E2M1FN", Bool](type)


fn mlirFloat4E2M1FNTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat4E2M1FNTypeGet", MlirType](context)


fn mlirFloat6E2M3FNTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat6E2M3FNTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat6E2M3FN(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat6E2M3FN", Bool](type)


fn mlirFloat6E2M3FNTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat6E2M3FNTypeGet", MlirType](context)


fn mlirFloat6E3M2FNTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat6E3M2FNTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat6E3M2FN(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat6E3M2FN", Bool](type)


fn mlirFloat6E3M2FNTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat6E3M2FNTypeGet", MlirType](context)


fn mlirFloat8E5M2TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E5M2TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E5M2(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E5M2", Bool](type)


fn mlirFloat8E5M2TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E5M2TypeGet", MlirType](context)


fn mlirFloat8E4M3TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E4M3TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E4M3(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E4M3", Bool](type)


fn mlirFloat8E4M3TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E4M3TypeGet", MlirType](context)


fn mlirFloat8E4M3FNTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E4M3FNTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E4M3FN(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E4M3FN", Bool](type)


fn mlirFloat8E4M3FNTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E4M3FNTypeGet", MlirType](context)


fn mlirFloat8E5M2FNUZTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E5M2FNUZTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E5M2FNUZ(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E5M2FNUZ", Bool](type)


fn mlirFloat8E5M2FNUZTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E5M2FNUZTypeGet", MlirType](context)


fn mlirFloat8E4M3FNUZTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E4M3FNUZTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E4M3FNUZ(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E4M3FNUZ", Bool](type)


fn mlirFloat8E4M3FNUZTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E4M3FNUZTypeGet", MlirType](context)


fn mlirFloat8E4M3B11FNUZTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E4M3B11FNUZTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E4M3B11FNUZ(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E4M3B11FNUZ", Bool](type)


fn mlirFloat8E4M3B11FNUZTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E4M3B11FNUZTypeGet", MlirType](context)


fn mlirFloat8E3M4TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E3M4TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E3M4(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E3M4", Bool](type)


fn mlirFloat8E3M4TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E3M4TypeGet", MlirType](context)


fn mlirFloat8E8M0FNUTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat8E8M0FNUTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFloat8E8M0FNU(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFloat8E8M0FNU", Bool](type)


fn mlirFloat8E8M0FNUTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat8E8M0FNUTypeGet", MlirType](context)


fn mlirBFloat16TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirBFloat16TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsABF16(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsABF16", Bool](type)


fn mlirBF16TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirBF16TypeGet", MlirType](context)


fn mlirFloat16TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat16TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAF16(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAF16", Bool](type)


fn mlirF16TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirFloat16TypeGet", MlirType](context)


fn mlirFloat32TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat32TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAF32(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAF32", Bool](type)


fn mlirF32TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirF32TypeGet", MlirType](context)


fn mlirFloat64TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloat64TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAF64(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAF64", Bool](type)


fn mlirF64TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirF64TypeGet", MlirType](context)


fn mlirFloatTF32TypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFloatTF32TypeGetTypeID", MlirTypeID]()


fn mlirTypeIsATF32(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsATF32", Bool](type)


fn mlirTF32TypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirTF32TypeGet", MlirType](context)


# ===----------------------------------------------------------------------===
#  None type.
# ===----------------------------------------------------------------------===


fn mlirNoneTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirNoneTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsANone(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsANone", Bool](type)


fn mlirNoneTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirNoneTypeGet", MlirType](context)


# ===----------------------------------------------------------------------===
#  Complex type.
# ===----------------------------------------------------------------------===


fn mlirComplexTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirComplexTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAComplex(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAComplex", Bool](type)


fn mlirComplexTypeGet(context: MlirContext) -> MlirType:
    return mlirc_fn["mlirComplexTypeGet", MlirType](context)


fn mlirComplexTypeGetElementType(type: MlirType) -> MlirType:
    return mlirc_fn["mlirComplexTypeGetElementType", MlirType](type)


# ===----------------------------------------------------------------------===
#  Shaped type.
# ===----------------------------------------------------------------------===


fn mlirTypeIsAShaped(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAShaped", Bool](type)


fn mlirShapedTypeGetElementType(type: MlirType) -> MlirType:
    return mlirc_fn["mlirShapedTypeGetElementType", MlirType](type)


fn mlirShapedTypeHasRank(type: MlirType) -> Bool:
    return mlirc_fn["mlirShapedTypeHasRank", Bool](type)


fn mlirShapedTypeGetRank(type: MlirType) -> Int64:
    return mlirc_fn["mlirShapedTypeGetRank", Int64](type)


fn mlirShapedTypeHasStaticShape(type: MlirType) -> Bool:
    return mlirc_fn["mlirShapedTypeHasStaticShape", Bool](type)


fn mlirShapedTypeIsDynamicDim(type: MlirType, dim: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsDynamicDim", Bool](type, dim)


fn mlirShapedTypeIsStaticDim(type: MlirType, dim: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsStaticDim", Bool](type, dim)


fn mlirShapedTypeGetDimSize(type: MlirType, dim: Int64) -> Int64:
    return mlirc_fn["mlirShapedTypeGetDimSize", Int64](type, dim)


fn mlirShapedTypeIsDynamicSize(size: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsDynamicSize", Bool](size)


fn mlirShapedTypeIsStaticSize(size: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsStaticSize", Bool](size)


fn mlirShapedTypeGetDynamicSize() -> Int64:
    return mlirc_fn["mlirShapedTypeGetDynamicSize", Int64]()


fn mlirShapedTypeIsDynamicStrideOrOffset(value: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsDynamicStrideOrOffset", Bool](value)


fn mlirShapedTypeIsStaticStrideOrOffset(value: Int64) -> Bool:
    return mlirc_fn["mlirShapedTypeIsStaticStrideOrOffset", Bool](value)


fn mlirShapedTypeGetDynamicStrideOrOffset() -> Int64:
    return mlirc_fn["mlirShapedTypeGetDynamicStrideOrOffset", Int64]()


# ===----------------------------------------------------------------------===
#  Vector type.
# ===----------------------------------------------------------------------===


fn mlirVectorTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirVectorTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAVector(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAVector", Bool](type)


fn mlirVectorTypeGet(
    rank: Int64,
    shape: ExternalPointer[Int64],
    elementType: MlirType,
) -> MlirType:
    return mlirc_fn["mlirVectorTypeGet", MlirType](rank, shape, elementType)


fn mlirVectorTypeGetChecked(
    location: MlirLocation,
    rank: Int64,
    shape: ExternalPointer[Int64],
    elementType: MlirType,
) -> MlirType:
    return mlirc_fn["mlirVectorTypeGetChecked", MlirType](
        location, rank, shape, elementType
    )


fn mlirVectorTypeGetScalable(
    rank: Int64,
    shape: ExternalPointer[Int64],
    scalable: ExternalPointer[Bool],
    elementType: MlirType,
) -> MlirType:
    return mlirc_fn["mlirVectorTypeGetScalable", MlirType](
        rank, shape, scalable, elementType
    )


fn mlirVectorTypeGetScalableChecked(
    location: MlirLocation,
    rank: Int64,
    shape: ExternalPointer[Int64],
    scalable: ExternalPointer[Bool],
    elementType: MlirType,
) -> MlirType:
    return mlirc_fn["mlirVectorTypeGetScalableChecked", MlirType](
        location, rank, shape, scalable, elementType
    )


fn mlirVectorTypeIsScalable(type: MlirType) -> Bool:
    return mlirc_fn["mlirVectorTypeIsScalable", Bool](type)


fn mlirVectorTypeIsDimScalable(type: MlirType, dim: Int64) -> Bool:
    return mlirc_fn["mlirVectorTypeIsDimScalable", Bool](type, dim)


# ===----------------------------------------------------------------------===//
#  Ranked / Unranked Tensor type.
# ===----------------------------------------------------------------------===//


fn mlirTypeIsATensor(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsATensor", Bool](type)


fn mlirRankedTensorTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirRankedTensorTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsARankedTensor(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsARankedTensor", Bool](type)


fn mlirUnrankedTensorTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirUnrankedTensorTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAUnrankedTensor(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAUnrankedTensor", Bool](type)


fn mlirRankedTensorTypeGet(
    rank: Int,
    shape: ExternalPointer[Int64],
    element_type: MlirType,
    encoding: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirRankedTensorTypeGet", MlirType](
        rank, shape, element_type, encoding
    )


fn mlirRankedTensorTypeGetChecked(
    location: MlirLocation,
    rank: Int,
    shape: ExternalPointer[Int64],
    element_type: MlirType,
    encoding: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirRankedTensorTypeGetChecked", MlirType](
        location, rank, shape, element_type, encoding
    )


fn mlirRankedTensorTypeGetEncoding(type: MlirType) -> MlirAttribute:
    return mlirc_fn["mlirRankedTensorTypeGetEncoding", MlirAttribute](type)


fn mlirUnrankedTensorTypeGet(element_type: MlirType) -> MlirType:
    return mlirc_fn["mlirUnrankedTensorTypeGet", MlirType](element_type)


fn mlirUnrankedTensorTypeGetChecked(
    location: MlirLocation, element_type: MlirType
) -> MlirType:
    return mlirc_fn["mlirUnrankedTensorTypeGetChecked", MlirType](
        location, element_type
    )


# ===----------------------------------------------------------------------===//
#  Ranked / Unranked MemRef type.
# ===----------------------------------------------------------------------===//


fn mlirMemRefTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirMemRefTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAMemRef(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAMemRef", Bool](type)


fn mlirUnrankedMemRefTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirUnrankedMemRefTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAUnrankedMemRef(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAUnrankedMemRef", Bool](type)


fn mlirMemRefTypeGet(
    element_type: MlirType,
    rank: Int,
    shape: ExternalPointer[Int64],
    layout: MlirAttribute,
    memory_space: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirMemRefTypeGet", MlirType](
        element_type, rank, shape, layout, memory_space
    )


fn mlirMemRefTypeGetChecked(
    location: MlirLocation,
    element_type: MlirType,
    rank: Int,
    shape: ExternalPointer[Int64],
    layout: MlirAttribute,
    memory_space: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirMemRefTypeGetChecked", MlirType](
        location, element_type, rank, shape, layout, memory_space
    )


fn mlirMemRefTypeContiguousGet(
    element_type: MlirType,
    rank: Int,
    shape: ExternalPointer[Int64],
    memory_space: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirMemRefTypeContiguousGet", MlirType](
        element_type, rank, shape, memory_space
    )


fn mlirMemRefTypeContiguousGetChecked(
    location: MlirLocation,
    element_type: MlirType,
    rank: Int,
    shape: ExternalPointer[Int64],
    memory_space: MlirAttribute,
) -> MlirType:
    return mlirc_fn["mlirMemRefTypeContiguousGetChecked", MlirType](
        location, element_type, rank, shape, memory_space
    )


fn mlirUnrankedMemRefTypeGet(
    element_type: MlirType, memory_space: MlirAttribute
) -> MlirType:
    return mlirc_fn["mlirUnrankedMemRefTypeGet", MlirType](
        element_type, memory_space
    )


fn mlirUnrankedMemRefTypeGetChecked(
    location: MlirLocation, element_type: MlirType, memory_space: MlirAttribute
) -> MlirType:
    return mlirc_fn["mlirUnrankedMemRefTypeGetChecked", MlirType](
        location, element_type, memory_space
    )


fn mlirMemRefTypeGetLayout(type: MlirType) -> MlirAttribute:
    return mlirc_fn["mlirMemRefTypeGetLayout", MlirAttribute](type)


fn mlirMemRefTypeGetAffineMap(type: MlirType) -> MlirAffineMap:
    return mlirc_fn["mlirMemRefTypeGetAffineMap", MlirAffineMap](type)


fn mlirMemRefTypeGetMemorySpace(type: MlirType) -> MlirAttribute:
    return mlirc_fn["mlirMemRefTypeGetMemorySpace", MlirAttribute](type)


fn mlirMemRefTypeGetStridesAndOffset(
    type: MlirType,
    strides: ExternalPointer[Int64],
    offset: ExternalPointer[Int64],
) -> MlirLogicalResult:
    return mlirc_fn["mlirMemRefTypeGetStridesAndOffset", MlirLogicalResult](
        type, strides, offset
    )


fn mlirUnrankedMemrefGetMemorySpace(type: MlirType) -> MlirAttribute:
    return mlirc_fn["mlirUnrankedMemrefGetMemorySpace", MlirAttribute](type)


# ===----------------------------------------------------------------------===//
#  Tuple type.
# ===----------------------------------------------------------------------===//


fn mlirTupleTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirTupleTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsATuple(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsATuple", Bool](type)


fn mlirTupleTypeGet(
    context: MlirContext,
    num_elements: Int,
    elements: ExternalPointer[MlirType],
) -> MlirType:
    return mlirc_fn["mlirTupleTypeGet", MlirType](
        context, num_elements, elements
    )


fn mlirTupleTypeGetNumTypes(type: MlirType) -> Int:
    return mlirc_fn["mlirTupleTypeGetNumTypes", Int](type)


fn mlirTupleTypeGetType(type: MlirType, position: Int) -> MlirType:
    return mlirc_fn["mlirTupleTypeGetType", MlirType](type, position)


# ===----------------------------------------------------------------------===//
#  Function type.
# ===----------------------------------------------------------------------===//


fn mlirFunctionTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirFunctionTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAFunction(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAFunction", Bool](type)


fn mlirFunctionTypeGet(
    context: MlirContext,
    num_inputs: Int,
    inputs: ExternalPointer[MlirType],
    num_results: Int,
    results: ExternalPointer[MlirType],
) -> MlirType:
    return mlirc_fn["mlirFunctionTypeGet", MlirType](
        context, num_inputs, inputs, num_results, results
    )


fn mlirFunctionTypeGetNumInputs(type: MlirType) -> Int:
    return mlirc_fn["mlirFunctionTypeGetNumInputs", Int](type)


fn mlirFunctionTypeGetNumResults(type: MlirType) -> Int:
    return mlirc_fn["mlirFunctionTypeGetNumResults", Int](type)


fn mlirFunctionTypeGetInput(type: MlirType, position: Int) -> MlirType:
    return mlirc_fn["mlirFunctionTypeGetInput", MlirType](type, position)


fn mlirFunctionTypeGetResult(type: MlirType, position: Int) -> MlirType:
    return mlirc_fn["mlirFunctionTypeGetResult", MlirType](type, position)


# ===----------------------------------------------------------------------===//
#  Opaque type.
# ===----------------------------------------------------------------------===//


fn mlirOpaqueTypeGetTypeID() -> MlirTypeID:
    return mlirc_fn["mlirOpaqueTypeGetTypeID", MlirTypeID]()


fn mlirTypeIsAOpaque(type: MlirType) -> Bool:
    return mlirc_fn["mlirTypeIsAOpaque", Bool](type)


fn mlirOpaqueTypeGet(
    context: MlirContext,
    dialect_namespace: MlirStringRef,
    type_data: MlirStringRef,
) -> MlirType:
    return mlirc_fn["mlirOpaqueTypeGet", MlirType](
        context, dialect_namespace, type_data
    )


fn mlirOpaqueTypeGetDialectNamespace(type: MlirType) -> MlirStringRef:
    return mlirc_fn["mlirOpaqueTypeGetDialectNamespace", MlirStringRef](type)


fn mlirOpaqueTypeGetData(type: MlirType) -> MlirStringRef:
    return mlirc_fn["mlirOpaqueTypeGetData", MlirStringRef](type)
