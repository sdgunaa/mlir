from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.context import MlirContext
from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.affine.affine_expr import MlirAffineExpr


@register_passable("trivial")
struct MlirAffineMap:
    var ptr: ExternalPointer


fn mlirAffineMapGetContext(affine_map: MlirAffineMap) -> MlirContext:
    return mlirc_fn["mlirAffineMapGetContext", MlirContext](affine_map)


@always_inline("nodebug")
fn mlirAffineMapIsNull(affine_map: MlirAffineMap) -> Bool:
    return not Bool(affine_map.ptr)


fn mlirAffineMapEqual(
    affine_map1: MlirAffineMap, affine_map2: MlirAffineMap
) -> Bool:
    return mlirc_fn["mlirAffineMapEqual", Bool](affine_map1, affine_map2)


fn mlirAffineMapPrint(affine_map: MlirAffineMap, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirAffineMapPrint", NoneType._mlir_type](
        affine_map, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirAffineMapDump(affine_map: MlirAffineMap):
    mlirc_fn["mlirAffineMapDump", NoneType._mlir_type](affine_map)


fn mlirAffineMapEmptyGet(context: MlirContext) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapEmptyGet", MlirAffineMap](context)


fn mlirAffineMapZeroResultGet(
    context: MlirContext, num_dims: Int, num_symbols: Int
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapZeroResultGet", MlirAffineMap](
        context, num_dims, num_symbols
    )


fn mlirAffineMapGet(
    context: MlirContext,
    num_dims: Int,
    num_symbols: Int,
    num_affine_exprs: Int,
    affine_exprs: UnsafePointer[MlirAffineExpr, MutExternalOrigin],
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapGet", MlirAffineMap](
        context, num_dims, num_symbols, num_affine_exprs, affine_exprs
    )


fn mlirAffineMapConstantGet(context: MlirContext, value: Int) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapConstantGet", MlirAffineMap](context, value)


fn mlirAffineMapMultiDimIdentityGet(
    context: MlirContext, num_dims: Int
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapMultiDimIdentityGet", MlirAffineMap](
        context, num_dims
    )


fn mlirAffineMapMinorIdentityGet(
    context: MlirContext, num_dims: Int, num_results: Int
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapMinorIdentityGet", MlirAffineMap](
        context, num_dims, num_results
    )


fn mlirAffineMapPermutationGet(
    context: MlirContext,
    size: Int,
    permutation: UnsafePointer[UInt32, MutExternalOrigin],
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapPermutationGet", MlirAffineMap](
        context, size, permutation
    )


fn mlirAffineMapIsIdentity(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsIdentity", Bool](affine_map)


fn mlirAffineMapIsMinorIdentity(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsMinorIdentity", Bool](affine_map)


fn mlirAffineMapIsEmpty(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsEmpty", Bool](affine_map)


fn mlirAffineMapIsSingleConstant(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsSingleConstant", Bool](affine_map)


fn mlirAffineMapGetSingleConstantResult(affine_map: MlirAffineMap) -> Int:
    return mlirc_fn["mlirAffineMapGetSingleConstantResult", Int](affine_map)


fn mlirAffineMapGetNumDims(affine_map: MlirAffineMap) -> Int:
    return mlirc_fn["mlirAffineMapGetNumDims", Int](affine_map)


fn mlirAffineMapGetNumSymbols(affine_map: MlirAffineMap) -> Int:
    return mlirc_fn["mlirAffineMapGetNumSymbols", Int](affine_map)


fn mlirAffineMapGetNumResults(affine_map: MlirAffineMap) -> Int:
    return mlirc_fn["mlirAffineMapGetNumResults", Int](affine_map)


fn mlirAffineMapGetResult(
    affine_map: MlirAffineMap, position: Int
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineMapGetResult", MlirAffineExpr](
        affine_map, position
    )


fn mlirAffineMapGetNumInputs(affine_map: MlirAffineMap) -> Int:
    return mlirc_fn["mlirAffineMapGetNumInputs", Int](affine_map)


fn mlirAffineMapIsProjectedPermutation(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsProjectedPermutation", Bool](affine_map)


fn mlirAffineMapIsPermutation(affine_map: MlirAffineMap) -> Bool:
    return mlirc_fn["mlirAffineMapIsPermutation", Bool](affine_map)


fn mlirAffineMapGetSubMap(
    affine_map: MlirAffineMap,
    size: Int,
    result_positions: UnsafePointer[Int, MutExternalOrigin],
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapGetSubMap", MlirAffineMap](
        affine_map, size, result_positions
    )


fn mlirAffineMapGetMajorSubMap(
    affine_map: MlirAffineMap, num_results: Int
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapGetMajorSubMap", MlirAffineMap](
        affine_map, num_results
    )


fn mlirAffineMapGetMinorSubMap(
    affine_map: MlirAffineMap, num_results: Int
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapGetMinorSubMap", MlirAffineMap](
        affine_map, num_results
    )


fn mlirAffineMapReplace(
    affine_map: MlirAffineMap,
    expression: MlirAffineExpr,
    replacement: MlirAffineExpr,
    num_result_dims: Int,
    num_result_symbols: Int,
) -> MlirAffineMap:
    return mlirc_fn["mlirAffineMapReplace", MlirAffineMap](
        affine_map, expression, replacement, num_result_dims, num_result_symbols
    )


fn mlirAffineMapCompressUnusedSymbols(
    affine_maps: UnsafePointer[MlirAffineMap, MutExternalOrigin],
    size: Int,
    result: ExternalPointer,
    populate_result: fn (ExternalPointer, Int, MlirAffineMap) -> None,
) -> None:
    mlirc_fn["mlirAffineMapCompressUnusedSymbols", NoneType._mlir_type](
        affine_maps, size, result, populate_result
    )
