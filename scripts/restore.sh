#!/usr/bin/env bash
set -euo pipefail

# Restore home server from backup

BACKUP_FILE="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ -z "$BACKUP_FILE" ]; then
    log_error "Usage: $0 <backup-file>"
    log_info "Available backups:"
    ls -lh backups/homeserver-backup-*.tar.gz 2>/dev/null || log_warn "No backups found"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    log_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Confirm restore
log_warn "This will overwrite existing configurations!"
read -p "Are you sure you want to restore from $BACKUP_FILE? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^yes$ ]]; then
    log_info "Restore cancelled."
    exit 0
fi

# Stop services
log_info "Stopping services..."
"$SCRIPT_DIR/stop.sh"

# Extract backup
log_info "Restoring from $BACKUP_FILE..."
cd "$PROJECT_ROOT"
tar -xzf "$BACKUP_FILE"

log_info "Restore complete!"
log_info "Start services with: make deploy"


