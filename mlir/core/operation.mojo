from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core import MlirStringRef, mlirStringCallback
from format._utils import _WriteBufferStack
from mlir.emit.printing_flags import (
    MlirOpPrintingFlags,
    mlirOpPrintingFlagsCreate,
    mlirOpPrintingFlagsEnableDebugInfo,
)
from mlir.emit.bytecode import MlirBytecodeWriterConfig
from mlir.emit.asm import MlirAsmState
from mlir.core.location import MlirLocation, Location
from mlir.core.type import MlirType, MlirTypeID, Type
from mlir.core.value import MlirValue, Value
from mlir.core.region import MlirRegion, Region
from mlir.core.block import MlirBlock, Block
from mlir.core.context import MlirContext, Context
from mlir.core.attribute import (
    MlirAttribute,
    MlirNamedAttribute,
    MlirIdentifier,
    NamedAttribute,
    Attribute,
    Identifier,
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


fn mlirOperationGetFirstRegion(operation: MlirOperation) -> MlirRegion:
    return mlirc_fn["mlirOperationGetFirstRegion", MlirRegion](operation)


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


fn mlirOpOperandGetOperandNumber(opOperand: MlirOpOperand) -> Int:
    return mlirc_fn["mlirOpOperandGetOperandNumber", Int](opOperand)


fn mlirOpOperandGetNextUse(opOperand: MlirOpOperand) -> MlirOpOperand:
    return mlirc_fn["mlirOpOperandGetNextUse", MlirOpOperand](opOperand)


@fieldwise_init("implicit")
@register_passable("trivial")
struct OpOperand(MlirWrapper):
    comptime c_type = MlirOpOperand
    var _ptr: Self.c_type

    fn get_value(self) -> Value:
        return Value(mlirOpOperandGetValue(self._ptr))

    fn get_owner(self) -> Operation:
        return Operation(mlirOpOperandGetOwner(self._ptr))

    fn get_operand_number(self) -> Int:
        return mlirOpOperandGetOperandNumber(self._ptr)

    fn get_next_use(self) -> OpOperand:
        return OpOperand(mlirOpOperandGetNextUse(self._ptr))

    fn __bool__(self) -> Bool:
        return not mlirOpOperandIsNull(self._ptr)

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr


@fieldwise_init("implicit")
@register_passable("trivial")
struct Operation(MlirWrapper, Stringable, Writable):
    comptime c_type = MlirOperation
    var _ptr: Self.c_type

    fn __init__(out self, operation_state: MlirOperationState):
        self._ptr = mlirOperationCreate(operation_state)

    fn __init__(
        out self,
        name: String,
        location: Location,
        *,
        mut attributes: _InnerList[NamedAttribute],
        mut operands: _InnerList[Value],
        mut results: _InnerList[Type],
        mut regions: _InnerList[Region],
        mut successors: _InnerList[Block],
    ):
        var state = mlirOperationStateGet(_static_from_str(name), location._ptr)
        self._intialize_state(
            state, attributes, operands, results, regions, successors
        )
        self._ptr = mlirOperationCreate(state)

    fn __init__(
        out self,
        name: String,
        location: Location,
        *,
        enable_result_type_inference: Bool,
        mut attributes: _InnerList[NamedAttribute],
        mut operands: _InnerList[Value],
        mut results: _InnerList[Type],
        mut regions: _InnerList[Region],
        mut successors: _InnerList[Block],
    ):
        var state = mlirOperationStateGet(_static_from_str(name), location._ptr)
        self._intialize_state(
            state, attributes, operands, results, regions, successors
        )
        if enable_result_type_inference:
            mlirOperationStateEnableResultTypeInference(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin]()
            )
        self._ptr = mlirOperationCreate(state)

    @staticmethod
    fn parse(
        context: Context, source: String, source_name: String
    ) raises -> Self:
        var operation = mlirOperationCreateParse(
            context._ptr,
            _static_from_str(source),
            _static_from_str(source_name),
        )
        if not operation.ptr:
            raise Error("Failed to parse operation")
        return Operation(operation)

    fn destroy(deinit self):
        mlirOperationDestroy(self._ptr)

    fn context(self) -> Context:
        return Context(mlirOperationGetContext(self._ptr))

    fn location(self) -> Location:
        return Location(mlirOperationGetLocation(self._ptr))

    fn verify(self) -> Bool:
        return mlirOperationVerify(self._ptr)

    fn name(self) -> Identifier:
        return Identifier(mlirOperationGetName(self._ptr))

    fn block(self) -> Block:
        return Block(mlirOperationGetBlock(self._ptr))

    fn parent(self) -> Operation:
        return Operation(mlirOperationGetParentOperation(self._ptr))

    fn remove_from_parent(self):
        mlirOperationRemoveFromParent(self._ptr)

    fn num_successors(self) -> Int:
        return mlirOperationGetNumSuccessors(self._ptr)

    fn successor(self, successor_index: Int) raises -> Block:
        var successor = mlirOperationGetSuccessor(self._ptr, successor_index)
        if not successor.ptr:
            raise Error("Failed to get successor")
        return Block(successor)

    fn set_successor(mut self, successor_index: Int, successor: Block):
        mlirOperationSetSuccessor(self._ptr, successor_index, successor._ptr)

    fn num_regions(self) -> Int:
        return mlirOperationGetNumRegions(self._ptr)

    fn first_region(self) -> Region:
        return Region(mlirOperationGetFirstRegion(self._ptr))

    fn region(self, region_index: Int) raises -> Region:
        var region = mlirOperationGetRegion(self._ptr, region_index)
        if not region.ptr:
            raise Error("Failed to get region")
        return Region(region)

    fn num_results(self) -> Int:
        return mlirOperationGetNumResults(self._ptr)

    fn result(self, result_index: Int) raises -> Value:
        var result = mlirOperationGetResult(self._ptr, result_index)
        if not result.ptr:
            raise Error("Failed to get result")
        return Value(result)

    fn num_operands(self) -> Int:
        return mlirOperationGetNumOperands(self._ptr)

    fn operand(self, operand_index: Int) raises -> Value:
        var operand = mlirOperationGetOperand(self._ptr, operand_index)
        if not operand.ptr:
            raise Error("Failed to get operand")
        return Value(operand)

    fn set_operand(mut self, operand_index: Int, operand: Value):
        mlirOperationSetOperand(self._ptr, operand_index, operand._ptr)

    fn set_operands(mut self, var operands: _InnerList[Value]):
        mlirOperationSetOperands(
            self._ptr, len(operands), operands.unsafe_ptr()
        )

    fn num_attributes(self) -> Int:
        return mlirOperationGetNumAttributes(self._ptr)

    fn attribute(self, attribute_index: Int) raises -> NamedAttribute:
        var attribute = mlirOperationGetAttribute(self._ptr, attribute_index)
        if not attribute.attribute.ptr:
            raise Error("Failed to get attribute")
        return NamedAttribute(attribute)

    fn attributes(self) raises -> List[NamedAttribute]:
        var attributes: List[NamedAttribute] = []
        for i in range(self.num_attributes()):
            attributes.append(self.attribute(i))
        return attributes.copy()

    fn operands(self) raises -> List[Value]:
        var operands: List[Value] = []
        for i in range(self.num_operands()):
            operands.append(self.operand(i))
        return operands.copy()

    fn results(self) raises -> List[Value]:
        var results: List[Value] = []
        for i in range(self.num_results()):
            results.append(self.result(i))
        return results.copy()

    fn successors(self) raises -> List[Block]:
        var successors: List[Block] = []
        for i in range(self.num_successors()):
            successors.append(self.successor(i))
        return successors.copy()

    fn regions(self) raises -> List[Region]:
        var regions: List[Region] = []
        for i in range(self.num_regions()):
            regions.append(self.region(i))
        return regions.copy()

    fn set_inherent_attribute(mut self, name: String, attribute: Attribute):
        mlirOperationSetInherentAttributeByName(
            self._ptr, _static_from_str(name), attribute._ptr
        )

    fn get_inherent_attribute(self, name: String) -> Attribute:
        return Attribute(
            mlirOperationGetInherentAttributeByName(
                self._ptr, _static_from_str(name)
            )
        )

    fn has_inherent_attribute(self, name: String) -> Bool:
        return mlirOperationHasInherentAttributeByName(
            self._ptr, _static_from_str(name)
        )

    fn get_num_discardable_attributes(self) -> Int:
        return mlirOperationGetNumDiscardableAttributes(self._ptr)

    fn set_discardable_attribute(mut self, name: String, attribute: Attribute):
        mlirOperationSetDiscardableAttributeByName(
            self._ptr, _static_from_str(name), attribute._ptr
        )

    fn get_discardable_attribute(self, name: String) -> Attribute:
        return Attribute(
            mlirOperationGetDiscardableAttributeByName(
                self._ptr, _static_from_str(name)
            )
        )

    fn remove_discardable_attribute(mut self, name: String) -> Bool:
        return mlirOperationRemoveDiscardableAttributeByName(
            self._ptr, _static_from_str(name)
        )

    fn clone(self) -> Self:
        return Self(mlirOperationClone(self._ptr))

    fn debug_string(self) -> String:
        var flags = mlirOpPrintingFlagsCreate()
        mlirOpPrintingFlagsEnableDebugInfo(flags, True, True)
        var result = String()
        mlirOperationPrintWithFlags(
            self._ptr,
            flags,
            result,
        )
        return result

    fn bytecode(self) -> String:
        var result = String()
        mlirOperationWriteBytecode(self._ptr, result)
        return result

    fn write_to(self, mut writer: Some[Writer]):
        mlirOperationPrint(self._ptr, writer)

    fn __str__(self) -> String:
        return String.write(self)

    @staticmethod
    fn _intialize_state(
        mut state: MlirOperationState,
        mut attributes: _InnerList[NamedAttribute],
        mut operands: _InnerList[Value],
        mut results: _InnerList[Type],
        mut regions: _InnerList[Region],
        mut successors: _InnerList[Block],
    ):
        if attributes:
            mlirOperationStateAddAttributes(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin](),
                len(attributes),
                attributes.unsafe_ptr(),
            )

        if operands:
            mlirOperationStateAddOperands(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin](),
                len(operands),
                operands.unsafe_ptr(),
            )

        if results:
            mlirOperationStateAddResults(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin](),
                len(results),
                results.unsafe_ptr(),
            )

        if regions:
            mlirOperationStateAddOwnedRegions(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin](),
                len(regions),
                regions.unsafe_ptr(),
            )

        if successors:
            mlirOperationStateAddSuccessors(
                UnsafePointer(to=state).unsafe_origin_cast[MutExternalOrigin](),
                len(successors),
                successors.unsafe_ptr(),
            )

    fn _mlir_type(self) -> Self.c_type:
        return self._ptr
