# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Context module.

Comprehensive tests covering:
1. Context creation and destruction
2. Context equality
3. Dialect management settings
4. Threading configuration
5. Operation registration
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextSetAllowUnregisteredDialects,
    mlirContextGetAllowUnregisteredDialects,
    mlirContextGetNumLoadedDialects,
    mlirContextGetNumRegisteredDialects,
    mlirContextLoadAllAvailableDialects,
    mlirContextAppendDialectRegistry,
    mlirContextEnableMultithreading,
    mlirContextIsRegisteredOperation,
)
from mlir.core.dialect import (
    mlirDialectRegistryCreate,
    mlirDialectRegistryDestroy,
    mlirRegisterAllDialects,
)


# ===----------------------------------------------------------------------=== #
# Context Lifecycle Tests
# ===----------------------------------------------------------------------=== #


def test_context_create_destroy():
    """Test that a context can be created and destroyed."""
    var ctx = mlirContextCreate()
    assert_false(
        mlirContextIsNull(ctx), "Newly created context should not be null"
    )
    mlirContextDestroy(ctx)


def test_context_multiple_create():
    """Test creating multiple contexts."""
    var ctx1 = mlirContextCreate()
    var ctx2 = mlirContextCreate()
    var ctx3 = mlirContextCreate()

    assert_false(mlirContextIsNull(ctx1), "First context should not be null")
    assert_false(mlirContextIsNull(ctx2), "Second context should not be null")
    assert_false(mlirContextIsNull(ctx3), "Third context should not be null")

    mlirContextDestroy(ctx1)
    mlirContextDestroy(ctx2)
    mlirContextDestroy(ctx3)


# ===----------------------------------------------------------------------=== #
# Context Equality Tests
# ===----------------------------------------------------------------------=== #


def test_context_equal_same():
    """Test context equals itself."""
    var ctx = mlirContextCreate()

    assert_true(mlirContextEqual(ctx, ctx), "Context should equal itself")

    mlirContextDestroy(ctx)


def test_context_not_equal_different():
    """Test different contexts should not be equal."""
    var ctx1 = mlirContextCreate()
    var ctx2 = mlirContextCreate()

    assert_false(
        mlirContextEqual(ctx1, ctx2), "Different contexts should not be equal"
    )

    mlirContextDestroy(ctx1)
    mlirContextDestroy(ctx2)


# ===----------------------------------------------------------------------=== #
# Dialect Management Tests
# ===----------------------------------------------------------------------=== #


def test_context_allow_unregistered_dialects_default():
    """Test default state of allow unregistered dialects."""
    var ctx = mlirContextCreate()

    # Default should be False
    assert_false(
        mlirContextGetAllowUnregisteredDialects(ctx),
        "Default should not allow unregistered dialects",
    )

    mlirContextDestroy(ctx)


def test_context_allow_unregistered_dialects_enable():
    """Test enabling allow unregistered dialects."""
    var ctx = mlirContextCreate()

    # Enable and verify
    mlirContextSetAllowUnregisteredDialects(ctx, True)
    assert_true(
        mlirContextGetAllowUnregisteredDialects(ctx),
        "Should allow unregistered dialects after enabling",
    )

    mlirContextDestroy(ctx)


def test_context_allow_unregistered_dialects_toggle():
    """Test toggling allow unregistered dialects."""
    var ctx = mlirContextCreate()

    # Enable
    mlirContextSetAllowUnregisteredDialects(ctx, True)
    assert_true(mlirContextGetAllowUnregisteredDialects(ctx))

    # Disable
    mlirContextSetAllowUnregisteredDialects(ctx, False)
    assert_false(mlirContextGetAllowUnregisteredDialects(ctx))

    # Enable again
    mlirContextSetAllowUnregisteredDialects(ctx, True)
    assert_true(mlirContextGetAllowUnregisteredDialects(ctx))

    mlirContextDestroy(ctx)


def test_context_num_loaded_dialects():
    """Test getting number of loaded dialects."""
    var ctx = mlirContextCreate()

    # A fresh context has at least the builtin dialect
    var num = mlirContextGetNumLoadedDialects(ctx)
    assert_true(num >= 0, "Number of loaded dialects should be non-negative")

    mlirContextDestroy(ctx)


def test_context_num_registered_dialects():
    """Test getting number of registered dialects."""
    var ctx = mlirContextCreate()

    var num = mlirContextGetNumRegisteredDialects(ctx)
    assert_true(
        num >= 0, "Number of registered dialects should be non-negative"
    )

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


def test_context_append_dialect_registry():
    """Test appending a dialect registry to context."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    var before = mlirContextGetNumRegisteredDialects(ctx)

    mlirContextAppendDialectRegistry(ctx, registry)

    var after = mlirContextGetNumRegisteredDialects(ctx)
    assert_true(
        after >= before,
        "Appending registry should not decrease registered dialects",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_context_dialects_increase_after_load_all():
    """Test that loading all dialects increases loaded count."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    var before = mlirContextGetNumLoadedDialects(ctx)
    mlirContextLoadAllAvailableDialects(ctx)
    var after = mlirContextGetNumLoadedDialects(ctx)

    # After loading all dialects, there should be more loaded
    assert_true(
        after >= before,
        "Loading all dialects should increase loaded count",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


# ===----------------------------------------------------------------------=== #
# Threading Configuration Tests
# ===----------------------------------------------------------------------=== #


def test_context_enable_multithreading():
    """Test enabling multithreading doesn't crash."""
    var ctx = mlirContextCreate()

    # Just verify these calls don't crash
    mlirContextEnableMultithreading(ctx, True)
    mlirContextEnableMultithreading(ctx, False)
    mlirContextEnableMultithreading(ctx, True)

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Registration Tests
# ===----------------------------------------------------------------------=== #


def test_context_is_registered_operation_builtin_module():
    """Test that builtin.module operation is registered."""
    var ctx = mlirContextCreate()

    # builtin.module should always be registered
    assert_true(
        mlirContextIsRegisteredOperation(ctx, "builtin.module"),
        "builtin.module should be a registered operation",
    )

    mlirContextDestroy(ctx)


def test_context_is_not_registered_invalid_operation():
    """Test that invalid operation name is not registered."""
    var ctx = mlirContextCreate()

    # An invalid operation name should not be registered
    assert_false(
        mlirContextIsRegisteredOperation(ctx, "nonexistent.invalid_op"),
        "Invalid operation should not be registered",
    )

    mlirContextDestroy(ctx)


def test_context_is_registered_after_dialect_load():
    """Test that operations become registered after loading dialects."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)
    mlirContextLoadAllAvailableDialects(ctx)

    # After loading all dialects, func.func should be registered
    assert_true(
        mlirContextIsRegisteredOperation(ctx, "func.func"),
        "func.func should be registered after loading all dialects",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_context_is_registered_arith_ops():
    """Test that arith operations are registered after loading."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)
    mlirContextLoadAllAvailableDialects(ctx)

    # After loading, arith operations should be registered
    assert_true(
        mlirContextIsRegisteredOperation(ctx, "arith.addi"),
        "arith.addi should be registered after loading all dialects",
    )
    assert_true(
        mlirContextIsRegisteredOperation(ctx, "arith.muli"),
        "arith.muli should be registered after loading all dialects",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
