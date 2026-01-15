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

For more details, see [docs/architecture.md](docs/architecture.md).

## License

MIT License
