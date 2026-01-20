from mlir.ffi import mlirc_fn, ExternalPointer


@register_passable("trivial")
struct MlirLlvmThreadPool:
    var ptr: ExternalPointer


fn mlirLlvmThreadPoolCreate(num_threads: Int) -> MlirLlvmThreadPool:
    """Creates a thread pool with the given number of threads."""
    return mlirc_fn["mlirLlvmThreadPoolCreate", MlirLlvmThreadPool](num_threads)


fn mlirLlvmThreadPoolGetNumThreads(
    thread_pool: MlirLlvmThreadPool,
) -> Int:
    """Returns the number of threads in the given thread pool."""
    return mlirc_fn["mlirLlvmThreadPoolGetNumThreads", Int](thread_pool)


fn mlirLlvmThreadPoolSetNumThreads(
    thread_pool: MlirLlvmThreadPool, num_threads: Int
) -> None:
    """Sets the number of threads in the given thread pool."""
    return mlirc_fn["mlirLlvmThreadPoolSetNumThreads", NoneType._mlir_type](
        thread_pool, num_threads
    )


fn mlirLlvmThreadPoolDestroy(thread_pool: MlirLlvmThreadPool) -> None:
    """Destroys the given thread pool."""
    return mlirc_fn["mlirLlvmThreadPoolDestroy", NoneType._mlir_type](
        thread_pool
    )


struct MlirThreadPool:
    var thread_pool: MlirLlvmThreadPool
    