#!/usr/bin/env bash
set -euo pipefail

# Backup home server configurations and data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/homeserver-backup-$TIMESTAMP.tar.gz"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

log_info "Creating backup at $BACKUP_FILE..."

# Create backup archive
cd "$PROJECT_ROOT"
tar -czf "$BACKUP_FILE" \
    --exclude='backups' \
    --exclude='.venv' \
    --exclude='__pycache__' \
    --exclude='.pytest_cache' \
    --exclude='htmlcov' \
    --exclude='.git' \
    configs/ \
    data/ \
    quadlets/

# Verify backup
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_info "Backup created successfully: $BACKUP_FILE ($SIZE)"
    
    # Keep only last 10 backups
    log_info "Cleaning old backups (keeping last 10)..."
    cd "$BACKUP_DIR"
    ls -t homeserver-backup-*.tar.gz | tail -n +11 | xargs -r rm --
    
    log_info "Backup complete!"
else
    log_warn "Backup file not created!"
    exit 1
fi


