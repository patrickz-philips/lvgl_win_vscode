@echo off
REM ============================================================
REM Clean Script for LVGL Project
REM ============================================================
REM Usage: clean.bat [TARGET]
REM   TARGET: all, build, bin, PROJECT_NAME (default: all)
REM
REM Examples:
REM   clean.bat              - Clean everything (build + bin)
REM   clean.bat all          - Clean everything (build + bin)
REM   clean.bat build        - Clean only build directory
REM   clean.bat bin          - Clean only bin directory
REM   clean.bat HAIR_DRYER   - Clean HAIR_DRYER project only
REM ============================================================

setlocal enabledelayedexpansion

set TARGET=%1
if "%TARGET%"=="" set TARGET=all

echo ============================================================
echo LVGL Project Cleaner
echo ============================================================
echo.

if /i "%TARGET%"=="all" goto CLEAN_ALL
if /i "%TARGET%"=="build" goto CLEAN_BUILD
if /i "%TARGET%"=="bin" goto CLEAN_BIN
if /i "%TARGET%"=="HAIR_DRYER" goto CLEAN_HAIR_DRYER
if /i "%TARGET%"=="SMART_SHAVER" goto CLEAN_SMART_SHAVER

echo ERROR: Unknown target "%TARGET%"
echo.
echo Valid targets: all, build, bin, HAIR_DRYER, SMART_SHAVER
echo.
pause
exit /b 1

:CLEAN_ALL
echo Cleaning all build artifacts...
echo.
if exist "build" (
    echo [1/2] Removing build directory...
    rmdir /s /q "build" 2>nul
    echo   Done.
) else (
    echo [1/2] Build directory not found, skipping.
)
if exist "bin" (
    echo [2/2] Removing bin directory...
    rmdir /s /q "bin" 2>nul
    echo   Done.
) else (
    echo [2/2] Bin directory not found, skipping.
)
goto END

:CLEAN_BUILD
echo Cleaning build directory...
echo.
if exist "build" (
    rmdir /s /q "build" 2>nul
    echo Done.
) else (
    echo Build directory not found, skipping.
)
goto END

:CLEAN_BIN
echo Cleaning bin directory...
echo.
if exist "bin" (
    rmdir /s /q "bin" 2>nul
    echo Done.
) else (
    echo Bin directory not found, skipping.
)
goto END

:CLEAN_HAIR_DRYER
echo Cleaning HAIR_DRYER project...
echo.
set CLEANED=0
if exist "build\Debug\hair_dryer" (
    echo Removing build\Debug\hair_dryer...
    rmdir /s /q "build\Debug\hair_dryer" 2>nul
    set CLEANED=1
)
if exist "build\Release\hair_dryer" (
    echo Removing build\Release\hair_dryer...
    rmdir /s /q "build\Release\hair_dryer" 2>nul
    set CLEANED=1
)
if exist "bin\Debug\hair_dryer" (
    echo Removing bin\Debug\hair_dryer...
    rmdir /s /q "bin\Debug\hair_dryer" 2>nul
    set CLEANED=1
)
if exist "bin\Release\hair_dryer" (
    echo Removing bin\Release\hair_dryer...
    rmdir /s /q "bin\Release\hair_dryer" 2>nul
    set CLEANED=1
)
if "%CLEANED%"=="0" (
    echo No HAIR_DRYER artifacts found, skipping.
) else (
    echo Done.
)
goto END

:CLEAN_SMART_SHAVER
echo Cleaning SMART_SHAVER project...
echo.
set CLEANED=0
if exist "build\Debug\smart_shaver" (
    echo Removing build\Debug\smart_shaver...
    rmdir /s /q "build\Debug\smart_shaver" 2>nul
    set CLEANED=1
)
if exist "build\Release\smart_shaver" (
    echo Removing build\Release\smart_shaver...
    rmdir /s /q "build\Release\smart_shaver" 2>nul
    set CLEANED=1
)
if exist "bin\Debug\smart_shaver" (
    echo Removing bin\Debug\smart_shaver...
    rmdir /s /q "bin\Debug\smart_shaver" 2>nul
    set CLEANED=1
)
if exist "bin\Release\smart_shaver" (
    echo Removing bin\Release\smart_shaver...
    rmdir /s /q "bin\Release\smart_shaver" 2>nul
    set CLEANED=1
)
if "%CLEANED%"=="0" (
    echo No SMART_SHAVER artifacts found, skipping.
) else (
    echo Done.
)
goto END

:END
echo.
echo ============================================================
echo Cleanup completed!
echo ============================================================
echo.
pause

