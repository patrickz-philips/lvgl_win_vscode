@echo off
REM ============================================================
REM Universal Build Script for LVGL Project
REM ============================================================
REM This script allows you to build any project in Debug or Release mode
REM Usage: build.bat [PROJECT] [BUILD_TYPE]
REM   PROJECT: HAIR_DRYER, SMART_SHAVER, CHEETAH (default: HAIR_DRYER)
REM   BUILD_TYPE: Debug, Release (default: Debug)
REM
REM Examples:
REM   build.bat                           - Build HAIR_DRYER in Debug mode
REM   build.bat HAIR_DRYER Debug         - Build HAIR_DRYER in Debug mode
REM   build.bat HAIR_DRYER Release       - Build HAIR_DRYER in Release mode
REM   build.bat SMART_SHAVER Debug       - Build SMART_SHAVER in Debug mode
REM   build.bat CHEETAH Debug            - Build CHEETAH in Debug mode
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM Prerequisite checks
REM ============================================================
where cmake >nul 2>nul
if errorlevel 1 (
    echo ERROR: CMake was not found in PATH.
    echo.
    echo Fix options:
    echo   1^) Install CMake, then reopen the terminal:
    echo      winget install -e --id Kitware.CMake
    echo   2^) Or download installer from Kitware and check "Add CMake to PATH".
    echo.
    echo Verify:
    echo   cmake --version
    echo.
    pause
    exit /b 1
)

REM Parse command line arguments
set PROJECT=%1
set BUILD_TYPE=%2

REM Set defaults if not provided
if "%PROJECT%"=="" set PROJECT=HAIR_DRYER
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug

REM Validate PROJECT
if /i not "%PROJECT%"=="HAIR_DRYER" if /i not "%PROJECT%"=="SMART_SHAVER" if /i not "%PROJECT%"=="CHEETAH" (
    echo ERROR: Invalid project "%PROJECT%"
    echo.
    echo Valid projects: HAIR_DRYER, SMART_SHAVER, CHEETAH
    echo.
    pause
    exit /b 1
)

REM Validate BUILD_TYPE
if /i not "%BUILD_TYPE%"=="Debug" if /i not "%BUILD_TYPE%"=="Release" (
    echo ERROR: Invalid build type "%BUILD_TYPE%"
    echo.
    echo Valid build types: Debug, Release
    echo.
    pause
    exit /b 1
)

REM Normalize case
if /i "%PROJECT%"=="HAIR_DRYER" set PROJECT=HAIR_DRYER
if /i "%PROJECT%"=="SMART_SHAVER" set PROJECT=SMART_SHAVER
if /i "%PROJECT%"=="CHEETAH" set PROJECT=CHEETAH
if /i "%BUILD_TYPE%"=="Debug" set BUILD_TYPE=Debug
if /i "%BUILD_TYPE%"=="Release" set BUILD_TYPE=Release

REM Create lowercase version for directory name
set PROJECT_LOWER=%PROJECT%
if /i "%PROJECT%"=="HAIR_DRYER" set PROJECT_LOWER=hair_dryer
if /i "%PROJECT%"=="SMART_SHAVER" set PROJECT_LOWER=smart_shaver
if /i "%PROJECT%"=="CHEETAH" set PROJECT_LOWER=cheetah

echo ============================================================
echo Building %PROJECT% Project - %BUILD_TYPE% Mode
echo ============================================================
echo.
echo Configuration:
echo   Project:     %PROJECT%
echo   Build Type:  %BUILD_TYPE%
echo   Build Dir:   build\%BUILD_TYPE%\%PROJECT_LOWER%
echo   Output Dir:  bin\%BUILD_TYPE%\%PROJECT_LOWER%
echo.

REM Special handling for HAIR_DRYER Release mode - convert images
if /i "%PROJECT%"=="HAIR_DRYER" if /i "%BUILD_TYPE%"=="Release" (
    if not exist "hair_dryer\assets\hair_dryer.c" (
        echo [Pre-build] Converting hair_dryer.png to C array...
        echo.
        
        python hair_dryer\assets\convert_image.py
        
        if errorlevel 1 (
            echo.
            echo WARNING: Image conversion failed!
            echo.
            echo Please either:
            echo   1. Install Pillow: pip install pillow
            echo   2. Or manually convert using online tool:
            echo      https://lvgl.io/tools/imageconverter
            echo.
            echo Continuing with filesystem loading...
            echo.
            timeout /t 3 >nul
        ) else (
            echo Static image file generated successfully!
            echo.
        )
    ) else (
        echo [Pre-build] Static image file already exists
        echo.
    )
)

REM Create build directory for this configuration
set BUILD_DIR=build\%BUILD_TYPE%\%PROJECT_LOWER%
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo [Step 1/2] Configuring CMake...
set "VCPKG_TOOLCHAIN=%~dp0..\vcpkg\scripts\buildsystems\vcpkg.cmake"

cmake -B "%BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DSELECTED_PROJECT=%PROJECT% ^
    -DVCPKG_TARGET_TRIPLET=x64-windows-static ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_TOOLCHAIN%"

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    echo.
    pause
    exit /b 1
)

echo.
echo [Step 2/2] Building project...
cmake --build "%BUILD_DIR%" --config %BUILD_TYPE% -j

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo Build completed successfully!
echo ============================================================
echo.
echo Output location: bin\%BUILD_TYPE%\%PROJECT_LOWER%\main.exe
echo.
echo To run the application:
echo   cd bin\%BUILD_TYPE%\%PROJECT_LOWER%
echo   main.exe
echo.
echo Or use: run.bat %PROJECT% %BUILD_TYPE%
echo.

pause

