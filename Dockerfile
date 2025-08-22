# syntax=docker/dockerfile:1.6

###############################################
# 1) Define PHP version + Composer stage
###############################################
ARG PHP_FPM_VER=82   # define variable (default 8.2 → alpine pkg format)

FROM composer:2 AS builder
WORKDIR /app

# copy composer.json and install only prod deps
COPY conf/composer.json ./
RUN composer install --no-dev --no-interaction --no-ansi --no-progress --prefer-dist --optimize-autoloader


###############################################
# 2) Final runtime — Alpine + PHP-FPM + Nginx
###############################################
FROM alpine:3.20 AS runtime

# redeclare ARG inside stage + export ENV
ARG PHP_FPM_VER=82
ENV PHP_FPM_VER=${PHP_FPM_VER}

# 1. Maintainer info
LABEL maintainer.name="myself" \
    maintainer.email="myself@gmail.com" \
    maintainer.version="1.0.0"

# 2. Install PHP-FPM, Nginx, DB extensions
RUN set -eux; \
    apk add --no-cache \
    bash ca-certificates curl nginx \
    php${PHP_FPM_VER} \
    php${PHP_FPM_VER}-fpm \
    php${PHP_FPM_VER}-pdo \
    php${PHP_FPM_VER}-pdo_mysql \
    php${PHP_FPM_VER}-mbstring \
    php${PHP_FPM_VER}-opcache; \
    ln -s /usr/bin/php${PHP_FPM_VER} /usr/bin/php; \
    ln -s /usr/sbin/php-fpm${PHP_FPM_VER} /usr/sbin/php-fpm; \
    mkdir -p /run/nginx /var/log/nginx /var/www/html; \
    chown -R root:root /var/www

# 3. Copy configs + app
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY src/ /var/www/html/
COPY --from=builder /app/vendor /var/www/vendor

# 4. Healthcheck
HEALTHCHECK --start-period=10s --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/index.php || exit 1

# 5. Expose + volume + working dir
EXPOSE 80
VOLUME ["/var/www/html"]
WORKDIR /var/www/html

# 6. Entrypoint — start php-fpm + nginx (foreground)
RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'php-fpm -D' \
    'exec nginx -g "daemon off;"' \
    > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
