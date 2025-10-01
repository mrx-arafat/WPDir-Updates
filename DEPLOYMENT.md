# WPDirectory VPS Deployment Guide

This guide provides instructions for deploying WPDirectory on a VPS with optimized resource usage.

## Overview

This deployment configuration is optimized for VPS environments with limited resources. By default, it indexes only the **5,000 most recently updated WordPress plugins** and **1,000 most recently updated themes**, significantly reducing:

- Storage requirements
- Processing time
- Memory usage
- Network bandwidth

## System Requirements

### Minimum Requirements
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 50GB SSD
- **OS**: Linux (Ubuntu 20.04+ recommended)

### Recommended Requirements
- **CPU**: 4 cores
- **RAM**: 8GB
- **Storage**: 100GB SSD
- **OS**: Linux (Ubuntu 22.04+ recommended)

## Prerequisites

1. **Docker** (recommended) or Go 1.24+ and Node.js 22+
2. **Git** for cloning the repository
3. **Domain name** (optional, for production deployment)

## Quick Start with Docker

### 1. Clone the Repository

```bash
git clone https://github.com/wpdirectory/wpdir.git
cd wpdir
```

### 2. Create Configuration File

```bash
cp configs/example-config.yml config.yml
```

Edit `config.yml` to customize your deployment:

```yaml
# WPdirectory Configuration
host: http://your-domain.com/
updateworkers: 2
searchworkers: 4

# Limit the number of plugins and themes to index
# Set to 0 to index all available extensions
# Default: 5000 plugins, 1000 themes (for VPS deployment)
pluginlimit: 5000
themelimit: 1000

ports:
  http: 80
  https: 443

# Add Admin Users (optional)
users:
  - username: admin
    password: changeme123
```

### 3. Build Docker Image

```bash
docker build -t wpdir:latest .
```

### 4. Run the Container

```bash
docker run -d \
  --name wpdir \
  -p 80:80 \
  -v $(pwd)/config.yml:/etc/wpdir/config.yml \
  -v wpdir-data:/etc/wpdir/data \
  wpdir:latest
```

### 5. Monitor Logs

```bash
docker logs -f wpdir
```

## Manual Deployment (Without Docker)

### 1. Install Dependencies

```bash
# Install Go 1.24+
wget https://go.dev/dl/go1.24.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.7.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install Node.js 22+
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone repository
git clone https://github.com/wpdirectory/wpdir.git
cd wpdir
```

### 2. Build Frontend

```bash
cd web
npm install
npm run build
cd ..
```

### 3. Embed Frontend Assets

```bash
cd scripts/assets
go run -tags=dev assets_generate.go
cd ../..
```

### 4. Build Backend

```bash
go build -o wpdir .
```

### 5. Create Configuration

```bash
mkdir -p /etc/wpdir
cp configs/example-config.yml /etc/wpdir/config.yml
# Edit /etc/wpdir/config.yml as needed
```

### 6. Run the Application

```bash
./wpdir
```

## Configuration Options

### Plugin/Theme Limits

The most important configuration for VPS deployment:

- **pluginlimit**: Number of most recently updated plugins to index (default: 5000)
- **themelimit**: Number of most recently updated themes to index (default: 1000)
- Set to **0** to index all available extensions (requires more resources)

### Worker Configuration

- **updateworkers**: Number of concurrent workers for downloading/indexing (default: 2)
  - Increase for faster indexing (uses more CPU/memory)
  - Decrease for lower resource usage
  
- **searchworkers**: Number of concurrent search workers (default: 4)
  - Increase for better search performance
  - Decrease for lower memory usage

### Resource Estimates

Based on configuration:

| Plugins | Themes | Storage | RAM | Initial Index Time |
|---------|--------|---------|-----|-------------------|
| 5,000   | 1,000  | ~30GB   | 4GB | ~2-4 hours        |
| 10,000  | 2,000  | ~60GB   | 6GB | ~4-8 hours        |
| All     | All    | ~200GB+ | 16GB+ | ~24+ hours      |

## Systemd Service (Production)

Create `/etc/systemd/system/wpdir.service`:

```ini
[Unit]
Description=WPDirectory Service
After=network.target

[Service]
Type=simple
User=wpdir
WorkingDirectory=/opt/wpdir
ExecStart=/opt/wpdir/wpdir
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
sudo systemctl status wpdir
```

## Nginx Reverse Proxy (Optional)

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:11001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Maintenance

### Update Extensions

The application automatically checks for updates every 2 hours. To force an update:

```bash
# Stop the service
sudo systemctl stop wpdir

# Start with fresh flag
./wpdir -fresh

# Or restart the service
sudo systemctl start wpdir
```

### Backup Data

```bash
# Backup database and indexes
tar -czf wpdir-backup-$(date +%Y%m%d).tar.gz /etc/wpdir/data
```

### Monitor Resources

```bash
# Check disk usage
du -sh /etc/wpdir/data

# Monitor memory
free -h

# Check logs
journalctl -u wpdir -f
```

## Troubleshooting

### High Memory Usage

- Reduce `searchworkers` in config
- Reduce `updateworkers` in config
- Decrease `pluginlimit` and `themelimit`

### Slow Indexing

- Increase `updateworkers` (if resources allow)
- Check network connectivity
- Verify disk I/O performance

### Application Won't Start

- Check configuration file syntax
- Verify port availability
- Check logs: `journalctl -u wpdir -n 100`
- Ensure data directory permissions

## Security Recommendations

1. **Change default admin credentials** in config.yml
2. **Use HTTPS** with Let's Encrypt or similar
3. **Configure firewall** to allow only necessary ports
4. **Regular updates** of system packages and dependencies
5. **Monitor logs** for suspicious activity

## Performance Tuning

### For Better Performance
- Use SSD storage
- Increase RAM allocation
- Use more worker threads
- Enable HTTP/2 in reverse proxy

### For Lower Resource Usage
- Reduce plugin/theme limits
- Decrease worker counts
- Use compression in reverse proxy
- Implement caching layer

## Support

For issues and questions:
- GitHub Issues: https://github.com/wpdirectory/wpdir/issues
- Original Project: https://wpdirectory.net/

## License

MIT License - See LICENSE file for details

