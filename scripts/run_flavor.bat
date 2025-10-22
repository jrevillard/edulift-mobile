@echo off
REM EduLift Mobile - Flavor Runner Script (Windows)
REM Simplifies Flutter flavor commands using convention over configuration
REM 
REM Convention: flavor name = main entry point name
REM Example: e2e flavor → lib/main_e2e.dart
REM
REM Usage:
REM   scripts\run_flavor.bat <flavor> [additional flutter args]
REM   scripts\run_flavor.bat development
REM   scripts\run_flavor.bat e2e --hot
REM   scripts\run_flavor.bat staging --release

setlocal enabledelayedexpansion

REM Get script directory
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..

REM Function to show usage
:show_usage
echo EduLift Mobile - Flavor Runner (Windows)
echo.
echo Usage: %0 ^<flavor^> [additional flutter args]
echo.
echo Available flavors:
call :list_available_flavors
echo.
echo Examples:
echo   %0 development                    # Run development flavor
echo   %0 e2e                           # Run E2E testing flavor
echo   %0 staging --hot                 # Run staging with hot reload
echo   %0 production --release          # Run production in release mode
echo   %0 development -d chrome         # Run development on Chrome
echo.
echo Convention: flavor name must match main_^<flavor^>.dart file
goto :eof

REM Function to list available flavors
:list_available_flavors
cd /d %PROJECT_DIR%
for %%f in (lib\main_*.dart) do (
    if not "%%f"=="lib\main.dart" (
        set filename=%%~nf
        set flavor=!filename:main_=!
        echo   • !flavor! → %%f
    )
)
goto :eof

REM Function to validate flavor and get target file
:get_target_file
set flavor=%1
set target_file=lib\main_%flavor%.dart

cd /d %PROJECT_DIR%

if not exist %target_file% (
    echo ❌ Flavor '%flavor%' not found!
    echo ⚠️  Expected file: %target_file%
    echo.
    echo Available flavors:
    call :list_available_flavors
    echo.
    echo To create a new flavor, create: %target_file%
    exit /b 1
)

set result=%target_file%
goto :eof

REM Main execution function
:run_flutter_flavor
set flavor=%1

REM Get target file for the flavor
call :get_target_file %flavor%
if errorlevel 1 exit /b 1
set target_file=%result%

echo ℹ️  Running Flutter flavor: %flavor%
echo 🐛 Target file: %target_file%

REM Shift to get additional arguments
shift
set additional_args=
:parse_args
if "%1"=="" goto :run_command
set additional_args=%additional_args% %1
shift
goto :parse_args

:run_command
echo 🐛 Additional args: %additional_args%

REM Change to project directory
cd /d %PROJECT_DIR%

REM Construct and execute Flutter command
set flutter_cmd=flutter run --flavor %flavor% --target %target_file% %additional_args%
echo ℹ️  Executing: %flutter_cmd%
echo.

%flutter_cmd%
goto :eof

REM Main script logic
:main
REM Check if flavor argument is provided
if "%1"=="" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help

REM Check if we're in the right directory
if not exist "%PROJECT_DIR%\pubspec.yaml" (
    echo ❌ Not in a Flutter project directory!
    echo ⚠️  Expected to find pubspec.yaml at: %PROJECT_DIR%\pubspec.yaml
    exit /b 1
)

REM Check if Flutter is available
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

REM Run the flavor
call :run_flutter_flavor %*
goto :eof

:show_help
call :show_usage
goto :eof

REM Execute main function
call :main %*