from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.context import MlirContext
from format._utils import _WriteBufferStack
from mlir.core import MlirStringRef, mlirStringCallback
from mlir.core.affine.affine_map import MlirAffineMap


@register_passable("trivial")
struct MlirAffineExpr:
    var ptr: ExternalPointer


fn mlirAffineExprGetContext(affine_expr: MlirAffineExpr) -> MlirContext:
    return mlirc_fn["mlirAffineExprGetContext", MlirContext](affine_expr)


fn mlirAffineExprEqual(
    affine_expr1: MlirAffineExpr, affine_expr2: MlirAffineExpr
) -> Bool:
    return mlirc_fn["mlirAffineExprEqual", Bool](affine_expr1, affine_expr2)


@always_inline("nodebug")
fn mlirAffineExprIsNull(affine_expr: MlirAffineExpr) -> Bool:
    return not Bool(affine_expr.ptr)


fn mlirAffineExprPrint(affine_expr: MlirAffineExpr, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirAffineExprPrint", NoneType._mlir_type](
        affine_expr, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirAffineExprDump(affine_expr: MlirAffineExpr):
    mlirc_fn["mlirAffineExprDump", NoneType._mlir_type](affine_expr)


fn mlirAffineExprIsSymbolicOrConstant(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsSymbolicOrConstant", Bool](affine_expr)


fn mlirAffineExprIsPureAffine(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsPureAffine", Bool](affine_expr)


fn mlirAffineExprGetLargestKnownDivisor(affine_expr: MlirAffineExpr) -> Int:
    return mlirc_fn["mlirAffineExprGetLargestKnownDivisor", Int](affine_expr)


fn mlirAffineExprIsMultipleOf(affine_expr: MlirAffineExpr, factor: Int) -> Bool:
    return mlirc_fn["mlirAffineExprIsMultipleOf", Bool](affine_expr, factor)


fn mlirAffineExprIsFunctionOfDim(
    affine_expr: MlirAffineExpr, position: Int
) -> Bool:
    return mlirc_fn["mlirAffineExprIsFunctionOfDim", Bool](
        affine_expr, position
    )


fn mlirAffineExprCompose(
    affine_expr: MlirAffineExpr, affine_map: MlirAffineMap
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineExprCompose", MlirAffineExpr](
        affine_expr, affine_map
    )


fn mlirAffineExprShiftDims(
    affine_expr: MlirAffineExpr, num_dims: UInt32, shift: UInt32, offset: UInt32
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineExprShiftDims", MlirAffineExpr](
        affine_expr, num_dims, shift, offset
    )


fn mlirAffineExprShiftSymbols(
    affine_expr: MlirAffineExpr,
    num_symbols: UInt32,
    shift: UInt32,
    offset: UInt32,
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineExprShiftSymbols", MlirAffineExpr](
        affine_expr, num_symbols, shift, offset
    )


fn mlirSimplifyAffineExpr(
    affine_expr: MlirAffineExpr, num_dims: UInt32, num_symbols: UInt32
) -> MlirAffineExpr:
    return mlirc_fn["mlirSimplifyAffineExpr", MlirAffineExpr](
        affine_expr, num_dims, num_symbols
    )


fn mlirAffineExprIsADim(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsADim", Bool](affine_expr)


fn mlirAffineDimExprGet(context: MlirContext, position: Int) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineDimExprGet", MlirAffineExpr](context, position)


fn mlirAffineDimExprGetPosition(affine_expr: MlirAffineExpr) -> Int:
    return mlirc_fn["mlirAffineDimExprGetPosition", Int](affine_expr)


fn mlirAffineExprIsASymbol(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsASymbol", Bool](affine_expr)


fn mlirAffineSymbolExprGet(
    context: MlirContext, position: Int
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineSymbolExprGet", MlirAffineExpr](
        context, position
    )


fn mlirAffineSymbolExprGetPosition(affine_expr: MlirAffineExpr) -> Int:
    return mlirc_fn["mlirAffineSymbolExprGetPosition", Int](affine_expr)


fn mlirAffineExprIsAConstant(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsAConstant", Bool](affine_expr)


fn mlirAffineConstantExprGet(
    context: MlirContext, constant: Int
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineConstantExprGet", MlirAffineExpr](
        context, constant
    )


fn mlirAffineConstantExprGetValue(affine_expr: MlirAffineExpr) -> Int:
    return mlirc_fn["mlirAffineConstantExprGetValue", Int](affine_expr)


fn mlirAffineExprIsAAdd(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsAAdd", Bool](affine_expr)


fn mlirAffineAddExprGet(
    lhs: MlirAffineExpr, rhs: MlirAffineExpr
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineAddExprGet", MlirAffineExpr](lhs, rhs)


fn mlirAffineExprIsAMul(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsAMul", Bool](affine_expr)


fn mlirAffineMulExprGet(
    lhs: MlirAffineExpr, rhs: MlirAffineExpr
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineMulExprGet", MlirAffineExpr](lhs, rhs)


fn mlirAffineExprIsAMod(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsAMod", Bool](affine_expr)


fn mlirAffineModExprGet(
    lhs: MlirAffineExpr, rhs: MlirAffineExpr
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineModExprGet", MlirAffineExpr](lhs, rhs)


fn mlirAffineExprIsAFloorDiv(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsAFloorDiv", Bool](affine_expr)


fn mlirAffineFloorDivExprGet(
    lhs: MlirAffineExpr, rhs: MlirAffineExpr
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineFloorDivExprGet", MlirAffineExpr](lhs, rhs)


fn mlirAffineExprIsACeilDiv(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsACeilDiv", Bool](affine_expr)


fn mlirAffineCeilDivExprGet(
    lhs: MlirAffineExpr, rhs: MlirAffineExpr
) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineCeilDivExprGet", MlirAffineExpr](lhs, rhs)


fn mlirAffineExprIsABinary(affine_expr: MlirAffineExpr) -> Bool:
    return mlirc_fn["mlirAffineExprIsABinary", Bool](affine_expr)


fn mlirAffineBinaryOpExprGetLHS(affine_expr: MlirAffineExpr) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineBinaryOpExprGetLHS", MlirAffineExpr](affine_expr)


fn mlirAffineBinaryOpExprGetRHS(affine_expr: MlirAffineExpr) -> MlirAffineExpr:
    return mlirc_fn["mlirAffineBinaryOpExprGetRHS", MlirAffineExpr](affine_expr)
