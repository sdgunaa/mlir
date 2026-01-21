# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Module module.

Verifies module creation, context extraction, and body relationships.
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextEqual,
)
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleIsNull,
    mlirModuleGetContext,
    mlirModuleGetBody,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.block import mlirBlockIsNull, mlirBlockGetParentOperation
from mlir.core.operation import mlirOperationIsNull, mlirOperationEqual


def test_module_context_extraction():
    """Test that module's context matches creating context."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var mod_ctx = mlirModuleGetContext(mod)

    # The contexts should be equal
    assert_true(mlirContextEqual(ctx, mod_ctx))

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

    # Body's parent should be the module operation
    assert_true(mlirOperationEqual(body_parent, mod_op))

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
