# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR Type module.

Comprehensive tests covering:
1. Type parsing (i32, f64, index, complex types)
2. Type equality and inequality
3. Type context and dialect retrieval
4. Type printing
5. Builtin type constructors
"""

from testing import assert_true, assert_false, assert_equal, TestSuite
from mlir.core.context import (
    mlirContextCreate,
    mlirContextDestroy,
    mlirContextIsNull,
    mlirContextEqual,
    mlirContextAppendDialectRegistry,
)
from mlir.core.type import (
    mlirTypeParseGet,
    mlirTypeIsNull,
    mlirTypeEqual,
    mlirTypeGetContext,
    mlirTypeGetDialect,
    mlirTypePrint,
    mlirTypeDump,
)
from mlir.core.dialect import (
    mlirDialectIsNull,
    mlirDialectRegistryCreate,
    mlirDialectRegistryDestroy,
    mlirRegisterAllDialects,
)
from mlir.core.builtin.builtin_types import (
    # Integer types
    mlirIntegerTypeGet,
    mlirIntegerTypeSignedGet,
    mlirIntegerTypeUnsignedGet,
    mlirIntegerTypeGetWidth,
    mlirIntegerTypeIsSignless,
    mlirIntegerTypeIsSigned,
    mlirIntegerTypeIsUnsigned,
    mlirTypeIsAInteger,
    # Float types
    mlirF16TypeGet,
    mlirF32TypeGet,
    mlirF64TypeGet,
    mlirBF16TypeGet,
    mlirTypeIsAF16,
    mlirTypeIsAF32,
    mlirTypeIsAF64,
    mlirTypeIsABF16,
    # Index type
    mlirIndexTypeGet,
    mlirTypeIsAIndex,
    # None type
    mlirNoneTypeGet,
    mlirTypeIsANone,
    # Vector type
    mlirVectorTypeGet,
    mlirVectorTypeGetChecked,
    mlirTypeIsAVector,
    # Tensor types
    mlirRankedTensorTypeGet,
    mlirUnrankedTensorTypeGet,
    mlirTypeIsATensor,
    mlirTypeIsARankedTensor,
    mlirTypeIsAUnrankedTensor,
    # Shaped type properties
    mlirShapedTypeGetElementType,
    mlirShapedTypeHasRank,
    mlirShapedTypeGetRank,
    mlirShapedTypeHasStaticShape,
    mlirShapedTypeIsDynamicDim,
    mlirShapedTypeGetDimSize,
)
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.attribute import mlirAttributeParseGet


# ===----------------------------------------------------------------------=== #
# Integer Type Parsing Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_i1():
    """Test parsing i1 (boolean) type."""
    var ctx = mlirContextCreate()
    var i1_type = mlirTypeParseGet(ctx, "i1")

    assert_false(mlirTypeIsNull(i1_type), "Parsed i1 type should not be null")
    assert_true(mlirTypeIsAInteger(i1_type), "i1 should be an integer type")
    assert_equal(mlirIntegerTypeGetWidth(i1_type), 1)

    mlirContextDestroy(ctx)


def test_type_parse_i8():
    """Test parsing i8 type."""
    var ctx = mlirContextCreate()
    var i8_type = mlirTypeParseGet(ctx, "i8")

    assert_false(mlirTypeIsNull(i8_type), "Parsed i8 type should not be null")
    assert_true(mlirTypeIsAInteger(i8_type), "i8 should be an integer type")
    assert_equal(mlirIntegerTypeGetWidth(i8_type), 8)

    mlirContextDestroy(ctx)


def test_type_parse_i16():
    """Test parsing i16 type."""
    var ctx = mlirContextCreate()
    var i16_type = mlirTypeParseGet(ctx, "i16")

    assert_false(mlirTypeIsNull(i16_type), "Parsed i16 type should not be null")
    assert_equal(mlirIntegerTypeGetWidth(i16_type), 16)

    mlirContextDestroy(ctx)


def test_type_parse_i32():
    """Test parsing i32 type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    assert_false(mlirTypeIsNull(i32_type), "Parsed i32 type should not be null")
    assert_equal(mlirIntegerTypeGetWidth(i32_type), 32)

    mlirContextDestroy(ctx)


