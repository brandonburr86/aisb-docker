#!/usr/bin/env bash
# =============================================================================
# CodeIgniter 4 Docker Environment — macOS Teardown Script
# =============================================================================
# Stops containers and optionally removes volumes (database data).
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "=============================================="
echo "  CodeIgniter 4 Docker — macOS Teardown"
echo "=============================================="
echo ""

if [[ "${1:-}" == "--volumes" ]]; then
    warn "Stopping containers AND removing volumes (all database data will be lost)..."
    docker compose down -v
else
    info "Stopping containers (database data preserved in Docker volume)..."
    docker compose down
fi

echo ""
success "Done. To start again, run:  scripts/mac/setup.sh"
echo ""
