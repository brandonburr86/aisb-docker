#!/usr/bin/env bash
# =============================================================================
# CodeIgniter 4 Docker Environment — macOS Setup Script
# =============================================================================
# This script installs all prerequisites and builds the Docker environment
# on macOS. Run from the codeigniter-docker project root.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No colour

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Locate project root (two levels up from this script) ─────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ""
echo "=============================================="
echo "  CodeIgniter 4 Docker — macOS Setup"
echo "=============================================="
echo ""

# ── 1. Check / Install Homebrew ──────────────────────────────────────────────
info "Checking for Homebrew..."
if command -v brew &>/dev/null; then
    success "Homebrew is installed."
else
    warn "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed."
fi

# ── 2. Check / Install Docker Desktop ───────────────────────────────────────
info "Checking for Docker..."
if command -v docker &>/dev/null; then
    success "Docker is installed ($(docker --version))."
else
    warn "Docker not found. Installing Docker Desktop via Homebrew..."
    brew install --cask docker
    info "Opening Docker Desktop — please wait for it to finish starting..."
    open -a Docker
    # Wait for the daemon to be ready
    TRIES=0
    while ! docker info &>/dev/null; do
        sleep 3
        TRIES=$((TRIES + 1))
        if [[ $TRIES -ge 40 ]]; then
            error "Docker daemon did not start after 2 minutes."
            error "Please open Docker Desktop manually, wait until it is running, then re-run this script."
            exit 1
        fi
    done
    success "Docker Desktop is running."
fi

# ── 3. Check Docker Compose ─────────────────────────────────────────────────
info "Checking for Docker Compose..."
if docker compose version &>/dev/null; then
    success "Docker Compose is available ($(docker compose version --short))."
else
    error "Docker Compose plugin not found."
    error "Please update Docker Desktop to the latest version (Compose V2 is included)."
    exit 1
fi

# ── 4. Set up environment file ───────────────────────────────────────────────
info "Setting up environment file..."
cd "$PROJECT_ROOT"
if [[ ! -f .env ]]; then
    if [[ -f .env.example ]]; then
        cp .env.example .env
        success "Created .env from .env.example."
    else
        warn "No .env or .env.example found — Docker Compose will use defaults."
    fi
else
    success ".env already exists."
fi

# ── 5. Build and start containers ───────────────────────────────────────────
info "Building and starting Docker containers (this may take a few minutes)..."
docker compose up -d --build

echo ""
success "All containers are running!"
echo ""

# ── 6. Show status ──────────────────────────────────────────────────────────
docker compose ps

echo ""
echo "=============================================="
echo "  Setup complete!"
echo ""
echo "  Web:   http://localhost:8080"
echo "  MySQL: localhost:3306"
echo "  Redis: localhost:6379"
echo ""
echo "  Next step: install CodeIgniter 4"
echo "    docker compose exec php bash"
echo "    composer create-project codeigniter4/appstarter ."
echo "=============================================="
echo ""
