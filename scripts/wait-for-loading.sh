#!/bin/bash
#
# Wait for WPDirectory to finish loading
# Monitors loading status and notifies when ready
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║          ⏳ Waiting for WPDirectory to Load ⏳                 ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

START_TIME=$(date +%s)

# Function to format seconds to human readable
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))
    echo "${minutes}m ${secs}s"
}

# Check initial status
LOADED=$(curl -s http://localhost:8080/api/v1/loaded | python3 -c "import sys, json; print(json.load(sys.stdin)['loaded'])" 2>/dev/null)

if [ "$LOADED" = "True" ]; then
    echo "✅ Application is already loaded and ready!"
    echo ""
    echo "You can now:"
    echo "  - Test search functionality"
    echo "  - Visit: http://143.110.233.73:8080"
    echo ""
    exit 0
fi

echo "Current Status: Loading..."
echo ""
echo "This will check every 10 seconds and notify you when ready."
echo "Press Ctrl+C to stop monitoring."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Monitor loading status
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    # Get loading status
    LOADED=$(curl -s http://localhost:8080/api/v1/loaded | python3 -c "import sys, json; print(json.load(sys.stdin)['loaded'])" 2>/dev/null)
    
    # Get current stats
    STATS=$(curl -s http://localhost:8080/api/v1/repos/overview 2>/dev/null | python3 -c "import sys, json; data = json.load(sys.stdin); print(f'{data[\"plugins\"][\"total\"]} plugins, {data[\"themes\"][\"total\"]} themes')" 2>/dev/null)
    
    # Get memory usage
    MEMORY=$(ps aux | grep '[w]pdir' | awk '{print $6/1024}' | head -1)
    
    # Display status
    echo "[$(date '+%H:%M:%S')] Elapsed: $(format_time $ELAPSED) | $STATS | Memory: ${MEMORY} MB"
    
    # Check if loaded
    if [ "$LOADED" = "True" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "🎉 APPLICATION IS NOW LOADED AND READY! 🎉"
        echo ""
        echo "Total loading time: $(format_time $ELAPSED)"
        echo ""
        echo "✅ You can now:"
        echo "   - Test search functionality"
        echo "   - Visit: http://143.110.233.73:8080"
        echo "   - Create searches without 406 errors"
        echo ""
        echo "📱 Mobile Testing:"
        echo "   1. Clear browser cache"
        echo "   2. Visit: http://143.110.233.73:8080"
        echo "   3. Try searching for: function"
        echo "   4. Should work without white screen!"
        echo ""
        exit 0
    fi
    
    # Wait 10 seconds
    sleep 10
done

