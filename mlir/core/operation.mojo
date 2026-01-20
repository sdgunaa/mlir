from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from format._utils import _WriteBufferStack
from mlir.emit.printing_flags import MlirOpPrintingFlags
from mlir.emit.bytecode import MlirBytecodeWriterConfig
from mlir.emit.asm import MlirAsmState
from mlir.core.location import MlirLocation
from mlir.core.type import MlirType, MlirTypeID
from mlir.core.value import MlirValue
from mlir.core.region import MlirRegion
from mlir.core.block import MlirBlock
from mlir.core.context import MlirContext
from mlir.core.attribute import (
    MlirAttribute,
    MlirNamedAttribute,
    MlirIdentifier,
)


@register_passable("trivial")
struct MlirOperationState:
    var name: MlirStringRef
    var location: MlirLocation
    var num_results: Int
    var results: UnsafePointer[MlirType, MutExternalOrigin]
    var num_operands: Int
    var operands: UnsafePointer[MlirValue, MutExternalOrigin]
    var num_regions: Int
    var regions: UnsafePointer[MlirRegion, MutExternalOrigin]
    var num_successors: Int
    var successors: UnsafePointer[MlirBlock, MutExternalOrigin]
    var num_attributes: Int
    var attributes: UnsafePointer[MlirNamedAttribute, MutExternalOrigin]
    var enableResultTypeInference: Bool


fn mlirOperationStateGet(
    name: MlirStringRef, location: MlirLocation
) -> MlirOperationState:
    return mlirc_fn["mlirOperationStateGet", MlirOperationState](name, location)


fn mlirOperationStateAddResults(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
    num_results: Int,
    results: UnsafePointer[MlirType, MutExternalOrigin],
):
    mlirc_fn["mlirOperationStateAddResults", NoneType._mlir_type](
        state, num_results, results
    )


fn mlirOperationStateAddOperands(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
    num_operands: Int,
    operands: UnsafePointer[MlirValue, MutExternalOrigin],
):
    mlirc_fn["mlirOperationStateAddOperands", NoneType._mlir_type](
        state, num_operands, operands
    )


fn mlirOperationStateAddOwnedRegions(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
    num_regions: Int,
    regions: UnsafePointer[MlirRegion, MutExternalOrigin],
):
    mlirc_fn["mlirOperationStateAddOwnedRegions", NoneType._mlir_type](
        state, num_regions, regions
    )


fn mlirOperationStateAddSuccessors(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
    num_successors: Int,
    successors: UnsafePointer[MlirBlock, MutExternalOrigin],
):
    mlirc_fn["mlirOperationStateAddSuccessors", NoneType._mlir_type](
        state, num_successors, successors
    )


fn mlirOperationStateAddAttributes(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
    num_attributes: Int,
    attributes: UnsafePointer[MlirNamedAttribute, MutExternalOrigin],
):
    mlirc_fn["mlirOperationStateAddAttributes", NoneType._mlir_type](
        state, num_attributes, attributes
    )


fn mlirOperationStateEnableResultTypeInference(
    state: UnsafePointer[MlirOperationState, MutExternalOrigin],
):
    mlirc_fn[
        "mlirOperationStateEnableResultTypeInference", NoneType._mlir_type
    ](state)


@register_passable("trivial")
struct MlirOperation:
    var ptr: ExternalPointer


fn mlirOperationCreate(state: MlirOperationState) -> MlirOperation:
    return mlirc_fn["mlirOperationCreate", MlirOperation](state)


fn mlirOperationCreateParse(
    context: MlirContext, source: MlirStringRef, source_name: MlirStringRef
) -> MlirOperation:
    return mlirc_fn["mlirOperationCreateParse", MlirOperation](
        context, source, source_name
    )


fn mlirOperationClone(operation: MlirOperation) -> MlirOperation:
    return mlirc_fn["mlirOperationClone", MlirOperation](operation)


fn mlirOperationDestroy(operation: MlirOperation):
    return mlirc_fn["mlirOperationDestroy", NoneType._mlir_type](operation)


fn mlirOperationRemoveFromParent(operation: MlirOperation):
    return mlirc_fn["mlirOperationRemoveFromParent", NoneType._mlir_type](
        operation
    )


@always_inline("nodebug")
fn mlirOperationIsNull(operation: MlirOperation) -> Bool:
    return not Bool(operation.ptr)


