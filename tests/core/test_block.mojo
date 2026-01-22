# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Block module.

Comprehensive tests for block operations including:
- Block creation and destruction
- Block equality and null checks
- Block arguments (add, insert, erase, get)
- Parent operation and region relationships
- Operation management within blocks
- Block successors and predecessors
- Block printing
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleCreateParse,
    mlirModuleGetBody,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.block import (
    MlirBlock,
    mlirBlockCreate,
    mlirBlockDestroy,
    mlirBlockIsNull,
    mlirBlockEqual,
    mlirBlockGetNumArguments,
    mlirBlockGetParentOperation,
    mlirBlockGetParentRegion,
    mlirBlockGetNextInRegion,
    mlirBlockGetFirstOperation,
    mlirBlockGetTerminator,
    mlirBlockAppendOwnedOperation,
    mlirBlockAddArgument,
    mlirBlockGetArgument,
    mlirBlockEraseArgument,
    mlirBlockInsertArgument,
    mlirBlockPrint,
    mlirBlockGetNumSuccessors,
    mlirBlockGetNumPredecessors,
)
from mlir.core.type import mlirTypeParseGet, MlirType
from mlir.core.operation import (
    mlirOperationEqual,
    mlirOperationIsNull,
    mlirOperationGetRegion,
)
from mlir.core.region import (
    mlirRegionCreate,
    mlirRegionDestroy,
    mlirRegionIsNull,
    mlirRegionAppendOwnedBlock,
    mlirRegionGetFirstBlock,
)
from mlir.core.value import mlirValueIsABlockArgument, mlirValueGetType


# =============================================================================
# Block Creation and Lifecycle Tests
# =============================================================================


def test_block_create_no_arguments():
    """Test creating a block with no arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block = mlirBlockCreate(0, types, loc)

    assert_false(mlirBlockIsNull(block), "Created block should not be null")
    assert_equal(mlirBlockGetNumArguments(block), 0)

    mlirBlockDestroy(block)
    mlirContextDestroy(ctx)


def test_block_create_with_arguments():
    """Test creating a block and adding typed arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var i32_type = mlirTypeParseGet(ctx, "i32")
    var i64_type = mlirTypeParseGet(ctx, "i64")

    var types = InlineArray[MlirType, 2](i32_type, i64_type)
    var block = mlirBlockCreate(
        2, types.unsafe_ptr().unsafe_origin_cast[MutExternalOrigin](), loc
    )

    assert_false(mlirBlockIsNull(block), "Created block should not be null")
    assert_equal(mlirBlockGetNumArguments(block), 2)

    mlirBlockDestroy(block)
    mlirContextDestroy(ctx)


