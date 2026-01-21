# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Operation module.

These tests verify:
1. Operation context retrieval
2. Operation location retrieval
3. Operation verification
4. Operation region count
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
)
from mlir.core.location import (
    mlirLocationUnknownGet,
    mlirLocationIsNull,
)
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.operation import (
    mlirOperationIsNull,
    mlirOperationGetContext,
    mlirOperationGetLocation,
    mlirOperationVerify,
    mlirOperationGetNumRegions,
)


def test_operation_from_module():
    """Test getting operation from module."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    assert_false(mlirOperationIsNull(op), "Module operation should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_get_context():
    """Test getting context from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var op_ctx = mlirOperationGetContext(op)
    assert_false(
        mlirContextIsNull(op_ctx), "Operation context should not be null"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_get_location():
    """Test getting location from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var op_loc = mlirOperationGetLocation(op)
    assert_false(
        mlirLocationIsNull(op_loc), "Operation location should not be null"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_verify():
    """Test operation verification."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # An empty module should verify successfully
    assert_true(
        mlirOperationVerify(op), "Empty module should verify successfully"
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_get_num_regions():
    """Test getting number of regions from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # A module has one region
    var num_regions = mlirOperationGetNumRegions(op)
    assert_true(num_regions == 1, "Module should have exactly one region")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
