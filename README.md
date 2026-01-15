# MLIR Mojo Bindings

A first-class, general-purpose MLIR platform for the [Mojo programming language](https://www.modular.com/mojo). This project exposes the complete upstream MLIR stack—from IR construction and dialect management to staged lowering and JIT/AOT execution—through a stable, high-performance Mojo interface.

## Quick Start

This project uses [pixi](https://pixi.sh) for dependency management.

```bash
# Install dependencies and setup environment
pixi install
```

## Project Structure

- `mlir/`: Core Mojo packages for MLIR bindings.
  - `core/`: Basic IR entities (Module, Operation, Type, etc.).
  - `dialects/`: Upstream MLIR dialect bindings.
  - `ffi/`: Low-level C-API bridge and ABI boundary.
  - `passes/`: Pass management and pipeline infrastructure.
  - `runtime/`: Execution engines and JIT/AOT support.
- `docs/`: Comprehensive documentation.
  - `architecture.md`: Detailed architectural overview.
  - `ffi.md`: Deep dive into the Mojo-MLIR bridge.

## Architecture

The platform is built around three primary design goals:
* **Native Power, Mojo Simplicity**: Leverage battle-tested MLIR/LLVM implementations while authoring compiler logic entirely in Mojo.
* **Type-Safe IR Construction**: Robust, idiomatic Mojo APIs for IR manipulation.
* **Architectural Stability**: Maintain a viable API across MLIR version upgrades.

For more details, see [docs/architecture.md](docs/architecture.md).

## License

[Add License Information Here]
