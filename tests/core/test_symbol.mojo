# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Symbol module.

Comprehensive tests for symbol table operations including:
- Symbol table creation and destruction
- Symbol attribute name constants
- Symbol lookup
- Symbol table from different operation types
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleCreateParse,
    mlirModuleGetOperation,
    mlirModuleIsNull,
    mlirModuleDestroy,
)
from mlir.core.operation import mlirOperationIsNull
from mlir.core.symbol import (
    MlirSymbolTable,
    mlirSymbolTableCreate,
    mlirSymbolTableDestroy,
    mlirSymbolTableIsNull,
    mlirSymbolTableGetSymbolAttributeName,
    mlirSymbolTableGetVisibilityAttributeName,
    mlirSymbolTableLookup,
)


# =============================================================================
# Symbol Attribute Name Tests
# =============================================================================


def test_symbol_attribute_name_not_empty():
    """Test that symbol attribute name is not empty."""
    var sym_name = mlirSymbolTableGetSymbolAttributeName()
    assert_true(len(sym_name) > 0, "Symbol attribute name should not be empty")


def test_visibility_attribute_name_not_empty():
    """Test that visibility attribute name is not empty."""
    var vis_name = mlirSymbolTableGetVisibilityAttributeName()
    assert_true(
        len(vis_name) > 0, "Visibility attribute name should not be empty"
    )


def test_symbol_visibility_names_different():
    """Test that symbol and visibility names are different."""
    var sym_name = mlirSymbolTableGetSymbolAttributeName()
    var vis_name = mlirSymbolTableGetVisibilityAttributeName()

    assert_true(
        sym_name != vis_name,
        "Symbol and visibility attribute names should be different",
    )


def test_symbol_attribute_name_is_sym_name():
    """Test that symbol attribute name is 'sym_name'."""
    var sym_name = mlirSymbolTableGetSymbolAttributeName()
    assert_equal(sym_name, "sym_name")


def test_visibility_attribute_name_is_sym_visibility():
    """Test that visibility attribute name is 'sym_visibility'."""
    var vis_name = mlirSymbolTableGetVisibilityAttributeName()
    assert_equal(vis_name, "sym_visibility")


# =============================================================================
# Symbol Table Creation Tests
# =============================================================================


def test_symbol_table_create_for_module():
    """Test creating symbol table for a module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var sym_table = mlirSymbolTableCreate(op)
    assert_false(
        mlirSymbolTableIsNull(sym_table),
        "Symbol table for module should not be null",
    )

    mlirSymbolTableDestroy(sym_table)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_symbol_table_create_destroy_cycle():
    """Test create/destroy lifecycle of symbol tables."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    for _ in range(3):
        var sym_table = mlirSymbolTableCreate(op)
        assert_false(mlirSymbolTableIsNull(sym_table))
        mlirSymbolTableDestroy(sym_table)

    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Symbol Lookup Tests
# =============================================================================


def test_symbol_lookup_empty_module():
    """Test looking up symbol in empty module returns null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var sym_table = mlirSymbolTableCreate(op)

    var result = mlirSymbolTableLookup(sym_table, "nonexistent")
    assert_true(
        mlirOperationIsNull(result),
        "Lookup in empty module should return null",
    )

    mlirSymbolTableDestroy(sym_table)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_symbol_lookup_not_found():
    """Test looking up non-existent symbol returns null."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var sym_table = mlirSymbolTableCreate(op)

    # Try multiple non-existent names
    var result1 = mlirSymbolTableLookup(sym_table, "foo")
    var result2 = mlirSymbolTableLookup(sym_table, "bar")
    var result3 = mlirSymbolTableLookup(sym_table, "baz")

    assert_true(mlirOperationIsNull(result1))
    assert_true(mlirOperationIsNull(result2))
    assert_true(mlirOperationIsNull(result3))

    mlirSymbolTableDestroy(sym_table)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


# =============================================================================
# Symbol Table Stability Tests
# =============================================================================


def test_symbol_table_multiple_creations():
    """Test creating multiple symbol tables for same operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var sym_table1 = mlirSymbolTableCreate(op)
    var sym_table2 = mlirSymbolTableCreate(op)

    assert_false(mlirSymbolTableIsNull(sym_table1))
    assert_false(mlirSymbolTableIsNull(sym_table2))

    mlirSymbolTableDestroy(sym_table1)
    mlirSymbolTableDestroy(sym_table2)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_symbol_attribute_names_consistent():
    """Test that attribute names are consistent across calls."""
    var sym_name1 = mlirSymbolTableGetSymbolAttributeName()
    var sym_name2 = mlirSymbolTableGetSymbolAttributeName()
    var vis_name1 = mlirSymbolTableGetVisibilityAttributeName()
    var vis_name2 = mlirSymbolTableGetVisibilityAttributeName()

    assert_equal(sym_name1, sym_name2)
    assert_equal(vis_name1, vis_name2)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
