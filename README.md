# MLIR Mojo Bindings

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A **first-class, general-purpose MLIR platform** for the [Mojo programming language](https://www.modular.com/mojo). This project exposes the complete upstream MLIR stack, from IR construction and dialect management to staged lowering and JIT/AOT execution through a almost stable, high-performance Mojo interface.

## Features

- **Complete C API Coverage** — Full bindings to LLVM and MLIR C APIs
- **Type-Safe IR Construction** — Idiomatic Mojo APIs for Operations, Blocks, Regions, Types, and Attributes
- **Dialect Support** — Access to all upstream MLIR dialects (builtin, func, arith, affine, linalg, etc.)
- **Pass Infrastructure** — Native pass pipeline orchestration and analysis frameworks
- **Serialization** — Support for both textual IR and MLIR bytecode
- **Multi-Platform** — Pre-built binaries for Linux (x64, ARM64) and macOS (Intel, Apple Silicon)

## Quick Start

```mojo
from mlir.core.context import Context
from mlir.core.location import Location
from mlir.core.module import Module

fn main() raises:
    # Create MLIR context and load dialects
    with Context() as ctx:
        ctx.load_all_available_dialects()
        
        # Parse MLIR module from string
        var loc = Location.unknown(ctx)
        var module = Module.parse(ctx, """
            func.func @add(%a: i32, %b: i32) -> i32 {
                %c = arith.addi %a, %b : i32
                return %c : i32
            }
        """, loc)
        
        # Print the module
        print(module)
```

## Project Structure

```
mlir/               # MLIR Mojo Bindings
scripts/            # Build and test scripts
tests/              # Comprehensive test suite
docs/               # Architecture and documentation
```

## Pre-built Binaries

LLVM+MLIR binaries with C API enabled are automatically built via GitHub Actions and published as [releases](https://github.com/sdgunaa/mlir/releases).

| Platform | Status |
|----------|--------|
| Linux x86_64 | ✓ |
| macOS Apple Silicon | ✓ |
| Linux ARM64 | ✗ |
| macOS Intel | ✗ |


## Documentation (not limited to)

- [Architecture Overview](docs/architecture.md) — Design and implementation details
- [FFI Layer](docs/ffi.md) — Low-level C API bridge documentation
- [Advanced Features](docs/advanced.md) — IRDL, PDL, and custom passes

## Requirements

- **Mojo** >= 24.6
- **LLVM/MLIR** 21.x (pre-built binaries provided)

## Contributing

Contributions are welcome! Please ensure:
1. Code follows the existing style
2. Tests pass (`./scripts/run_tests.sh`)
3. Commit messages follow [Conventional Commits](https://conventionalcommits.org)

## License

MIT License — see [LICENSE](LICENSE) for details.
