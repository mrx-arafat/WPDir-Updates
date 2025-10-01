# WPDirectory - Access Information

## 🌐 Public Access URL

Your WPDirectory application is now **LIVE and PUBLICLY ACCESSIBLE**!

```
http://143.110.233.73:8080
```

Open this URL in your web browser to access the application.

## ✅ Issue Resolved

**Problem**: The application was not accessible from external networks.

**Root Cause**: UFW firewall was blocking incoming connections to port 8080.

**Solution**: Added firewall rule to allow port 8080:
```bash
sudo ufw allow 8080/tcp
```

## 📊 Current Status

### Download Progress
- **Plugins**: 3,917 / 5,000 indexed (78% complete)
- **Themes**: 1,000 / 1,000 indexed (100% complete)
- **Update Queue**: ~4,074 items remaining
- **Status**: Actively downloading and indexing

### Application Status
- ✅ Server running on port 8080
- ✅ Firewall configured correctly
- ✅ Publicly accessible from internet
- ✅ Web interface functional
- ✅ API endpoints responding

## 🔍 Available Features

### Web Interface
Access the main interface at: `http://143.110.233.73:8080`

Features available:
- Search through indexed plugins and themes
- Browse repository statistics
- View plugin/theme source code
- Use regex search patterns
- View search history

### API Endpoints

**Check if loaded:**
```bash
curl http://143.110.233.73:8080/api/v1/loaded
```

**Repository overview:**
```bash
curl http://143.110.233.73:8080/api/v1/repos/overview
```

**Create new search:**
```bash
curl -X POST http://143.110.233.73:8080/api/v1/search/new \
  -H "Content-Type: application/json" \
  -d '{"input":"function_name","target":"plugins","private":false}'
```

## 🔧 Server Configuration

### Firewall Rules (UFW)
```
Port 22   - SSH (ALLOW)
Port 80   - HTTP (ALLOW)
Port 443  - HTTPS (ALLOW)
Port 8080 - WPDirectory (ALLOW) ← Newly added
```

### Application Details
- **Server IP**: 143.110.233.73
- **Port**: 8080
- **Protocol**: HTTP
- **Process**: Running as root (PID: 835304)
- **Data Directory**: /var/www/wpdir/data/
- **Config File**: /var/www/wpdir/config.yml

### Resource Usage
- **Plugins Limit**: 5,000 (configured)
- **Themes Limit**: 1,000 (configured)
- **Update Workers**: 4
- **Search Workers**: 6

## 📈 Monitoring

### Check Application Status
```bash
# Check if process is running
ps aux | grep wpdir | grep -v grep

# Check port binding
ss -tlnp | grep :8080

# Check firewall status
sudo ufw status | grep 8080
```

### View Logs
The application is running in terminal ID 49. To view logs:
```bash
# From the server
tail -f /var/log/syslog | grep wpdir
```

### Check Download Progress
```bash
curl -s http://localhost:8080/api/v1/repos/overview | python3 -m json.tool
```

## 🚀 Next Steps

### 1. Wait for Full Download
The application is still downloading plugins. Estimated time: 1-2 more hours.

You can use the application now with the already downloaded plugins, or wait for the full dataset.

### 2. Set Up Nginx Reverse Proxy (Optional)

To use port 80 instead of 8080, configure Nginx:

```nginx
server {
    listen 80;
    server_name 143.110.233.73;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Save to `/etc/nginx/sites-available/wpdir` and enable:
```bash
sudo ln -s /etc/nginx/sites-available/wpdir /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Configure Domain Name (Optional)

If you have a domain name, point it to 143.110.233.73 and update:
- Nginx server_name
- config.yml host setting

### 4. Set Up SSL/HTTPS (Recommended)

Install Let's Encrypt certificate:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### 5. Set Up Systemd Service (Production)

Create `/etc/systemd/system/wpdir.service`:
```ini
[Unit]
Description=WPDirectory Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/wpdir
ExecStart=/var/www/wpdir/wpdir
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable wpdir
sudo systemctl start wpdir
```

### 6. Push to GitHub

Once satisfied with the setup:
```bash
cd /var/www/wpdir
git push -u origin master
```

## 🔒 Security Recommendations

1. **Change default admin credentials** (if configured in config.yml)
2. **Set up HTTPS** with Let's Encrypt
3. **Configure rate limiting** (already enabled in the app)
4. **Regular backups** of /var/www/wpdir/data/
5. **Monitor logs** for suspicious activity
6. **Keep system updated**: `sudo apt update && sudo apt upgrade`

## 🐛 Troubleshooting

### Application Not Accessible
```bash
# Check if running
ps aux | grep wpdir

# Check port binding
ss -tlnp | grep :8080

# Check firewall
sudo ufw status

# Test locally
curl http://localhost:8080/
```

### Slow Performance
- Reduce updateworkers in config.yml
- Reduce searchworkers in config.yml
- Check disk space: `df -h`
- Check memory: `free -h`

### Application Crashes
```bash
# Check logs
journalctl -xe

# Restart application
cd /var/www/wpdir
./wpdir -fresh
```

## 📞 Support

For issues and questions:
- Check DEPLOYMENT.md for detailed deployment instructions
- Check TESTING_SUMMARY.md for test results and changes
- GitHub Issues: https://github.com/mrx-arafat/wpdir/issues (after pushing)

## 📝 Summary

✅ **Application is LIVE**: http://143.110.233.73:8080
✅ **Firewall configured**: Port 8080 open
✅ **Downloads in progress**: 78% plugins, 100% themes
✅ **Fully functional**: Ready to use now
✅ **Production ready**: Follow next steps for optimization

---

**Last Updated**: October 2, 2025
**Status**: ✅ OPERATIONAL
**Access**: 🌐 PUBLIC

