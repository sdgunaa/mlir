# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Attribute module.

Comprehensive tests covering:
1. Attribute parsing (integer, float, string, dense array)
2. Attribute equality and inequality
3. Identifier creation and equality
4. Attribute type and dialect retrieval
5. Attribute printing
6. Named attribute creation
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextAppendDialectRegistry,
)
from mlir.core.attribute import (
    mlirAttributeParseGet,
    mlirAttributeIsNull,
    mlirAttributeEqual,
    mlirAttributeGetContext,
    mlirAttributeGetType,
    mlirAttributeGetDialect,
    mlirAttributePrint,
    mlirAttributeDump,
    mlirNamedAttributeGet,
    mlirIdentifierGet,
    mlirIdentifierEqual,
    mlirIdentifierGetContext,
    mlirIdentifierStr,
)
from mlir.core.type import mlirTypeIsNull, mlirTypeEqual, mlirTypeParseGet
from mlir.core.dialect import (
    mlirDialectIsNull,
    mlirDialectRegistryCreate,
    mlirDialectRegistryDestroy,
    mlirRegisterAllDialects,
)

# ===----------------------------------------------------------------------=== #
# Integer Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_integer_i32():
    """Test parsing an i32 integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed i32 integer attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_integer_i64():
    """Test parsing an i64 integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "9223372036854775807 : i64")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed i64 integer attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_integer_i1():
    """Test parsing a boolean (i1) integer attribute."""
    var ctx = mlirContextCreate()
    var attr_true = mlirAttributeParseGet(ctx, "true")
    var attr_false = mlirAttributeParseGet(ctx, "false")

    assert_false(
        mlirAttributeIsNull(attr_true),
        "Parsed true attribute should not be null",
    )
    assert_false(
        mlirAttributeIsNull(attr_false),
        "Parsed false attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_negative_integer():
    """Test parsing a negative integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "-100 : i32")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed negative integer attribute should not be null",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Float Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_float_f32():
    """Test parsing an f32 float attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "3.14159 : f32")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed f32 float attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_float_f64():
    """Test parsing an f64 float attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "2.718281828 : f64")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed f64 float attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_float_negative():
    """Test parsing a negative float attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "-1.5 : f32")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed negative float attribute should not be null",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# String Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_string():
    """Test parsing a string attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, '"hello"')

    assert_false(
        mlirAttributeIsNull(attr), "Parsed string attribute should not be null"
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_string_empty():
    """Test parsing an empty string attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, '""')

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed empty string attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_string_with_special_chars():
    """Test parsing a string attribute with special characters."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, '"hello\\nworld"')

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed string with escapes should not be null",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Unit Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_unit():
    """Test parsing a unit attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "unit")

    assert_false(
        mlirAttributeIsNull(attr), "Parsed unit attribute should not be null"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Array Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_array():
    """Test parsing an array attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "[1 : i32, 2 : i32, 3 : i32]")

    assert_false(
        mlirAttributeIsNull(attr), "Parsed array attribute should not be null"
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_empty_array():
    """Test parsing an empty array attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "[]")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed empty array attribute should not be null",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Dense Elements Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_dense_elements():
    """Test parsing a dense elements attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "dense<[1, 2, 3, 4]> : tensor<4xi32>")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed dense elements attribute should not be null",
    )

    mlirContextDestroy(ctx)


def test_attribute_parse_dense_splat():
    """Test parsing a splat dense elements attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "dense<0.0> : tensor<2x3xf32>")

    assert_false(
        mlirAttributeIsNull(attr),
        "Parsed dense splat attribute should not be null",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Attribute Equality Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_equal_same():
    """Test attribute equality for same attributes."""
    var ctx = mlirContextCreate()
    var attr1 = mlirAttributeParseGet(ctx, "42 : i32")
    var attr2 = mlirAttributeParseGet(ctx, "42 : i32")

    assert_true(
        mlirAttributeEqual(attr1, attr1), "Attribute should equal itself"
    )
    assert_true(
        mlirAttributeEqual(attr1, attr2), "Same attributes should be equal"
    )

    mlirContextDestroy(ctx)


def test_attribute_not_equal_different_values():
    """Test attribute inequality for different values."""
    var ctx = mlirContextCreate()
    var attr1 = mlirAttributeParseGet(ctx, "42 : i32")
    var attr2 = mlirAttributeParseGet(ctx, "100 : i32")

    assert_false(
        mlirAttributeEqual(attr1, attr2),
        "Different value attributes should not be equal",
    )

    mlirContextDestroy(ctx)


def test_attribute_not_equal_different_types():
    """Test attribute inequality for different types."""
    var ctx = mlirContextCreate()
    var attr1 = mlirAttributeParseGet(ctx, "42 : i32")
    var attr2 = mlirAttributeParseGet(ctx, "42 : i64")

    assert_false(
        mlirAttributeEqual(attr1, attr2),
        "Different type attributes should not be equal",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Attribute Context Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_get_context():
    """Test getting context from attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    var attr_ctx = mlirAttributeGetContext(attr)
    assert_false(
        mlirContextIsNull(attr_ctx), "Attribute context should not be null"
    )
    assert_true(
        mlirContextEqual(ctx, attr_ctx),
        "Attribute context should match creating context",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Attribute Type Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_get_type_integer():
    """Test getting type from integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")
    var expected_type = mlirTypeParseGet(ctx, "i32")

    var attr_type = mlirAttributeGetType(attr)
    assert_false(mlirTypeIsNull(attr_type), "Attribute type should not be null")
    assert_true(
        mlirTypeEqual(attr_type, expected_type),
        "Attribute type should be i32",
    )

    mlirContextDestroy(ctx)


def test_attribute_get_type_float():
    """Test getting type from float attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "3.14 : f64")
    var expected_type = mlirTypeParseGet(ctx, "f64")

    var attr_type = mlirAttributeGetType(attr)
    assert_false(mlirTypeIsNull(attr_type), "Attribute type should not be null")
    assert_true(
        mlirTypeEqual(attr_type, expected_type),
        "Attribute type should be f64",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Attribute Dialect Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_get_dialect():
    """Test getting dialect from attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    var dialect = mlirAttributeGetDialect(attr)
    # Integer attributes belong to the builtin dialect
    assert_false(
        mlirDialectIsNull(dialect), "Attribute dialect should not be null"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Attribute Printing Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_print_integer():
    """Test printing an integer attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    var output = String()
    mlirAttributePrint(attr, output)

    assert_true(len(output) > 0, "Printed attribute should not be empty")
    assert_true("42" in output, "Printed output should contain the value")

    mlirContextDestroy(ctx)


def test_attribute_print_string():
    """Test printing a string attribute."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, '"hello"')

    var output = String()
    mlirAttributePrint(attr, output)

    assert_true(len(output) > 0, "Printed attribute should not be empty")
    assert_true("hello" in output, "Printed output should contain the string")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Identifier Tests
# ===----------------------------------------------------------------------=== #


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


def test_identifier_str():
    """Test getting string from identifier."""
    var ctx = mlirContextCreate()
    var ident = mlirIdentifierGet(ctx, "test_name")

    var str_ref = mlirIdentifierStr(ident)
    # Verify the identifier string is retrievable (non-zero length)
    assert_true(
        len(str_ref) > 0, "Identifier string should have non-zero length"
    )

    mlirContextDestroy(ctx)


def test_identifier_context_matches():
    """Test that identifier context matches the creating context."""
    var ctx = mlirContextCreate()
    var ident = mlirIdentifierGet(ctx, "my_ident")

    var ident_ctx = mlirIdentifierGetContext(ident)
    assert_true(
        mlirContextEqual(ctx, ident_ctx),
        "Identifier context should match creating context",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Named Attribute Tests
# ===----------------------------------------------------------------------=== #


def test_named_attribute_get():
    """Test creating a named attribute."""
    var ctx = mlirContextCreate()
    var name = mlirIdentifierGet(ctx, "my_attr")
    var attr = mlirAttributeParseGet(ctx, "42 : i32")

    var named_attr = mlirNamedAttributeGet(name, attr)

    # Verify the named attribute has the correct name
    assert_true(
        mlirIdentifierEqual(named_attr.name, name),
        "Named attribute should have the correct name",
    )
    # Verify the named attribute has the correct attribute
    assert_true(
        mlirAttributeEqual(named_attr.attribute, attr),
        "Named attribute should have the correct attribute",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Invalid Attribute Parsing Tests
# ===----------------------------------------------------------------------=== #


def test_attribute_parse_invalid():
    """Test parsing an invalid attribute string returns null."""
    var ctx = mlirContextCreate()
    var attr = mlirAttributeParseGet(ctx, "not_a_valid_attribute!!!")

    # Invalid parse should return null attribute
    assert_true(
        mlirAttributeIsNull(attr),
        "Invalid attribute parse should return null",
    )

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
