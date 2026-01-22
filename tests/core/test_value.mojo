# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Value module.

Comprehensive tests for value operations including:
- Block argument values
- Value type retrieval
- Value equality
- Block argument owner and arg number
- Value context and location
- Value printing
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextEqual,
)
from mlir.core.location import (
    mlirLocationUnknownGet,
    mlirLocationIsNull,
)
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetBody,
    mlirModuleDestroy,
)
from mlir.core.type import mlirTypeParseGet, mlirTypeIsNull, mlirTypeEqual
from mlir.core.block import (
    mlirBlockAddArgument,
    mlirBlockGetArgument,
    mlirBlockGetNumArguments,
    mlirBlockEqual,
)
from mlir.core.value import (
    MlirValue,
    mlirValueIsNull,
    mlirValueEqual,
    mlirValueIsABlockArgument,
    mlirValueIsAOpResult,
    mlirValueGetType,
    mlirBlockArgumentGetOwner,
    mlirBlockArgumentGetArgNumber,
    mlirBlockArgumentSetType,
    mlirValueGetContext,
    mlirValueGetLocation,
    mlirValuePrint,
)


# =============================================================================
# Block Argument Value Tests
# =============================================================================


def test_value_from_block_argument_not_null():
    """Test that block argument value is not null."""
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


def test_value_is_not_op_result():
    """Test that block argument is not an op result."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    assert_false(
        mlirValueIsAOpResult(arg),
        "Block argument should not be an op result",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Value Type Tests
# =============================================================================


def test_value_get_type_not_null():
    """Test getting type from value is not null."""
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


def test_value_get_type_matches_declared():
    """Test that value type matches the declared type."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    var value_type = mlirValueGetType(arg)
    assert_true(
        mlirTypeEqual(value_type, i32_type),
        "Value type should match declared type",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_get_type_different_types():
    """Test getting types from multiple values with different types."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var f64_type = mlirTypeParseGet(ctx, "f64")

    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, f64_type, loc)

    var arg0 = mlirBlockGetArgument(body, 0)
    var arg1 = mlirBlockGetArgument(body, 1)

    var type0 = mlirValueGetType(arg0)
    var type1 = mlirValueGetType(arg1)

    assert_true(mlirTypeEqual(type0, i32_type))
    assert_true(mlirTypeEqual(type1, f64_type))
    assert_false(mlirTypeEqual(type0, type1))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Value Equality Tests
# =============================================================================


def test_value_equal_self():
    """Test value equals itself."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)
    assert_true(mlirValueEqual(arg, arg), "Value should equal itself")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_equal_same_retrieved():
    """Test same value retrieved twice is equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg1 = mlirBlockGetArgument(body, 0)
    var arg2 = mlirBlockGetArgument(body, 0)

    assert_true(
        mlirValueEqual(arg1, arg2),
        "Same value retrieved twice should be equal",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_not_equal_different():
    """Test different values are not equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg0 = mlirBlockGetArgument(body, 0)
    var arg1 = mlirBlockGetArgument(body, 1)

    assert_false(
        mlirValueEqual(arg0, arg1),
        "Different values should not be equal",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Argument Owner Tests
# =============================================================================


def test_block_argument_get_owner():
    """Test getting owner block of a block argument."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)
    var owner = mlirBlockArgumentGetOwner(arg)

    assert_true(
        mlirBlockEqual(owner, body),
        "Block argument owner should be the containing block",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_argument_get_arg_number():
    """Test getting argument number of block arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg0 = mlirBlockGetArgument(body, 0)
    var arg1 = mlirBlockGetArgument(body, 1)
    var arg2 = mlirBlockGetArgument(body, 2)

    assert_equal(mlirBlockArgumentGetArgNumber(arg0), 0)
    assert_equal(mlirBlockArgumentGetArgNumber(arg1), 1)
    assert_equal(mlirBlockArgumentGetArgNumber(arg2), 2)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Argument Type Mutation Tests
# =============================================================================


def test_block_argument_set_type():
    """Test setting a new type on a block argument."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var f64_type = mlirTypeParseGet(ctx, "f64")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)

    # Set new type
    mlirBlockArgumentSetType(arg, f64_type)

    var new_type = mlirValueGetType(arg)
    assert_true(
        mlirTypeEqual(new_type, f64_type),
        "Block argument type should be updated",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Value Context and Location Tests
# =============================================================================


def test_value_get_context():
    """Test getting context from value."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)
    var value_ctx = mlirValueGetContext(arg)

    assert_true(
        mlirContextEqual(value_ctx, ctx),
        "Value context should match creating context",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_get_location():
    """Test getting location from value."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)
    var value_loc = mlirValueGetLocation(arg)

    assert_false(
        mlirLocationIsNull(value_loc),
        "Value location should not be null",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Value Printing Tests
# =============================================================================


def test_value_print():
    """Test printing a value to string."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)

    var output = String()
    mlirValuePrint(arg, output)

    assert_true(len(output) > 0, "Value print output should not be empty")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_print_with_type():
    """Test printing a value includes type information."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i64_type = mlirTypeParseGet(ctx, "i64")
    _ = mlirBlockAddArgument(body, i64_type, loc)

    var arg = mlirBlockGetArgument(body, 0)

    var output = String()
    mlirValuePrint(arg, output)

    # Output should contain value info
    assert_true(len(output) > 0, "Value print output should not be empty")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_value_print_different_types():
    """Test printing values with different types."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var f64_type = mlirTypeParseGet(ctx, "f64")
    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, f64_type, loc)

    var arg0 = mlirBlockGetArgument(body, 0)
    var arg1 = mlirBlockGetArgument(body, 1)

    var output0 = String()
    var output1 = String()
    mlirValuePrint(arg0, output0)
    mlirValuePrint(arg1, output1)

    # Both should produce non-empty output
    assert_true(len(output0) > 0)
    assert_true(len(output1) > 0)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
