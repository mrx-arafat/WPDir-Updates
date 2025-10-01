# WPDirectory Storage & Plugin Limit Status

**Date:** October 2, 2025 01:23 UTC+6  
**Status:** ✅ Configuration Updated

---

## Configuration Update

### Plugin Limit Changed
- **Previous Limit:** 5,000 plugins
- **New Limit:** 6,000 plugins
- **Reason:** User confirmed 6,000 is acceptable

### Updated config.yml
```yaml
# Limit to 6000 most recent plugins and 1000 themes for VPS deployment
pluginlimit: 6000
themelimit: 1000
```

---

## Current Status

### Application
- **Status:** Running and restarting with new configuration
- **Process:** Fetching metadata for 18,000 plugins (3x limit)
- **Expected Result:** Will select top 6,000 most recently updated plugins

### Storage Usage
- **Current Data Size:** 1.8 GB
- **Expected Final Size:** ~2.5-3 GB (for 6,000 plugins + 1,000 themes)

### What's Happening Now
1. ✅ Application restarted with new 6,000 plugin limit
2. ⏳ Fetching metadata for 18,000 plugins to sort by last_updated
3. ⏳ Will select top 6,000 most recently updated
4. ⏳ Will download and index those 6,000 plugins
5. ⏳ Old plugin data from previous runs will be overwritten

---

## Expected Results

### Plugins
- **Target:** 6,000 most recently updated plugins
- **Expected Date Range:** 2025-10-01 to ~2019-2020
- **Sampling:** 18,000 plugins (3x limit)
- **Processing Time:** ~3-4 minutes for sorting

### Themes
- **Target:** 1,000 most recently updated themes
- **Expected Date Range:** 2025-10-01 to ~2019
- **Sampling:** 3,000 themes (3x limit)
- **Processing Time:** ~15 seconds for sorting

---

## Storage Management

### Automatic Cleanup
The application automatically manages storage by:
1. **Overwriting old indexes** when plugins are updated
2. **Removing stale data** for plugins no longer in the list
3. **Reusing storage** for updated plugins

### Manual Cleanup (if needed)
If you want to clean up old data manually:

```bash
# Stop the application
kill $(ps aux | grep wpdir | grep -v grep | awk '{print $2}')

# Remove old plugin indexes
rm -rf data/index/plugins/*

# Remove old theme indexes
rm -rf data/index/themes/*

# Remove database (will rebuild on restart)
rm -f data/wpdir.db

# Restart application
cd /var/www/wpdir
nohup ./wpdir -fresh > wpdir.log 2>&1 &
```

**Note:** Only do this if you want to start completely fresh!

---

## Storage Estimates

### Current Configuration (6,000 plugins + 1,000 themes)

**Plugins:**
- Average plugin size: ~300-500 KB (indexed)
- 6,000 plugins × 400 KB = ~2.4 GB

**Themes:**
- Average theme size: ~200-400 KB (indexed)
- 1,000 themes × 300 KB = ~300 MB

**Database:**
- Metadata storage: ~50-100 MB

**Total Estimated:** ~2.5-3 GB

### If You Want to Reduce Storage

**Option 1: Reduce plugin limit**
```yaml
pluginlimit: 3000  # Half the plugins = ~1.2 GB
themelimit: 500    # Half the themes = ~150 MB
```

**Option 2: Reduce both**
```yaml
pluginlimit: 2000  # Minimal set = ~800 MB
themelimit: 500    # Minimal set = ~150 MB
```

---

## Monitoring

### Check Current Status
```bash
# Application status
ps aux | grep wpdir | grep -v grep

# Storage usage
du -sh /var/www/wpdir/data

# Plugin count
curl -s http://localhost:8080/api/v1/repos/overview | grep total

# View logs
tail -f /var/www/wpdir/wpdir.log
```

### Check Progress
```bash
# Watch the sorting progress
tail -f /var/www/wpdir/wpdir.log | grep Progress

# Check when sorting completes
tail -f /var/www/wpdir/wpdir.log | grep "Selected plugins"
```

---

## Timeline

### Sorting Phase (Current)
- **Duration:** ~3-4 minutes
- **Activity:** Fetching metadata for 18,000 plugins
- **Progress:** Updates every 1,000 plugins
- **Result:** Top 6,000 most recently updated selected

### Indexing Phase (Next)
- **Duration:** Several hours
- **Activity:** Downloading and indexing 6,000 plugins
- **Progress:** 4 concurrent workers
- **Result:** All 6,000 plugins fully searchable

### Completion
- **Total Time:** 4-8 hours (depending on network speed)
- **Final Storage:** ~2.5-3 GB
- **Status:** Fully operational with 6,000 searchable plugins

---

## Summary

✅ **Configuration Updated:** Plugin limit set to 6,000  
⏳ **Application Restarting:** Fetching metadata for sorting  
⏳ **Expected Completion:** 4-8 hours for full indexing  
✅ **Storage:** ~2.5-3 GB (acceptable for VPS)  
✅ **Quality:** Only most recently updated plugins (2025-10-01 to ~2019)  

---

**Current Status:** Application is running and sorting plugins  
**Next Step:** Wait for sorting to complete (~3-4 minutes)  
**Access:** http://143.110.233.73:8080

