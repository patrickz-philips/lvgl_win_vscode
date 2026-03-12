cmake_minimum_required(VERSION 3.12.4)

# vcpkg support - set toolchain file before project()
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(_VCPKG_CMAKE_WORKSPACE "${CMAKE_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake")
    if(EXISTS "${_VCPKG_CMAKE_WORKSPACE}")
        set(CMAKE_TOOLCHAIN_FILE "${_VCPKG_CMAKE_WORKSPACE}"
            CACHE STRING "Vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain (workspace): ${CMAKE_TOOLCHAIN_FILE}")
    elseif(EXISTS "${CMAKE_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake")
        set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "Vcpkg toolchain file")
        message(STATUS "Using vcpkg toolchain (legacy): ${CMAKE_TOOLCHAIN_FILE}")
    endif()
endif()

# Default to static triplet if not specified
if(NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_TARGET_TRIPLET "x64-windows-static" CACHE STRING "Vcpkg target triplet")
endif()
message(STATUS "Using vcpkg triplet: ${VCPKG_TARGET_TRIPLET}")

project(lvgl C CXX)

# Set the correct FreeRTOS port for your system (e.g., Posix for WSL)
set(FREERTOS_PORT GCC_POSIX CACHE STRING "Port for FreeRTOS on Posix environment")

set(LVGL_PRO_PROJECT_DIR
    ""
    CACHE PATH "Path to LVGL Pro Project folder")

option(USE_FREERTOS "Enable FreeRTOS" OFF) # Turn this on to enable FreeRTOS

# Project Selection: Choose which project to build
# Options: HAIR_DRYER, SMART_SHAVER
set(SELECTED_PROJECT "HAIR_DRYER" CACHE STRING "Select project to build: HAIR_DRYER or SMART_SHAVER")
set_property(CACHE SELECTED_PROJECT PROPERTY STRINGS "HAIR_DRYER" "SMART_SHAVER")

if(USE_FREERTOS)
    message(STATUS "FreeRTOS is enabled")

    # FreeRTOS integration when USE_FREERTOS is enabled
    add_library(freertos_config INTERFACE)
    target_include_directories(freertos_config SYSTEM INTERFACE ${PROJECT_SOURCE_DIR}/config)
    target_compile_definitions(freertos_config INTERFACE projCOVERAGE_TEST=0)

    # Add FreeRTOS as a subdirectory
    add_subdirectory(FreeRTOS)

    # FreeRTOS-specific include directories
    include_directories(${PROJECT_SOURCE_DIR}/FreeRTOS/include)
    include_directories(${PROJECT_SOURCE_DIR}/FreeRTOS/portable/ThirdParty/GCC/Posix)
    include_directories(${PROJECT_SOURCE_DIR}/config)

    # Add FreeRTOS sources
    file(GLOB FREERTOS_SOURCES
        "${PROJECT_SOURCE_DIR}/FreeRTOS/*.c"
        "${PROJECT_SOURCE_DIR}/FreeRTOS/portable/MemMang/heap_4.c"
        "${PROJECT_SOURCE_DIR}/FreeRTOS/portable/ThirdParty/GCC/Posix/*.c"
    )
else()
    message(STATUS "FreeRTOS is disabled")
    set(FREERTOS_SOURCES "")  # No FreeRTOS sources if FreeRTOS is disabled
endif()

# Main include files of the project
include_directories(${PROJECT_SOURCE_DIR}/main/inc)

# Define options for LVGL with default values (OFF)
option(LV_USE_DRAW_SDL "Use SDL draw unit" OFF)
option(LV_USE_LIBPNG "Use libpng to decode PNG" OFF)
option(LV_USE_LIBJPEG_TURBO "Use libjpeg turbo to decode JPEG" OFF)
option(LV_USE_FFMPEG "Use libffmpeg to display video using lv_ffmpeg" OFF)
option(LV_USE_FREETYPE "Use freetype library" OFF)

# Set C and C++ standards
set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Output directory structure: build/{Debug|Release}/{project} and bin/{Debug|Release}/{project}
# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose Debug or Release" FORCE)
endif()

# Create a sanitized project name for directory structure
string(TOLOWER ${SELECTED_PROJECT} PROJECT_NAME_LOWER)

# Set the output paths
set(BUILD_OUTPUT_DIR ${PROJECT_SOURCE_DIR}/build/${CMAKE_BUILD_TYPE}/${PROJECT_NAME_LOWER})
set(BIN_OUTPUT_DIR ${PROJECT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE}/${PROJECT_NAME_LOWER})

# Set output paths for executables and libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BIN_OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BIN_OUTPUT_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${BIN_OUTPUT_DIR}/lib)

# Set per-configuration output directories (for multi-config generators like Visual Studio)
foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG_UPPER)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UPPER} ${BIN_OUTPUT_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UPPER} ${BIN_OUTPUT_DIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG_UPPER} ${BIN_OUTPUT_DIR}/lib)
endforeach()

set(EXECUTABLE_OUTPUT_PATH ${BIN_OUTPUT_DIR})
set(WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})

