#!/bin/bash
#
# WPDirectory Auto-Update Script
# This script triggers a full re-download of plugins and themes every 3 days
# to keep the data up-to-date with WordPress.org
#
# Usage: ./auto-update.sh
#

set -e

# Configuration
WPDIR_PATH="/var/www/wpdir"
LOG_FILE="/var/www/wpdir/auto-update.log"
PID_FILE="/var/www/wpdir/wpdir.pid"
BINARY="./wpdir"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

# Change to wpdir directory
cd "$WPDIR_PATH" || {
    log_error "Failed to change to directory: $WPDIR_PATH"
    exit 1
}

log "========================================="
log "Starting WPDirectory Auto-Update Process"
log "========================================="

# Check if wpdir binary exists
if [ ! -f "$BINARY" ]; then
    log_error "WPDirectory binary not found at: $WPDIR_PATH/$BINARY"
    exit 1
fi

# Get current stats before update
log "Fetching current statistics..."
CURRENT_STATS=$(curl -s http://localhost:8080/api/v1/repos/overview 2>/dev/null || echo "")

if [ -n "$CURRENT_STATS" ]; then
    CURRENT_PLUGINS=$(echo "$CURRENT_STATS" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['plugins']['total'])" 2>/dev/null || echo "unknown")
    CURRENT_THEMES=$(echo "$CURRENT_STATS" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['themes']['total'])" 2>/dev/null || echo "unknown")
    log "Current status: $CURRENT_PLUGINS plugins, $CURRENT_THEMES themes"
else
    log_warning "Could not fetch current statistics (application may not be running)"
fi

# Find and stop the running wpdir process
log "Stopping WPDirectory application..."

# Try to find the process
WPDIR_PID=$(ps aux | grep '[w]pdir' | grep -v grep | awk '{print $2}' | head -1)

if [ -n "$WPDIR_PID" ]; then
    log "Found WPDirectory process with PID: $WPDIR_PID"
    kill "$WPDIR_PID"
    
    # Wait for process to stop (max 30 seconds)
    for i in {1..30}; do
        if ! ps -p "$WPDIR_PID" > /dev/null 2>&1; then
            log_success "WPDirectory stopped successfully"
            break
        fi
        sleep 1
    done
    
    # Force kill if still running
    if ps -p "$WPDIR_PID" > /dev/null 2>&1; then
        log_warning "Process did not stop gracefully, forcing kill..."
        kill -9 "$WPDIR_PID"
        sleep 2
    fi
else
    log_warning "No running WPDirectory process found"
fi

# Backup current data (optional but recommended)
log "Creating backup of current data..."
BACKUP_DIR="/var/www/wpdir/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/wpdir-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

if tar -czf "$BACKUP_FILE" data/ 2>/dev/null; then
    log_success "Backup created: $BACKUP_FILE"
    
    # Keep only last 5 backups
    ls -t "$BACKUP_DIR"/wpdir-backup-*.tar.gz | tail -n +6 | xargs -r rm
    log "Cleaned up old backups (keeping last 5)"
else
    log_warning "Backup creation failed, continuing anyway..."
fi

# Start WPDirectory with fresh flag to trigger re-download
log "Starting WPDirectory with fresh data download..."
log "This will re-download all plugins and themes from WordPress.org"

nohup "$BINARY" > wpdir.log 2>&1 &
NEW_PID=$!

log "WPDirectory started with PID: $NEW_PID"

# Wait a few seconds for the application to start
sleep 5

# Verify the application is running
if ps -p "$NEW_PID" > /dev/null 2>&1; then
    log_success "WPDirectory is running successfully"
else
    log_error "WPDirectory failed to start. Check wpdir.log for details"
    exit 1
fi

# Wait for API to be available
log "Waiting for API to become available..."
for i in {1..30}; do
    if curl -s http://localhost:8080/api/v1/loaded > /dev/null 2>&1; then
        log_success "API is responding"
        break
    fi
    sleep 2
done

# Get initial stats
sleep 5
NEW_STATS=$(curl -s http://localhost:8080/api/v1/repos/overview 2>/dev/null || echo "")

if [ -n "$NEW_STATS" ]; then
    NEW_PLUGINS=$(echo "$NEW_STATS" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['plugins']['total'])" 2>/dev/null || echo "unknown")
    NEW_THEMES=$(echo "$NEW_STATS" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['themes']['total'])" 2>/dev/null || echo "unknown")
    log "Update started: $NEW_PLUGINS plugins, $NEW_THEMES themes (will increase as downloads progress)"
fi

log "========================================="
log "Auto-Update Process Completed"
log "========================================="
log "The application is now downloading updated data in the background."
log "Monitor progress with: tail -f $WPDIR_PATH/wpdir.log"
log "Check status at: http://localhost:8080/api/v1/repos/overview"

exit 0

