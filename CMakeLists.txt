
cmake_minimum_required(VERSION 3.15)

# Set cross-compiler explicitly (TI ARM Clang)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER "/c/ems2/T2P_Tools/ti-arm-clang/3.2.0/bin/tiarmclang.exe" CACHE FILEPATH "C Compiler" FORCE)
set(CMAKE_CXX_COMPILER "/c/ems2/T2P_Tools/ti-arm-clang/3.2.0/bin/tiarmclang.exe" CACHE FILEPATH "CXX Compiler" FORCE)

# Don't try to test the compiler (cross-compilation)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

# Skip compiler ABI detection
set(CMAKE_C_ABI_COMPILED 1)
set(CMAKE_CXX_ABI_COMPILED 1)

project(build-benchmark C)

# Allow override of ITER from command line: -DITER=100
set(ITER 500 CACHE STRING "Number of modules to generate")

# Python executable (use MSYS2-style path)
set(PYTHON_EXE "/c/T2P_Tools/Python/3.13.2-01/python.exe")

# Generate files
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/generated/all.h
    COMMAND ${PYTHON_EXE} ${CMAKE_SOURCE_DIR}/gen_c_files.py ${ITER}
    DEPENDS ${CMAKE_SOURCE_DIR}/gen_c_files.py
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Generating C and H files with ITER=${ITER}"
    VERBATIM
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/main.c
    DEPENDS ${CMAKE_BINARY_DIR}/generated/all.h
    COMMENT ""
)

add_custom_target(generate ALL DEPENDS ${CMAKE_BINARY_DIR}/generated/all.h ${CMAKE_BINARY_DIR}/main.c)

# Generate list of C files based on ITER (instead of using GLOB which runs at configure time)
set(GEN_C_FILES "")
foreach(i RANGE 1 ${ITER})
    string(LENGTH ${i} len)
    if(len EQUAL 1)
        set(mod_num "00${i}")
    elseif(len EQUAL 2)
        set(mod_num "0${i}")
    else()
        set(mod_num "${i}")
    endif()
    list(APPEND GEN_C_FILES ${CMAKE_BINARY_DIR}/generated/mod_${mod_num}/mod_${mod_num}.c)
endforeach()

# Mark all generated files as GENERATED so CMake knows they will be created during build
set_source_files_properties(${GEN_C_FILES} PROPERTIES GENERATED TRUE)
set_source_files_properties(${CMAKE_BINARY_DIR}/main.c PROPERTIES GENERATED TRUE)

add_executable(test_app ${CMAKE_BINARY_DIR}/main.c ${GEN_C_FILES})

# Make sure the executable depends on the generation step
add_dependencies(test_app generate)

target_include_directories(test_app PRIVATE ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/generated)

# Add all module subdirectories to include path (like the Makefile does)
foreach(i RANGE 1 ${ITER})
    string(LENGTH ${i} len)
    if(len EQUAL 1)
        set(mod_num "00${i}")
    elseif(len EQUAL 2)
        set(mod_num "0${i}")
    else()
        set(mod_num "${i}")
    endif()
    target_include_directories(test_app PRIVATE ${CMAKE_BINARY_DIR}/generated/mod_${mod_num})
endforeach()

# Clean target: remove generated directory
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_SOURCE_DIR}/generated")

# Optional: add a test target to run the executable
add_custom_target(test
    COMMAND test_app
    DEPENDS test_app
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running test_app executable"
)
