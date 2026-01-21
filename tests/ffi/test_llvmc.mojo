# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the LLVM-C FFI layer.

Verifies LLVM-C library loading and symbol availability.
"""

from testing import assert_true, assert_false, TestSuite
from mlir.ffi import has_llvmc_symbol


def test_core_symbols_available():
    """Test that core LLVM C-API symbols are available."""
    assert_true(has_llvmc_symbol["LLVMContextCreate"]())
    assert_true(has_llvmc_symbol["LLVMContextDispose"]())
    assert_true(has_llvmc_symbol["LLVMModuleCreateWithName"]())
    assert_true(has_llvmc_symbol["LLVMDisposeModule"]())
    assert_true(has_llvmc_symbol["LLVMGetGlobalContext"]())


def test_missing_symbol_returns_false():
    """Test that non-existent symbol lookup returns False."""
    assert_false(has_llvmc_symbol["nonExistentSymbolXYZ123"]())


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
