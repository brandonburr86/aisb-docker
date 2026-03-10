# =============================================================================
# CodeIgniter 4 Docker Environment — Windows PowerShell Setup Script
# =============================================================================
# Alternative to setup.bat for users who prefer PowerShell.
# Run from the codeigniter-docker project root:
#   powershell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

function Write-Info  ($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok    ($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn  ($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err   ($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\..\.."

Write-Host ""
Write-Host "=============================================="
Write-Host "  CodeIgniter 4 Docker — Windows Setup"
Write-Host "=============================================="
Write-Host ""

# ── 1. Check Docker ─────────────────────────────────────────────────────────
Write-Info "Checking for Docker..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Err "Docker is not installed or not in your PATH."
    Write-Host ""
    Write-Host "  Please install Docker Desktop for Windows:"
    Write-Host "  https://docs.docker.com/desktop/install/windows-install/"
    Write-Host ""
    Write-Host "  After installing, enable WSL 2 backend, start Docker Desktop, and re-run."
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Ok "Docker is installed."

# ── 2. Check Docker daemon ──────────────────────────────────────────────────
Write-Info "Checking Docker daemon..."
$null = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Docker daemon not running. Attempting to start Docker Desktop..."
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    $tries = 0
    do {
        Start-Sleep -Seconds 3
        $null = docker info 2>&1
        $tries++
        if ($tries -ge 40) {
            Write-Err "Docker daemon did not start after 2 minutes."
            Write-Err "Please open Docker Desktop manually and re-run."
            Read-Host "Press Enter to exit"
            exit 1
        }
    } while ($LASTEXITCODE -ne 0)
}
Write-Ok "Docker daemon is running."

# ── 3. Check Docker Compose ─────────────────────────────────────────────────
Write-Info "Checking Docker Compose..."
$null = docker compose version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Docker Compose plugin not found. Please update Docker Desktop."
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Ok "Docker Compose is available."

# ── 4. Environment file ─────────────────────────────────────────────────────
Write-Info "Setting up environment file..."
Set-Location $ProjectRoot
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Ok "Created .env from .env.example."
    } else {
        Write-Warn "No .env or .env.example found — Docker Compose will use defaults."
    }
} else {
    Write-Ok ".env already exists."
}

# ── 5. Build and start ──────────────────────────────────────────────────────
Write-Info "Building and starting Docker containers (this may take a few minutes)..."
docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Err "Docker Compose build failed."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Ok "All containers are running!"
Write-Host ""

docker compose ps

Write-Host ""
Write-Host "=============================================="
Write-Host "  Setup complete!"
Write-Host ""
Write-Host "  Web:   http://localhost:8080"
Write-Host "  MySQL: localhost:3306"
Write-Host "  Redis: localhost:6379"
Write-Host ""
Write-Host "  Next step: install CodeIgniter 4"
Write-Host "    docker compose exec php bash"
Write-Host "    composer create-project codeigniter4/appstarter ."
Write-Host "=============================================="
Write-Host ""
Read-Host "Press Enter to close"
