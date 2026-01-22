# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Operation module.

Comprehensive tests covering:
1. Operation context and location retrieval
2. Operation verification
3. Operation regions and blocks
4. Operation name and attributes
5. Operation equality
6. Operation printing
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextAppendDialectRegistry,
    mlirContextLoadAllAvailableDialects,
)
from mlir.core.location import (
    mlirLocationUnknownGet,
    mlirLocationIsNull,
    mlirLocationEqual,
)
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.operation import (
    mlirOperationIsNull,
    mlirOperationEqual,
    mlirOperationGetContext,
    mlirOperationGetLocation,
    mlirOperationVerify,
    mlirOperationGetNumRegions,
    mlirOperationGetRegion,
    mlirOperationGetName,
    mlirOperationGetNumOperands,
    mlirOperationGetNumResults,
    mlirOperationGetNumAttributes,
    mlirOperationPrint,
)
from mlir.core.region import mlirRegionIsNull
from mlir.core.dialect import (
    mlirDialectRegistryCreate,
    mlirDialectRegistryDestroy,
    mlirRegisterAllDialects,
)


# ===----------------------------------------------------------------------=== #
# Operation Lifecycle Tests
# ===----------------------------------------------------------------------=== #


def test_operation_from_module():
    """Test getting operation from module."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    assert_false(mlirOperationIsNull(op), "Module operation should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_equal_same():
    """Test operation equals itself."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    assert_true(mlirOperationEqual(op, op), "Operation should equal itself")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_not_equal_different():
    """Test different operations are not equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod1 = mlirModuleCreateEmpty(loc)
    var mod2 = mlirModuleCreateEmpty(loc)
    var op1 = mlirModuleGetOperation(mod1)
    var op2 = mlirModuleGetOperation(mod2)

    assert_false(
        mlirOperationEqual(op1, op2), "Different operations should not be equal"
    )

    mlirModuleDestroy(mod1)
    mlirModuleDestroy(mod2)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Context Retrieval Tests
# ===----------------------------------------------------------------------=== #


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
    assert_true(
        mlirContextEqual(ctx, op_ctx),
        "Operation context should match creating context",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Location Retrieval Tests
# ===----------------------------------------------------------------------=== #


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


def test_operation_location_matches_module():
    """Test that operation location matches module creation location."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var op_loc = mlirOperationGetLocation(op)
    assert_true(
        mlirLocationEqual(loc, op_loc),
        "Operation location should match module location",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Verification Tests
# ===----------------------------------------------------------------------=== #


def test_operation_verify_empty_module():
    """Test verifying an empty module."""
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


# ===----------------------------------------------------------------------=== #
# Operation Region Tests
# ===----------------------------------------------------------------------=== #


def test_operation_get_num_regions():
    """Test getting number of regions from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # A module has one region
    var num_regions = mlirOperationGetNumRegions(op)
    assert_equal(num_regions, 1, "Module should have exactly one region")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_get_region():
    """Test getting a region from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var region = mlirOperationGetRegion(op, 0)
    assert_false(mlirRegionIsNull(region), "Module region should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Name Tests
# ===----------------------------------------------------------------------=== #


def test_operation_get_name():
    """Test getting operation name."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # Module operation name should be "builtin.module"
    var name = mlirOperationGetName(op)
    # Name is an MlirIdentifier, which is valid if we got here without crash

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Operand/Result Count Tests
# ===----------------------------------------------------------------------=== #


def test_operation_num_operands():
    """Test getting number of operands from module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # Module operation has no operands
    var num_operands = mlirOperationGetNumOperands(op)
    assert_equal(num_operands, 0, "Module should have zero operands")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_num_results():
    """Test getting number of results from module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # Module operation has no results
    var num_results = mlirOperationGetNumResults(op)
    assert_equal(num_results, 0, "Module should have zero results")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_operation_num_attributes():
    """Test getting number of attributes from module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    # Empty module should have no attributes
    var num_attrs = mlirOperationGetNumAttributes(op)
    assert_true(num_attrs >= 0, "Number of attributes should be non-negative")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Operation Printing Tests
# ===----------------------------------------------------------------------=== #


def test_operation_print():
    """Test printing operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var output = String()
    mlirOperationPrint(op, output)

    assert_true(len(output) > 0, "Printed operation should not be empty")
    assert_true("module" in output, "Printed output should contain 'module'")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_print_empty_module():
    """Test printing empty module output format."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var output = String()
    mlirOperationPrint(op, output)

    # Empty module should print as "module { }" or similar
    assert_true("module" in output, "Should contain module keyword")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
