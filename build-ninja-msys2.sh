#!/bin/bash

# MSYS2 build script - uses system-installed cmake and ninja from PATH
# Override compiler paths for MSYS2 environment

# Set MSYS2-style paths for the TI compiler
export TI_COMPILER_MSYS2="/c/ems2/T2P_Tools/ti-arm-clang/3.2.0/bin/tiarmclang.exe"
export PYTHON_MSYS2="/c/T2P_Tools/Python/3.13.2-01/python.exe"

# Run the main build script with MSYS2 paths
CMAKE_EXE=cmake NINJA_EXE=ninja ./build-ninja.sh
