from mlir.ffi import mlirc_fn, ExternalPointer


@register_passable("trivial")
struct MlirBytecodeWriterConfig:
    var ptr: ExternalPointer


fn mlirBytecodeWriterConfigCreate() -> MlirBytecodeWriterConfig:
    return mlirc_fn[
        "mlirBytecodeWriterConfigCreate", MlirBytecodeWriterConfig
    ]()


fn mlirBytecodeWriterConfigDestroy(config: MlirBytecodeWriterConfig):
    mlirc_fn["mlirBytecodeWriterConfigDestroy", NoneType._mlir_type](config)


fn mlirBytecodeWriterConfigDesiredEmitVersion(
    config: MlirBytecodeWriterConfig, version: Int
):
    mlirc_fn["mlirBytecodeWriterConfigDesiredEmitVersion", NoneType._mlir_type](
        config, version
    )