def test_type_parse_i64():
    """Test parsing i64 type."""
    var ctx = mlirContextCreate()
    var i64_type = mlirTypeParseGet(ctx, "i64")

    assert_false(mlirTypeIsNull(i64_type), "Parsed i64 type should not be null")
    assert_equal(mlirIntegerTypeGetWidth(i64_type), 64)

    mlirContextDestroy(ctx)


def test_type_parse_si32():
    """Test parsing signed i32 type."""
    var ctx = mlirContextCreate()
    var si32_type = mlirTypeParseGet(ctx, "si32")

    assert_false(
        mlirTypeIsNull(si32_type), "Parsed si32 type should not be null"
    )
    assert_true(mlirIntegerTypeIsSigned(si32_type), "si32 should be signed")

    mlirContextDestroy(ctx)


def test_type_parse_ui32():
    """Test parsing unsigned i32 type."""
    var ctx = mlirContextCreate()
    var ui32_type = mlirTypeParseGet(ctx, "ui32")

    assert_false(
        mlirTypeIsNull(ui32_type), "Parsed ui32 type should not be null"
    )
    assert_true(mlirIntegerTypeIsUnsigned(ui32_type), "ui32 should be unsigned")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Integer Type Constructor Tests
# ===----------------------------------------------------------------------=== #


def test_integer_type_signless_constructor():
    """Test creating signless integer types."""
    var ctx = mlirContextCreate()

    var i32 = mlirIntegerTypeGet(ctx, 32)
    assert_false(mlirTypeIsNull(i32), "Created i32 should not be null")
    assert_equal(mlirIntegerTypeGetWidth(i32), 32)
    assert_true(
        mlirIntegerTypeIsSignless(i32), "Default integer should be signless"
    )

    mlirContextDestroy(ctx)


def test_integer_type_signed_constructor():
    """Test creating signed integer types."""
    var ctx = mlirContextCreate()

    var si16 = mlirIntegerTypeSignedGet(ctx, 16)
    assert_false(mlirTypeIsNull(si16), "Created si16 should not be null")
    assert_equal(mlirIntegerTypeGetWidth(si16), 16)
    assert_true(mlirIntegerTypeIsSigned(si16), "Should be signed")

    mlirContextDestroy(ctx)


def test_integer_type_unsigned_constructor():
    """Test creating unsigned integer types."""
    var ctx = mlirContextCreate()

    var ui64 = mlirIntegerTypeUnsignedGet(ctx, 64)
    assert_false(mlirTypeIsNull(ui64), "Created ui64 should not be null")
    assert_equal(mlirIntegerTypeGetWidth(ui64), 64)
    assert_true(mlirIntegerTypeIsUnsigned(ui64), "Should be unsigned")

    mlirContextDestroy(ctx)


def test_integer_type_arbitrary_width():
    """Test creating arbitrary-width integer types."""
    var ctx = mlirContextCreate()

    # Create a 7-bit integer
    var i7 = mlirIntegerTypeGet(ctx, 7)
    assert_false(mlirTypeIsNull(i7), "Created i7 should not be null")
    assert_equal(mlirIntegerTypeGetWidth(i7), 7)

    # Create a 128-bit integer
    var i128 = mlirIntegerTypeGet(ctx, 128)
    assert_equal(mlirIntegerTypeGetWidth(i128), 128)

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Float Type Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_f16():
    """Test parsing f16 type."""
    var ctx = mlirContextCreate()
    var f16_type = mlirTypeParseGet(ctx, "f16")

    assert_false(mlirTypeIsNull(f16_type), "Parsed f16 type should not be null")
    assert_true(mlirTypeIsAF16(f16_type), "f16 should be f16 type")

    mlirContextDestroy(ctx)


def test_type_parse_bf16():
    """Test parsing bf16 type."""
    var ctx = mlirContextCreate()
    var bf16_type = mlirTypeParseGet(ctx, "bf16")

    assert_false(
        mlirTypeIsNull(bf16_type), "Parsed bf16 type should not be null"
    )
    assert_true(mlirTypeIsABF16(bf16_type), "bf16 should be bf16 type")

    mlirContextDestroy(ctx)


