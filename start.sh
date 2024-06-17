#! /usr/bin/env sh
set -e

cd /project

if [ -f /project/core/wsgi.py ]; then
  DEFAULT_MODULE_NAME=core.wsgi
elif [ -f /project/wsgi.py ]; then
  DEFAULT_MODULE_NAME=wsgi
fi

MODULE_NAME=${MODULE_NAME:-$DEFAULT_MODULE_NAME}

export APP_MODULE=${APP_MODULE:-"$MODULE_NAME"}

IS_INIT=${IS_INIT:-0}

if [ "$IS_INIT" -eq 1 ]; then
  python manage.py migrate
fi

python manage.py collectstatic --noinput

caddy validate /etc/caddy/Caddyfile
caddy fmt /etc/caddy/Caddyfile --overwrite
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

# Start Gunicorn
gunicorn "$APP_MODULE" -w 4 --bind 0.0.0.0:8000
