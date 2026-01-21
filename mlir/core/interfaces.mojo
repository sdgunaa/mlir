from mlir.ffi import mlirc_fn, ExternalPointer
from mlir.core.operation import MlirOperation
from mlir.core.type import MlirTypeID, MlirType
from mlir.core import MlirStringRef
from mlir.core.context import MlirContext
from mlir.core.walk import MlirLogicalResult
from mlir.core.location import MlirLocation
from mlir.core.value import MlirValue
from mlir.core.attribute import MlirAttribute
from mlir.core.region import MlirRegion


fn mlirOperationImplementsInterface(
    operation: MlirOperation, interface_type_id: MlirTypeID
) -> Bool:
    return mlirc_fn["mlirOperationImplementsInterface", Bool](
        operation, interface_type_id
    )


fn mlirOperationImplementsInterfaceStatic(
    operation_name: MlirStringRef,
    context: MlirContext,
    interface_type_id: MlirTypeID,
) -> Bool:
    return mlirc_fn["mlirOperationImplementsInterfaceStatic", Bool](
        operation_name, context, interface_type_id
    )


fn mlirInferTypeOpInterfaceTypeID() -> MlirTypeID:
    return mlirc_fn["mlirInferTypeOpInterfaceTypeID", MlirTypeID]()


comptime MlirTypesCallback = fn (
    Int, UnsafePointer[MlirType, MutExternalOrigin], ExternalPointer
) -> None

comptime MlirShapedTypeComponentsCallback = fn (
    Bool, Int, Int64, MlirType, MlirAttribute, ExternalPointer
) -> None


fn mlirInferTypeOpInterfaceInferReturnTypes(
    operation_name: MlirStringRef,
    context: MlirContext,
    location: MlirLocation,
    num_operands: Int,
    operands: UnsafePointer[MlirValue, MutExternalOrigin],
    attributes: MlirAttribute,
    properties: ExternalPointer,
    num_regions: Int,
    regions: UnsafePointer[MlirRegion, MutExternalOrigin],
    callback: MlirTypesCallback,
    user_data: ExternalPointer,
) -> MlirLogicalResult:
    return mlirc_fn[
        "mlirInferTypeOpInterfaceInferReturnTypes", MlirLogicalResult
    ](
        operation_name,
        context,
        location,
        num_operands,
        operands,
        attributes,
        properties,
        num_regions,
        regions,
        callback,
        user_data,
    )


fn mlirInferShapedTypeOpInterfaceTypeID() -> MlirTypeID:
    return mlirc_fn["mlirInferShapedTypeOpInterfaceTypeID", MlirTypeID]()


fn mlirInferShapedTypeOpInterfaceInferReturnTypes(
    operation_name: MlirStringRef,
    context: MlirContext,
    location: MlirLocation,
    num_operands: Int,
    operands: UnsafePointer[MlirValue, MutExternalOrigin],
    attributes: MlirAttribute,
    properties: ExternalPointer,
    num_regions: Int,
    regions: UnsafePointer[MlirRegion, MutExternalOrigin],
    callback: MlirShapedTypeComponentsCallback,
    user_data: ExternalPointer,
) -> MlirLogicalResult:
    return mlirc_fn[
        "mlirInferShapedTypeOpInterfaceInferReturnTypes", MlirLogicalResult
    ](
        operation_name,
        context,
        location,
        num_operands,
        operands,
        attributes,
        properties,
        num_regions,
        regions,
        callback,
        user_data,
    )
