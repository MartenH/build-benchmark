#!/bin/bash

# CMake build script with Ninja generator
# Cleans, configures, and times the build

set -e

echo "=== CMake Build with Ninja Generator ==="
echo "Date: $(date)"

# Clean up previous build
echo "Cleaning build directory..."
rm -rf build
mkdir build
cd build

# Configure with Ninja
echo "Configuring with CMake (Ninja generator)..."
cmake -G Ninja .. -DITER=500

# Time the actual build
echo "Starting timed build..."
start_time=$(date +%s.%3N)
cmake --build . --parallel
end_time=$(date +%s.%3N)

# Calculate elapsed time
elapsed=$(echo "$end_time - $start_time" | bc -l)

echo "=== Build Complete ==="
echo "Generator: Ninja"
echo "Modules: 500"
echo "Build time: ${elapsed} seconds"
echo "Date: $(date)"

# Optional: show build artifacts
echo ""
echo "Build artifacts:"
ls -la test_app* 2>/dev/null || echo "No test_app files found"
