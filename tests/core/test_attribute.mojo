# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Attribute module.

These tests verify:
1. Attribute parsing
2. Attribute equality
3. Identifier creation and equality
"""

from testing import assert_true, assert_false, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
)
from mlir.core.attribute import (
    mlirAttributeParseGet,
    mlirAttributeIsNull,
    mlirAttributeEqual,
    mlirAttributeGetContext,
    mlirIdentifierGet,
    mlirIdentifierEqual,
    mlirIdentifierGetContext,
)


def test_attribute_parse_integer():
    """Test parsing an integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    assert_false(
        mlirAttributeIsNull(attr), "Parsed integer attribute should not be null"
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_string():
    """Test parsing a string attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, '"hello"')

    assert_false(
        mlirAttributeIsNull(attr), "Parsed string attribute should not be null"
    )

    mlirContextDestroy(ctx)


def test_attribute_equal():
    """Test attribute equality."""
    var ctx = mlirContextCreate()
    var attr1 = mlirAttributeParseGet(ctx, "42 : i32")
    var attr2 = mlirAttributeParseGet(ctx, "42 : i32")
    var attr3 = mlirAttributeParseGet(ctx, "100 : i32")

    assert_true(
        mlirAttributeEqual(attr1, attr1), "Attribute should equal itself"
    )
    assert_true(
        mlirAttributeEqual(attr1, attr2), "Same attributes should be equal"
    )
    assert_false(
        mlirAttributeEqual(attr1, attr3),
        "Different attributes should not be equal",
    )

    mlirContextDestroy(ctx)


def test_attribute_get_context():
    """Test getting context from attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    var attr_ctx = mlirAttributeGetContext(attr)
    assert_false(
        mlirContextIsNull(attr_ctx), "Attribute context should not be null"
    )

    mlirContextDestroy(ctx)


def test_identifier_create():
    """Test creating an identifier."""
    var ctx = mlirContextCreate()
    var ident = mlirIdentifierGet(ctx, "my_identifier")

    var ident_ctx = mlirIdentifierGetContext(ident)
    assert_false(
        mlirContextIsNull(ident_ctx), "Identifier context should not be null"
    )

    mlirContextDestroy(ctx)


def test_identifier_equal():
    """Test identifier equality."""
    var ctx = mlirContextCreate()
    var ident1 = mlirIdentifierGet(ctx, "foo")
    var ident2 = mlirIdentifierGet(ctx, "foo")
    var ident3 = mlirIdentifierGet(ctx, "bar")

    assert_true(
        mlirIdentifierEqual(ident1, ident1), "Identifier should equal itself"
    )
    assert_true(
        mlirIdentifierEqual(ident1, ident2), "Same identifiers should be equal"
    )
    assert_false(
        mlirIdentifierEqual(ident1, ident3),
        "Different identifiers should not be equal",
    )

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