def test_type_parse_f32():
    """Test parsing f32 type."""
    var ctx = mlirContextCreate()
    var f32_type = mlirTypeParseGet(ctx, "f32")

    assert_false(mlirTypeIsNull(f32_type), "Parsed f32 type should not be null")
    assert_true(mlirTypeIsAF32(f32_type), "f32 should be f32 type")

    mlirContextDestroy(ctx)


def test_type_parse_f64():
    """Test parsing f64 type."""
    var ctx = mlirContextCreate()
    var f64_type = mlirTypeParseGet(ctx, "f64")

    assert_false(mlirTypeIsNull(f64_type), "Parsed f64 type should not be null")
    assert_true(mlirTypeIsAF64(f64_type), "f64 should be f64 type")

    mlirContextDestroy(ctx)


def test_float_type_constructors():
    """Test float type constructors."""
    var ctx = mlirContextCreate()

    var f16 = mlirF16TypeGet(ctx)
    var bf16 = mlirBF16TypeGet(ctx)
    var f32 = mlirF32TypeGet(ctx)
    var f64 = mlirF64TypeGet(ctx)

    assert_false(mlirTypeIsNull(f16), "Created f16 should not be null")
    assert_false(mlirTypeIsNull(bf16), "Created bf16 should not be null")
    assert_false(mlirTypeIsNull(f32), "Created f32 should not be null")
    assert_false(mlirTypeIsNull(f64), "Created f64 should not be null")

    assert_true(mlirTypeIsAF16(f16), "f16 should be f16 type")
    assert_true(mlirTypeIsABF16(bf16), "bf16 should be bf16 type")
    assert_true(mlirTypeIsAF32(f32), "f32 should be f32 type")
    assert_true(mlirTypeIsAF64(f64), "f64 should be f64 type")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Index Type Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_index():
    """Test parsing index type."""
    var ctx = mlirContextCreate()
    var index_type = mlirTypeParseGet(ctx, "index")

    assert_false(
        mlirTypeIsNull(index_type), "Parsed index type should not be null"
    )
    assert_true(mlirTypeIsAIndex(index_type), "Should be index type")

    mlirContextDestroy(ctx)


def test_index_type_constructor():
    """Test index type constructor."""
    var ctx = mlirContextCreate()

    var index_type = mlirIndexTypeGet(ctx)
    assert_false(
        mlirTypeIsNull(index_type), "Created index type should not be null"
    )
    assert_true(mlirTypeIsAIndex(index_type), "Should be index type")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# None Type Tests
# ===----------------------------------------------------------------------=== #


def test_none_type_constructor():
    """Test none type constructor."""
    var ctx = mlirContextCreate()

    var none_type = mlirNoneTypeGet(ctx)
    assert_false(
        mlirTypeIsNull(none_type), "Created none type should not be null"
    )
    assert_true(mlirTypeIsANone(none_type), "Should be none type")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Vector Type Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_vector():
    """Test parsing vector type."""
    var ctx = mlirContextCreate()
    var vec_type = mlirTypeParseGet(ctx, "vector<4xf32>")

    assert_false(
        mlirTypeIsNull(vec_type), "Parsed vector type should not be null"
    )
    assert_true(mlirTypeIsAVector(vec_type), "Should be vector type")

    mlirContextDestroy(ctx)


def test_type_parse_vector_2d():
    """Test parsing 2D vector type."""
    var ctx = mlirContextCreate()
    var vec_type = mlirTypeParseGet(ctx, "vector<2x4xf32>")

    assert_false(
        mlirTypeIsNull(vec_type), "Parsed 2D vector type should not be null"
    )
    assert_true(mlirTypeIsAVector(vec_type), "Should be vector type")
    assert_true(mlirShapedTypeHasRank(vec_type), "Vector should have rank")
    assert_equal(mlirShapedTypeGetRank(vec_type), 2)

    mlirContextDestroy(ctx)


