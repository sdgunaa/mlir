#!/usr/bin/env bash

# Format all .mojo files using the Mojo formatter


set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

total=0
formatted=0
failed=0

echo "Running MLIR Mojo Bindings Format Check"
echo "=================================" 
echo

# Run all .mojo files in mlir directory and tests directory
for file in $(find ./mlir ./tests -type f -name '*.mojo' | sort); do
    ((total++))
    printf "%-60s" "$file"
    
    if pixi run mojo format "$file" >/dev/null 2>&1; then
        ((formatted++))
        echo "✓"
    else
        ((failed++))
        echo "✗"
    fi
done

# Summary
echo
echo "================================="
echo "Results: $formatted/$total passed"

[ "$failed" -eq 0 ] && exit 0 || exit 1