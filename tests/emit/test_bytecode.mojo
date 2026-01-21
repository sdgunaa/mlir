# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR bytecode module.

Verifies bytecode writer config creation and version setting doesn't crash.
Note: Cannot verify written bytecode without file I/O.
"""

from testing import assert_true, TestSuite
from mlir.emit.bytecode import (
    mlirBytecodeWriterConfigCreate,
    mlirBytecodeWriterConfigDestroy,
    mlirBytecodeWriterConfigDesiredEmitVersion,
)


def test_bytecode_config_lifecycle():
    """Test creating, configuring, and destroying bytecode writer config."""
    var config = mlirBytecodeWriterConfigCreate()

    # Set various versions to test the setter doesn't crash
    mlirBytecodeWriterConfigDesiredEmitVersion(config, 1)
    mlirBytecodeWriterConfigDesiredEmitVersion(config, 2)

    mlirBytecodeWriterConfigDestroy(config)
    assert_true(True)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