# Find and include SDL2 library
# For static linking, prefer static libraries
if(VCPKG_TARGET_TRIPLET MATCHES ".*-static$")
    set(SDL2_USE_STATIC_LIBS ON)
    message(STATUS "Using static SDL2 library")
endif()
find_package(SDL2 REQUIRED)

# Add compile definitions based on the selected options
add_compile_definitions($<$<BOOL:${LV_USE_DRAW_SDL}>:LV_USE_DRAW_SDL=1>)
add_compile_definitions($<$<BOOL:${LV_USE_LIBPNG}>:LV_USE_LIBPNG=1>)
add_compile_definitions($<$<BOOL:${LV_USE_LIBJPEG_TURBO}>:LV_USE_LIBJPEG_TURBO=1>)
add_compile_definitions($<$<BOOL:${LV_USE_FFMPEG}>:LV_USE_FFMPEG=1>)

# Configure LVGL to build only necessary components
# These options are controlled by CONFIG_LV_BUILD_* in lvgl/env_support/cmake/os_desktop.cmake
set(CONFIG_LV_BUILD_EXAMPLES OFF CACHE BOOL "Build LVGL examples" FORCE)
set(CONFIG_LV_BUILD_DEMOS OFF CACHE BOOL "Build LVGL demos" FORCE)
set(CONFIG_LV_USE_THORVG_INTERNAL OFF CACHE BOOL "Use ThorVG internal" FORCE)

message(STATUS "LVGL Build Configuration:")
message(STATUS "  - Examples: ${CONFIG_LV_BUILD_EXAMPLES}")
message(STATUS "  - Demos:    ${CONFIG_LV_BUILD_DEMOS}")
message(STATUS "  - ThorVG:   ${CONFIG_LV_USE_THORVG_INTERNAL}")

# Add LVGL subdirectory
add_subdirectory(lvgl)
target_include_directories(lvgl PUBLIC ${PROJECT_SOURCE_DIR} ${SDL2_INCLUDE_DIRS})

set(MAIN_SOURCES src/mouse_cursor_icon.c src/hal/hal.c)
# Only link necessary libraries (removed examples and demos to speed up build)
set(MAIN_LIBS lvgl ${SDL2_LIBRARIES})

# Add project-specific sources and include directories based on selection
if(SELECTED_PROJECT STREQUAL "HAIR_DRYER")
    message(STATUS "Building Hair Dryer Project")
    add_compile_definitions(PROJECT_HAIR_DRYER)
    list(APPEND MAIN_SOURCES 
        hair_dryer/src/hair_dryer.c
        hair_dryer/src/led_strips_discolor.c
    )
    include_directories(${PROJECT_SOURCE_DIR}/hair_dryer/inc)
    
    # Asset compilation strategy: Release uses static, Debug uses dynamic
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        # Release mode: Use static compiled assets
        if(EXISTS "${PROJECT_SOURCE_DIR}/hair_dryer/assets/hair_dryer.c")
            list(APPEND MAIN_SOURCES hair_dryer/assets/hair_dryer.c)
            add_compile_definitions(USE_STATIC_ASSETS)
            message(STATUS "Release mode: Using static compiled assets")
        else()
            message(WARNING "Release mode but static asset file not found!")
            message(WARNING "Please generate hair_dryer/assets/hair_dryer.c from hair_dryer.png")
            message(WARNING "See hair_dryer/assets/README.md for instructions")
            message(STATUS "Falling back to filesystem loading")
        endif()
    else()
        # Debug mode: Use dynamic filesystem loading
        message(STATUS "Debug mode: Using dynamic filesystem loading")
    endif()
    include_directories(${PROJECT_SOURCE_DIR}/hair_dryer/assets)
elseif(SELECTED_PROJECT STREQUAL "SMART_SHAVER")
    message(STATUS "Building Smart Shaver Project")
    add_compile_definitions(PROJECT_SMART_SHAVER)
    list(APPEND MAIN_SOURCES smart_shaver/src/smart_shaver.c)
    include_directories(${PROJECT_SOURCE_DIR}/smart_shaver/inc)
else()
    message(FATAL_ERROR "Invalid project selection: ${SELECTED_PROJECT}. Must be HAIR_DRYER or SMART_SHAVER")
endif()

# Create the main executable, depending on the FreeRTOS option
if(USE_FREERTOS)
    list(APPEND MAIN_SOURCES src/freertos_main.c src/freertos/freertos_posix_port.c ${FREERTOS_SOURCES})
    list(APPEND MAIN_LIBS freertos_config freertos_kernel)
else()
    list(APPEND MAIN_SOURCES src/main.c)
endif()


if(NOT MSVC)
    list(APPEND MAIN_LIBS m pthread)
endif()

# Custom target to run the executable
add_custom_target(run 
    COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/main
    WORKING_DIRECTORY ${WORKING_DIRECTORY}
    DEPENDS main
    COMMENT "Running ${SELECTED_PROJECT} in ${CMAKE_BUILD_TYPE} mode"
)

