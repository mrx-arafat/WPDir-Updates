#!/bin/bash
#
# Setup Cron Job for WPDirectory Auto-Update
# Alternative to systemd timer for simpler setups
#
# Usage: sudo ./scripts/setup-cron.sh
#

set -e

WPDIR_PATH="/var/www/wpdir"
SCRIPT_PATH="$WPDIR_PATH/scripts/auto-update.sh"
CRON_SCHEDULE="0 2 */3 * *"  # Every 3 days at 2:00 AM

echo "========================================="
echo "WPDirectory Auto-Update Cron Setup"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Please run as root (use sudo)"
    exit 1
fi

# Check if auto-update script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "ERROR: Auto-update script not found at: $SCRIPT_PATH"
    exit 1
fi

# Make script executable
chmod +x "$SCRIPT_PATH"
echo "✓ Made auto-update script executable"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "auto-update.sh"; then
    echo ""
    echo "WARNING: A cron job for auto-update.sh already exists:"
    echo ""
    crontab -l | grep "auto-update.sh"
    echo ""
    read -p "Do you want to replace it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    # Remove existing cron job
    crontab -l | grep -v "auto-update.sh" | crontab -
    echo "✓ Removed existing cron job"
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH >> $WPDIR_PATH/auto-update.log 2>&1") | crontab -

echo "✓ Added cron job successfully"
echo ""
echo "========================================="
echo "Cron Job Details"
echo "========================================="
echo "Schedule: Every 3 days at 2:00 AM"
echo "Script: $SCRIPT_PATH"
echo "Log: $WPDIR_PATH/auto-update.log"
echo ""
echo "Current crontab:"
crontab -l | grep "auto-update.sh"
echo ""
echo "========================================="
echo "Next Steps"
echo "========================================="
echo "1. The auto-update will run every 3 days at 2:00 AM"
echo "2. Monitor logs: tail -f $WPDIR_PATH/auto-update.log"
echo "3. Test manually: sudo $SCRIPT_PATH"
echo ""
echo "To remove the cron job:"
echo "  crontab -e"
echo "  (then delete the line with auto-update.sh)"
echo ""
echo "Setup complete! ✓"

