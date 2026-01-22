# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Location module.

Comprehensive tests covering:
1. Unknown location creation
2. File line column location creation
3. Location equality and inequality
4. Location context relationships
5. Location printing
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextEqual,
    mlirContextIsNull,
)
from mlir.core.location import (
    mlirLocationUnknownGet,
    mlirLocationFileLineColGet,
    mlirLocationIsNull,
    mlirLocationEqual,
    mlirLocationGetContext,
    mlirLocationPrint,
)


# ===----------------------------------------------------------------------=== #
# Unknown Location Tests
# ===----------------------------------------------------------------------=== #


def test_unknown_location_create():
    """Test creating an unknown location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    assert_false(mlirLocationIsNull(loc), "Unknown location should not be null")

    mlirContextDestroy(ctx)


def test_unknown_location_equal_same():
    """Test unknown location equals itself."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    assert_true(
        mlirLocationEqual(loc, loc), "Unknown location should equal itself"
    )

    mlirContextDestroy(ctx)


def test_unknown_locations_same_context_equal():
    """Test that unknown locations from same context are equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationUnknownGet(ctx)
    var loc2 = mlirLocationUnknownGet(ctx)

    assert_true(
        mlirLocationEqual(loc1, loc2),
        "Unknown locations from same context should be equal",
    )

    mlirContextDestroy(ctx)


def test_unknown_locations_different_context_not_equal():
    """Test that unknown locations from different contexts are not equal."""
    var ctx1 = mlirContextCreate()
    var ctx2 = mlirContextCreate()
    var loc1 = mlirLocationUnknownGet(ctx1)
    var loc2 = mlirLocationUnknownGet(ctx2)

    assert_false(
        mlirLocationEqual(loc1, loc2),
        "Unknown locations from different contexts should not be equal",
    )

    mlirContextDestroy(ctx1)
    mlirContextDestroy(ctx2)


# ===----------------------------------------------------------------------=== #
# File Line Column Location Tests
# ===----------------------------------------------------------------------=== #


def test_file_line_col_location_create():
    """Test creating a file line column location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    assert_false(
        mlirLocationIsNull(loc), "File line col location should not be null"
    )

    mlirContextDestroy(ctx)


def test_file_line_col_location_equal_same():
    """Test file line col location equals itself."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    assert_true(
        mlirLocationEqual(loc, loc),
        "File line col location should equal itself",
    )

    mlirContextDestroy(ctx)


def test_file_line_col_location_same_params_equal():
    """Test file line col locations with same params are equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)
    var loc2 = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    assert_true(
        mlirLocationEqual(loc1, loc2),
        "File line col locations with same params should be equal",
    )

    mlirContextDestroy(ctx)


def test_file_line_col_location_different_file():
    """Test file line col locations with different files are not equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationFileLineColGet(ctx, "test1.mojo", 10, 5)
    var loc2 = mlirLocationFileLineColGet(ctx, "test2.mojo", 10, 5)

    assert_false(
        mlirLocationEqual(loc1, loc2),
        "Locations with different files should not be equal",
    )

    mlirContextDestroy(ctx)


def test_file_line_col_location_different_line():
    """Test file line col locations with different lines are not equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)
    var loc2 = mlirLocationFileLineColGet(ctx, "test.mojo", 20, 5)

    assert_false(
        mlirLocationEqual(loc1, loc2),
        "Locations with different lines should not be equal",
    )

    mlirContextDestroy(ctx)


def test_file_line_col_location_different_column():
    """Test file line col locations with different columns are not equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)
    var loc2 = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 15)

    assert_false(
        mlirLocationEqual(loc1, loc2),
        "Locations with different columns should not be equal",
    )

    mlirContextDestroy(ctx)


def test_file_line_col_line_zero():
    """Test file line col location with line 0."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 0, 0)

    assert_false(
        mlirLocationIsNull(loc), "Location with line 0 should not be null"
    )

    mlirContextDestroy(ctx)


def test_file_line_col_large_values():
    """Test file line col location with large line/column values."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 1000000, 500)

    assert_false(
        mlirLocationIsNull(loc), "Location with large values should not be null"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Unknown vs File Location Tests
# ===----------------------------------------------------------------------=== #


def test_unknown_vs_file_location_not_equal():
    """Test that unknown and file locations are not equal."""
    var ctx = mlirContextCreate()
    var unknown = mlirLocationUnknownGet(ctx)
    var file_loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    assert_false(
        mlirLocationEqual(unknown, file_loc),
        "Unknown and file locations should not be equal",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Location Context Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_location_get_context_unknown():
    """Test getting context from unknown location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var loc_ctx = mlirLocationGetContext(loc)
    assert_false(
        mlirContextIsNull(loc_ctx), "Location context should not be null"
    )
    assert_true(
        mlirContextEqual(ctx, loc_ctx),
        "Location context should match creating context",
    )

    mlirContextDestroy(ctx)


def test_location_get_context_file():
    """Test getting context from file location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    var loc_ctx = mlirLocationGetContext(loc)
    assert_true(
        mlirContextEqual(ctx, loc_ctx),
        "File location context should match creating context",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Location Printing Tests
# ===----------------------------------------------------------------------=== #


def test_location_print_unknown():
    """Test printing unknown location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var output = String()
    mlirLocationPrint(loc, output)

    assert_true(len(output) > 0, "Printed location should not be empty")

    mlirContextDestroy(ctx)


def test_location_print_file_line_col():
    """Test printing file line col location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    var output = String()
    mlirLocationPrint(loc, output)

    assert_true(len(output) > 0, "Printed location should not be empty")
    assert_true("test.mojo" in output, "Printed output should contain filename")

    mlirContextDestroy(ctx)


def test_location_print_file_contains_line():
    """Test that printed file location contains line number."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationFileLineColGet(ctx, "myfile.py", 42, 1)

    var output = String()
    mlirLocationPrint(loc, output)

    assert_true("myfile.py" in output, "Should contain filename")
    assert_true("42" in output, "Should contain line number")

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
