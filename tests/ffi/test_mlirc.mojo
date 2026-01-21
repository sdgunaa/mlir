# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR-C FFI layer.

Verifies MLIR-C library loading and symbol availability.
"""

from testing import assert_true, assert_false, TestSuite
from mlir.ffi import has_mlir_symbol


def test_core_symbols_available():
    """Test that core MLIR C-API symbols are available."""
    # Context symbols
    assert_true(has_mlir_symbol["mlirContextCreate"]())
    assert_true(has_mlir_symbol["mlirContextDestroy"]())

    # Module symbols
    assert_true(has_mlir_symbol["mlirModuleCreateEmpty"]())
    assert_true(has_mlir_symbol["mlirModuleCreateParse"]())

    # Operation symbols
    assert_true(has_mlir_symbol["mlirOperationCreate"]())

    # Location symbols
    assert_true(has_mlir_symbol["mlirLocationUnknownGet"]())

    # Type symbols
    assert_true(has_mlir_symbol["mlirTypeParseGet"]())


def test_missing_symbol_returns_false():
    """Test that non-existent symbol lookup returns False."""
    assert_false(has_mlir_symbol["nonExistentSymbolXYZ123"]())


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
