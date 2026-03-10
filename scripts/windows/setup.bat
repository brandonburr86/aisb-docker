@echo off
REM ============================================================================
REM CodeIgniter 4 Docker Environment — Windows Setup Script
REM ============================================================================
REM This script checks prerequisites and builds the Docker environment
REM on Windows. Run from the codeigniter-docker project root.
REM Requires: Docker Desktop for Windows (with WSL 2 backend recommended)
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ==============================================
echo   CodeIgniter 4 Docker — Windows Setup
echo ==============================================
echo.

REM ── Locate project root (two levels up from this script) ───────────────────
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%\..\.."
set "PROJECT_ROOT=%CD%"
popd

REM ── 1. Check for Docker ────────────────────────────────────────────────────
echo [INFO]  Checking for Docker...
where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed or not in your PATH.
    echo.
    echo         Please install Docker Desktop for Windows:
    echo         https://docs.docker.com/desktop/install/windows-install/
    echo.
    echo         After installing, make sure to:
    echo           1. Enable WSL 2 backend (recommended)
    echo           2. Start Docker Desktop
    echo           3. Re-run this script
    echo.
    pause
    exit /b 1
)
echo [OK]    Docker is installed.

REM ── 2. Check Docker daemon is running ──────────────────────────────────────
echo [INFO]  Checking Docker daemon...
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARN]  Docker daemon is not running. Attempting to start Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo [INFO]  Waiting for Docker Desktop to start...
    set TRIES=0
    :wait_loop
    timeout /t 3 /nobreak >nul
    docker info >nul 2>&1
    if %ERRORLEVEL% equ 0 goto docker_ready
    set /a TRIES+=1
    if !TRIES! geq 40 (
        echo [ERROR] Docker daemon did not start after 2 minutes.
        echo         Please open Docker Desktop manually and re-run this script.
        pause
        exit /b 1
    )
    goto wait_loop
)
:docker_ready
echo [OK]    Docker daemon is running.

REM ── 3. Check Docker Compose ────────────────────────────────────────────────
echo [INFO]  Checking for Docker Compose...
docker compose version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Compose plugin not found.
    echo         Please update Docker Desktop to the latest version.
    pause
    exit /b 1
)
echo [OK]    Docker Compose is available.

REM ── 4. Set up environment file ─────────────────────────────────────────────
echo [INFO]  Setting up environment file...
cd /d "%PROJECT_ROOT%"
if not exist .env (
    if exist .env.example (
        copy .env.example .env >nul
        echo [OK]    Created .env from .env.example.
    ) else (
        echo [WARN]  No .env or .env.example found — Docker Compose will use defaults.
    )
) else (
    echo [OK]    .env already exists.
)

REM ── 5. Build and start containers ──────────────────────────────────────────
echo [INFO]  Building and starting Docker containers (this may take a few minutes)...
docker compose up -d --build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Compose build failed. See errors above.
    pause
    exit /b 1
)

echo.
echo [OK]    All containers are running!
echo.

REM ── 6. Show status ────────────────────────────────────────────────────────
docker compose ps

echo.
echo ==============================================
echo   Setup complete!
echo.
echo   Web:   http://localhost:8080
echo   MySQL: localhost:3306
echo   Redis: localhost:6379
echo.
echo   Next step: install CodeIgniter 4
echo     docker compose exec php bash
echo     composer create-project codeigniter4/appstarter .
echo ==============================================
echo.
pause
