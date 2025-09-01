#!/bin/bash

# CMake build script with Unix Makefiles generator
# Cleans, configures, and times the build

set -e

echo "=== CMake Build with Unix Makefiles Generator ==="
echo "Date: $(date)"

# Clean up previous build
echo "Cleaning build directory..."
rm -rf build
mkdir build
cd build

# Configure with Unix Makefiles (default)
echo "Configuring with CMake (Unix Makefiles generator)..."
cmake .. -DITER=100

# Time the actual build
echo "Starting timed build..."
start_time=$(date +%s.%3N)
cmake --build . --parallel
end_time=$(date +%s.%3N)

# Calculate elapsed time
elapsed=$(echo "$end_time - $start_time" | bc -l)

echo "=== Build Complete ==="
echo "Generator: Unix Makefiles"
echo "Modules: 100"
echo "Build time: ${elapsed} seconds"
echo "Date: $(date)"

# Optional: show build artifacts
echo ""
echo "Build artifacts:"
ls -la test_app* 2>/dev/null || echo "No test_app files found"
