# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Symbol module.

Verifies symbol table creation and attribute name constants.
"""

from testing import assert_true, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.symbol import (
    mlirSymbolTableCreate,
    mlirSymbolTableDestroy,
    mlirSymbolTableIsNull,
    mlirSymbolTableGetSymbolAttributeName,
    mlirSymbolTableGetVisibilityAttributeName,
)


def test_symbol_table_for_module():
    """Test creating symbol table for a module operation."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var sym_table = mlirSymbolTableCreate(op)
    assert_true(not mlirSymbolTableIsNull(sym_table))

    mlirSymbolTableDestroy(sym_table)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def test_symbol_attribute_names_are_defined():
    """Test that symbol and visibility attribute names are non-empty constants.
    """
    var sym_name = mlirSymbolTableGetSymbolAttributeName()
    var vis_name = mlirSymbolTableGetVisibilityAttributeName()

    # These should be known constants like "sym_name" and "sym_visibility"
    assert_true(len(sym_name) > 0)
    assert_true(len(vis_name) > 0)

    # Visibility name should be different from symbol name
    assert_true(sym_name != vis_name)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
