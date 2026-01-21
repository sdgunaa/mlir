# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Region module.

Verifies region creation, equality, and block management.
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.operation import (
    mlirOperationGetRegion,
    mlirOperationGetNumRegions,
)
from mlir.core.region import (
    mlirRegionCreate,
    mlirRegionDestroy,
    mlirRegionIsNull,
    mlirRegionEqual,
    mlirRegionGetFirstBlock,
    mlirRegionAppendOwnedBlock,
)
from mlir.core.block import mlirBlockCreate, mlirBlockIsNull, mlirBlockEqual
from mlir.core.type import MlirType


def test_region_equality():
    """Test that different regions are not equal, same region is equal."""
    var region1 = mlirRegionCreate()
    var region2 = mlirRegionCreate()

    assert_true(mlirRegionEqual(region1, region1))
    assert_false(mlirRegionEqual(region1, region2))

    mlirRegionDestroy(region1)
    mlirRegionDestroy(region2)


def test_module_has_one_region():
    """Test that a module operation has exactly one region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var num_regions = mlirOperationGetNumRegions(op)
    assert_equal(num_regions, 1)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_region_block_appending():
    """Test appending blocks to a region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    # Create and append a block
    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block = mlirBlockCreate(0, types, loc)
    mlirRegionAppendOwnedBlock(region, block)

    # First block should now be the block we appended
    var first = mlirRegionGetFirstBlock(region)
    assert_true(mlirBlockEqual(first, block))

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
