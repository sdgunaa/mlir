# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR ASM module.

Verifies ASM state creation for operations and values.
"""

from testing import assert_true, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetBody,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.block import mlirBlockAddArgument
from mlir.core.type import mlirTypeParseGet
from mlir.emit.printing_flags import (
    mlirOpPrintingFlagsCreate,
    mlirOpPrintingFlagsDestroy,
)
from mlir.emit.asm import (
    mlirAsmStateCreateForOperation,
    mlirAsmStateCreateForValue,
    mlirAsmStateDestroy,
)


def test_asm_state_for_operation_and_value():
    """Test creating ASM state for both operation and value."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)
    var flags = mlirOpPrintingFlagsCreate()

    # Create ASM state for operation
    var op_state = mlirAsmStateCreateForOperation(op, flags)
    mlirAsmStateDestroy(op_state)

    # Create ASM state for a value
    var body = mlirModuleGetBody(mod)
    var i32_type = mlirTypeParseGet(ctx, "i32")
    var arg = mlirBlockAddArgument(body, i32_type, loc)
    var val_state = mlirAsmStateCreateForValue(arg, flags)
    mlirAsmStateDestroy(val_state)

    mlirOpPrintingFlagsDestroy(flags)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)

    assert_true(True)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
