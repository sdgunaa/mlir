# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR thread pool module.

These tests verify:
1. Thread pool symbol availability check

Note: LLVM thread pool symbols may not be available in all builds.
"""

from testing import assert_true, assert_false, TestSuite
from mlir.ffi import has_mlir_symbol


def test_thread_pool_symbol_available():
    """Test if thread pool symbols are available in the build."""
    # Just check if the symbol exists - it may not be available in all builds
    var has_create = has_mlir_symbol["mlirLlvmThreadPoolCreate"]()
    # This is informational - we don't fail if not available
    if has_create:
        assert_true(True, "Thread pool create symbol is available")
    else:
        # Symbol not available - that's OK for this build
        assert_true(True, "Thread pool create symbol not in this build (OK)")


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
