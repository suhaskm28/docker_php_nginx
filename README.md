# Nginx + PHP-FPM Docker Setup

## Overview

Dockerized PHP web application using:

* Nginx (web server)
* PHP-FPM (default 8.2)
* Composer (dependency management)
* Alpine Linux (lightweight runtime)

Includes multi-stage build, production dependency installation, dynamic code updates, and health checks.

---

## PHP Version

```
ARG PHP_FPM_VER=82
```

* Default: PHP 8.2 (Alpine format)
* Can be overridden during build.

---

## Build & Run

### Build Image

```
docker build -t a1:<tag> .
```

### Run Container

```
docker run -d \
  --name cca1_nginx_php \
  -p 80:80 \
  -v $(pwd)/src:/var/www/html \
  a1:<tag>
```

---

## Health Check

* Command: `curl -f http://localhost/index.php || exit 1`
* Start period: 10s
* Interval: 30s
* Timeout: 10s
* Retries: 3

---

## Exposed & Volume

* Port: **80**
* Volume: `/var/www/html`
* Working Directory: `/var/www/html`

---

## Test

Open:

```
http://public_ip/index.php
```

If successful, the PHP page loads and Composer dependencies work correctly.

---
