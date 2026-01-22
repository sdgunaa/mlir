# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Dialect module.

Comprehensive tests for dialect operations including:
- Dialect registry creation and destruction
- Dialect loading and registration
- Dialect equality and context
- Multiple dialect management
- Namespace retrieval
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextGetOrLoadDialect,
    mlirContextLoadAllAvailableDialects,
    mlirContextAppendDialectRegistry,
    mlirContextGetNumLoadedDialects,
    mlirContextGetNumRegisteredDialects,
)
from mlir.core.dialect import (
    MlirDialect,
    mlirDialectRegistryCreate,
    mlirRegisterAllDialects,
    mlirDialectRegistryDestroy,
    mlirDialectRegistryIsNull,
    mlirDialectIsNull,
    mlirDialectEqual,
    mlirDialectGetContext,
    mlirDialectGetNamespace,
)


# =============================================================================
# Dialect Registry Tests
# =============================================================================


def test_dialect_registry_create():
    """Test creating a dialect registry."""
    var registry = mlirDialectRegistryCreate()
    assert_false(
        mlirDialectRegistryIsNull(registry),
        "Created registry should not be null",
    )
    mlirDialectRegistryDestroy(registry)


def test_dialect_registry_create_destroy_cycle():
    """Test create/destroy lifecycle of multiple registries."""
    for _ in range(5):
        var registry = mlirDialectRegistryCreate()
        assert_false(mlirDialectRegistryIsNull(registry))
        mlirDialectRegistryDestroy(registry)


def test_register_all_dialects_to_registry():
    """Test registering all dialects to a registry."""
    var registry = mlirDialectRegistryCreate()

    # This should not crash
    mlirRegisterAllDialects(registry)

    mlirDialectRegistryDestroy(registry)


# =============================================================================
# Dialect Loading Tests
# =============================================================================


def test_load_builtin_dialect():
    """Test loading the builtin dialect."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    assert_false(
        mlirDialectIsNull(dialect), "Builtin dialect should not be null"
    )

    mlirContextDestroy(ctx)


def test_load_builtin_dialect_twice():
    """Test loading the same dialect twice returns same dialect."""
    var ctx = mlirContextCreate()

    var dialect1 = mlirContextGetOrLoadDialect(ctx, "builtin")
    var dialect2 = mlirContextGetOrLoadDialect(ctx, "builtin")

    assert_true(
        mlirDialectEqual(dialect1, dialect2),
        "Loading same dialect twice should return equal dialects",
    )

    mlirContextDestroy(ctx)


def test_load_nonexistent_dialect():
    """Test loading a non-existent dialect returns null."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "nonexistent_dialect_xyz")
    assert_true(
        mlirDialectIsNull(dialect),
        "Non-existent dialect should return null",
    )

    mlirContextDestroy(ctx)


def test_load_all_available_dialects():
    """Test loading all available dialects doesn't crash."""
    var ctx = mlirContextCreate()

    mlirContextLoadAllAvailableDialects(ctx)

    # Builtin should always be available
    var builtin = mlirContextGetOrLoadDialect(ctx, "builtin")
    assert_false(
        mlirDialectIsNull(builtin), "Builtin dialect should be available"
    )

    mlirContextDestroy(ctx)


# =============================================================================
# Dialect Equality Tests
# =============================================================================


def test_dialect_equal_self():
    """Test dialect equals itself."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    assert_true(
        mlirDialectEqual(dialect, dialect), "Dialect should equal itself"
    )

    mlirContextDestroy(ctx)


def test_dialect_equal_same_loaded():
    """Test same dialect loaded twice is equal."""
    var ctx = mlirContextCreate()

    var dialect1 = mlirContextGetOrLoadDialect(ctx, "builtin")
    var dialect2 = mlirContextGetOrLoadDialect(ctx, "builtin")

    assert_true(mlirDialectEqual(dialect1, dialect1))
    assert_true(
        mlirDialectEqual(dialect1, dialect2),
        "Same dialect loaded twice should be equal",
    )

    mlirContextDestroy(ctx)


# =============================================================================
# Dialect Context Tests
# =============================================================================


def test_dialect_get_context():
    """Test getting context from dialect."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    var dialect_ctx = mlirDialectGetContext(dialect)

    assert_false(
        mlirContextIsNull(dialect_ctx), "Dialect context should not be null"
    )
    assert_true(
        mlirContextEqual(ctx, dialect_ctx),
        "Dialect context should match creating context",
    )

    mlirContextDestroy(ctx)


# =============================================================================
# Dialect Namespace Tests
# =============================================================================


def test_dialect_get_namespace():
    """Test getting namespace from builtin dialect."""
    var ctx = mlirContextCreate()

    var dialect = mlirContextGetOrLoadDialect(ctx, "builtin")
    var namespace = mlirDialectGetNamespace(dialect)

    assert_true(
        len(namespace) > 0, "Builtin dialect namespace should not be empty"
    )
    assert_equal(namespace, "builtin")

    mlirContextDestroy(ctx)


# =============================================================================
# Registry and Context Integration Tests
# =============================================================================


def test_append_registry_to_context():
    """Test appending a registry to a context."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    # arith dialect should now be loadable
    var arith = mlirContextGetOrLoadDialect(ctx, "arith")
    assert_false(
        mlirDialectIsNull(arith),
        "Arith dialect should be available after registering all dialects",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_load_multiple_dialects():
    """Test loading multiple different dialects."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    var arith = mlirContextGetOrLoadDialect(ctx, "arith")
    var func = mlirContextGetOrLoadDialect(ctx, "func")

    assert_false(mlirDialectIsNull(arith), "Arith should be loadable")
    assert_false(mlirDialectIsNull(func), "Func should be loadable")

    # They should be different dialects
    assert_false(
        mlirDialectEqual(arith, func),
        "Different dialects should not be equal",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_loaded_dialect_count():
    """Test counting loaded dialects."""
    var ctx = mlirContextCreate()

    var initial_count = mlirContextGetNumLoadedDialects(ctx)

    # Load builtin
    _ = mlirContextGetOrLoadDialect(ctx, "builtin")

    var after_count = mlirContextGetNumLoadedDialects(ctx)

    # Count should have increased or stayed same (if already loaded)
    assert_true(after_count >= initial_count)

    mlirContextDestroy(ctx)


def test_registered_dialect_count():
    """Test counting registered dialects after appending registry."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    var before_count = mlirContextGetNumRegisteredDialects(ctx)

    mlirContextAppendDialectRegistry(ctx, registry)

    var after_count = mlirContextGetNumRegisteredDialects(ctx)

    # Should have more registered dialects after appending registry
    assert_true(
        after_count >= before_count,
        "Registered dialect count should increase after appending registry",
    )

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_dialect_namespace_arith():
    """Test arith dialect namespace."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    var arith = mlirContextGetOrLoadDialect(ctx, "arith")
    if not mlirDialectIsNull(arith):
        var namespace = mlirDialectGetNamespace(arith)
        assert_equal(namespace, "arith")

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def test_dialect_namespace_func():
    """Test func dialect namespace."""
    var registry = mlirDialectRegistryCreate()
    mlirRegisterAllDialects(registry)

    var ctx = mlirContextCreate()
    mlirContextAppendDialectRegistry(ctx, registry)

    var func = mlirContextGetOrLoadDialect(ctx, "func")
    if not mlirDialectIsNull(func):
        var namespace = mlirDialectGetNamespace(func)
        assert_equal(namespace, "func")

    mlirContextDestroy(ctx)
    mlirDialectRegistryDestroy(registry)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
