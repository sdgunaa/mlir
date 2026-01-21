# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Dialect module.

These tests verify:
1. Dialect registry creation and destruction
2. Dialect equality
3. Dialect context retrieval
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextGetOrLoadDialect,
    mlirContextLoadAllAvailableDialects,
    mlirContextAppendDialectRegistry,
)
from mlir.core.dialect import (
    mlirDialectRegistryCreate,
    mlirRegisterAllDialects,
    mlirDialectRegistryDestroy,
    mlirDialectRegistryIsNull,
    mlirDialectIsNull,
    mlirDialectEqual,
    mlirDialectGetContext,
)


def test_dialect_registry_create_destroy():
    """Test creating and destroying a dialect registry."""
    var registry = mlirDialectRegistryCreate()
    assert_false(
        mlirDialectRegistryIsNull(registry),
        "Created registry should not be null",
    )
    mlirDialectRegistryDestroy(registry)


def test_dialect_load_builtin():
    """Test loading builtin dialect."""
    var ctx = mlirContextCreate()

    # Load builtin dialect
    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    assert_false(
        mlirDialectIsNull(dialect), "Builtin dialect should not be null"
    )

    mlirContextDestroy(ctx)


def test_dialect_equal():
    """Test dialect equality."""
    var ctx = mlirContextCreate()

    var dialect1 = mlirContextGetOrLoadDialect(ctx, "builtin")
    var dialect2 = mlirContextGetOrLoadDialect(ctx, "builtin")

    assert_true(
        mlirDialectEqual(dialect1, dialect1), "Dialect should equal itself"
    )
    assert_true(
        mlirDialectEqual(dialect1, dialect2),
        "Same dialect loaded twice should be equal",
    )

    mlirContextDestroy(ctx)


def test_dialect_get_context():
    """Test getting context from dialect."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    var dialect_ctx = mlirDialectGetContext(dialect)

    assert_false(
        mlirContextIsNull(dialect_ctx), "Dialect context should not be null"
    )

    mlirContextDestroy(ctx)


def test_load_all_dialects():
    """Test loading all available dialects doesn't crash."""
    var ctx = mlirContextCreate()

    # Just verify this function doesn't crash
    mlirContextLoadAllAvailableDialects(ctx)

    # Builtin should always be available
    var builtin = mlirContextGetOrLoadDialect(ctx, "builtin")
    assert_false(
        mlirDialectIsNull(builtin), "Builtin dialect should be available"
    )

    mlirContextDestroy(ctx)


def test_register_all_dialects():
    """Test registering all dialects to a registry and using them."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    # Create context and append the registry
    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    # Now arith dialect should be loadable
    var arith = mlirContextGetOrLoadDialect(ctx, "arith")
    assert_false(
        mlirDialectIsNull(arith),
        "Arith dialect should be available after registering all dialects",
    )

    # func dialect should also be available
    var func = mlirContextGetOrLoadDialect(ctx, "func")
    assert_false(
        mlirDialectIsNull(func),
        "Func dialect should be available after registering all dialects",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
