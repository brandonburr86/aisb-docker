#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Entrypoint for the PHP-FPM container.
# Runs at every container start to fix common cross-platform issues.
# ─────────────────────────────────────────────────────────────────────────────

set -e

PROJECT_DIR="/var/www/html"
WRITABLE_DIR="$PROJECT_DIR/writable"
VENDOR_DIR="$PROJECT_DIR/vendor"

# ── 1. Fix CRLF in .env (#3) ────────────────────────────────────────────────
# Windows Git may convert LF→CRLF despite .gitattributes (e.g. if a student
# clones before .gitattributes exists). Strip \r from both .env files so
# Docker Compose and CodeIgniter parse passwords/settings correctly.
for envfile in "$PROJECT_DIR/.env" "$PROJECT_DIR/../.env"; do
    if [ -f "$envfile" ]; then
        if grep -qP '\r' "$envfile" 2>/dev/null; then
            sed -i 's/\r$//' "$envfile"
            echo "[entrypoint] Stripped CRLF from $envfile"
        fi
    fi
done

# ── 2. Fix writable/ permissions (#14, #15) ─────────────────────────────────
# CodeIgniter needs www-data to write to cache, logs, session, uploads, and
# debugbar. Create subdirs if missing, then fix ownership recursively.
if [ -d "$WRITABLE_DIR" ]; then
    # Ensure all expected subdirectories exist
    mkdir -p "$WRITABLE_DIR/cache" \
             "$WRITABLE_DIR/logs" \
             "$WRITABLE_DIR/session" \
             "$WRITABLE_DIR/uploads" \
             "$WRITABLE_DIR/debugbar"

    chown -R www-data:www-data "$WRITABLE_DIR"
    chmod -R 775 "$WRITABLE_DIR"
    echo "[entrypoint] Fixed permissions on $WRITABLE_DIR"
fi

# ── 3. Fix vendor/ permissions (#5) ─────────────────────────────────────────
# When Composer runs as root inside the container, vendor/ ends up owned by
# root. On Linux hosts this means the host user can't read/edit vendor files
# and subsequent Composer commands may fail.
if [ -d "$VENDOR_DIR" ]; then
    chown -R www-data:www-data "$VENDOR_DIR"
    echo "[entrypoint] Fixed permissions on $VENDOR_DIR"
fi

# ── Hand off to CMD (php-fpm) ───────────────────────────────────────────────
exec "$@"
