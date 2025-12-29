@echo off
REM ============================================================
REM Run Script for LVGL Project
REM ============================================================
REM Usage: run.bat [PROJECT] [BUILD_TYPE]
REM   PROJECT: HAIR_DRYER, SMART_SHAVER (default: HAIR_DRYER)
REM   BUILD_TYPE: Debug, Release (default: Debug)
REM ============================================================

setlocal enabledelayedexpansion

set PROJECT=%1
set BUILD_TYPE=%2

if "%PROJECT%"=="" set PROJECT=HAIR_DRYER
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug

REM Validate and normalize
if /i not "%PROJECT%"=="HAIR_DRYER" if /i not "%PROJECT%"=="SMART_SHAVER" (
    echo ERROR: Invalid project "%PROJECT%"
    echo Valid projects: HAIR_DRYER, SMART_SHAVER
    pause
    exit /b 1
)

if /i not "%BUILD_TYPE%"=="Debug" if /i not "%BUILD_TYPE%"=="Release" (
    echo ERROR: Invalid build type "%BUILD_TYPE%"
    echo Valid build types: Debug, Release
    pause
    exit /b 1
)

if /i "%PROJECT%"=="HAIR_DRYER" set PROJECT=HAIR_DRYER
if /i "%PROJECT%"=="SMART_SHAVER" set PROJECT=SMART_SHAVER
if /i "%BUILD_TYPE%"=="Debug" set BUILD_TYPE=Debug
if /i "%BUILD_TYPE%"=="Release" set BUILD_TYPE=Release

set PROJECT_LOWER=%PROJECT%
if /i "%PROJECT%"=="HAIR_DRYER" set PROJECT_LOWER=hair_dryer
if /i "%PROJECT%"=="SMART_SHAVER" set PROJECT_LOWER=smart_shaver

set EXE_PATH=bin\%BUILD_TYPE%\%PROJECT_LOWER%\main.exe

if not exist "%EXE_PATH%" (
    echo ERROR: Executable not found at %EXE_PATH%
    echo.
    echo Please build the project first:
    echo   build.bat %PROJECT% %BUILD_TYPE%
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo Running %PROJECT% - %BUILD_TYPE% Mode
echo ============================================================
echo.
echo Working Directory: %CD%
echo Executable: bin\%BUILD_TYPE%\%PROJECT_LOWER%\main.exe
echo.

REM Run from project root directory so relative paths work
bin\%BUILD_TYPE%\%PROJECT_LOWER%\main.exe

echo.
echo Application closed.
pause

