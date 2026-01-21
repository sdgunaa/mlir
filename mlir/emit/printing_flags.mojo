from mlir.ffi import mlirc_fn, ExternalPointer


@register_passable("trivial")
struct MlirOpPrintingFlags:
    var ptr: ExternalPointer


fn mlirOpPrintingFlagsCreate() -> MlirOpPrintingFlags:
    return mlirc_fn["mlirOpPrintingFlagsCreate", MlirOpPrintingFlags]()


fn mlirOpPrintingFlagsDestroy(flags: MlirOpPrintingFlags):
    return mlirc_fn["mlirOpPrintingFlagsDestroy", NoneType._mlir_type](flags)


fn mlirOpPrintingFlagsElideLargeElementsAttrs(
    flags: MlirOpPrintingFlags, large_element_limit: Int
):
    return mlirc_fn[
        "mlirOpPrintingFlagsElideLargeElementsAttrs", NoneType._mlir_type
    ](flags, large_element_limit)


fn mlirOpPrintingFlagsElideLargeResourceString(
    flags: MlirOpPrintingFlags, large_resource_limit: Int
):
    return mlirc_fn[
        "mlirOpPrintingFlagsElideLargeResourceString", NoneType._mlir_type
    ](flags, large_resource_limit)


fn mlirOpPrintingFlagsEnableDebugInfo(
    flags: MlirOpPrintingFlags, enable: Bool, prettyForm: Bool
):
    return mlirc_fn["mlirOpPrintingFlagsEnableDebugInfo", NoneType._mlir_type](
        flags, enable, prettyForm
    )


fn mlirOpPrintingFlagsPrintGenericOpForm(flags: MlirOpPrintingFlags):
    return mlirc_fn[
        "mlirOpPrintingFlagsPrintGenericOpForm", NoneType._mlir_type
    ](flags)


fn mlirOpPrintingFlagsPrintNameLocAsPrefix(flags: MlirOpPrintingFlags):
    return mlirc_fn[
        "mlirOpPrintingFlagsPrintNameLocAsPrefix", NoneType._mlir_type
    ](flags)


fn mlirOpPrintingFlagsUseLocalScope(flags: MlirOpPrintingFlags):
    return mlirc_fn["mlirOpPrintingFlagsUseLocalScope", NoneType._mlir_type](
        flags
    )


fn mlirOpPrintingFlagsAssumeVerified(flags: MlirOpPrintingFlags):
    return mlirc_fn["mlirOpPrintingFlagsAssumeVerified", NoneType._mlir_type](
        flags
    )


fn mlirOpPrintingFlagsSkipRegions(flags: MlirOpPrintingFlags):
    return mlirc_fn["mlirOpPrintingFlagsSkipRegions", NoneType._mlir_type](
        flags
    )
