# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Block module.

Verifies block operations, arguments, and parent relationships.
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetBody,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.block import (
    mlirBlockIsNull,
    mlirBlockEqual,
    mlirBlockGetNumArguments,
    mlirBlockGetParentOperation,
    mlirBlockAddArgument,
    mlirBlockGetArgument,
)
from mlir.core.type import mlirTypeParseGet
from mlir.core.operation import mlirOperationEqual
from mlir.core.value import mlirValueIsABlockArgument


def test_block_from_module():
    """Test getting block from module and verifying parent relationship."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var mod_op = mlirModuleGetOperation(mod)

    var body = mlirModuleGetBody(mod)
    assert_false(mlirBlockIsNull(body))

    # Block's parent should be the module operation
    var parent = mlirBlockGetParentOperation(body)
    assert_true(mlirOperationEqual(parent, mod_op))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_equality():
    """Test that same block retrieved multiple times is equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body1 = mlirModuleGetBody(mod)
    var body2 = mlirModuleGetBody(mod)

    assert_true(mlirBlockEqual(body1, body2))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_arguments():
    """Test adding and retrieving block arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)

    # Initially no arguments
    assert_equal(mlirBlockGetNumArguments(body), 0)

    # Add an i32 argument
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var _ = mlirBlockAddArgument(body, i32_type, loc)

    # Now 1 argument
    assert_equal(mlirBlockGetNumArguments(body), 1)

    # Retrieved argument should be a block argument
    var retrieved = mlirBlockGetArgument(body, 0)
    assert_true(mlirValueIsABlockArgument(retrieved))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
