# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Type module.

These tests verify:
1. Type parsing
2. Type equality
3. Type context retrieval
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
)
from mlir.core.type import (
    mlirTypeParseGet,
    mlirTypeIsNull,
    mlirTypeEqual,
    mlirTypeGetContext,
)


def test_type_parse_i32():
    """Test parsing i32 type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    assert_false(mlirTypeIsNull(i32_type), "Parsed i32 type should not be null")

    mlirContextDestroy(ctx)


def test_type_parse_f64():
    """Test parsing f64 type."""
    var ctx = mlirContextCreate()
    var f64_type = mlirTypeParseGet(ctx, "f64")

    assert_false(mlirTypeIsNull(f64_type), "Parsed f64 type should not be null")

    mlirContextDestroy(ctx)


def test_type_parse_index():
    """Test parsing index type."""
    var ctx = mlirContextCreate()
    var index_type = mlirTypeParseGet(ctx, "index")

    assert_false(
        mlirTypeIsNull(index_type), "Parsed index type should not be null"
    )

    mlirContextDestroy(ctx)


def test_type_equal():
    """Test type equality."""
    var ctx = mlirContextCreate()
    var i32_1 = mlirTypeParseGet(ctx, "i32")
    var i32_2 = mlirTypeParseGet(ctx, "i32")
    var f64 = mlirTypeParseGet(ctx, "f64")

    assert_true(mlirTypeEqual(i32_1, i32_1), "Type should equal itself")
    assert_true(mlirTypeEqual(i32_1, i32_2), "Same types should be equal")
    assert_false(
        mlirTypeEqual(i32_1, f64), "Different types should not be equal"
    )

    mlirContextDestroy(ctx)


def test_type_get_context():
    """Test getting context from type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    var type_ctx = mlirTypeGetContext(i32_type)
    assert_false(mlirContextIsNull(type_ctx), "Type context should not be null")

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