def test_vector_type_constructor():
    """Test vector type via parsing and property verification."""
    var ctx = mlirContextCreate()

    # Parse vector type and verify properties
    var vec_type = mlirTypeParseGet(ctx, "vector<4xf32>")
    assert_false(
        mlirTypeIsNull(vec_type), "Created vector type should not be null"
    )
    assert_true(mlirTypeIsAVector(vec_type), "Should be vector type")
    assert_equal(mlirShapedTypeGetRank(vec_type), 1)
    assert_equal(mlirShapedTypeGetDimSize(vec_type, 0), 4)

    # Verify element type
    var f32_type = mlirF32TypeGet(ctx)
    var elem_type = mlirShapedTypeGetElementType(vec_type)
    assert_true(
        mlirTypeEqual(elem_type, f32_type), "Element type should be f32"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Tensor Type Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_ranked_tensor():
    """Test parsing ranked tensor type."""
    var ctx = mlirContextCreate()
    var tensor_type = mlirTypeParseGet(ctx, "tensor<2x3xf32>")

    assert_false(
        mlirTypeIsNull(tensor_type), "Parsed tensor type should not be null"
    )
    assert_true(mlirTypeIsATensor(tensor_type), "Should be tensor type")
    assert_true(mlirTypeIsARankedTensor(tensor_type), "Should be ranked tensor")
    assert_true(mlirShapedTypeHasRank(tensor_type), "Should have rank")
    assert_equal(mlirShapedTypeGetRank(tensor_type), 2)

    mlirContextDestroy(ctx)


def test_type_parse_unranked_tensor():
    """Test parsing unranked tensor type."""
    var ctx = mlirContextCreate()
    var tensor_type = mlirTypeParseGet(ctx, "tensor<*xf32>")

    assert_false(
        mlirTypeIsNull(tensor_type), "Parsed unranked tensor should not be null"
    )
    assert_true(mlirTypeIsATensor(tensor_type), "Should be tensor type")
    assert_true(
        mlirTypeIsAUnrankedTensor(tensor_type), "Should be unranked tensor"
    )
    assert_false(
        mlirShapedTypeHasRank(tensor_type), "Unranked should not have rank"
    )

    mlirContextDestroy(ctx)


def test_type_parse_dynamic_tensor():
    """Test parsing tensor with dynamic dimensions."""
    var ctx = mlirContextCreate()
    var tensor_type = mlirTypeParseGet(ctx, "tensor<?x4xf32>")

    assert_false(
        mlirTypeIsNull(tensor_type), "Parsed dynamic tensor should not be null"
    )
    assert_true(mlirTypeIsARankedTensor(tensor_type), "Should be ranked tensor")
    assert_false(
        mlirShapedTypeHasStaticShape(tensor_type),
        "Dynamic tensor should not have static shape",
    )
    assert_true(
        mlirShapedTypeIsDynamicDim(tensor_type, 0),
        "First dim should be dynamic",
    )
    assert_false(
        mlirShapedTypeIsDynamicDim(tensor_type, 1),
        "Second dim should be static",
    )

    mlirContextDestroy(ctx)


def test_tensor_element_type():
    """Test getting element type from tensor."""
    var ctx = mlirContextCreate()
    var tensor_type = mlirTypeParseGet(ctx, "tensor<2x3xf32>")
    var f32_type = mlirF32TypeGet(ctx)

    var elem_type = mlirShapedTypeGetElementType(tensor_type)
    assert_true(
        mlirTypeEqual(elem_type, f32_type),
        "Element type should be f32",
    )

    mlirContextDestroy(ctx)


def test_ranked_tensor_constructor():
    """Test ranked tensor type via parsing and property verification."""
    var ctx = mlirContextCreate()

    # Parse tensor type and verify properties
    var tensor_type = mlirTypeParseGet(ctx, "tensor<3x4xf64>")
    assert_false(
        mlirTypeIsNull(tensor_type), "Created tensor type should not be null"
    )
    assert_true(mlirTypeIsARankedTensor(tensor_type), "Should be ranked tensor")
    assert_equal(mlirShapedTypeGetRank(tensor_type), 2)
    assert_equal(mlirShapedTypeGetDimSize(tensor_type, 0), 3)
    assert_equal(mlirShapedTypeGetDimSize(tensor_type, 1), 4)
    assert_true(
        mlirShapedTypeHasStaticShape(tensor_type), "Should have static shape"
    )

    # Verify element type
    var f64_type = mlirF64TypeGet(ctx)
    var elem_type = mlirShapedTypeGetElementType(tensor_type)
    assert_true(
        mlirTypeEqual(elem_type, f64_type), "Element type should be f64"
    )

    mlirContextDestroy(ctx)


def test_unranked_tensor_constructor():
    """Test unranked tensor type constructor."""
    var ctx = mlirContextCreate()
    var i32_type = mlirIntegerTypeGet(ctx, 32)

    var tensor_type = mlirUnrankedTensorTypeGet(i32_type)

    assert_false(
        mlirTypeIsNull(tensor_type),
        "Created unranked tensor should not be null",
    )
    assert_true(
        mlirTypeIsAUnrankedTensor(tensor_type), "Should be unranked tensor"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Type Equality Tests
# ===----------------------------------------------------------------------=== #


def test_type_equal_same():
    """Test type equality for same types."""
    var ctx = mlirContextCreate()
    var i32_1 = mlirTypeParseGet(ctx, "i32")
    var i32_2 = mlirTypeParseGet(ctx, "i32")

    assert_true(mlirTypeEqual(i32_1, i32_1), "Type should equal itself")
    assert_true(mlirTypeEqual(i32_1, i32_2), "Same types should be equal")

    mlirContextDestroy(ctx)


def test_type_not_equal_different():
    """Test type inequality for different types."""
    var ctx = mlirContextCreate()
    var i32 = mlirTypeParseGet(ctx, "i32")
    var f64 = mlirTypeParseGet(ctx, "f64")

    assert_false(mlirTypeEqual(i32, f64), "Different types should not be equal")

    mlirContextDestroy(ctx)


def test_type_not_equal_different_widths():
    """Test type inequality for different integer widths."""
    var ctx = mlirContextCreate()
    var i32 = mlirTypeParseGet(ctx, "i32")
    var i64 = mlirTypeParseGet(ctx, "i64")

    assert_false(
        mlirTypeEqual(i32, i64), "Different width integers should not be equal"
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Type Context Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_type_get_context():
    """Test getting context from type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    var type_ctx = mlirTypeGetContext(i32_type)
    assert_false(mlirContextIsNull(type_ctx), "Type context should not be null")
    assert_true(
        mlirContextEqual(ctx, type_ctx),
        "Type context should match creating context",
    )

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Type Dialect Retrieval Tests
# ===----------------------------------------------------------------------=== #


def test_type_get_dialect():
    """Test getting dialect from type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    var dialect = mlirTypeGetDialect(i32_type)
    # Integer types belong to the builtin dialect
    assert_false(mlirDialectIsNull(dialect), "Type dialect should not be null")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Type Printing Tests
# ===----------------------------------------------------------------------=== #


def test_type_print_integer():
    """Test printing an integer type."""
    var ctx = mlirContextCreate()
    var i32_type = mlirTypeParseGet(ctx, "i32")

    var output = String()
    mlirTypePrint(i32_type, output)

    assert_true(len(output) > 0, "Printed type should not be empty")
    assert_true("i32" in output, "Printed output should contain i32")

    mlirContextDestroy(ctx)


def test_type_print_tensor():
    """Test printing a tensor type."""
    var ctx = mlirContextCreate()
    var tensor_type = mlirTypeParseGet(ctx, "tensor<2x3xf32>")

    var output = String()
    mlirTypePrint(tensor_type, output)

    assert_true(len(output) > 0, "Printed type should not be empty")
    assert_true("tensor" in output, "Printed output should contain tensor")
    assert_true("f32" in output, "Printed output should contain f32")

    mlirContextDestroy(ctx)


# ===----------------------------------------------------------------------=== #
# Invalid Type Parsing Tests
# ===----------------------------------------------------------------------=== #


def test_type_parse_invalid():
    """Test parsing an invalid type string returns null."""
    var ctx = mlirContextCreate()
    var invalid_type = mlirTypeParseGet(ctx, "not_a_valid_type!!!")

    # Invalid parse should return null type
    assert_true(
        mlirTypeIsNull(invalid_type),
        "Invalid type parse should return null",
    )

    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
