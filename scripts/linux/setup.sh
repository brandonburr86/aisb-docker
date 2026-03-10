#!/usr/bin/env bash
# =============================================================================
# CodeIgniter 4 Docker Environment — Linux Setup Script
# =============================================================================
# This script installs all prerequisites and builds the Docker environment
# on Ubuntu / Debian-based Linux. Run from the codeigniter-docker project root.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ""
echo "=============================================="
echo "  CodeIgniter 4 Docker — Linux Setup"
echo "=============================================="
echo ""

# ── 1. Check / Install Docker Engine ────────────────────────────────────────
info "Checking for Docker..."
if command -v docker &>/dev/null; then
    success "Docker is installed ($(docker --version))."
else
    warn "Docker not found. Installing Docker Engine..."

    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Install prerequisites
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker GPG key and repository
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    DISTRO=$(. /etc/os-release && echo "$ID")
    CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/${DISTRO} ${CODENAME} stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    success "Docker Engine installed."
fi

# ── 2. Ensure current user is in docker group ────────────────────────────────
info "Checking Docker permissions..."
if groups "$USER" | grep -qw docker; then
    success "User '$USER' is in the docker group."
else
    warn "Adding '$USER' to the docker group..."
    sudo usermod -aG docker "$USER"
    warn "You may need to log out and log back in (or run 'newgrp docker') for group changes to take effect."
    warn "If Docker commands fail after this script, please log out/in and re-run."
fi

# ── 3. Start Docker daemon if not running ───────────────────────────────────
info "Checking Docker daemon..."
if docker info &>/dev/null; then
    success "Docker daemon is running."
else
    info "Starting Docker daemon..."
    sudo systemctl start docker
    sudo systemctl enable docker
    success "Docker daemon started and enabled."
fi

# ── 4. Check Docker Compose ─────────────────────────────────────────────────
info "Checking for Docker Compose..."
if docker compose version &>/dev/null; then
    success "Docker Compose is available ($(docker compose version --short))."
else
    error "Docker Compose plugin not found."
    error "Try: sudo apt-get install docker-compose-plugin"
    exit 1
fi

# ── 5. Set up environment file ───────────────────────────────────────────────
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

# ── 6. Build and start containers ───────────────────────────────────────────
info "Building and starting Docker containers (this may take a few minutes)..."
docker compose up -d --build

echo ""
success "All containers are running!"
echo ""

# ── 7. Show status ──────────────────────────────────────────────────────────
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