fn mlirOperationEqual(operation: MlirOperation, other: MlirOperation) -> Bool:
    return mlirc_fn["mlirOperationEqual", Bool](operation, other)


fn mlirOperationGetContext(operation: MlirOperation) -> MlirContext:
    return mlirc_fn["mlirOperationGetContext", MlirContext](operation)


fn mlirOperationGetLocation(operation: MlirOperation) -> MlirLocation:
    return mlirc_fn["mlirOperationGetLocation", MlirLocation](operation)


fn mlirOperationGetTypeID(operation: MlirOperation) -> MlirTypeID:
    return mlirc_fn["mlirOperationGetTypeID", MlirTypeID](operation)


fn mlirOperationGetName(operation: MlirOperation) -> MlirIdentifier:
    return mlirc_fn["mlirOperationGetName", MlirIdentifier](operation)


fn mlirOperationGetBlock(operation: MlirOperation) -> MlirBlock:
    return mlirc_fn["mlirOperationGetBlock", MlirBlock](operation)


fn mlirOperationGetParentOperation(operation: MlirOperation) -> MlirOperation:
    return mlirc_fn["mlirOperationGetParentOperation", MlirOperation](operation)


fn mlirOperationGetNumRegions(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumRegions", Int](operation)


fn mlirOperationGetRegion(operation: MlirOperation, index: Int) -> MlirRegion:
    return mlirc_fn["mlirOperationGetRegion", MlirRegion](operation, index)


fn mlirOperationGetNextInBlock(operation: MlirOperation) -> MlirOperation:
    return mlirc_fn["mlirOperationGetNextInBlock", MlirOperation](operation)


fn mlirOperationGetNumOperands(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumOperands", Int](operation)


fn mlirOperationGetOperand(operation: MlirOperation, index: Int) -> MlirValue:
    return mlirc_fn["mlirOperationGetOperand", MlirValue](operation, index)


fn mlirOperationSetOperand(
    operation: MlirOperation, index: Int, value: MlirValue
):
    return mlirc_fn["mlirOperationSetOperand", NoneType._mlir_type](
        operation, index, value
    )


fn mlirOperationSetOperands(
    operation: MlirOperation,
    num_operands: Int,
    operands: UnsafePointer[MlirValue, MutExternalOrigin],
):
    return mlirc_fn["mlirOperationSetOperands", NoneType._mlir_type](
        operation, num_operands, operands
    )


fn mlirOperationGetNumResults(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumResults", Int](operation)


fn mlirOperationGetResult(operation: MlirOperation, index: Int) -> MlirValue:
    return mlirc_fn["mlirOperationGetResult", MlirValue](operation, index)


fn mlirOperationGetNumSuccessors(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumSuccessors", Int](operation)


fn mlirOperationGetSuccessor(operation: MlirOperation, index: Int) -> MlirBlock:
    return mlirc_fn["mlirOperationGetSuccessor", MlirBlock](operation, index)


fn mlirOperationSetSuccessor(
    operation: MlirOperation, index: Int, block: MlirBlock
):
    mlirc_fn["mlirOperationSetSuccessor", NoneType._mlir_type](
        operation, index, block
    )


fn mlirOperationHasInherentAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> Bool:
    return mlirc_fn["mlirOperationHasInherentAttributeByName", Bool](
        operation, name
    )


fn mlirOperationGetInherentAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirOperationGetInherentAttributeByName", MlirAttribute](
        operation, name
    )


fn mlirOperationSetInherentAttributeByName(
    operation: MlirOperation, name: MlirStringRef, attribute: MlirAttribute
):
    return mlirc_fn[
        "mlirOperationSetInherentAttributeByName", NoneType._mlir_type
    ](operation, name, attribute)


fn mlirOperationGetNumDiscardableAttributes(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumDiscardableAttributes", Int](operation)


fn mlirOperationGetDiscardableAttribute(
    operation: MlirOperation, index: Int
) -> MlirNamedAttribute:
    return mlirc_fn["mlirOperationGetDiscardableAttribute", MlirNamedAttribute](
        operation, index
    )


fn mlirOperationGetDiscardableAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn[
        "mlirOperationGetDiscardableAttributeByName", MlirAttribute
    ](operation, name)


fn mlirOperationSetDiscardableAttributeByName(
    operation: MlirOperation, name: MlirStringRef, attribute: MlirAttribute
):
    return mlirc_fn[
        "mlirOperationSetDiscardableAttributeByName", NoneType._mlir_type
    ](operation, name, attribute)


fn mlirOperationRemoveDiscardableAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> Bool:
    return mlirc_fn["mlirOperationRemoveDiscardableAttributeByName", Bool](
        operation, name
    )


fn mlirOperationGetNumAttributes(operation: MlirOperation) -> Int:
    return mlirc_fn["mlirOperationGetNumAttributes", Int](operation)


fn mlirOperationGetAttribute(
    operation: MlirOperation, index: Int
) -> MlirNamedAttribute:
    return mlirc_fn["mlirOperationGetAttribute", MlirNamedAttribute](
        operation, index
    )


fn mlirOperationGetAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> MlirAttribute:
    return mlirc_fn["mlirOperationGetAttributeByName", MlirAttribute](
        operation, name
    )


fn mlirOperationSetAttributeByName(
    operation: MlirOperation, name: MlirStringRef, attribute: MlirAttribute
):
    return mlirc_fn["mlirOperationSetAttributeByName", NoneType._mlir_type](
        operation, name, attribute
    )


fn mlirOperationRemoveAttributeByName(
    operation: MlirOperation, name: MlirStringRef
) -> Bool:
    return mlirc_fn["mlirOperationRemoveAttributeByName", Bool](operation, name)


fn mlirOperationPrint(operation: MlirOperation, mut writer: Some[Writer]):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirOperationPrint", NoneType._mlir_type](
        operation, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirOperationPrintWithFlags(
    operation: MlirOperation,
    flags: MlirOpPrintingFlags,
    mut writer: Some[Writer],
):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirOperationPrintWithFlags", NoneType._mlir_type](
        operation, flags, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirOperationPrintWithState(
    operation: MlirOperation, state: MlirAsmState, mut writer: Some[Writer]
):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirOperationPrintWithState", NoneType._mlir_type](
        operation, state, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirOperationWriteBytecode(
    operation: MlirOperation, mut writer: Some[Writer]
):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirOperationWriteBytecode", NoneType._mlir_type](
        operation, mlirStringCallback[buffer.W], UnsafePointer(to=buffer)
    )
    buffer.flush()


fn mlirOperationWriteBytecodeWithConfig(
    operation: MlirOperation,
    config: MlirBytecodeWriterConfig,
    mut writer: Some[Writer],
):
    var buffer = _WriteBufferStack(writer)
    mlirc_fn["mlirOperationWriteBytecodeWithConfig", NoneType._mlir_type](
        operation,
        config,
        mlirStringCallback[buffer.W],
        UnsafePointer(to=buffer),
    )
    buffer.flush()


fn mlirOperationDump(operation: MlirOperation):
    return mlirc_fn["mlirOperationDump", NoneType._mlir_type](operation)


fn mlirOperationVerify(operation: MlirOperation) -> Bool:
    return mlirc_fn["mlirOperationVerify", Bool](operation)


fn mlirOperationMoveAfter(operation: MlirOperation, other: MlirOperation):
    return mlirc_fn["mlirOperationMoveAfter", NoneType._mlir_type](
        operation, other
    )


fn mlirOperationMoveBefore(operation: MlirOperation, other: MlirOperation):
    return mlirc_fn["mlirOperationMoveBefore", NoneType._mlir_type](
        operation, other
    )


@register_passable("trivial")
struct MlirOpOperand:
    var ptr: ExternalPointer


fn mlirOpOperandIsNull(opOperand: MlirOpOperand) -> Bool:
    return mlirc_fn["mlirOpOperandIsNull", Bool](opOperand)


fn mlirOpOperandGetValue(opOperand: MlirOpOperand) -> MlirValue:
    return mlirc_fn["mlirOpOperandGetValue", MlirValue](opOperand)


fn mlirOpOperandGetOwner(opOperand: MlirOpOperand) -> MlirOperation:
    return mlirc_fn["mlirOpOperandGetOwner", MlirOperation](opOperand)


fn mlirOpOperandGetOperandNumber(opOperand: MlirOpOperand) -> UInt32:
    return mlirc_fn["mlirOpOperandGetOperandNumber", Int](opOperand)


fn mlirOpOperandGetNextUse(opOperand: MlirOpOperand) -> MlirOpOperand:
    return mlirc_fn["mlirOpOperandGetNextUse", MlirOpOperand](opOperand)
