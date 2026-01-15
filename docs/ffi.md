# MLIR in Mojo — FFI and Runtime Binding Architecture

This document specifies the Foreign Function Interface (FFI) and dynamic runtime binding layer used to integrate MLIR and LLVM into Mojo. The architecture is designed for production-grade, low-level systems integration, featuring dynamic library discovery, global symbol caching, and ABI-stable call surfaces.

The objective is to expose the complete MLIR C API and auxiliary LLVM facilities with minimal overhead, deterministic lifetime semantics, and strict type safety.

---

## 1. Design Principles

The FFI layer is built on five core constraints to ensure performance and maintainability:

1.  **ABI Stability**: All interaction with native code occurs exclusively through the stable MLIR C API and LLVM C entry points.
2.  **Zero-Overhead Abstraction**: The binding layer avoids virtual dispatch and boxing. Resolved symbols are cached and invoked as direct, aggressively inlined calls.
3.  **Deterministic Lifetime Management**: Shared libraries and global objects follow RAII-style ownership semantics (`OwnedDLHandle`) with explicit teardown.
4.  **Strict Type Safety**: Every imported symbol is bound to a fully specified Mojo function type, enabling compile-time signature verification.
5.  **Global Symbol Caching**: Each C symbol is resolved once per process and cached in a compiler-runtime global table for O(1) subsequent access.

---

## 2. Dynamic Library Discovery

### 2.1 Component Libraries
The MLIR runtime is partitioned into several shared libraries to support modular loading:
* **Core**: `libMLIR.so` (Context, Core IR)
* **Dialects**: `libMLIRAllDialects.so` (Standard and upstream dialects)
* **Infrastructure**: `libMLIRPasses.so`, `libMLIRConversion.so`
* **Execution**: `libMLIRExecutionEngine.so`, `libLLVM.so`

### 2.2 Search and Validation
Libraries are discovered via a prioritized search path:
1.  **Environment**: Explicitly provided paths via `MLIR_LIBRARY_PATH`.
2.  **Toolchain**: Prefixes derived from the Mojo toolchain installation.
3.  **System**: Default linker search paths (`/usr/lib`, etc.).

The loader utilizes `OwnedDLHandle` to manage `dlopen` and `dlclose` cycles, ensuring library availability for the entire duration of the compiler session.

---

## 3. Global Library Registry

To prevent redundant loads and ensure symbol identity across modules, libraries are registered in a global, lazily-initialized registry.

```mojo
struct MLIRLibrary[lib: StaticString]:
    @staticmethod
    fn init() -> OwnedDLHandle:
        # Implementation-defined discovery logic
        ...

# Global handle cached in the compiler runtime
comptime _mlir_global[lib] = _Global[
    name = lib,
    init_fn = MLIRLibrary[lib].init
]
```

---

## 4. Symbol Resolution and Caching

### 4.1 Static Resolution
For performance-critical entry points, the system uses compile-time name resolution and global caching:

```mojo
fn _get_mlir_function[
    lib: StaticString = "mlir",
    name: StaticString,
    RetType: AnyTrivialRegType
]() -> RetType:
    # 1. Check global cache table
    # 2. If missing: dl-resolve using 'lib' handle
    # 3. Store in global table and return
    ...
```

### 4.2 Dynamic Resolution
A dynamic path is provided for reflective scenarios (e.g., dynamically loading custom dialect operations), which still benefits from the underlying global cache.

---

## 5. Lightweight Handle Wrappers

Native MLIR objects (opaque C pointers) are wrapped in Mojo as trivially copyable, zero-cost structs. These handles carry no state beyond the underlying pointer.

```mojo
struct MlirContext:
    ptr: UnsafePointer[NoneType, MutExternalOrigin]

struct MlirModule:
    ptr: UnsafePointer[NoneType, MutExternalOrigin]

struct MlirOperation:
    ptr: UnsafePointer[NoneType, MutExternalOrigin]
```

These wrappers carry no behavior beyond identity and are passed by value, preserving the zero-cost abstraction property.

---

## 6. Functional Binding Layer

The high-level Mojo API forwards calls to the cached functional pointers. This layer handles the transition from Mojo-native types to C-compatible handles.

```mojo
fn mlirContextCreate() -> MlirContext:
    return _get_mlir_function["mlir", "mlirContextCreate", MlirContext]()

fn mlirContextDestroy(ctx: MlirContext):
    _get_mlir_function["mlir", "mlirContextDestroy", NoneType](ctx)
```

---


## 7. Thread Safety and Diagnostics

* **Concurrency**: The FFI layer is lock-free and reentrant. Global initialization utilizes the compiler runtime's atomic registration to ensure single-initialization per symbol.
* **Error Handling**: Failures in `dlopen` or `dlsym` trigger immediate, descriptive aborts in configuration paths, while reflective paths use recoverable error propagation.
* **Diagnostics**: MLIR C-API diagnostic callbacks are bridged into Mojo, allowing native compiler errors to be surfaced as structured Mojo objects with source provenance.

---

## 8. Summary

The FFI and runtime binding architecture provides a high-performance foundation for MLIR in Mojo. By combining dynamic discovery with global caching and static type specialization, it achieves the efficiency of a statically linked system with the flexibility of a dynamic runtime.
