# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Value module.

These tests verify:
1. Value type retrieval
2. Value equality
3. Block argument detection
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
)
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetBody,
    mlirModuleDestroy,
)
from mlir.core.type import mlirTypeParseGet, mlirTypeIsNull
from mlir.core.block import mlirBlockAddArgument, mlirBlockGetArgument
from mlir.core.value import (
    mlirValueIsNull,
    mlirValueEqual,
    mlirValueIsABlockArgument,
    mlirValueGetType,
)


def test_value_from_block_argument():
    """Test creating a value as block argument."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    assert_false(
        mlirValueIsNull(arg), "Block argument value should not be null"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_is_block_argument():
    """Test detecting block argument value."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    assert_true(
        mlirValueIsABlockArgument(arg), "Value should be a block argument"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_get_type():
    """Test getting type from value."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    var value_type = mlirValueGetType(arg)
    assert_false(mlirTypeIsNull(value_type), "Value type should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_equal():
    """Test value equality."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg1 = mlirBlockGetArgument(body, 0)
    var arg2 = mlirBlockGetArgument(body, 0)

    assert_true(mlirValueEqual(arg1, arg1), "Value should equal itself")
    assert_true(
        mlirValueEqual(arg1, arg2), "Same value retrieved twice should be equal"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
