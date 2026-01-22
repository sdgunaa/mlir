# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Region module.

Comprehensive tests for region operations including:
- Region creation and destruction
- Region equality
- Block management (append, insert, iterate)
- Region iteration in operations
- Region body transfer
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
    MlirRegion,
    mlirRegionCreate,
    mlirRegionDestroy,
    mlirRegionIsNull,
    mlirRegionEqual,
    mlirRegionGetFirstBlock,
    mlirRegionAppendOwnedBlock,
    mlirRegionInsertOwnedBlock,
    mlirRegionInsertOwnedBlockAfter,
    mlirRegionInsertOwnedBlockBefore,
    mlirOperationGetFirstRegion,
    mlirRegionGetNextInOperation,
    mlirRegionTakeBody,
)
from mlir.core.block import (
    MlirBlock,
    mlirBlockCreate,
    mlirBlockIsNull,
    mlirBlockEqual,
    mlirBlockGetNextInRegion,
)
from mlir.core.type import MlirType


# =============================================================================
# Region Creation and Lifecycle Tests
# =============================================================================


def test_region_create_not_null():
    """Test that created region is not null."""
    var region = mlirRegionCreate()
    assert_false(mlirRegionIsNull(region), "Created region should not be null")
    mlirRegionDestroy(region)


def test_region_create_multiple():
    """Test creating multiple independent regions."""
    var region1 = mlirRegionCreate()
    var region2 = mlirRegionCreate()
    var region3 = mlirRegionCreate()

    assert_false(mlirRegionIsNull(region1))
    assert_false(mlirRegionIsNull(region2))
    assert_false(mlirRegionIsNull(region3))

    mlirRegionDestroy(region1)
    mlirRegionDestroy(region2)
    mlirRegionDestroy(region3)


# =============================================================================
# Region Equality Tests
# =============================================================================


def test_region_equality_self():
    """Test that a region equals itself."""
    var region = mlirRegionCreate()
    assert_true(mlirRegionEqual(region, region), "Region should equal itself")
    mlirRegionDestroy(region)


def test_region_equality_different():
    """Test that different regions are not equal."""
    var region1 = mlirRegionCreate()
    var region2 = mlirRegionCreate()

    assert_true(mlirRegionEqual(region1, region1))
    assert_false(
        mlirRegionEqual(region1, region2),
        "Different regions should not be equal",
    )

    mlirRegionDestroy(region1)
    mlirRegionDestroy(region2)


# =============================================================================
# Region from Operation Tests
# =============================================================================


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


def test_operation_get_region():
    """Test getting region from operation by index."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var region = mlirOperationGetRegion(op, 0)
    assert_false(
        mlirRegionIsNull(region),
        "Module's first region should not be null",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_operation_get_first_region():
    """Test getting first region from operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var region = mlirOperationGetFirstRegion(op)
    var region_by_index = mlirOperationGetRegion(op, 0)

    # Both should refer to the same region
    assert_true(
        mlirRegionEqual(region, region_by_index),
        "First region should equal region at index 0",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_region_next_in_operation_single_region():
    """Test that single-region operation has no next region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var first_region = mlirOperationGetFirstRegion(op)
    var next_region = mlirRegionGetNextInOperation(first_region)

    assert_true(
        mlirRegionIsNull(next_region),
        "Single-region operation should have no next region",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Region Block Management Tests
# =============================================================================


def test_region_append_owned_block():
    """Test appending a block to a region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block = mlirBlockCreate(0, types, loc)
    mlirRegionAppendOwnedBlock(region, block)

    var first = mlirRegionGetFirstBlock(region)
    assert_true(
        mlirBlockEqual(first, block),
        "First block should be the appended block",
    )

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def test_region_empty_has_null_first_block():
    """Test that empty region has null first block."""
    var region = mlirRegionCreate()

    var first = mlirRegionGetFirstBlock(region)
    assert_true(
        mlirBlockIsNull(first),
        "Empty region should have null first block",
    )

    mlirRegionDestroy(region)


def test_region_append_multiple_blocks():
    """Test appending multiple blocks to a region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)
    var block3 = mlirBlockCreate(0, types, loc)

    mlirRegionAppendOwnedBlock(region, block1)
    mlirRegionAppendOwnedBlock(region, block2)
    mlirRegionAppendOwnedBlock(region, block3)

    # Verify order by iterating
    var first = mlirRegionGetFirstBlock(region)
    var second = mlirBlockGetNextInRegion(first)
    var third = mlirBlockGetNextInRegion(second)

    assert_true(mlirBlockEqual(first, block1))
    assert_true(mlirBlockEqual(second, block2))
    assert_true(mlirBlockEqual(third, block3))

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def test_region_insert_owned_block_at_position():
    """Test inserting block at specific position."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)
    var block_middle = mlirBlockCreate(0, types, loc)

    mlirRegionAppendOwnedBlock(region, block1)
    mlirRegionAppendOwnedBlock(region, block2)

    # Insert at position 1 (between block1 and block2)
    mlirRegionInsertOwnedBlock(region, 1, block_middle)

    var first = mlirRegionGetFirstBlock(region)
    var second = mlirBlockGetNextInRegion(first)

    assert_true(mlirBlockEqual(first, block1))
    assert_true(mlirBlockEqual(second, block_middle))

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def test_region_insert_block_after():
    """Test inserting block after another block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)

    mlirRegionAppendOwnedBlock(region, block1)
    mlirRegionInsertOwnedBlockAfter(region, block1, block2)

    var first = mlirRegionGetFirstBlock(region)
    var second = mlirBlockGetNextInRegion(first)

    assert_true(mlirBlockEqual(first, block1))
    assert_true(mlirBlockEqual(second, block2))

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def test_region_insert_block_before():
    """Test inserting block before another block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)

    mlirRegionAppendOwnedBlock(region, block2)
    mlirRegionInsertOwnedBlockBefore(region, block2, block1)

    var first = mlirRegionGetFirstBlock(region)
    var second = mlirBlockGetNextInRegion(first)

    assert_true(mlirBlockEqual(first, block1))
    assert_true(mlirBlockEqual(second, block2))

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


# =============================================================================
# Region Body Transfer Tests
# =============================================================================


def test_region_take_body():
    """Test transferring blocks between regions."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var source = mlirRegionCreate()
    var target = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block = mlirBlockCreate(0, types, loc)
    mlirRegionAppendOwnedBlock(source, block)

    # Transfer body from source to target
    mlirRegionTakeBody(target, source)

    # Source should now be empty
    var source_first = mlirRegionGetFirstBlock(source)
    assert_true(
        mlirBlockIsNull(source_first),
        "Source region should be empty after take body",
    )

    # Target should have the block
    var target_first = mlirRegionGetFirstBlock(target)
    assert_false(
        mlirBlockIsNull(target_first),
        "Target region should have blocks after take body",
    )

    mlirRegionDestroy(source)
    mlirRegionDestroy(target)
    mlirContextDestroy(ctx)


# =============================================================================
# Region Iteration Tests
# =============================================================================


def test_region_block_iteration():
    """Test iterating all blocks in a region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()

    # Add 5 blocks
    for _ in range(5):
        var block = mlirBlockCreate(0, types, loc)
        mlirRegionAppendOwnedBlock(region, block)

    # Count blocks by iteration
    var count = 0
    var current = mlirRegionGetFirstBlock(region)
    while not mlirBlockIsNull(current):
        count += 1
        current = mlirBlockGetNextInRegion(current)

    assert_equal(count, 5)

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
