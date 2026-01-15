# MLIR API in Mojo — Full-Stack Architecture

**Author:** Gunasekar

**Purpose:**
This document specifies the architecture for a first-class, general-purpose MLIR platform in Mojo. It exposes the complete upstream MLIR stack—from IR construction and dialect management to staged lowering and JIT/AOT execution—through a stable, high-performance Mojo interface.

The specification is implementation-oriented, focusing on production-grade constraints such as strict ABI discipline, reproducibility, and extensibility. It encompasses both standard core functionality and advanced features (IRDL, PDL, and Mojo-authored passes and all remaining MLIR features), providing a robust foundation for building maintainable compiler infrastructure in Mojo.

---

## 1. Overview and Strategic Goals

This specification defines a Mojo-native API surface that exposes MLIR's full capabilities while enabling high-level, language-driven compiler development. It provides a stable, type-safe interface that mirrors MLIR’s conceptual model, ensuring that performance and semantic guarantees are preserved when authoring transformations in Mojo.

### 1.1 Core Objectives
The platform is built around three primary design goals:

* **Native Power, Mojo Simplicity**: Leverage battle-tested MLIR/LLVM implementations for core behavior while allowing compiler logic to be authored entirely in Mojo.
* **Type-Safe IR Construction**: Provide robust, idiomatic Mojo APIs for IR manipulation, removing the need for C++ exposure or reliance on fragile internal details.
* **Architectural Stability**: Maintain a viable API across MLIR version upgrades and evolving dialect ecosystems, preserving reproducibility and debuggability.

### 1.2 Scope of the Standard Stack
The integrated stack provides comprehensive coverage for production-grade compiler infrastructure:

* **Core IR & Type System**: Complete support for Modules, Regions, Blocks, Operations, and extensible metadata.
* **Dialect Ecosystem**: Full access to all upstream standard dialects and their associated interfaces.
* **Transformation Engines**: Native orchestration of pass pipelines, analysis frameworks, and canonicalization.
* **Lowering & Execution**: Multi-stage, legality-driven conversion to LLVM IR with support for JIT (ORC) and AOT paths.

---

## 2. Runtime Bridge and ABI Boundary

The foundation of the stack is the MLIR C API, accessed through Mojo’s FFI facilities. The bridge layer is responsible for:

* **Dynamic Loading**: Locating and loading required MLIR and LLVM shared libraries at runtime.
* **Symbol Resolution**: Mapping all essential C-API symbols to stable Mojo handles.
* **Compatibility**: Enforcing strict version and feature checks between the Mojo API and native libraries.
* **Type Safety**: Providing stable, typed Mojo wrappers for opaque C handles.

All higher layers depend exclusively on this boundary, ensuring a clean separation between Mojo orchestration and its native implementation.

---

## 3. Context and Registry

The `MlirContext` serves as the global state and ownership root for the IR. The Mojo wrapper provides:

* **Resource Management**: Transparent ownership of IR uniquing, dialect loading, and interface registration.
* **Concurrency**: Configuration for multi-threading and parallel pass execution.
* **Diagnostics**: A centralized routing system that intercepts native MLIR diagnostics and propagates them as structured Mojo errors.

---

## 4. Core IR Model

The API provides high-performance, type-safe Mojo wrappers for the primary MLIR building blocks:

* **Structure**: `Module`, `Region`, and `Block` for hierarchical IR organization.
* **Operations**: `Operation` and `Value` (Results/Arguments) for defining computation.
* **Metadata**: `Type`, `Attribute`, and `Location` for semantic and debug annotations.

### Key Capabilities
* **Fluent Construction**: Region-aware builders that ensure structural consistency (e.g., proper SSA dominance) at construction time.
* **Manipulation**: Advanced APIs for operation cloning, replacement, and block-level transformations.
* **Serialization**: Native support for parsing and printing both textual IR and MLIR bytecode.

---

## 5. Standard Dialect Support

The platform exposes all upstream MLIR dialects, ensuring that Mojo users can leverage the full spectrum of compiler infrastructure.

### 5.1 Included Dialects
The standard stack provides deep integration for:
* **Core**: `builtin`, `func`, `arith`, `math`, `index`
* **Control Flow**: `scf`, `cf`, `affine`
* **Data & Memory**: `tensor`, `memref`, `vector`, `sparse_tensor`
* **Math & Targets**: `linalg`, `gpu`, `llvm`, `nvvm`, `rocdl`, `shape`
* **Experimental/Meta**: `pdl`, `irdl`, `transform`

