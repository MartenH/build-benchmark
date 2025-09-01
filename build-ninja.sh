#!/bin/bash

# Set the number of iterations/modules
ITER=${ITER:-500}

# Set custom tool paths (can be overridden by environment variables)
# For MSYS2: Leave as defaults (cmake/ninja) - tools should be in PATH
# For Cygwin: Set full paths to Windows executables
CMAKE_EXE=${CMAKE_EXE:-cmake}
NINJA_EXE=${NINJA_EXE:-ninja}

# Convert Cygwin paths to Windows paths for CMake if needed
if [[ "$CMAKE_EXE" == /cygdrive/* ]]; then
    CMAKE_EXE_WIN=$(cygpath -w "$CMAKE_EXE")
else
    CMAKE_EXE_WIN="$CMAKE_EXE"
fi

if [[ "$NINJA_EXE" == /cygdrive/* ]]; then
    NINJA_EXE_WIN=$(cygpath -w "$NINJA_EXE")
else
    NINJA_EXE_WIN="$NINJA_EXE"
fi

# CMake build script with Ninja generator
# Cleans, configures, and times the build

set -e

echo "=== CMake Build with Ninja Generator ==="
echo "Date: $(date)"
echo "CMake: ${CMAKE_EXE}"
echo "Ninja: ${NINJA_EXE}"
if [[ "$CMAKE_EXE" == /cygdrive/* ]] || [[ "$NINJA_EXE" == /cygdrive/* ]]; then
    echo "CMake (Windows path): ${CMAKE_EXE_WIN}"
    echo "Ninja (Windows path): ${NINJA_EXE_WIN}"
    echo "Environment: Cygwin (using custom tool paths)"
else
    echo "Environment: MSYS2 or system default (using PATH)"
fi
echo "Modules: ${ITER}"

# Clean up previous build
echo "Cleaning build directory..."
rm -rf build
mkdir build
cd build

# Configure with Ninja
echo "Configuring with CMake (Ninja generator)..."

# Prepare CMake arguments
CMAKE_ARGS=("-G" "Ninja" ".." "-DITER=${ITER}")

# Add custom ninja path if specified
if [ "${NINJA_EXE}" != "ninja" ]; then
    CMAKE_ARGS+=("-DCMAKE_MAKE_PROGRAM=${NINJA_EXE_WIN}")
fi

# Add MSYS2 paths if specified
if [ -n "${TI_COMPILER_MSYS2}" ]; then
    CMAKE_ARGS+=("-DTI_COMPILER_PATH=${TI_COMPILER_MSYS2}")
fi

if [ -n "${PYTHON_MSYS2}" ]; then
    CMAKE_ARGS+=("-DPYTHON_EXE=${PYTHON_MSYS2}")
fi

# Run CMake with all arguments
"${CMAKE_EXE}" "${CMAKE_ARGS[@]}"

# Time the actual build
echo "Starting timed build..."
start_time=$(date +%s.%3N)
"${CMAKE_EXE}" --build . --parallel --verbose
end_time=$(date +%s.%3N)

# Calculate elapsed time
elapsed=$(echo "$end_time - $start_time" | bc -l)

echo "=== Build Complete ==="
echo "Generator: Ninja"
echo "Modules: ${ITER}"
echo "Build time: ${elapsed} seconds"
echo "Date: $(date)"

# Optional: show build artifacts
echo ""
echo "Build artifacts:"
ls -la test_app* 2>/dev/null || echo "No test_app files found"
