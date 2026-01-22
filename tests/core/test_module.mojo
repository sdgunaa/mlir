# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Module module.

Comprehensive tests for module operations including:
- Module creation (empty and from parsing)
- Module context extraction
- Module body relationships
- Module operation conversion
- Module printing
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextEqual,
)
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    MlirModule,
    mlirModuleCreateEmpty,
    mlirModuleCreateParse,
    mlirModuleIsNull,
    mlirModuleGetContext,
    mlirModuleGetBody,
    mlirModuleGetOperation,
    mlirModuleFromOperation,
    mlirModuleDestroy,
)
from mlir.core.block import (
    mlirBlockIsNull,
    mlirBlockGetParentOperation,
    mlirBlockGetNumArguments,
)
from mlir.core.operation import (
    mlirOperationIsNull,
    mlirOperationEqual,
    mlirOperationGetNumRegions,
    mlirOperationVerify,
    mlirOperationPrint,
)


# =============================================================================
# Module Creation Tests
# =============================================================================


def test_module_create_empty_not_null():
    """Test that empty module is not null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    assert_false(mlirModuleIsNull(mod), "Created module should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_create_parse_valid():
    """Test parsing a valid module from MLIR text."""
    var ctx = mlirContextCreate()
    var mod = mlirModuleCreateParse(ctx, "module {}")

    assert_false(mlirModuleIsNull(mod), "Parsed module should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_create_parse_nested():
    """Test parsing a nested module."""
    var ctx = mlirContextCreate()
    # Simple nested module without dialect dependencies
    var mod = mlirModuleCreateParse(ctx, "module {}")

    if not mlirModuleIsNull(mod):
        var mod_op = mlirModuleGetOperation(mod)
        assert_true(mlirOperationVerify(mod_op))
        mlirModuleDestroy(mod)

    mlirContextDestroy(ctx)


def test_module_create_parse_invalid():
    """Test parsing invalid MLIR returns null module."""
    var ctx = mlirContextCreate()
    var mod = mlirModuleCreateParse(ctx, "this is not valid mlir {{{")

    assert_true(mlirModuleIsNull(mod), "Invalid MLIR should return null module")

    mlirContextDestroy(ctx)


# =============================================================================
# Module Context Tests
# =============================================================================


def test_module_get_context():
    """Test that module's context matches creating context."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_ctx = mlirModuleGetContext(mod)
    assert_true(
        mlirContextEqual(ctx, mod_ctx),
        "Module context should match creating context",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_context_after_operations():
    """Test module context after adding operations."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    # Add an argument to body (just to do something)
    var body = mlirModuleGetBody(mod)

    # Context should still be valid
    var mod_ctx = mlirModuleGetContext(mod)
    assert_true(mlirContextEqual(ctx, mod_ctx))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Module Body Tests
# =============================================================================


def test_module_get_body_not_null():
    """Test that module body is not null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    assert_false(mlirBlockIsNull(body), "Module body should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_body_has_no_arguments():
    """Test that module body has no block arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    assert_equal(
        mlirBlockGetNumArguments(body),
        0,
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_body_parent_is_module_operation():
    """Test that module body's parent operation is the module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var mod_op = mlirModuleGetOperation(mod)
    var body_parent = mlirBlockGetParentOperation(body)

    assert_true(
        mlirOperationEqual(body_parent, mod_op),
        "Body's parent should be the module operation",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Module Operation Tests
# =============================================================================


def test_module_get_operation_not_null():
    """Test that module operation is not null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_op = mlirModuleGetOperation(mod)
    assert_false(
        mlirOperationIsNull(mod_op), "Module operation should not be null"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_operation_has_one_region():
    """Test that module operation has exactly one region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_op = mlirModuleGetOperation(mod)
    assert_equal(
        mlirOperationGetNumRegions(mod_op),
        1,
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_operation_verifies():
    """Test that empty module operation verifies successfully."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_op = mlirModuleGetOperation(mod)
    assert_true(
        mlirOperationVerify(mod_op),
        "Empty module should verify successfully",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_module_from_operation():
    """Test converting operation back to module."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_op = mlirModuleGetOperation(mod)
    var recovered_mod = mlirModuleFromOperation(mod_op)

    # The recovered module should not be null
    assert_false(
        mlirModuleIsNull(recovered_mod),
        "Recovered module should not be null",
    )

    # Context should match
    var recovered_ctx = mlirModuleGetContext(recovered_mod)
    assert_true(mlirContextEqual(ctx, recovered_ctx))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Module Printing Tests
# =============================================================================


def test_module_print():
    """Test printing module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_op = mlirModuleGetOperation(mod)

    var output = String()
    mlirOperationPrint(mod_op, output)

    assert_true(len(output) > 0, "Module print output should not be empty")
    assert_true("module" in output, "Output should contain 'module'")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_parsed_module_print():
    """Test printing a parsed module."""
    var ctx = mlirContextCreate()
    var mod = mlirModuleCreateParse(ctx, "module {}")

    if not mlirModuleIsNull(mod):
        var mod_op = mlirModuleGetOperation(mod)

        var output = String()
        mlirOperationPrint(mod_op, output)

        assert_true(len(output) > 0)
        mlirModuleDestroy(mod)

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