### 5.2 Dialect Features
For every supported dialect, the API provides:
* **Operation Builders**: Statically-typed builders with built-in verification logic.
* **Interfaces & Traits**: Easy discovery and querying of dialect-specific interfaces (e.g., `TilingInterface`).
* **Canonicalization**: Full access to native folding hooks and canonicalization patterns.
* **Reflection**: Dynamic discovery of operations, types, and attributes via the dialect registry.

---

## 6. Analysis and Canonicalization

The platform provides a comprehensive suite of native analyses and simplification tools, exposed through idiomatic Mojo interfaces.

### 6.1 Analysis Framework
Native MLIR analyses are available as first-class objects:
* **Structural**: Dominance, post-dominance, and control-flow/region structure.
* **Dataflow**: Liveness, reaching definitions, and constant propagation.
* **Memory & Alias**: Alias analysis and memory effect side-effect modeling.
* **Shape**: Dimension and shape inference across tensor/memref boundaries.

### 6.2 Canonicalization & Simplification
The system leverages MLIR's powerful simplification engine:
* **Folding**: Direct invocation of operation folding hooks.
* **Patterns**: Application of canonicalization patterns for dialect-specific optimizations.
* **CSE**: Global and local Common Subexpression Elimination.

---

## 7. Pass and Pipeline Infrastructure

The infrastructure allows developers to compose complex transformation sequences with fine-grained control and instrumented execution.

### 7.1 Pass Management
The Mojo API provides high-level wrappers for:
* **Pass Managers**: Hierarchical orchestration for `Module` and nested operation levels.
* **Configuration**: Type-safe mechanisms for setting pass options and configuration parameters.
* **Verification**: Integrated verification of IR invariants before and after every pass execution.

### 7.2 Instrumentation & Tooling
Built-in support for compiler observability:
* **Timing**: Detailed breakdown of execution time per pass.
* **Dumping**: Snapshots of IR at specific stages or upon failure.
* **Reproducibility**: Generation of command-line reproduction strings for standalone debugging.

---

## 8. Conversion and Lowering

The multi-stage lowering engine enables progressive refinement of high-level abstractions into machine-specific instructions.

### 8.1 Legality-Driven Conversion
Lowering is governed by the native MLIR conversion framework:
* **Target Management**: Defining `ConversionTarget` objects to specify legal and illegal operations.
* **Type Conversion**: `TypeConverter` objects for systematic re-mapping of data types across layers.
* **Rewrite Patterns**: Managed sets of `RewritePattern` for atomic IR transformations.

### 8.2 Standard Lowering Flow
A typical transformation journey follows a structured path:
1.  **High-Level**: Domain-specific dialects (e.g., Linalg)
2.  **Structured**: SCF, Tensor, and Vector abstractions
3.  **Low-Level**: MemRef, CF, and Affine structures
4.  **Native**: LLVM IR and target-specific dialects (NVVM, ROCDL)

---

## 9. Code Generation and Execution

The platform bridges the gap between intermediate representation and hardware execution via LLVM.

### 9.1 LLVM Backend Integration
Translation to LLVM IR preserves all critical compiler metadata:
* **Architecture Support**: Configuration for data layouts and target triples.
* **Calling Conventions**: Consistent ABI management for interoperability.
* **Optimization**: Propagation of debug info and optimization hints.

### 9.2 Execution Modes
The Mojo API supports multiple execution paths:
* **JIT (ORC)**: Real-time compilation and execution with symbol interposition and dynamic resolution.
* **AOT Compilation**: Emission of object files and shared libraries for permanent deployment.
* **LTO**: Cross-module linkage-time optimization for production builds.

---

### Determinism
* **Pass Ordering**: Guaranteed stable execution order of transformations.
* **Serialization**: Robust MLIR bytecode support for stable, version-agnostic IR storage.

---

## 11. Plugin and Extension Model

The platform supports both native and Mojo-authored extensions:

* **Native Plugins**: Binary dialect or pass plugins that implement a registration entrypoint via the C ABI.
* **Mojo Plugins**: Dialects, patterns, or passes implemented directly in Mojo by constructing IR or providing specialized pass objects.
* **Compatibility**: The loader enforces strict versioning and policy checks for all external plugins.

---

## 12. Summary

This architecture exposes MLIR’s complete, upstream-supported compilation pipeline through a high-performance, Mojo-native API. By covering the entire IR lifecycle—from construction and analysis to multi-stage lowering and JIT/AOT execution—it provides a production-grade foundation while maintaining strict semantic compatibility with the broader MLIR ecosystem.

Advanced and experimental capabilities, such as runtime dialect synthesis and declarative pattern meta-languages, are designed to build seamlessly upon these core architectural pillars.