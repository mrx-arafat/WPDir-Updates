#!/bin/bash
#
# WPDirectory Status Check Script
# Quick overview of all services and stats
#

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              📊  WPDIR STATUS CHECK  📊                        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 SERVICES STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check main service
if systemctl is-active wpdir.service > /dev/null 2>&1; then
    echo "   ✅ wpdir.service is ACTIVE and RUNNING"
    UPTIME=$(systemctl show wpdir.service -p ActiveEnterTimestamp --value)
    echo "      Started: $UPTIME"
else
    echo "   ❌ wpdir.service is NOT running"
    echo "      Run: sudo systemctl start wpdir"
fi

echo ""

# Check auto-update timer
if systemctl is-active wpdir-auto-update.timer > /dev/null 2>&1; then
    echo "   ✅ wpdir-auto-update.timer is ACTIVE"
else
    echo "   ❌ wpdir-auto-update.timer is NOT active"
    echo "      Run: sudo systemctl start wpdir-auto-update.timer"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 NEXT SCHEDULED UPDATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TIMER_INFO=$(systemctl list-timers wpdir-auto-update.timer --no-pager 2>/dev/null | grep wpdir)
if [ -n "$TIMER_INFO" ]; then
    NEXT=$(echo "$TIMER_INFO" | awk '{print $1, $2}')
    LEFT=$(echo "$TIMER_INFO" | awk '{print $3, $4}')
    echo "   📅 Next Update: $NEXT"
    echo "   ⏰ Time Left: $LEFT"
else
    echo "   ⚠️  Timer not found or not scheduled"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 APPLICATION STATISTICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check API
if curl -s http://localhost:8080/api/v1/loaded > /dev/null 2>&1; then
    echo "   ✅ API is responding"
    echo ""
    
    # Get stats
    STATS=$(curl -s http://localhost:8080/api/v1/repos/overview 2>/dev/null)
    if [ -n "$STATS" ]; then
        echo "$STATS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'   📦 Plugins: {data[\"plugins\"][\"total\"]:,}')
    print(f'   🎨 Themes: {data[\"themes\"][\"total\"]:,}')
    print(f'   🕐 Last Updated: {data[\"plugins\"][\"updated\"]}')
    
    # Calculate update queue
    queue = data.get('update_queue', 0)
    if queue > 0:
        print(f'   📥 Update Queue: {queue:,} items')
except:
    print('   ⚠️  Could not parse stats')
"
    else
        echo "   ⚠️  Could not fetch stats"
    fi
else
    echo "   ❌ API is not responding"
    echo "      Service may still be starting..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 RESOURCE USAGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get resource usage
if systemctl is-active wpdir.service > /dev/null 2>&1; then
    MEMORY=$(systemctl show wpdir.service -p MemoryCurrent --value 2>/dev/null)
    if [ -n "$MEMORY" ] && [ "$MEMORY" != "[not set]" ]; then
        MEMORY_MB=$((MEMORY / 1024 / 1024))
        echo "   💾 Memory: ${MEMORY_MB} MB"
    fi
    
    CPU=$(systemctl show wpdir.service -p CPUUsageNSec --value 2>/dev/null)
    if [ -n "$CPU" ] && [ "$CPU" != "[not set]" ]; then
        CPU_SEC=$((CPU / 1000000000))
        echo "   ⚡ CPU Time: ${CPU_SEC}s"
    fi
    
    TASKS=$(systemctl show wpdir.service -p TasksCurrent --value 2>/dev/null)
    if [ -n "$TASKS" ] && [ "$TASKS" != "[not set]" ]; then
        echo "   🔧 Tasks: $TASKS"
    fi
fi

# Disk usage
DISK_USAGE=$(du -sh /var/www/wpdir/data 2>/dev/null | awk '{print $1}')
if [ -n "$DISK_USAGE" ]; then
    echo "   💿 Data Size: $DISK_USAGE"
fi

DISK_FREE=$(df -h /var/www/wpdir 2>/dev/null | tail -1 | awk '{print $4}')
if [ -n "$DISK_FREE" ]; then
    echo "   📊 Disk Free: $DISK_FREE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 RECENT ACTIVITY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Last 3 log entries
echo "   📝 Recent Logs (last 3 entries):"
journalctl -u wpdir -n 3 --no-pager 2>/dev/null | tail -3 | sed 's/^/      /'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔹 QUICK ACTIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "   🌐 Access Site:"
echo "      http://143.110.233.73:8080"
echo ""
echo "   📊 View Full Status:"
echo "      sudo systemctl status wpdir"
echo ""
echo "   📜 View Live Logs:"
echo "      sudo journalctl -u wpdir -f"
echo ""
echo "   🔄 Restart Service:"
echo "      sudo systemctl restart wpdir"
echo ""
echo "   ⏰ Check Timer:"
echo "      sudo systemctl list-timers wpdir-auto-update.timer"
echo ""
echo "   🚀 Trigger Update Now:"
echo "      sudo systemctl start wpdir-auto-update.service"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

