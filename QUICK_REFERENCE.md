# WPDirectory - Quick Reference Guide

**Application URL:** http://143.110.233.73:8080  
**Status:** ✅ Fully Operational  
**Last Updated:** October 2, 2025

---

## 🚀 Quick Start

### Access the Application
Open your browser and go to: **http://143.110.233.73:8080**

### Perform a Search
1. Enter a regex pattern (e.g., `wp_enqueue_script`, `function.*get_posts`, `class.*Widget`)
2. Select **Plugins** or **Themes**
3. Choose if search should be **Private** (not listed publicly)
4. Click **Search**
5. Wait for results (usually 1-10 seconds)
6. Browse matches and view source code

---

## 📝 Common Search Examples

### Basic Text Search
```
wp_enqueue_script
```
Finds all occurrences of "wp_enqueue_script"

### Function Search
```
function wp_head
```
Finds function definitions containing "wp_head"

### Class Search
```
class.*Widget
```
Finds class definitions containing "Widget"

### Hook Search
```
add_action.*init
```
Finds add_action calls with "init" hook

### SQL Query Search
```
SELECT.*FROM.*wp_posts
```
Finds SQL queries selecting from wp_posts

### Security Pattern Search
```
\$_GET\[
```
Finds direct usage of $_GET (potential security issue)

---

## 🔧 Application Management

### Check Status
```bash
# Check if running
ps aux | grep wpdir | grep -v grep

# Check port
ss -tlnp | grep :8080

# Check API
curl http://localhost:8080/api/v1/loaded
```

### View Logs
```bash
tail -f /var/www/wpdir/wpdir.log
```

### Restart Application
```bash
cd /var/www/wpdir
kill $(ps aux | grep wpdir | grep -v grep | awk '{print $2}')
nohup ./wpdir > wpdir.log 2>&1 &
```

### Check Indexing Progress
```bash
curl -s http://localhost:8080/api/v1/repos/overview | grep -o '"total":[0-9]*'
```

---

## 🌐 API Endpoints

### Check if Loaded
```bash
curl http://143.110.233.73:8080/api/v1/loaded
```

### Create Search
```bash
curl -X POST http://143.110.233.73:8080/api/v1/search/new \
  -H "Content-Type: application/json" \
  -d '{"input":"wp_enqueue","target":"plugins","private":false}'
```

### Get Search Status
```bash
curl http://143.110.233.73:8080/api/v1/search/{SEARCH_ID}
```

### Get Repository Overview
```bash
curl http://143.110.233.73:8080/api/v1/repos/overview
```

### Get Recent Searches
```bash
curl http://143.110.233.73:8080/api/v1/searches/100
```

---

## 📊 Configuration

### Current Settings
- **Plugins Indexed:** 5,000 most recent
- **Themes Indexed:** 1,000 most recent
- **Update Workers:** 4
- **Search Workers:** 6
- **HTTP Port:** 8080
- **HTTPS Port:** 8443 (not configured)

### Configuration File
Location: `/var/www/wpdir/config.yml`

```yaml
host: ""
updateworkers: 4
searchworkers: 6
pluginlimit: 5000
themelimit: 1000
ports:
  http: 8080
  https: 8443
```

**After changing config:** Restart the application

---

## 🐛 Troubleshooting

### Application Not Responding
```bash
# Check if running
ps aux | grep wpdir | grep -v grep

# If not running, start it
cd /var/www/wpdir
nohup ./wpdir > wpdir.log 2>&1 &
```

### Search Not Working
```bash
# Check if loaded
curl http://localhost:8080/api/v1/loaded

# Should return: {"loaded":true}
# If false, wait for indexing to complete
```

### Port Already in Use
```bash
# Find what's using port 8080
sudo lsof -i :8080

# Kill the process if needed
kill <PID>
```

### High Memory Usage
```bash
# Check memory
free -h

# Reduce workers in config.yml
# updateworkers: 2
# searchworkers: 4
```

### Slow Searches
- Wait for initial indexing to complete
- Check system resources (CPU, memory, disk I/O)
- Reduce concurrent searches
- Simplify regex patterns

---

## 📁 Important Files

### Application Files
- `/var/www/wpdir/wpdir` - Application binary
- `/var/www/wpdir/config.yml` - Configuration
- `/var/www/wpdir/wpdir.log` - Application logs
- `/var/www/wpdir/data/` - Database and indexes

### Documentation
- `DEPLOYMENT_STATUS.md` - Full deployment info
- `SEARCH_FIX_SUMMARY.md` - Search functionality fix details
- `DEPLOYMENT.md` - Deployment guide
- `QUICK_START.md` - Quick start guide
- `QUICK_REFERENCE.md` - This file

---

## 🔐 Security Notes

### Firewall
Port 8080 is open to the internet. Consider:
- Using Nginx reverse proxy on port 80/443
- Implementing rate limiting
- Adding authentication for sensitive searches
- Using HTTPS with SSL certificate

### Private Searches
Use the "Private" option for sensitive searches to prevent them from appearing in public search lists.

---

## 🚀 Performance Tips

### For Better Search Performance
1. Use specific patterns instead of broad wildcards
2. Limit context lines if not needed
3. Search plugins OR themes, not both
4. Use private searches for one-time queries

### For Better System Performance
1. Reduce `updateworkers` if CPU is high
2. Reduce `searchworkers` if memory is high
3. Reduce `pluginlimit` and `themelimit` if disk space is limited
4. Use SSD storage for better I/O

---

## 📞 Support

### Check Documentation
1. `DEPLOYMENT_STATUS.md` - Current status and configuration
2. `SEARCH_FIX_SUMMARY.md` - Search functionality details
3. `DEPLOYMENT.md` - Full deployment guide
4. Application logs: `tail -f /var/www/wpdir/wpdir.log`

### Common Issues
- **Search fails:** Check `SEARCH_FIX_SUMMARY.md`
- **App won't start:** Check logs and port availability
- **Slow performance:** Check system resources
- **Out of disk space:** Reduce plugin/theme limits

---

## 🎯 Quick Commands Cheat Sheet

```bash
# Status
ps aux | grep wpdir | grep -v grep
ss -tlnp | grep :8080
curl http://localhost:8080/api/v1/loaded

# Logs
tail -f /var/www/wpdir/wpdir.log
tail -100 /var/www/wpdir/wpdir.log

# Restart
cd /var/www/wpdir
kill $(ps aux | grep wpdir | grep -v grep | awk '{print $2}')
nohup ./wpdir > wpdir.log 2>&1 &

# Test Search
curl -X POST http://localhost:8080/api/v1/search/new \
  -H "Content-Type: application/json" \
  -d '{"input":"test","target":"plugins","private":false}'

# Check Disk Usage
du -sh /var/www/wpdir/data

# Check Memory
free -h

# Check CPU
top -p $(pgrep wpdir)
```

---

## ✅ Verification Checklist

- [ ] Application is running
- [ ] Port 8080 is listening
- [ ] API returns `{"loaded":true}`
- [ ] Web interface loads at http://143.110.233.73:8080
- [ ] Can create searches
- [ ] Searches complete successfully
- [ ] Can view results
- [ ] Can view source files

---

**Application Status:** ✅ Fully Operational  
**Search Functionality:** ✅ Working  
**Ready for Use:** ✅ Yes

**Access Now:** http://143.110.233.73:8080