# Conditionally include and link SDL2_image if LV_USE_DRAW_SDL is enabled
if(LV_USE_DRAW_SDL)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
    find_package(SDL2_image REQUIRED)
    target_include_directories(lvgl PUBLIC ${SDL2_IMAGE_INCLUDE_DIRS})
    list(APPEND MAIN_LIBS ${SDL2_IMAGE_LIBRARIES})
endif()

# Conditionally include and link libpng if LV_USE_LIBPNG is enabled
if(LV_USE_LIBPNG)
    find_package(PNG REQUIRED)
    target_include_directories(lvgl PUBLIC ${PNG_INCLUDE_DIRS})
    list(APPEND MAIN_LIBS ${PNG_LIBRARIES})
endif()

# Conditionally include and link libjpeg-turbo if LV_USE_LIBJPEG_TURBO is enabled
if(LV_USE_LIBJPEG_TURBO)
    find_package(JPEG REQUIRED)
    target_include_directories(lvgl PUBLIC ${JPEG_INCLUDE_DIRS})
    list(APPEND MAIN_LIBS ${JPEG_LIBRARIES})
endif()

# Conditionally include and link FFmpeg libraries if LV_USE_FFMPEG is enabled
if(LV_USE_FFMPEG)
    list(APPEND MAIN_LIBS avformat avcodec avutil swscale z)
endif()

# Conditionally include and link FreeType if LV_USE_FREETYPE is enabled
if(LV_USE_FREETYPE)
    find_package(Freetype REQUIRED)
    target_include_directories(lvgl PUBLIC ${FREETYPE_INCLUDE_DIRS})
    list(APPEND MAIN_LIBS ${FREETYPE_LIBRARIES})
endif()

if(LVGL_PRO_PROJECT_DIR)
  if(EXISTS "${LVGL_PRO_PROJECT_DIR}/CMakeLists.txt")
    add_subdirectory(${LVGL_PRO_PROJECT_DIR} ui)
    list(APPEND MAIN_LIBS lib-ui)

    target_compile_definitions(lib-ui PUBLIC LV_LVGL_H_INCLUDE_SIMPLE)
    target_include_directories(lib-ui PUBLIC
      ${LVGL_PRO_PROJECT_DIR}  # local headers like ui.h, generated files, etc.
      ${CMAKE_SOURCE_DIR}/lvgl # include "lvgl.h" works
    )
    message(STATUS "LVGL Pro Project enabled from: ${LVGL_PRO_PROJECT_DIR}")
  else()
    message(
      WARNING
        "LVGL_PRO_PROJECT_DIR specified but no CMakeLists.txt found at: ${LVGL_PRO_PROJECT_DIR}"
    )
  endif()
endif()

add_executable(main ${MAIN_SOURCES})
target_compile_definitions(main PRIVATE LV_CONF_INCLUDE_SIMPLE)
target_link_libraries(main ${MAIN_LIBS})

# Disable automatic DLL copying for static builds
if(VCPKG_TARGET_TRIPLET MATCHES ".*-static$")
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
    set(VCPKG_APPLOCAL_DEPS OFF CACHE BOOL "Disable automatic DLL copying" FORCE)
    message(STATUS "Static build: Disabled automatic DLL copying")
endif()

# On Windows, GUI applications do not show a console by default,
# which hides log output. This ensures a console is available for logging.
if (WIN32)
    if (MSVC)
        target_link_options(main PRIVATE "/SUBSYSTEM:CONSOLE")
    else()
        target_link_options(main PRIVATE "-mconsole")
    endif()
endif()

# Apply additional compile options if the build type is Debug
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Debug mode enabled")

    # Apply compiler-specific warning flags
    if(NOT MSVC)
        # GCC/Clang warning flags
        target_compile_options(lvgl PRIVATE
            -pedantic-errors
            -Wall
            -Wclobbered
            -Wdeprecated
            -Wdouble-promotion
            -Wempty-body
            -Wextra
            -Wformat-security
            -Wmaybe-uninitialized
            # -Wmissing-prototypes
            -Wpointer-arith
            -Wmultichar
            -Wno-pedantic # ignored for now, we convert functions to pointers for properties table.
            -Wreturn-type
            -Wshadow
            -Wshift-negative-value
            -Wsizeof-pointer-memaccess
            -Wtype-limits
            -Wundef
            -Wuninitialized
            -Wunreachable-code
            -Wfloat-conversion
            -Wstrict-aliasing
        )
    else()
        # MSVC warning flags
        target_compile_options(lvgl PRIVATE
            /W4                 # Warning level 4
            /WX-                # Do not treat warnings as errors
            /wd4996             # Disable deprecated function warnings
        )
    endif()

    if (ASAN)
        if(NOT MSVC)
            message(STATUS "AddressSanitizer enabled (GCC/Clang)")
            # Add AddressSanitizer flags for GCC/Clang
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fsanitize=address")
        else()
            message(STATUS "AddressSanitizer enabled (MSVC)")
            # MSVC uses /fsanitize=address
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=address")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /fsanitize=address")
        endif()
    else()
        message(STATUS "AddressSanitizer disabled")
    endif()
endif()
