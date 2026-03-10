@echo off
REM ============================================================================
REM CodeIgniter 4 Docker Environment — Windows Teardown Script
REM ============================================================================

setlocal

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%\..\.."
set "PROJECT_ROOT=%CD%"
popd

cd /d "%PROJECT_ROOT%"

echo.
echo ==============================================
echo   CodeIgniter 4 Docker — Windows Teardown
echo ==============================================
echo.

if "%~1"=="--volumes" (
    echo [WARN]  Stopping containers AND removing volumes (all database data will be lost)...
    docker compose down -v
) else (
    echo [INFO]  Stopping containers (database data preserved in Docker volume)...
    docker compose down
)

echo.
echo [OK]    Done. To start again, run:  scripts\windows\setup.bat
echo.
pause
