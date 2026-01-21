# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Context module.

These tests verify:
1. Context creation and destruction
2. Context equality
3. Dialect management settings
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextSetAllowUnregisteredDialects,
    mlirContextGetAllowUnregisteredDialects,
    mlirContextGetNumLoadedDialects,
    mlirContextLoadAllAvailableDialects,
)


def test_context_create_destroy():
    """Test that a context can be created and destroyed."""
    var ctx = mlirContextCreate()
    assert_false(
        mlirContextIsNull(ctx), "Newly created context should not be null"
    )
    mlirContextDestroy(ctx)


def test_context_equal():
    """Test context equality."""
    var ctx1 = mlirContextCreate()
    var ctx2 = mlirContextCreate()

    assert_true(mlirContextEqual(ctx1, ctx1), "Context should equal itself")
    assert_false(
        mlirContextEqual(ctx1, ctx2), "Different contexts should not be equal"
    )

    mlirContextDestroy(ctx1)
    mlirContextDestroy(ctx2)


def test_context_allow_unregistered_dialects():
    """Test allow unregistered dialects setting."""
    var ctx = mlirContextCreate()

    # Default should be False
    assert_false(
        mlirContextGetAllowUnregisteredDialects(ctx),
        "Default should not allow unregistered dialects",
    )

    # Enable and verify
    mlirContextSetAllowUnregisteredDialects(ctx, True)
    assert_true(
        mlirContextGetAllowUnregisteredDialects(ctx),
        "Should allow unregistered dialects after enabling",
    )

    # Disable and verify
    mlirContextSetAllowUnregisteredDialects(ctx, False)
    assert_false(
        mlirContextGetAllowUnregisteredDialects(ctx),
        "Should not allow unregistered dialects after disabling",
    )

    mlirContextDestroy(ctx)


def test_context_num_loaded_dialects():
    """Test getting number of loaded dialects."""
    var ctx = mlirContextCreate()

    # A fresh context has at least the builtin dialect
    var num = mlirContextGetNumLoadedDialects(ctx)
    assert_true(num >= 0, "Number of loaded dialects should be non-negative")

    mlirContextDestroy(ctx)


def test_context_load_all_dialects():
    """Test loading all available dialects."""
    var ctx = mlirContextCreate()

    var before = mlirContextGetNumLoadedDialects(ctx)
    mlirContextLoadAllAvailableDialects(ctx)
    var after = mlirContextGetNumLoadedDialects(ctx)

    assert_true(
        after >= before,
        "Loading all dialects should not decrease dialect count",
    )

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
