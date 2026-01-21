# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Location module.

Verifies location creation, equality, and context relationships.
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextEqual,
)
from mlir.core.location import (
    mlirLocationUnknownGet,
    mlirLocationFileLineColGet,
    mlirLocationIsNull,
    mlirLocationEqual,
    mlirLocationGetContext,
)


def test_unknown_vs_file_location_inequality():
    """Test that unknown and file locations are not equal."""
    var ctx = mlirContextCreate()
    var unknown = mlirLocationUnknownGet(ctx)
    var file_loc = mlirLocationFileLineColGet(ctx, "test.mojo", 10, 5)

    assert_false(mlirLocationIsNull(unknown))
    assert_false(mlirLocationIsNull(file_loc))

    # Different location kinds should not be equal
    assert_false(mlirLocationEqual(unknown, file_loc))

    mlirContextDestroy(ctx)


def test_location_context_extraction():
    """Test that location's context matches creating context."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var loc_ctx = mlirLocationGetContext(loc)

    # The contexts should be equal
    assert_true(mlirContextEqual(ctx, loc_ctx))

    mlirContextDestroy(ctx)


def test_unknown_locations_from_same_context_equal():
    """Test that unknown locations from same context are equal."""
    var ctx = mlirContextCreate()
    var loc1 = mlirLocationUnknownGet(ctx)
    var loc2 = mlirLocationUnknownGet(ctx)

    assert_true(mlirLocationEqual(loc1, loc2))

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