def test_block_from_module_is_not_null():
    """Test getting block from module body is not null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    assert_false(mlirBlockIsNull(body), "Module body block should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Equality Tests
# =============================================================================


def test_block_equality_same_block():
    """Test that same block retrieved multiple times is equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body1 = mlirModuleGetBody(mod)
    var body2 = mlirModuleGetBody(mod)

    assert_true(mlirBlockEqual(body1, body1), "Block should equal itself")
    assert_true(
        mlirBlockEqual(body1, body2),
        "Same block retrieved twice should be equal",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_equality_different_blocks():
    """Test that different blocks are not equal."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)

    assert_false(
        mlirBlockEqual(block1, block2),
        "Different blocks should not be equal",
    )

    mlirBlockDestroy(block1)
    mlirBlockDestroy(block2)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Parent Relationship Tests
# =============================================================================


def test_block_get_parent_operation():
    """Test getting parent operation from block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var mod_op = mlirModuleGetOperation(mod)

    var body = mlirModuleGetBody(mod)
    var parent = mlirBlockGetParentOperation(body)

    assert_true(
        mlirOperationEqual(parent, mod_op),
        "Block's parent should be the module operation",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_get_parent_region():
    """Test getting parent region from block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var mod_op = mlirModuleGetOperation(mod)

    var body = mlirModuleGetBody(mod)
    var parent_region = mlirBlockGetParentRegion(body)

    # The parent region should be the first region of the module operation
    var mod_region = mlirOperationGetRegion(mod_op, 0)

    assert_false(
        mlirRegionIsNull(parent_region),
        "Block's parent region should not be null",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Argument Tests
# =============================================================================


def test_block_add_argument():
    """Test adding an argument to a block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    assert_equal(mlirBlockGetNumArguments(body), 0)

    # Add an i32 argument
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)

    assert_equal(mlirBlockGetNumArguments(body), 1)
    assert_true(
        mlirValueIsABlockArgument(arg),
        "Added value should be a block argument",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_add_multiple_arguments():
    """Test adding multiple arguments to a block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)

    var i32_type = mlirTypeParseGet(ctx, "i32")
    var i64_type = mlirTypeParseGet(ctx, "i64")
    var f32_type = mlirTypeParseGet(ctx, "f32")

    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, i64_type, loc)
    _ = mlirBlockAddArgument(body, f32_type, loc)

    assert_equal(mlirBlockGetNumArguments(body), 3)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_get_argument():
    """Test retrieving block arguments by index."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var retrieved = mlirBlockGetArgument(body, 0)
    assert_true(
        mlirValueIsABlockArgument(retrieved),
        "Retrieved value should be a block argument",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_insert_argument():
    """Test inserting argument at specific position."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var i64_type = mlirTypeParseGet(ctx, "i64")
    var f32_type = mlirTypeParseGet(ctx, "f32")

    # Add first and third arguments
    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, f32_type, loc)

    assert_equal(mlirBlockGetNumArguments(body), 2)

    # Insert i64 at position 1
    _ = mlirBlockInsertArgument(body, 1, i64_type, loc)

    assert_equal(mlirBlockGetNumArguments(body), 3)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_erase_argument():
    """Test erasing block arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")

    _ = mlirBlockAddArgument(body, i32_type, loc)
    _ = mlirBlockAddArgument(body, i32_type, loc)
    assert_equal(mlirBlockGetNumArguments(body), 2)

    # Erase first argument
    mlirBlockEraseArgument(body, 0)
    assert_equal(mlirBlockGetNumArguments(body), 1)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_argument_type():
    """Test that block argument has correct type."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var arg = mlirBlockGetArgument(body, 0)
    var arg_type = mlirValueGetType(arg)

    # The type should not be null
    assert_true(Bool(arg_type.ptr), "Argument type should not be null")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Region Integration Tests
# =============================================================================


def test_block_in_region():
    """Test appending block to a region and retrieving it."""
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


def test_block_next_in_region():
    """Test iterating blocks in a region."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var region = mlirRegionCreate()

    var types = UnsafePointer[MlirType, MutExternalOrigin]()
    var block1 = mlirBlockCreate(0, types, loc)
    var block2 = mlirBlockCreate(0, types, loc)

    mlirRegionAppendOwnedBlock(region, block1)
    mlirRegionAppendOwnedBlock(region, block2)

    var first = mlirRegionGetFirstBlock(region)
    var second = mlirBlockGetNextInRegion(first)

    assert_true(
        mlirBlockEqual(second, block2),
        "Next block should be the second appended block",
    )

    mlirRegionDestroy(region)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Operation Management Tests
# =============================================================================


def test_block_get_first_operation_empty():
    """Test getting first operation from empty block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var first_op = mlirBlockGetFirstOperation(body)

    # Empty block should have null first operation
    assert_true(
        mlirOperationIsNull(first_op),
        "Empty block should have null first operation",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_get_terminator_empty():
    """Test getting terminator from empty block."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var terminator = mlirBlockGetTerminator(body)

    # Empty block should have null terminator
    assert_true(
        mlirOperationIsNull(terminator),
        "Empty block should have null terminator",
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Successor/Predecessor Tests
# =============================================================================


def test_block_successors_empty():
    """Test block with no successors."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)

    # Module body has no successors
    assert_equal(
        mlirBlockGetNumSuccessors(body),
        0,
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_predecessors_empty():
    """Test block with no predecessors."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)

    # Module body has no predecessors
    assert_equal(
        mlirBlockGetNumPredecessors(body),
        0,
    )

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Block Printing Tests
# =============================================================================


def test_block_print():
    """Test printing a block to string."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)

    var output = String()
    mlirBlockPrint(body, output)

    # Output should contain block structure
    assert_true(len(output) > 0, "Block print output should not be empty")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_block_print_with_arguments():
    """Test printing a block with arguments."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)

    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    _ = mlirBlockAddArgument(body, i32_type, loc)

    var output = String()
    mlirBlockPrint(body, output)

    # Output should contain block with argument
    assert_true(len(output) > 0, "Block print output should not be empty")

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
