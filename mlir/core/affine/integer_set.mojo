from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.context import MlirContext
from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.affine.affine_expr import MlirAffineExpr


@register_passable("trivial")
struct MlirIntegerSet:
    var ptr: ExternalPointer


fn mlirIntegerSetGetContext(integer_set: MlirIntegerSet) -> MlirContext:
    return mlirc_fn["mlirIntegerSetGetContext", MlirContext](integer_set)


@always_inline("nodebug")
fn mlirIntegerSetIsNull(integer_set: MlirIntegerSet) -> Bool:
    return not Bool(integer_set.ptr)


fn mlirIntegerSetEqual(
    integer_set1: MlirIntegerSet, integer_set2: MlirIntegerSet
) -> Bool:
    return mlirc_fn["mlirIntegerSetEqual", Bool](integer_set1, integer_set2)


fn mlirIntegerSetPrint(integer_set: MlirIntegerSet, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirIntegerSetPrint", NoneType._mlir_type](
        integer_set, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirIntegerSetDump(integer_set: MlirIntegerSet):
    mlirc_fn["mlirIntegerSetDump", NoneType._mlir_type](integer_set)


fn mlirIntegerSetEmptyGet(
    context: MlirContext, num_dims: Int, num_symbols: Int
) -> MlirIntegerSet:
    return mlirc_fn["mlirIntegerSetEmptyGet", MlirIntegerSet](
        context, num_dims, num_symbols
    )


fn mlirIntegerSetGet(
    context: MlirContext,
    num_dims: Int,
    num_symbols: Int,
    num_constraints: Int,
    constraints: UnsafePointer[MlirAffineExpr, MutExternalOrigin],
    eq_flags: UnsafePointer[Bool, MutExternalOrigin],
) -> MlirIntegerSet:
    return mlirc_fn["mlirIntegerSetGet", MlirIntegerSet](
        context, num_dims, num_symbols, num_constraints, constraints, eq_flags
    )


fn mlirIntegerSetReplaceGet(
    integer_set: MlirIntegerSet,
    dim_replacements: UnsafePointer[MlirAffineExpr, MutExternalOrigin],
    symbol_replacements: UnsafePointer[MlirAffineExpr, MutExternalOrigin],
    num_result_dims: Int,
    num_result_symbols: Int,
) -> MlirIntegerSet:
    return mlirc_fn["mlirIntegerSetReplaceGet", MlirIntegerSet](
        integer_set,
        dim_replacements,
        symbol_replacements,
        num_result_dims,
        num_result_symbols,
    )


fn mlirIntegerSetIsCanonicalEmpty(integer_set: MlirIntegerSet) -> Bool:
    return mlirc_fn["mlirIntegerSetIsCanonicalEmpty", Bool](integer_set)


fn mlirIntegerSetGetNumDims(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumDims", Int](integer_set)


fn mlirIntegerSetGetNumSymbols(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumSymbols", Int](integer_set)


fn mlirIntegerSetGetNumInputs(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumInputs", Int](integer_set)


fn mlirIntegerSetGetNumConstraints(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumConstraints", Int](integer_set)


fn mlirIntegerSetGetNumEqualities(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumEqualities", Int](integer_set)


fn mlirIntegerSetGetNumInequalities(integer_set: MlirIntegerSet) -> Int:
    return mlirc_fn["mlirIntegerSetGetNumInequalities", Int](integer_set)


fn mlirIntegerSetGetConstraint(
    integer_set: MlirIntegerSet, position: Int
) -> MlirAffineExpr:
    return mlirc_fn["mlirIntegerSetGetConstraint", MlirAffineExpr](
        integer_set, position
    )


fn mlirIntegerSetIsConstraintEq(
    integer_set: MlirIntegerSet, position: Int
) -> Bool:
    return mlirc_fn["mlirIntegerSetIsConstraintEq", Bool](integer_set, position)
