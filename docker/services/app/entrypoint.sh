#!/usr/bin/env sh
set -eu

# PHP-FPM must write bind-mounted Laravel directories as the host user. The
# values are supplied by local.sh, with safe defaults for direct Compose use.
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

if ! getent group "$PGID" >/dev/null; then
    groupadd --gid "$PGID" laravel
fi

if ! getent passwd "$PUID" >/dev/null; then
    useradd --uid "$PUID" --gid "$PGID" --no-create-home --shell /usr/sbin/nologin laravel
fi

PHP_FPM_GROUP="$(getent group "$PGID" | cut -d: -f1)"
PHP_FPM_USER="$(getent passwd "$PUID" | cut -d: -f1)"

sed -i \
    -e "s/^user = .*/user = ${PHP_FPM_USER}/" \
    -e "s/^group = .*/group = ${PHP_FPM_GROUP}/" \
    /usr/local/etc/php-fpm.d/www.conf

mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R "${PUID}:${PGID}" storage bootstrap/cache

exec "$@"
