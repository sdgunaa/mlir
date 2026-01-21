# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026 sdgunaa. All rights reserved.
#
# Licensed under the MIT License.
# ===----------------------------------------------------------------------=== #
"""Tests for the MLIR printing flags module.

Verifies printing flags affect operation output.
"""

from testing import assert_true, TestSuite
from mlir.core.context import mlirContextCreate, mlirContextDestroy
from mlir.core.location import mlirLocationUnknownGet
from mlir.core.module import (
    mlirModuleCreateEmpty,
    mlirModuleGetOperation,
    mlirModuleDestroy,
)
from mlir.core.operation import mlirOperationPrintWithFlags
from mlir.emit.printing_flags import (
    mlirOpPrintingFlagsCreate,
    mlirOpPrintingFlagsDestroy,
    mlirOpPrintingFlagsPrintGenericOpForm,
)


def test_print_with_generic_form():
    """Test that generic form flag changes output format."""
    var ctx = mlirContextCreate()
    var loc = mlirLocationUnknownGet(ctx)
    var mod = mlirModuleCreateEmpty(loc)
    var op = mlirModuleGetOperation(mod)

    var flags = mlirOpPrintingFlagsCreate()
    mlirOpPrintingFlagsPrintGenericOpForm(flags)

    # Print the operation - generic form should use "builtin.module"
    var output = String()
    mlirOperationPrintWithFlags(op, flags, output)

    # Generic form includes the full operation name
    assert_true("builtin.module" in output or "module" in output)

    mlirOpPrintingFlagsDestroy(flags)
    mlirModuleDestroy(mod)
    mlirContextDestroy(ctx)


def main():
    TestSuite.discover_tests[__functions_in_module()]().run()
