#!/usr/bin/env bash

# Test all .mojo files in the tests directory

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Counters
total=0
passed=0
failed=0

echo "Running MLIR Mojo Bindings Tests"
echo "================================="
echo

# Run all test files
for file in $(find ./tests -type f -name 'test_*.mojo' | sort); do
    ((total++))
    printf "%-60s" "$file"
    
    if pixi run mojo run -I . "$file" >/dev/null 2>&1; then
        ((passed++))
        echo "✓"
    else
        ((failed++))
        echo "✗"
    fi
done

# Summary
echo
echo "================================="
echo "Results: $passed/$total passed"

[ "$failed" -eq 0 ] && exit 0 || exit 1
